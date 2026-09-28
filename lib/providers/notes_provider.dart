import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_providers.dart';

// ---------------------------------------------------------------------------
// Per-Lesson Notes Notifier
// ---------------------------------------------------------------------------
class LessonNotesNotifier extends Notifier<Map<String, String>> {
  static const String _key = 'video_player_lesson_notes';

  @override
  Map<String, String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null || jsonStr.trim().isEmpty) return {};
    try {
      final decoded = json.decode(jsonStr);
      if (decoded is Map) {
        return Map<String, String>.from(decoded);
      }
    } catch (_) {}
    return {};
  }

  Future<void> saveNote(String lessonId, String noteText) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final updated = Map<String, String>.from(state);
    if (noteText.trim().isEmpty) {
      updated.remove(lessonId);
    } else {
      updated[lessonId] = noteText;
    }
    await prefs.setString(_key, json.encode(updated));
    state = updated;
  }

  String getNote(String lessonId) => state[lessonId] ?? '';
}

final lessonNotesProvider =
    NotifierProvider<LessonNotesNotifier, Map<String, String>>(
  LessonNotesNotifier.new,
);
