import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../localization/app_localizations.dart';

class LoadingView extends StatelessWidget {
  final String? message;
  final Color? textColor;

  const LoadingView({
    super.key,
    this.message,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final displayMessage = message ?? loc.loading;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            displayMessage,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor ??
                  Theme.of(context).textTheme.bodyMedium?.color ??
                  AppColors.lightTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
