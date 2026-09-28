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

      // Boundary: exact 90%
      expect(
        progressService.isCompleted(currentPositionSec: 45, durationSec: 50),
        isTrue,
      );

      // 100% position is completed
      expect(
        progressService.isCompleted(currentPositionSec: 100, durationSec: 100),
        isTrue,
      );

      // Edge case: zero duration
      expect(
        progressService.isCompleted(currentPositionSec: 10, durationSec: 0),
        isFalse,
      );

      // Edge case: negative duration
      expect(
        progressService.isCompleted(currentPositionSec: 10, durationSec: -5),
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
        lessonId: 'lesson_0',
        isCompleted: true,
        lastUpdated: DateTime.now(),
      );
      progressMap['lesson_1'] = LessonProgress(
        lessonId: 'lesson_1',
        isCompleted: true,
        lastUpdated: DateTime.now(),
      );
      progressMap['lesson_2'] = LessonProgress(
        lessonId: 'lesson_2',
        isCompleted: true,
        lastUpdated: DateTime.now(),
      );

      // Should equal 50.0%
      expect(
        progressService.calculateCourseProgress(
          course: course,
          progressMap: progressMap,
        ),
        equals(50.0),
      );

      // Complete remaining 3 lessons
      for (int i = 3; i < 6; i++) {
        progressMap['lesson_$i'] = LessonProgress(
          lessonId: 'lesson_$i',
          isCompleted: true,
          lastUpdated: DateTime.now(),
        );
      }

      // Should equal 100.0%
      expect(
        progressService.calculateCourseProgress(
          course: course,
          progressMap: progressMap,
        ),
        equals(100.0),
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

    test('FR-05: getContinueWatchingLesson returns last played unfinished lesson', () {
      const lesson1 = Lesson(id: 'l1', title: 'L1', durationSec: 100, video: 'v1.mp4');
      const lesson2 = Lesson(id: 'l2', title: 'L2', durationSec: 100, video: 'v2.mp4');
      const course = Course(
        id: 'c1',
        title: 'Course 1',
        instructor: 'Teacher',
        thumbnail: 'thumb.png',
        description: 'Desc',
        sections: [
          Section(id: 's1', title: 'Section 1', lessons: [lesson1, lesson2]),
        ],
      );

      final progressMap = <String, LessonProgress>{
        'l1': LessonProgress(
          lessonId: 'l1',
          lastPositionSec: 100,
          isCompleted: true,
          lastUpdated: DateTime.now(),
        ),
        'l2': LessonProgress(
          lessonId: 'l2',
          lastPositionSec: 30,
          isCompleted: false,
          lastUpdated: DateTime.now(),
        ),
      };

      final result = progressService.getContinueWatchingLesson(
        courses: [course],
        progressMap: progressMap,
        lastPlayedLessonId: 'l2',
      );

      expect(result, isNotNull);
      expect(result!.course.id, equals('c1'));
      expect(result.lesson.id, equals('l2'));
    });

    test('FR-05: getContinueWatchingLesson falls back to first unlocked unfinished lesson', () {
      const lesson1 = Lesson(id: 'l1', title: 'L1', durationSec: 100, video: 'v1.mp4');
      const lesson2 = Lesson(id: 'l2', title: 'L2', durationSec: 100, video: 'v2.mp4');
      const course = Course(
        id: 'c1',
        title: 'Course 1',
        instructor: 'Teacher',
        thumbnail: 'thumb.png',
        description: 'Desc',
        sections: [
          Section(id: 's1', title: 'Section 1', lessons: [lesson1, lesson2]),
        ],
      );

      final result = progressService.getContinueWatchingLesson(
        courses: [course],
        progressMap: {},
        lastPlayedLessonId: null,
      );

      expect(result, isNotNull);
      expect(result!.course.id, equals('c1'));
      expect(result.lesson.id, equals('l1'));
    });

    test('FR-17: getNextUnlockedLesson returns next lesson when unlocked', () {
      const lesson1 = Lesson(id: 'l1', title: 'L1', durationSec: 100, video: 'v1.mp4');
      const lesson2 = Lesson(id: 'l2', title: 'L2', durationSec: 100, video: 'v2.mp4');
      const course = Course(
        id: 'c1',
        title: 'Course 1',
        instructor: 'Teacher',
        thumbnail: 'thumb.png',
        description: 'Desc',
        sections: [
          Section(id: 's1', title: 'Section 1', lessons: [lesson1, lesson2]),
        ],
      );

      final progressMap = <String, LessonProgress>{
        'l1': LessonProgress(
          lessonId: 'l1',
          lastPositionSec: 100,
          isCompleted: true,
          lastUpdated: DateTime.now(),
        ),
      };

      final next = progressService.getNextUnlockedLesson(
        currentLesson: lesson1,
        course: course,
        progressMap: progressMap,
      );

      expect(next, isNotNull);
      expect(next!.id, equals('l2'));
    });

    test('FR-17: getNextUnlockedLesson returns null on last lesson', () {
      const lesson1 = Lesson(id: 'l1', title: 'L1', durationSec: 100, video: 'v1.mp4');
      const course = Course(
        id: 'c1',
        title: 'Course 1',
        instructor: 'Teacher',
        thumbnail: 'thumb.png',
        description: 'Desc',
        sections: [
          Section(id: 's1', title: 'Section 1', lessons: [lesson1]),
        ],
      );

      final next = progressService.getNextUnlockedLesson(
        currentLesson: lesson1,
        course: course,
        progressMap: {},
      );

      expect(next, isNull);
    });
  });

  group('LessonProgress Model Tests', () {
    test('LessonProgress toJson and fromJson serialization round-trip', () {
      final now = DateTime.now();
      final original = LessonProgress(
        lessonId: 'lesson_test_101',
        lastPositionSec: 42,
        isCompleted: true,
        playbackSpeed: 1.5,
        lastUpdated: now,
      );

      final jsonMap = original.toJson();
      final deserialized = LessonProgress.fromJson(jsonMap);

      expect(deserialized.lessonId, equals(original.lessonId));
      expect(deserialized.lastPositionSec, equals(original.lastPositionSec));
      expect(deserialized.isCompleted, equals(original.isCompleted));
      expect(deserialized.playbackSpeed, equals(original.playbackSpeed));
      expect(
        deserialized.lastUpdated.millisecondsSinceEpoch,
        equals(original.lastUpdated.millisecondsSinceEpoch),
      );
    });

    test('LessonProgress copyWith updates only specified fields', () {
      final original = LessonProgress(
        lessonId: 'l1',
        lastPositionSec: 10,
        isCompleted: false,
        playbackSpeed: 1.0,
        lastUpdated: DateTime(2026, 1, 1),
      );

      final updated = original.copyWith(
        lastPositionSec: 50,
        isCompleted: true,
      );

      expect(updated.lessonId, equals('l1'));
      expect(updated.lastPositionSec, equals(50));
      expect(updated.isCompleted, isTrue);
      expect(updated.playbackSpeed, equals(1.0));
      expect(updated.lastUpdated, equals(DateTime(2026, 1, 1)));
    });
  });
}
