// Appearance: the app follows the phone and both palettes stay coherent.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/data/store.dart';
import 'package:fight_camp/main.dart';
import 'package:fight_camp/models/types.dart';
import 'package:fight_camp/ui/theme.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> boot(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({
    'fight-camp:lang': 'it',
    'fight-camp:onboarding-seen': true,
  });
  await tester.pumpWidget(const FightCampApp());
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

void main() {
  testWidgets('light phone renders the light palette', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await boot(tester);

    expect(AppColors.isDark, false);
    expect(AppColors.bg, AppPalette.light.bg);
    // Material widgets (dialogs, inputs, switches) resolve the same palette.
    final context = tester.element(find.byType(Text).first);
    expect(Theme.of(context).brightness, Brightness.light);
    expect(Theme.of(context).scaffoldBackgroundColor, AppPalette.light.bg);
  });

  testWidgets('dark phone renders the dark palette', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await boot(tester);

    expect(AppColors.isDark, true);
    expect(AppColors.bg, AppPalette.dark.bg);
  });

  testWidgets('the in-app theme switch overrides the phone and persists', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await boot(tester);

    GoRouter.of(tester.element(find.byType(Text).first)).go('/settings');
    await tester.pumpAndSettle();

    await tester.tap(find.text('SCURO'));
    await tester.pumpAndSettle();
    expect(AppColors.isDark, true);
    expect(find.text('IMPOSTAZIONI'), findsOneWidget);
    final store = tester.element(find.byType(MaterialApp)).read<AppStore>();
    expect(store.data.settings.themeChoice, ThemeChoice.dark);

    await tester.tap(find.text('CHIARO'));
    await tester.pumpAndSettle();
    expect(AppColors.isDark, false);

    // Back to system: the phone is light, so the app is light again.
    await tester.tap(find.text('SISTEMA'));
    await tester.pumpAndSettle();
    expect(store.data.settings.themeChoice, ThemeChoice.system);
    expect(AppColors.isDark, false);
  });

  testWidgets('flipping the phone appearance repaints and keeps the route', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await boot(tester);

    GoRouter.of(tester.element(find.byType(Text).first)).go('/settings');
    await tester.pumpAndSettle();
    expect(find.text('IMPOSTAZIONI'), findsOneWidget);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();

    expect(AppColors.isDark, true);
    // The remount is limited to the app frame: navigation state survives.
    expect(find.text('IMPOSTAZIONI'), findsOneWidget);
  });
}
