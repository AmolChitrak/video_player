import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../providers/app_providers.dart';
import 'widgets/continue_watching_card.dart';
import 'widgets/course_card.dart';

class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final langCode = ref.watch(localeProvider).languageCode;
    final coursesAsync = ref.watch(coursesProvider);
    final progressMap = ref.watch(progressMapProvider);
    final continueWatching = ref.watch(continueWatchingProvider);
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
                Icons.menu_book_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Text(loc.appTitle),
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
          if (courses.isEmpty) {
            return EmptyView(
              message: loc.emptyCourses,
              icon: Icons.auto_stories_rounded,
            );
          }

          // Filter courses based on search query
          final filteredCourses = courses.where((course) {
            if (_searchQuery.trim().isEmpty) return true;
            final query = _searchQuery.trim().toLowerCase();
            final title = course.getTitle(langCode).toLowerCase();
            final instructor = course.instructor.toLowerCase();
            final description = course.description.toLowerCase();
            return title.contains(query) ||
                instructor.contains(query) ||
                description.contains(query);
          }).toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(coursesProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color ??
                          Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: loc.searchCourses,
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Continue Watching Card if available and not searching
                  if (continueWatching != null && _searchQuery.isEmpty) ...[
                    ContinueWatchingCard(
                      course: continueWatching.course,
                      lesson: continueWatching.lesson,
                    ),
                    const SizedBox(height: 24),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.coursesHeader,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (_searchQuery.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${filteredCourses.length}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Filtered Course Cards List or Empty Search Result
                  if (filteredCourses.isEmpty) ...[
                    const SizedBox(height: 30),
                    EmptyView(
                      message: loc.noCoursesFound,
                      icon: Icons.search_off_rounded,
                    ),
                  ] else ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredCourses.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final course = filteredCourses[index];
                        final progressPct =
                            progressService.calculateCourseProgress(
                          course: course,
                          progressMap: progressMap,
                        );

                        return CourseCard(
                          course: course,
                          progressPercentage: progressPct,
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
