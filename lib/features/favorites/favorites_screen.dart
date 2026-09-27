import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../providers/app_providers.dart';
import '../courses/widgets/course_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final coursesAsync = ref.watch(coursesProvider);
    final favorites = ref.watch(favoritesProvider);
    final progressMap = ref.watch(progressMapProvider);
    final progressService = ref.watch(progressServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.bookmark_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Text(loc.navFavorites),
          ],
        ),
      ),
      body: coursesAsync.when(
        loading: () => const LoadingView(),
        error: (err, stack) => ErrorView(
          message: loc.errorLoadingCourses,
          onRetry: () => ref.refresh(coursesProvider),
        ),
        data: (courses) {
          final favoriteCourses =
              courses.where((c) => favorites.contains(c.id)).toList();

          if (favoriteCourses.isEmpty) {
            return EmptyView(
              message: loc.emptyFavorites,
              icon: Icons.bookmark_border_rounded,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20.0),
            itemCount: favoriteCourses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final course = favoriteCourses[index];
              final progressPct = progressService.calculateCourseProgress(
                course: course,
                progressMap: progressMap,
              );

              return CourseCard(
                course: course,
                progressPercentage: progressPct,
              );
            },
          );
        },
      ),
    );
  }
}
