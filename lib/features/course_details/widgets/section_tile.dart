import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/lesson.dart';
import '../../../data/models/lesson_progress.dart';
import '../../../data/models/section.dart';
import '../../../providers/app_providers.dart';
import 'lesson_tile.dart';

class SectionTile extends ConsumerWidget {
  final Section section;
  final List<Lesson> courseLessonsInOrder;
  final Map<String, LessonProgress> progressMap;
  final Function(Lesson lesson, bool isUnlocked) onLessonTap;

  const SectionTile({
    super.key,
    required this.section,
    required this.courseLessonsInOrder,
    required this.progressMap,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode = ref.watch(localeProvider).languageCode;
    final sectionTitle = section.getTitle(langCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sectionTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                      ),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: section.lessons.length,
          itemBuilder: (context, index) {
            final lesson = section.lessons[index];
            final prog = progressMap[lesson.id];

            // Determine if unlocked using sequential rule
            final lessonIndexInCourse =
                courseLessonsInOrder.indexWhere((l) => l.id == lesson.id);
            bool isUnlocked = false;
            if (lessonIndexInCourse == 0) {
              isUnlocked = true;
            } else if (lessonIndexInCourse > 0) {
              final prevLesson = courseLessonsInOrder[lessonIndexInCourse - 1];
              isUnlocked = progressMap[prevLesson.id]?.isCompleted ?? false;
            }

            return LessonTile(
              lesson: lesson,
              progress: prog,
              isUnlocked: isUnlocked,
              onTap: () => onLessonTap(lesson, isUnlocked),
            );
          },
        ),
      ],
    );
  }
}
