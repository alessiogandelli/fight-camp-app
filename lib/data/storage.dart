// Persistence ported from src/data/storage.ts (shared_preferences JSON blobs).
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/types.dart';
import '../models/seed.dart';

const dataKey = 'fight-camp:data:v3';
const activeKey = 'fight-camp:active:v3';
const storageVersion = 6;

/// Seed workout ids that existed before v6 and are replaced by the new
/// seed list (riscaldamento / corda / circuito / sparring).
const _v5SeedWorkoutIds = ['workout-basics', 'workout-tabata', 'workout-sharp'];

/// v6: replace the old seed workouts with the new ones, keeping any
/// workout created by the user.
AppData _migrateToV6(AppData d) {
  if (d.version >= 6) return d;
  final now = DateTime.now().millisecondsSinceEpoch;
  final fresh = seedWorkouts
      .map(
        (w) => Workout(
          id: w.id,
          name: w.name,
          workDuration: w.workDuration,
          restDuration: w.restDuration,
          rounds: w.rounds,
          createdAt: now,
        ),
      )
      .toList();
  final kept = d.workouts
      .where(
        (w) =>
            !_v5SeedWorkoutIds.contains(w.id) &&
            !fresh.any((s) => s.id == w.id),
      )
      .toList();
  return AppData(
    version: 6,
    techniques: d.techniques,
    combinations: d.combinations,
    workouts: [...kept, ...fresh],
    sessions: d.sessions,
    plans: d.plans,
    settings: d.settings,
  );
}

Future<AppData> loadData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(dataKey);
    if (raw == null) return seedData();
    final parsed = jsonDecode(raw);
    if (parsed is! Map<String, dynamic>) return seedData();
    final appData = AppData.fromJson(parsed);
    if (appData.techniques.isEmpty && parsed['techniques'] is! List)
      return seedData();
    if (appData.version < 1 || appData.version > storageVersion)
      return seedData();
    final migrated = _migrateToV6(appData);
    if (migrated.version != appData.version) await saveData(migrated);
    return migrated;
  } catch (_) {
    return seedData();
  }
}

Future<void> saveData(AppData data) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(dataKey, jsonEncode(data.toJson()));
  } catch (_) {}
}

Future<ActiveSnapshot?> loadActive() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(activeKey);
    if (raw == null) return null;
    final parsed = jsonDecode(raw);
    if (parsed is! Map<String, dynamic> || parsed['config'] == null)
      return null;
    return ActiveSnapshot.fromJson(parsed);
  } catch (_) {
    return null;
  }
}

Future<void> saveActive(ActiveSnapshot snapshot) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(activeKey, jsonEncode(snapshot.toJson()));
  } catch (_) {}
}

Future<void> clearActive() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(activeKey);
  } catch (_) {}
}

/// Stored preference wins; otherwise detect the system language (fallback IT).
Future<Lang> loadLang() async {
  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getString('fight-camp:lang');
  if (stored != null) return LangX.parse(stored);
  return LangX.parse(PlatformDispatcher.instance.locale.languageCode);
}

Future<void> saveLang(Lang lang) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('fight-camp:lang', lang.code);
}

const _onboardingKey = 'fight-camp:onboarding-seen';

/// Whether the first-run onboarding has already been shown.
Future<bool> loadOnboardingSeen() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  } catch (_) {
    return false;
  }
}

Future<void> saveOnboardingSeen() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  } catch (_) {}
}

const _lastTimerKey = 'fight-camp:last-timer:v1';

Future<Map<String, dynamic>?> loadLastTimer() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastTimerKey);
    if (raw == null) return null;
    final parsed = jsonDecode(raw);
    return parsed is Map<String, dynamic> ? parsed : null;
  } catch (_) {
    return null;
  }
}

Future<void> saveLastTimer(Map<String, dynamic> json) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastTimerKey, jsonEncode(json));
  } catch (_) {}
}
