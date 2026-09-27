import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player_app/main.dart';
import 'package:video_player_app/providers/app_providers.dart';

void main() {
  testWidgets('VideoPlayerApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const VideoPlayerApp(),
      ),
    );

    // Initial pump
    await tester.pumpAndSettle();

    // Verify main app title or courses header renders
    expect(find.text('Video Player - LMS Platform'), findsOneWidget);
  });
}
