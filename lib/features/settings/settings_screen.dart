import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final currentThemeMode = ref.watch(themeModeProvider);

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
                Icons.settings_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Text(loc.settingsTitle),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Section: Appearance & Theme Mode
          _buildSectionHeader(context, loc.appearance, Icons.palette_outlined),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.themeMode,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.light,
                          label: Text(loc.lightMode),
                          icon: const Icon(Icons.light_mode_rounded),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.dark,
                          label: Text(loc.darkMode),
                          icon: const Icon(Icons.dark_mode_rounded),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.system,
                          label: Text(loc.systemMode),
                          icon: const Icon(Icons.settings_brightness_rounded),
                        ),
                      ],
                      selected: {currentThemeMode},
                      onSelectionChanged: (Set<ThemeMode> selection) {
                        if (selection.isNotEmpty) {
                          ref
                              .read(themeModeProvider.notifier)
                              .setThemeMode(selection.first);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section: Language Selection
          _buildSectionHeader(context, loc.language, Icons.language_rounded),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _buildLanguageItem(
                  context: context,
                  title: loc.arabic,
                  flag: '🇸🇦',
                  code: 'ar',
                  selectedCode: currentLocale.languageCode,
                  onSelect: () => _changeLanguage(ref, 'ar'),
                ),
                const Divider(height: 1),
                _buildLanguageItem(
                  context: context,
                  title: loc.english,
                  flag: '🇺🇸',
                  code: 'en',
                  selectedCode: currentLocale.languageCode,
                  onSelect: () => _changeLanguage(ref, 'en'),
                ),
                const Divider(height: 1),
                _buildLanguageItem(
                  context: context,
                  title: loc.hindi,
                  flag: '🇮🇳',
                  code: 'hi',
                  selectedCode: currentLocale.languageCode,
                  onSelect: () => _changeLanguage(ref, 'hi'),
                ),
                const Divider(height: 1),
                _buildLanguageItem(
                  context: context,
                  title: loc.chinese,
                  flag: '🇨🇳',
                  code: 'zh',
                  selectedCode: currentLocale.languageCode,
                  onSelect: () => _changeLanguage(ref, 'zh'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildLanguageItem({
    required BuildContext context,
    required String title,
    required String flag,
    required String code,
    required String selectedCode,
    required VoidCallback onSelect,
  }) {
    final isSelected = code == selectedCode;
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
      onTap: onSelect,
    );
  }

  void _changeLanguage(WidgetRef ref, String code) {
    ref.read(localeProvider.notifier).setLocale(Locale(code));
  }
}
