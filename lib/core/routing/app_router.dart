import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/main_shell_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/courses/courses_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/course_details/course_details_screen.dart';
import '../../features/lesson_player/lesson_player_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'courses',
                builder: (context, state) => const CoursesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                name: 'favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Course Details & Lesson Player Routes
      GoRoute(
        path: '/course/:courseId',
        name: 'course_details',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId'] ?? '';
          return CourseDetailsScreen(courseId: courseId);
        },
        routes: [
          GoRoute(
            path: 'lesson/:lessonId',
            name: 'lesson_player',
            builder: (context, state) {
              final courseId = state.pathParameters['courseId'] ?? '';
              final lessonId = state.pathParameters['lessonId'] ?? '';
              return LessonPlayerScreen(
                courseId: courseId,
                lessonId: lessonId,
              );
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
}
