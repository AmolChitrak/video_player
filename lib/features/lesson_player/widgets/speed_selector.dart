import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';

class SpeedSelector extends StatelessWidget {
  final double currentSpeed;
  final ValueChanged<double> onSpeedChanged;

  static const List<double> availableSpeeds = [1.0, 1.25, 1.5, 2.0];

  const SpeedSelector({
    super.key,
    required this.currentSpeed,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return PopupMenuButton<double>(
      initialValue: currentSpeed,
      tooltip: loc.speedLabel,
      onSelected: onSpeedChanged,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.primaryDark,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(40),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.speed_rounded,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${currentSpeed}x',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) {
        return availableSpeeds.map((speed) {
          final isSelected = (currentSpeed - speed).abs() < 0.01;
          return PopupMenuItem<double>(
            value: speed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${speed}x',
                  style: TextStyle(
                    color: isSelected ? AppColors.primaryLight : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_rounded,
                    color: AppColors.primaryLight,
                    size: 18,
                  ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
