// Persistence ported from src/data/storage.ts (shared_preferences JSON blobs).
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/types.dart';
import '../models/seed.dart';

const dataKey = 'combat-training:data:v2';
const activeKey = 'combat-training:active:v2';
const storageVersion = 4;

Future<AppData> loadData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    // Discard pre-blocks-model blobs outright (ADR 0002: no migration).
    await prefs.remove('combat-training:data:v1');
    await prefs.remove('combat-training:active:v1');
    final raw = prefs.getString(dataKey);
    if (raw == null) return seedData();
    final parsed = jsonDecode(raw);
    if (parsed is! Map<String, dynamic>) return seedData();
    final appData = AppData.fromJson(parsed);
    if (appData.techniques.isEmpty && parsed['techniques'] is! List) return seedData();
    if (appData.version < 1 || appData.version > storageVersion) return seedData();
    return appData;
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
    if (parsed is! Map<String, dynamic> || parsed['config'] == null) return null;
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
  final stored = prefs.getString('combat-training:lang');
  if (stored != null) return LangX.parse(stored);
  return LangX.parse(PlatformDispatcher.instance.locale.languageCode);
}

Future<void> saveLang(Lang lang) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('combat-training:lang', lang.code);
}

const _lastTimerKey = 'combat-training:last-timer:v1';

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
