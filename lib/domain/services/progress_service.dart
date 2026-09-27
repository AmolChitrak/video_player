import '../../data/models/course.dart';
import '../../data/models/lesson.dart';
import '../../data/models/lesson_progress.dart';

class ProgressService {
  const ProgressService();

  /// FR-15: A lesson is marked completed when current position divided by duration >= 0.9 (90%).
  bool isCompleted({required int currentPositionSec, required int durationSec}) {
    if (durationSec <= 0) return false;
    return (currentPositionSec / durationSec) >= 0.9;
  }

  /// FR-08: The first lesson shall be unlocked. Every subsequent lesson shall remain locked
  /// until the immediately preceding lesson is completed.
  bool isLessonUnlocked({
    required Lesson lesson,
    required List<Lesson> courseLessonsInOrder,
    required Map<String, LessonProgress> progressMap,
  }) {
    if (courseLessonsInOrder.isEmpty) return false;

    final index = courseLessonsInOrder.indexWhere((l) => l.id == lesson.id);
    if (index == -1) return false;

    // First lesson in course is always unlocked
    if (index == 0) return true;

    // Previous lesson must be completed
    final prevLesson = courseLessonsInOrder[index - 1];
    final prevProgress = progressMap[prevLesson.id];

    return prevProgress?.isCompleted ?? false;
  }

  /// FR-16: Course progress shall be calculated as completed lessons divided by total lessons multiplied by 100.
  double calculateCourseProgress({
    required Course course,
    required Map<String, LessonProgress> progressMap,
  }) {
    final allLessons = course.allLessons;
    if (allLessons.isEmpty) return 0.0;

    int completedCount = 0;
    for (final lesson in allLessons) {
      final prog = progressMap[lesson.id];
      if (prog?.isCompleted == true) {
        completedCount++;
      }
    }

    return (completedCount / allLessons.length) * 100.0;
  }

  /// FR-05: Returns the most recently watched unfinished lesson or first unlocked unfinished lesson.
  ({Course course, Lesson lesson})? getContinueWatchingLesson({
    required List<Course> courses,
    required Map<String, LessonProgress> progressMap,
    required String? lastPlayedLessonId,
  }) {
    // First, check if lastPlayedLessonId points to an unfinished & unlocked lesson
    if (lastPlayedLessonId != null && lastPlayedLessonId.isNotEmpty) {
      for (final course in courses) {
        final lessons = course.allLessons;
        final index = lessons.indexWhere((l) => l.id == lastPlayedLessonId);
        if (index != -1) {
          final targetLesson = lessons[index];
          final unlocked = isLessonUnlocked(
            lesson: targetLesson,
            courseLessonsInOrder: lessons,
            progressMap: progressMap,
          );
          final prog = progressMap[targetLesson.id];
          final completed = prog?.isCompleted ?? false;

          if (unlocked && !completed) {
            return (course: course, lesson: targetLesson);
          }
        }
      }
    }

    // Otherwise, search all courses for the first unlocked, unfinished lesson
    for (final course in courses) {
      final lessons = course.allLessons;
      for (final lesson in lessons) {
        final unlocked = isLessonUnlocked(
          lesson: lesson,
          courseLessonsInOrder: lessons,
          progressMap: progressMap,
        );
        final prog = progressMap[lesson.id];
        final completed = prog?.isCompleted ?? false;

        if (unlocked && !completed) {
          return (course: course, lesson: lesson);
        }
      }
    }

    return null;
  }

  /// Helper to get Next Unlocked Lesson (FR-17)
  Lesson? getNextUnlockedLesson({
    required Lesson currentLesson,
    required Course course,
    required Map<String, LessonProgress> progressMap,
  }) {
    final lessons = course.allLessons;
    final currentIndex = lessons.indexWhere((l) => l.id == currentLesson.id);
    if (currentIndex == -1 || currentIndex >= lessons.length - 1) {
      return null;
    }

    final nextLesson = lessons[currentIndex + 1];
    final unlocked = isLessonUnlocked(
      lesson: nextLesson,
      courseLessonsInOrder: lessons,
      progressMap: progressMap,
    );

    return unlocked ? nextLesson : null;
  }
}
