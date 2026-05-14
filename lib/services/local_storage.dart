import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const _kOnboardingDone = 'onboarding_done';
const _kAnswers = 'questionnaire_answers_v1';
const _kMorningRoutine = 'routine_morning_v1';
const _kNightRoutine = 'routine_night_v1';
const _kDailyTasksPrefix = 'daily_tasks_';
const _kProgressPhotos = 'progress_photos_v1';
const _kPhotoAnalysisHistory = 'photo_analysis_history_v1';
const _kDarkModeEnabled = 'dark_mode_enabled_v1';
const _kAiGeneratedContent = 'ai_generated_content_v1';
const _kPremiumActive = 'premium_active_v1';
const _kActivePremiumProductId = 'active_premium_product_id_v1';
const _kUploadTimestamps = 'upload_timestamps_v1';

class LocalStorage {
  LocalStorage(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalStorage> open() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }

  bool get onboardingComplete => _prefs.getBool(_kOnboardingDone) ?? false;

  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(_kOnboardingDone, value);

  Map<String, dynamic> get answers {
    final raw = _prefs.getString(_kAnswers);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw);
    if (decoded is Map) {
      return Map<String, dynamic>.from(
        decoded.map((k, v) => MapEntry(k.toString(), v)),
      );
    }
    return {};
  }

  Future<void> saveAnswers(Map<String, dynamic> map) =>
      _prefs.setString(_kAnswers, jsonEncode(map));

  Set<String> getRoutineChecked(String period) {
    final key = period == 'night' ? _kNightRoutine : _kMorningRoutine;
    final list = _prefs.getStringList(key) ?? [];
    return list.toSet();
  }

  Future<void> saveRoutineChecked(String period, Set<String> ids) {
    final key = period == 'night' ? _kNightRoutine : _kMorningRoutine;
    return _prefs.setStringList(key, ids.toList());
  }

  Map<String, bool> dailyTasksFor(DateTime day) {
    final key = _dailyKey(day);
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return {};
    return decoded.map((k, v) => MapEntry(k.toString(), v == true));
  }

  Future<void> saveDailyTasks(DateTime day, Map<String, bool> tasks) {
    final key = _dailyKey(day);
    return _prefs.setString(key, jsonEncode(tasks));
  }

  List<String> get progressPhotos =>
      List<String>.from(_prefs.getStringList(_kProgressPhotos) ?? const []);

  Future<void> saveProgressPhotos(List<String> paths) =>
      _prefs.setStringList(_kProgressPhotos, paths);

  List<Map<String, dynamic>> get photoAnalysisHistory {
    final raw = _prefs.getString(_kPhotoAnalysisHistory);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> savePhotoAnalysisHistory(List<Map<String, dynamic>> items) =>
      _prefs.setString(_kPhotoAnalysisHistory, jsonEncode(items));

  bool get darkModeEnabled => _prefs.getBool(_kDarkModeEnabled) ?? false;

  Future<void> setDarkModeEnabled(bool value) =>
      _prefs.setBool(_kDarkModeEnabled, value);

  Map<String, dynamic> get aiGeneratedContent {
    final raw = _prefs.getString(_kAiGeneratedContent);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return {};
    return Map<String, dynamic>.from(
      decoded.map((k, v) => MapEntry(k.toString(), v)),
    );
  }

  Future<void> saveAiGeneratedContent(Map<String, dynamic> content) =>
      _prefs.setString(_kAiGeneratedContent, jsonEncode(content));

  bool get premiumActive => _prefs.getBool(_kPremiumActive) ?? false;

  Future<void> setPremiumActive(bool value) =>
      _prefs.setBool(_kPremiumActive, value);

  String get activePremiumProductId =>
      _prefs.getString(_kActivePremiumProductId) ?? '';

  Future<void> setActivePremiumProductId(String productId) =>
      _prefs.setString(_kActivePremiumProductId, productId);

  List<int> get uploadTimestamps {
    final raw = _prefs.getStringList(_kUploadTimestamps) ?? const [];
    return raw
        .map((e) => int.tryParse(e))
        .whereType<int>()
        .toList(growable: false);
  }

  Future<void> saveUploadTimestamps(List<int> timestamps) => _prefs.setStringList(
    _kUploadTimestamps,
    timestamps.map((e) => e.toString()).toList(),
  );

  String _dailyKey(DateTime d) =>
      '$_kDailyTasksPrefix${d.year}-${d.month}-${d.day}';
}
