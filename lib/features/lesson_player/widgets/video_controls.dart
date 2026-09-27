import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/formatted_time.dart';
import 'speed_selector.dart';

class VideoControls extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;
  final double currentSpeed;
  final ValueChanged<double> onSpeedChanged;

  const VideoControls({
    super.key,
    required this.controller,
    required this.isFullscreen,
    required this.onToggleFullscreen,
    required this.currentSpeed,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    final position = value.position;
    final duration = value.duration;

    final posSec = position.inSeconds;
    final durSec = duration.inSeconds;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withAlpha(160),
            Colors.transparent,
            Colors.black.withAlpha(200),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top bar: Speed & Fullscreen buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SpeedSelector(
                  currentSpeed: currentSpeed,
                  onSpeedChanged: onSpeedChanged,
                ),
                IconButton(
                  icon: Icon(
                    isFullscreen
                        ? Icons.fullscreen_exit_rounded
                        : Icons.fullscreen_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: onToggleFullscreen,
                ),
              ],
            ),
          ),

          // Center Play/Pause & Seek buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 36,
                icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
                onPressed: () {
                  final newPos = position - const Duration(seconds: 10);
                  controller.seekTo(newPos < Duration.zero ? Duration.zero : newPos);
                },
              ),
              const SizedBox(width: 20),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  iconSize: 48,
                  icon: value.isBuffering
                      ? const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Icon(
                          value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                  onPressed: () {
                    if (value.isPlaying) {
                      controller.pause();
                    } else {
                      controller.play();
                    }
                  },
                ),
              ),
              const SizedBox(width: 20),
              IconButton(
                iconSize: 36,
                icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
                onPressed: () {
                  final newPos = position + const Duration(seconds: 10);
                  controller.seekTo(newPos > duration ? duration : newPos);
                },
              ),
            ],
          ),

          // Bottom Bar: Progress Slider & Time
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      TimeFormatter.formatSeconds(posSec),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 7,
                          ),
                          activeTrackColor: AppColors.primaryLight,
                          inactiveTrackColor: Colors.white30,
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: posSec.toDouble().clamp(
                                0.0,
                                durSec > 0 ? durSec.toDouble() : 1.0,
                              ),
                          min: 0.0,
                          max: durSec > 0 ? durSec.toDouble() : 1.0,
                          onChanged: (val) {
                            controller.seekTo(Duration(seconds: val.toInt()));
                          },
                        ),
                      ),
                    ),
                    Text(
                      TimeFormatter.formatSeconds(durSec),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
