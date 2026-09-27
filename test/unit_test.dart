import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_app/data/models/course.dart';
import 'package:video_player_app/data/models/lesson.dart';
import 'package:video_player_app/data/models/section.dart';
import 'package:video_player_app/data/models/lesson_progress.dart';
import 'package:video_player_app/domain/services/progress_service.dart';

void main() {
  late ProgressService progressService;

  setUp(() {
    progressService = const ProgressService();
  });

  group('ProgressService Unit Tests', () {
    test('FR-15 / Mandatory Test 1: 90% Completion Rule', () {
      // 90/100 seconds is completed
      expect(
        progressService.isCompleted(currentPositionSec: 90, durationSec: 100),
        isTrue,
      );

      // 89/100 seconds is NOT completed
      expect(
        progressService.isCompleted(currentPositionSec: 89, durationSec: 100),
        isFalse,
      );

      // Edge case: zero duration
      expect(
        progressService.isCompleted(currentPositionSec: 10, durationSec: 0),
        isFalse,
      );
    });

    test('FR-08 / Mandatory Test 2: Sequential Unlock Rule', () {
      const lesson1 = Lesson(
        id: 'l1',
        title: 'Lesson 1',
        durationSec: 60,
        video: 'assets/videos/l1.mp4',
      );
      const lesson2 = Lesson(
        id: 'l2',
        title: 'Lesson 2',
        durationSec: 90,
        video: 'assets/videos/l2.mp4',
      );
      const lesson3 = Lesson(
        id: 'l3',
        title: 'Lesson 3',
        durationSec: 120,
        video: 'assets/videos/l3.mp4',
      );

      final lessons = [lesson1, lesson2, lesson3];
      final progressMap = <String, LessonProgress>{};

      // Lesson 1 is always unlocked initially
      expect(
        progressService.isLessonUnlocked(
          lesson: lesson1,
          courseLessonsInOrder: lessons,
          progressMap: progressMap,
        ),
        isTrue,
      );

      // Lesson 2 is locked initially when Lesson 1 is not completed
      expect(
        progressService.isLessonUnlocked(
          lesson: lesson2,
          courseLessonsInOrder: lessons,
          progressMap: progressMap,
        ),
        isFalse,
      );

      // Complete Lesson 1
      progressMap['l1'] = LessonProgress(
        lessonId: 'l1',
        lastPositionSec: 60,
        isCompleted: true,
        lastUpdated: DateTime.now(),
      );

      // Now Lesson 2 becomes unlocked!
      expect(
        progressService.isLessonUnlocked(
          lesson: lesson2,
          courseLessonsInOrder: lessons,
          progressMap: progressMap,
        ),
        isTrue,
      );

      // Lesson 3 is still locked until Lesson 2 is completed
      expect(
        progressService.isLessonUnlocked(
          lesson: lesson3,
          courseLessonsInOrder: lessons,
          progressMap: progressMap,
        ),
        isFalse,
      );
    });

    test('FR-16 / Mandatory Test 3: Course Progress Calculation', () {
      final lessons = List.generate(
        6,
        (i) => Lesson(
          id: 'lesson_$i',
          title: 'Lesson $i',
          durationSec: 100,
          video: 'assets/videos/l.mp4',
        ),
      );

      final course = Course(
        id: 'c1',
        title: 'Test Course',
        instructor: 'Dr. Test',
        thumbnail: 'assets/images/thumb.png',
        description: 'Description',
        sections: [
          Section(
            id: 's1',
            title: 'Section 1',
            lessons: lessons.sublist(0, 3),
          ),
          Section(
            id: 's2',
            title: 'Section 2',
            lessons: lessons.sublist(3, 6),
          ),
        ],
      );

      final progressMap = <String, LessonProgress>{};

      // Initially 0% progress
      expect(
        progressService.calculateCourseProgress(
          course: course,
          progressMap: progressMap,
        ),
        equals(0.0),
      );

      // Complete 3 out of 6 lessons
      progressMap['lesson_0'] = LessonProgress(
          lessonId: 'lesson_0', isCompleted: true, lastUpdated: DateTime.now());
      progressMap['lesson_1'] = LessonProgress(
          lessonId: 'lesson_1', isCompleted: true, lastUpdated: DateTime.now());
      progressMap['lesson_2'] = LessonProgress(
          lessonId: 'lesson_2', isCompleted: true, lastUpdated: DateTime.now());

      // Should equal 50.0%
      expect(
        progressService.calculateCourseProgress(
          course: course,
          progressMap: progressMap,
        ),
        equals(50.0),
      );
    });

    test('Edge Case: Empty course progress calculation', () {
      const emptyCourse = Course(
        id: 'c_empty',
        title: 'Empty Course',
        instructor: 'Dr. None',
        thumbnail: 'assets/images/thumb.png',
        description: '',
        sections: [],
      );

      expect(
        progressService.calculateCourseProgress(
          course: emptyCourse,
          progressMap: {},
        ),
        equals(0.0),
      );
    });
  });
}
