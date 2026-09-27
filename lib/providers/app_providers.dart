import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/course.dart';
import '../data/models/lesson.dart';
import '../data/models/lesson_progress.dart';
import '../data/repositories/courses_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../domain/services/progress_service.dart';

// Base SharedPreferences Provider (must be overridden at root)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});

// Repositories & Services
final progressRepositoryProvider = Provider<IProgressRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProgressRepository(prefs);
});

final coursesRepositoryProvider = Provider<CoursesRepository>((ref) {
  return CoursesRepository();
});

final progressServiceProvider = Provider<ProgressService>((ref) {
  return const ProgressService();
});

// Courses Data Provider
final coursesProvider = FutureProvider<List<Course>>((ref) async {
  final repository = ref.watch(coursesRepositoryProvider);
  return repository.getCourses();
});

// Progress Map Notifier using modern Riverpod Notifier API
class ProgressNotifier extends Notifier<Map<String, LessonProgress>> {
  @override
  Map<String, LessonProgress> build() {
    final repository = ref.watch(progressRepositoryProvider);
    return repository.loadAllProgressSync();
  }

  Future<void> saveProgress({
    required String lessonId,
    required int currentPositionSec,
    required int durationSec,
    double playbackSpeed = 1.0,
  }) async {
    final repository = ref.read(progressRepositoryProvider);
    final progressService = ref.read(progressServiceProvider);

    final existing = state[lessonId];

    // Calculate completion with 90% rule (FR-15)
    final newlyCompleted = progressService.isCompleted(
      currentPositionSec: currentPositionSec,
      durationSec: durationSec,
    );

    final isCompleted = (existing?.isCompleted ?? false) || newlyCompleted;

    final updated = LessonProgress(
      lessonId: lessonId,
      lastPositionSec: currentPositionSec,
      isCompleted: isCompleted,
      playbackSpeed: playbackSpeed,
      lastUpdated: DateTime.now(),
    );

    // Update memory state FIRST so UI updates immediately
    state = {
      ...state,
      lessonId: updated,
    };

    // Save to SharedPreferences (persistent storage)
    await repository.saveLessonProgress(updated);
    await repository.saveLastPlayedLessonId(lessonId);
  }
}

final progressMapProvider =
    NotifierProvider<ProgressNotifier, Map<String, LessonProgress>>(ProgressNotifier.new);

// Last Played Lesson ID Provider (reads synchronously from SharedPreferences)
final lastPlayedLessonIdProvider = Provider<String?>((ref) {
  final repository = ref.watch(progressRepositoryProvider);
  return repository.getLastPlayedLessonIdSync();
});

// Continue Watching Provider (FR-05)
final continueWatchingProvider = Provider<({Course course, Lesson lesson})?>((ref) {
  final coursesAsync = ref.watch(coursesProvider);
  final progressMap = ref.watch(progressMapProvider);
  final lastPlayedId = ref.watch(lastPlayedLessonIdProvider);
  final progressService = ref.watch(progressServiceProvider);

  return coursesAsync.when(
    data: (courses) {
      return progressService.getContinueWatchingLesson(
        courses: courses,
        progressMap: progressMap,
        lastPlayedLessonId: lastPlayedId,
      );
    },
    loading: () => null,
    error: (err, stackTrace) => null,
  );
});

// Locale Provider (Supports ar, en, hi, zh)
class LocaleNotifier extends Notifier<Locale> {
  static const String _key = 'video_player_app_locale';

  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final code = prefs.getString(_key) ?? 'en';
    return Locale(code);
  }

  Future<void> setLocale(Locale newLocale) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, newLocale.languageCode);
    state = newLocale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

// Theme Mode Provider (Supports light, dark, system)
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String _key = 'video_player_app_theme_mode';

  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(_key);
    if (saved == 'dark') return ThemeMode.dark;
    if (saved == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    String strVal = 'system';
    if (mode == ThemeMode.dark) strVal = 'dark';
    if (mode == ThemeMode.light) strVal = 'light';
    await prefs.setString(_key, strVal);
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

// Favorites Notifier (Course Bookmarks)
class FavoritesNotifier extends Notifier<Set<String>> {
  static const String _key = 'video_player_app_favorites';

  @override
  Set<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final list = prefs.getStringList(_key) ?? [];
    return list.toSet();
  }

  Future<void> toggleFavorite(String courseId) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final current = Set<String>.from(state);
    if (current.contains(courseId)) {
      current.remove(courseId);
    } else {
      current.add(courseId);
    }
    await prefs.setStringList(_key, current.toList());
    state = current;
  }

  bool isFavorite(String courseId) => state.contains(courseId);
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

// Per-Lesson Notes Notifier
class LessonNotesNotifier extends Notifier<Map<String, String>> {
  static const String _key = 'video_player_lesson_notes';

  @override
  Map<String, String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null || jsonStr.trim().isEmpty) return {};
    try {
      final decoded = json.decode(jsonStr);
      if (decoded is Map) {
        return Map<String, String>.from(decoded);
      }
    } catch (_) {}
    return {};
  }

  Future<void> saveNote(String lessonId, String noteText) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final updated = Map<String, String>.from(state);
    if (noteText.trim().isEmpty) {
      updated.remove(lessonId);
    } else {
      updated[lessonId] = noteText;
    }
    await prefs.setString(_key, json.encode(updated));
    state = updated;
  }

  String getNote(String lessonId) => state[lessonId] ?? '';
}

final lessonNotesProvider =
    NotifierProvider<LessonNotesNotifier, Map<String, String>>(LessonNotesNotifier.new);

// Remember Last Playback Speed Notifier
class PlaybackSpeedNotifier extends Notifier<double> {
  static const String _key = 'video_player_last_playback_speed';

  @override
  double build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getDouble(_key) ?? 1.0;
  }

  Future<void> setSpeed(double speed) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setDouble(_key, speed);
    state = speed;
  }
}

final defaultPlaybackSpeedProvider =
    NotifierProvider<PlaybackSpeedNotifier, double>(PlaybackSpeedNotifier.new);
