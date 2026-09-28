import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/lesson_progress.dart';
import '../data/repositories/progress_repository.dart';
import '../domain/services/progress_service.dart';
import 'core_providers.dart';

// ---------------------------------------------------------------------------
// Progress Repository Provider
// ---------------------------------------------------------------------------
final progressRepositoryProvider = Provider<IProgressRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProgressRepository(prefs);
});

final progressServiceProvider = Provider<ProgressService>((ref) {
  return const ProgressService();
});

// ---------------------------------------------------------------------------
// Last Played Lesson ID Provider (reads synchronously from SharedPreferences)
// ---------------------------------------------------------------------------
final lastPlayedLessonIdProvider = Provider<String?>((ref) {
  final repository = ref.watch(progressRepositoryProvider);
  return repository.getLastPlayedLessonIdSync();
});

// ---------------------------------------------------------------------------
// Progress Map Notifier (modern Riverpod Notifier API)
// ---------------------------------------------------------------------------
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

    // Use copyWith if we have an existing record, otherwise create fresh
    final updated = existing != null
        ? existing.copyWith(
            lastPositionSec: currentPositionSec,
            isCompleted: isCompleted,
            playbackSpeed: playbackSpeed,
            lastUpdated: DateTime.now(),
          )
        : LessonProgress(
            lessonId: lessonId,
            lastPositionSec: currentPositionSec,
            isCompleted: isCompleted,
            playbackSpeed: playbackSpeed,
            lastUpdated: DateTime.now(),
          );

    // Update memory state FIRST so UI updates immediately
    state = {...state, lessonId: updated};

    // Persist to SharedPreferences
    await repository.saveLessonProgress(updated);
    await repository.saveLastPlayedLessonId(lessonId);
  }
}

final progressMapProvider =
    NotifierProvider<ProgressNotifier, Map<String, LessonProgress>>(
  ProgressNotifier.new,
);
