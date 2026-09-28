import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/course.dart';
import '../data/models/lesson.dart';
import '../data/repositories/courses_repository.dart';
import 'progress_providers.dart';

// ---------------------------------------------------------------------------
// Courses Repository Provider
// ---------------------------------------------------------------------------
final coursesRepositoryProvider = Provider<CoursesRepository>((ref) {
  return CoursesRepository();
});

// ---------------------------------------------------------------------------
// Courses Data Provider
// ---------------------------------------------------------------------------
final coursesProvider = FutureProvider<List<Course>>((ref) async {
  final repository = ref.watch(coursesRepositoryProvider);
  return repository.getCourses();
});

// ---------------------------------------------------------------------------
// Continue Watching Provider (FR-05)
// ---------------------------------------------------------------------------
final continueWatchingProvider =
    Provider<({Course course, Lesson lesson})?>((ref) {
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
