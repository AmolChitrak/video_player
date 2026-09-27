import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/formatted_time.dart';
import '../../../data/models/lesson.dart';
import '../../../data/models/lesson_progress.dart';
import '../../../providers/app_providers.dart';

class LessonTile extends ConsumerWidget {
  final Lesson lesson;
  final LessonProgress? progress;
  final bool isUnlocked;
  final VoidCallback onTap;

  const LessonTile({
    super.key,
    required this.lesson,
    required this.progress,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final langCode = ref.watch(localeProvider).languageCode;
    final lessonTitle = lesson.getTitle(langCode);

    final isCompleted = progress?.isCompleted ?? false;
    final lastPos = progress?.lastPositionSec ?? 0;
    final isInProgress = !isCompleted && lastPos > 0;

    // Determine status badge color and text
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (!isUnlocked) {
      statusColor = AppColors.locked;
      statusText = loc.statusLocked;
      statusIcon = Icons.lock_rounded;
    } else if (isCompleted) {
      statusColor = AppColors.success;
      statusText = loc.statusCompleted;
      statusIcon = Icons.check_circle_rounded;
    } else if (isInProgress) {
      statusColor = AppColors.warning;
      statusText = loc.statusInProgress;
      statusIcon = Icons.play_circle_fill_rounded;
    } else {
      statusColor = AppColors.primary;
      statusText = loc.statusNotStarted;
      statusIcon = Icons.play_circle_outline_rounded;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isUnlocked
            ? Theme.of(context).cardTheme.color
            : (isDark
                ? AppColors.darkSurfaceVariant.withAlpha(100)
                : AppColors.lightSurfaceVariant.withAlpha(120)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha(30),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                // Status Icon Box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // Lesson Title & Duration
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lessonTitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isUnlocked
                              ? Theme.of(context).textTheme.titleMedium?.color
                              : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            TimeFormatter.formatSeconds(lesson.durationSec),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (isInProgress) ...[
                            const SizedBox(width: 10),
                            Text(
                              '(${TimeFormatter.formatSeconds(lastPos)} / ${TimeFormatter.formatSeconds(lesson.durationSec)})',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.warning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Status Tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
