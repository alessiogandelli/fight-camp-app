// Full-app smoke test: boots the app and walks through all tabs.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/data/store.dart';
import 'package:fight_camp/main.dart';
import 'package:fight_camp/ui/widgets.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> bootApp(WidgetTester tester) async {
    // The Home is non-scrollable now, so tests need enough height for it.
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // Seed Italian so label-based finders are deterministic (stored
    // preference wins over system-locale detection).
    SharedPreferences.setMockInitialValues({
      'fight-camp:lang': 'it',
      'fight-camp:onboarding-seen': true,
    });
    await tester.pumpWidget(const FightCampApp());
    await tester.pumpAndSettle(const Duration(seconds: 1));
    // The GoRouter instance is global: force it back to the home tab so
    // previous tests leaving other routes don't leak into this one.
    GoRouter.of(tester.element(find.byType(Text).first)).go('/');
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  testWidgets('app boots and tabs render without layout errors', (
    tester,
  ) async {
    await bootApp(tester);

    // Walk through the bottom navigation tabs.
    for (final label in ['WORKOUT', 'LIBRERIA', 'PROGRESSI', 'ALLENATI']) {
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets(
    'settings page opens from the header gear and edits preferences',
    (tester) async {
      await bootApp(tester);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.text('IMPOSTAZIONI'), findsOneWidget);
      expect(find.text('COUNTDOWN PREPARAZIONE'), findsOneWidget);
      // language segmented control present with both options
      expect(find.text('IT'), findsOneWidget);
      expect(find.text('EN'), findsOneWidget);

      // switch language to EN
      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();
      expect(find.text('SETTINGS'), findsOneWidget);
    },
  );

  testWidgets('store provider exposes seed data', (tester) async {
    await bootApp(tester);
    final store = tester.element(find.byType(MaterialApp)).read<AppStore>();
    expect(store.data.techniques.length, 48);
    expect(store.data.combinations.length, 21);
    expect(store.data.workouts.length, 6);
    // No plans are auto-inserted any more: the user owns their schedule.
    expect(store.data.plans, isEmpty);
  });

  testWidgets('free round session runs through prep and work', (tester) async {
    await bootApp(tester);

    // Default timer setup (5×3:00/1:00, no combos) and start the session.
    // Starting from a routed config auto-starts: there is no second START.
    // The Start button is pinned to the bottom and always visible.
    final startBtn = find.widgetWithText(Button, 'AVVIA').hitTestable().last;
    await tester.tap(startBtn);
    await tester.pumpAndSettle();

    // Prep countdown is active (default prep 3s) — header shows PREPARAZIONE
    // and the big number counts 3-2-1.
    expect(find.text('PREPARAZIONE'), findsWidgets);
    expect(find.text('3'), findsWidgets);

    // Skip controls exist.
    expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
  });
}
