import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_providers.dart';

// ---------------------------------------------------------------------------
// Favorites Notifier (Course Bookmarks)
// ---------------------------------------------------------------------------
class FavoritesNotifier extends Notifier<Set<String>> {
  static const String _key = 'video_player_app_favorites';

  @override
  Set<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final list = prefs.getStringList(_key) ?? [];
    return list.toSet();
  }

  Future<void> toggleFavorite(String courseId) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final current = Set<String>.from(state);
    if (current.contains(courseId)) {
      current.remove(courseId);
    } else {
      current.add(courseId);
    }
    await prefs.setStringList(_key, current.toList());
    state = current;
  }

  bool isFavorite(String courseId) => state.contains(courseId);
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);
