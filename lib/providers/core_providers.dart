import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Base SharedPreferences Provider (must be overridden at ProviderScope root)
// ---------------------------------------------------------------------------
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  );
});

// ---------------------------------------------------------------------------
// Locale Provider (Supports ar, en, hi, zh)
// ---------------------------------------------------------------------------
class LocaleNotifier extends Notifier<Locale> {
  static const String _key = 'video_player_app_locale';

  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final code = prefs.getString(_key) ?? 'en';
    return Locale(code);
  }

  Future<void> setLocale(Locale newLocale) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, newLocale.languageCode);
    state = newLocale;
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

// ---------------------------------------------------------------------------
// Theme Mode Provider (Supports light, dark, system)
// ---------------------------------------------------------------------------
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String _key = 'video_player_app_theme_mode';

  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(_key);
    if (saved == 'dark') return ThemeMode.dark;
    if (saved == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final String strVal = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_key, strVal);
    state = mode;
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
