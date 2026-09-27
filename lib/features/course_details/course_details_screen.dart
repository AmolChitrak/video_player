import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/formatted_time.dart';
import '../../core/widgets/loading_view.dart';
import '../../providers/app_providers.dart';
import 'widgets/section_tile.dart';

class CourseDetailsScreen extends ConsumerWidget {
  final String courseId;

  const CourseDetailsScreen({
    super.key,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final langCode = ref.watch(localeProvider).languageCode;
    final coursesAsync = ref.watch(coursesProvider);
    final progressMap = ref.watch(progressMapProvider);
    final progressService = ref.watch(progressServiceProvider);
    final isFav = ref.watch(favoritesProvider).contains(courseId);

    return Scaffold(
      body: coursesAsync.when(
        loading: () => const LoadingView(),
        error: (err, stack) => ErrorView(
          message: loc.errorLoadingCourses,
          onRetry: () => ref.refresh(coursesProvider),
        ),
        data: (courses) {
          final course = courses.firstWhere(
            (c) => c.id == courseId,
            orElse: () => courses.firstWhere((element) => true),
          );

          if (course.id != courseId) {
            return ErrorView(message: loc.courseNotFound);
          }

          final courseTitle = course.getTitle(langCode);
          final instructor = course.getInstructor(langCode);
          final description = course.getDescription(langCode);

          final progressPct = progressService.calculateCourseProgress(
            course: course,
            progressMap: progressMap,
          );

          final allLessonsInOrder = course.allLessons;

          return CustomScrollView(
            slivers: [
              // Flexible AppBar with thumbnail banner
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: isFav ? AppColors.accent : Colors.white,
                    ),
                    onPressed: () {
                      ref.read(favoritesProvider.notifier).toggleFavorite(course.id);
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        course.thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: AppColors.primaryDark),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha(220),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        left: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              courseTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${loc.instructorPrefix}$instructor',
                              style: TextStyle(
                                color: Colors.white.withAlpha(200),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Course Info Header & Progress Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Metadata badges
                      Row(
                        children: [
                          _buildInfoBadge(
                            context: context,
                            icon: Icons.video_library_rounded,
                            label: '${course.totalLessonsCount} ${loc.totalLessons}',
                          ),
                          const SizedBox(width: 12),
                          _buildInfoBadge(
                            context: context,
                            icon: Icons.timer_rounded,
                            label: TimeFormatter.formatSeconds(
                                course.totalDurationSec),
                          ),
                          const SizedBox(width: 12),
                          _buildInfoBadge(
                            context: context,
                            icon: Icons.view_headline_rounded,
                            label: '${course.sections.length} ${loc.totalSections}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      if (description.isNotEmpty) ...[
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Progress Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).dividerColor.withAlpha(40),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.courseProgress,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  '${progressPct.toInt()}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (progressPct / 100).clamp(0.0, 1.0),
                                minHeight: 8,
                                backgroundColor: Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkSurfaceVariant
                                    : AppColors.lightSurfaceVariant,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Sections & Lessons List
              if (course.sections.isEmpty)
                SliverToBoxAdapter(
                  child: EmptyView(
                    message: loc.emptyCourses,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final section = course.sections[index];
                        return SectionTile(
                          section: section,
                          courseLessonsInOrder: allLessonsInOrder,
                          progressMap: progressMap,
                          onLessonTap: (lesson, isUnlocked) {
                            if (isUnlocked) {
                              context.go(
                                '/course/${course.id}/lesson/${lesson.id}',
                              );
                            } else {
                              final isDark = Theme.of(context).brightness == Brightness.dark;
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(
                                          Icons.lock_rounded,
                                          color: AppColors.warning,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            loc.lockedLessonMessage,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: isDark
                                        ? const Color(0xFF020617)
                                        : const Color(0xFF0F172A),
                                    elevation: 8,
                                    margin: const EdgeInsets.only(
                                      bottom: 24,
                                      left: 16,
                                      right: 16,
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: AppColors.warning.withAlpha(220),
                                        width: 1.5,
                                      ),
                                    ),
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                            }
                          },
                        );
                      },
                      childCount: course.sections.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 30),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoBadge({
    required BuildContext context,
    required IconData icon,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
