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
    // Seed Italian so label-based finders are deterministic (stored
    // preference wins over system-locale detection).
    SharedPreferences.setMockInitialValues({'combat-training:lang': 'it'});
    await tester.pumpWidget(const FightCampApp());
    await tester.pumpAndSettle(const Duration(seconds: 1));
    // The GoRouter instance is global: force it back to the home tab so
    // previous tests leaving other routes don't leak into this one.
    GoRouter.of(tester.element(find.byType(Text).first)).go('/');
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  testWidgets('app boots and tabs render without layout errors', (tester) async {
    await bootApp(tester);

    // Walk through the bottom navigation tabs.
    for (final label in ['WORKOUT', 'LIBRERIA', 'PROGRESSI', 'ALLENATI']) {
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('settings page opens from the header gear and edits preferences', (tester) async {
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
  });

  testWidgets('store provider exposes seed data', (tester) async {
    await bootApp(tester);
    final store = tester.element(find.byType(MaterialApp)).read<AppStore>();
    expect(store.data.techniques.length, 37);
    expect(store.data.combinations.length, 9);
    expect(store.data.workouts.length, 4);
    expect(store.data.presets.length, 4);
    // stretching plans auto-inserted Mon-Fri
    expect(store.data.plans.where((p) => p.id.startsWith('plan-stretching-')).length, 5);
  });

  testWidgets('free round session runs through prep and work', (tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await bootApp(tester);

    // Select the Free preset on the unified timer and start the session.
    final libero = find.text('Libero');
    await tester.ensureVisible(libero);
    await tester.pumpAndSettle();
    await tester.tap(libero);
    await tester.pumpAndSettle();

    // Start the session (scroll the button into view first).
    final startBtn = find.widgetWithText(Button, 'AVVIA').hitTestable().last;
    await tester.ensureVisible(startBtn);
    await tester.pumpAndSettle();
    await tester.tap(startBtn);
    await tester.pumpAndSettle();

    // Idle screen shows the start button.
    await tester.tap(find.text('AVVIA').hitTestable().last);
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
