// Route argument payloads shared between pages.
import 'models/types.dart';

class LiveArgs {
  final LiveConfig config;
  final int? resumeElapsedMs;

  /// When true and there is no resume point, the session starts immediately
  /// instead of waiting on the idle "ready" screen (removes the double START).
  final bool autostart;
  LiveArgs(this.config, {this.resumeElapsedMs, this.autostart = false});
}

class CompleteArgs {
  final LiveConfig config;
  final SessionSummary summary;

  /// Id of the record already written by auto-save, or null when auto-save
  /// failed and the completion screen must fall back to a manual save.
  final String? sessionId;
  CompleteArgs(this.config, this.summary, {this.sessionId});
}
