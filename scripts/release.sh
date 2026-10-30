#!/bin/bash
#
# Build the iOS app, bump the version, and upload it to App Store Connect.
#
# Usage:
#   scripts/release.sh [options]
#
# Options:
#   --major              bump the major version (1.3.0 -> 2.0.0)
#   --minor              bump the minor version (1.3.0 -> 1.4.0)
#   --patch              bump the patch version (1.3.0 -> 1.3.1)
#   --version X.Y.Z      set the marketing version explicitly
#   --build-number N     set the build number instead of auto-incrementing
#   --dry-run            bump + build + validate, but do not upload
#   --no-upload          bump + build only
#   --no-commit          do not commit the version bump
#   --clean              run `flutter clean` before building
#   -h, --help           show this help
#
# Credentials (read from fight_camp_app/.env):
#   ASC_API_KEY_ID       App Store Connect API key ID
#   ASC_API_ISSUER_ID    App Store Connect API issuer ID
#
# The .p8 key must live at ~/.appstoreconnect/private_keys/AuthKey_<KEY_ID>.p8

set -euo pipefail

APP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBSPEC="$APP_ROOT/pubspec.yaml"
ENV_FILE="$APP_ROOT/.env"
KEY_DIR="$HOME/.appstoreconnect/private_keys"

BUMP=""
EXPLICIT_VERSION=""
BUILD_NUMBER=""
DRY_RUN=0
NO_UPLOAD=0
NO_COMMIT=0
CLEAN=0

usage() {
  sed -n '3,25p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

while [ $# -gt 0 ]; do
  case "$1" in
    --major) BUMP="major" ;;
    --minor) BUMP="minor" ;;
    --patch) BUMP="patch" ;;
    --version) EXPLICIT_VERSION="${2:-}"; shift ;;
    --build-number) BUILD_NUMBER="${2:-}"; shift ;;
    --dry-run) DRY_RUN=1 ;;
    --no-upload) NO_UPLOAD=1 ;;
    --no-commit) NO_COMMIT=1 ;;
    --clean) CLEAN=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
  shift
done

log() { printf '==> %s\n' "$1"; }
die() { printf 'error: %s\n' "$1" >&2; exit 1; }

[ -f "$PUBSPEC" ] || die "pubspec.yaml not found at $PUBSPEC"

if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  set +a
fi

: "${ASC_API_KEY_ID:?set ASC_API_KEY_ID in $ENV_FILE}"
: "${ASC_API_ISSUER_ID:?set ASC_API_ISSUER_ID in $ENV_FILE}"

KEY_FILE="$KEY_DIR/AuthKey_${ASC_API_KEY_ID}.p8"
[ -f "$KEY_FILE" ] || die "API key not found at $KEY_FILE"

# --- read current version -----------------------------------------------------

CUR_VERSION="$(sed -nE 's/^version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' "$PUBSPEC" | head -1)"
CUR_BUILD="$(sed -nE 's/^version:[[:space:]]*[0-9]+\.[0-9]+\.[0-9]+\+([0-9]+).*/\1/p' "$PUBSPEC" | head -1)"
[ -n "$CUR_VERSION" ] || die "could not parse version from $PUBSPEC"
CUR_BUILD="${CUR_BUILD:-0}"

IFS=. read -r MAJ MIN PAT <<< "$CUR_VERSION"
PAT="${PAT:-0}"

# --- compute new version ------------------------------------------------------

if [ -n "$EXPLICIT_VERSION" ]; then
  [[ "$EXPLICIT_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "--version must be X.Y.Z"
  IFS=. read -r MAJ MIN PAT <<< "$EXPLICIT_VERSION"
fi

case "$BUMP" in
  major) MAJ=$((MAJ + 1)); MIN=0; PAT=0 ;;
  minor) MIN=$((MIN + 1)); PAT=0 ;;
  patch) PAT=$((PAT + 1)) ;;
  "") ;;
  *) die "unknown bump: $BUMP" ;;
esac

if [ -n "$BUILD_NUMBER" ]; then
  [[ "$BUILD_NUMBER" =~ ^[0-9]+$ ]] || die "--build-number must be an integer"
  NEW_BUILD="$BUILD_NUMBER"
else
  NEW_BUILD=$((CUR_BUILD + 1))
fi

NEW_VERSION="$MAJ.$MIN.$PAT+$NEW_BUILD"

log "version: $CUR_VERSION+$CUR_BUILD -> $NEW_VERSION"

# --- write pubspec ------------------------------------------------------------

TMP="$(mktemp)"
sed -E "s/^version:.*/version: $NEW_VERSION/" "$PUBSPEC" > "$TMP"
mv "$TMP" "$PUBSPEC"

# --- commit -------------------------------------------------------------------

if [ "$NO_COMMIT" -eq 1 ]; then
  log "skipping commit (--no-commit)"
else
  git -C "$APP_ROOT" add pubspec.yaml
  if git -C "$APP_ROOT" diff --cached --quiet; then
    log "no version change to commit"
  else
    git -C "$APP_ROOT" commit -m "chore: bump version to $NEW_VERSION"
    log "committed version bump"
  fi
fi

# --- build --------------------------------------------------------------------

if [ "$CLEAN" -eq 1 ]; then
  log "flutter clean"
  (cd "$APP_ROOT" && flutter clean)
fi

log "flutter pub get"
(cd "$APP_ROOT" && flutter pub get)

log "flutter build ipa --release"
# Remove any previous IPA first: `flutter build ipa` can exit 0 even when the
# export/signing step fails, and the script would then validate a stale build.
rm -f "$APP_ROOT"/build/ios/ipa/*.ipa
if ! (cd "$APP_ROOT" && flutter build ipa --release); then
  die "flutter build ipa failed"
fi

IPA="$(ls -t "$APP_ROOT"/build/ios/ipa/*.ipa 2>/dev/null | head -1 || true)"
[ -n "$IPA" ] || die "no .ipa found in build/ios/ipa (build or signing failed)"
log "ipa: $IPA"

# --- validate / upload --------------------------------------------------------

AUTH=(--apiKey "$ASC_API_KEY_ID" --apiIssuer "$ASC_API_ISSUER_ID")

# altool can exit 0 while reporting a failure in its output, so treat both a
# non-zero status and the error markers as fatal.
run_altool() {
  local label="$1"
  shift
  local out status=0
  out="$(xcrun altool "$@" 2>&1)" || status=$?
  printf '%s\n' "$out"
  if [ "$status" -ne 0 ] || printf '%s' "$out" | grep -qE 'FAILED|ERROR:'; then
    die "$label failed"
  fi
}

log "validating with App Store Connect"
run_altool "validation" --validate-app -f "$IPA" -t ios "${AUTH[@]}"

if [ "$DRY_RUN" -eq 1 ] || [ "$NO_UPLOAD" -eq 1 ]; then
  log "skipping upload (--dry-run/--no-upload)"
  log "done: $NEW_VERSION built and validated"
  exit 0
fi

log "uploading to App Store Connect"
run_altool "upload" --upload-app -f "$IPA" -t ios "${AUTH[@]}"

log "done: $NEW_VERSION uploaded"
