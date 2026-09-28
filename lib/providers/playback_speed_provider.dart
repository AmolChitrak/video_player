import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_providers.dart';

// ---------------------------------------------------------------------------
// Remember Last Playback Speed Notifier
// ---------------------------------------------------------------------------
class PlaybackSpeedNotifier extends Notifier<double> {
  static const String _key = 'video_player_last_playback_speed';

  @override
  double build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getDouble(_key) ?? 1.0;
  }

  Future<void> setSpeed(double speed) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setDouble(_key, speed);
    state = speed;
  }
}

final defaultPlaybackSpeedProvider =
    NotifierProvider<PlaybackSpeedNotifier, double>(
  PlaybackSpeedNotifier.new,
);
