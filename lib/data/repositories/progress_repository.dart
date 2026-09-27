import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lesson_progress.dart';

abstract class IProgressRepository {
  Map<String, LessonProgress> loadAllProgressSync();
  Future<Map<String, LessonProgress>> loadAllProgress();
  Future<void> saveLessonProgress(LessonProgress progress);
  String? getLastPlayedLessonIdSync();
  Future<String?> getLastPlayedLessonId();
  Future<void> saveLastPlayedLessonId(String lessonId);
  Future<void> clearAll();
}

class ProgressRepository implements IProgressRepository {
  static const String _progressKey = 'video_player_lesson_progress';
  static const String _lastPlayedKey = 'video_player_last_played_lesson_id';

  final SharedPreferences _prefs;

  ProgressRepository(this._prefs);

  @override
  Map<String, LessonProgress> loadAllProgressSync() {
    try {
      final jsonString = _prefs.getString(_progressKey);
      if (jsonString == null || jsonString.trim().isEmpty) {
        return {};
      }
      final decoded = json.decode(jsonString);
      if (decoded is! Map) {
        return {};
      }
      final map = <String, LessonProgress>{};
      decoded.forEach((key, value) {
        if (value is Map) {
          try {
            final mapValue = Map<String, dynamic>.from(value);
            final prog = LessonProgress.fromJson(mapValue);
            if (prog.lessonId.isNotEmpty) {
              map[prog.lessonId] = prog;
            }
          } catch (e) {
            // Log individual item decode errors without throwing away entire map
          }
        }
      });
      return map;
    } catch (e) {
      return {};
    }
  }

  @override
  Future<Map<String, LessonProgress>> loadAllProgress() async {
    return loadAllProgressSync();
  }

  @override
  Future<void> saveLessonProgress(LessonProgress progress) async {
    try {
      final currentMap = loadAllProgressSync();
      currentMap[progress.lessonId] = progress;

      final mapToSerialize = <String, dynamic>{};
      currentMap.forEach((key, value) {
        mapToSerialize[key] = value.toJson();
      });

      await _prefs.setString(_progressKey, json.encode(mapToSerialize));
    } catch (e) {
      // Storage errors logged cleanly, avoiding crash (FR-24)
    }
  }

  @override
  String? getLastPlayedLessonIdSync() {
    try {
      return _prefs.getString(_lastPlayedKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getLastPlayedLessonId() async {
    return getLastPlayedLessonIdSync();
  }

  @override
  Future<void> saveLastPlayedLessonId(String lessonId) async {
    try {
      await _prefs.setString(_lastPlayedKey, lessonId);
    } catch (e) {
      // Ignore storage errors safely
    }
  }

  @override
  Future<void> clearAll() async {
    await _prefs.remove(_progressKey);
    await _prefs.remove(_lastPlayedKey);
  }
}
