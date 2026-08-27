// Tests for the unified Timer page (ADR 0001): preset selection, manual
// config, optional combinations and last-used persistence.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/data/store.dart';
import 'package:fight_camp/main.dart';
import 'package:fight_camp/ui/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> bootApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {'combat-training:lang': 'it'},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  await tester.pumpWidget(const FightCampApp());
  await tester.pumpAndSettle(const Duration(seconds: 1));
  // Global GoRouter: force back to the home tab.
  GoRouter.of(tester.element(find.byType(Text).first)).go('/');
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

void main() {
  testWidgets('timer hero shows big work/rest numbers and preset chips', (
    tester,
  ) async {
    await bootApp(tester);
    // Default preset Sacco 3'/1' → 03:00 work, 01:00 rest, ×5
    expect(find.text('03:00'), findsOneWidget);
    expect(find.text('01:00'), findsOneWidget);
    expect(find.text('×5'), findsOneWidget);
    for (final chip in [
      '3💪 1💤',
      '20💪 10💤',
      '40💪 20💤',
      'Libero',
    ]) {
      expect(find.text(chip), findsOneWidget);
    }
    // Tools section present with push-ups inside.
    expect(find.text('STRUMENTI EXTRA'), findsOneWidget);
  });

  testWidgets('selecting a tabata preset updates the big numbers', (
    tester,
  ) async {
    await bootApp(tester);
    final tabata = find.text('20💪 10💤');
    await tester.ensureVisible(tabata);
    await tester.pumpAndSettle();
    await tester.tap(tabata);
    await tester.pumpAndSettle();
    expect(find.text('00:20'), findsOneWidget);
    expect(find.text('00:10'), findsOneWidget);
    expect(find.text('×8'), findsOneWidget);
  });

  testWidgets('tapping the rounds plus button adjusts the value', (tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await bootApp(tester);
    // The rounds stepper is the -/+ control wrapping ×5; tap its + button.
    final roundsRow = find.ancestor(of: find.text('×5'), matching: find.byType(Row)).first;
    await tester.tap(find.descendant(of: roundsRow, matching: find.byIcon(Icons.add_rounded)));
    await tester.pumpAndSettle();
    expect(find.text('×6'), findsOneWidget);
  });

  testWidgets('combinations toggle reveals the combo picker', (tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await bootApp(tester);
    final toggleLabel = find.text('Allenati sulle combinazioni');
    await tester.ensureVisible(toggleLabel);
    await tester.pumpAndSettle();
    expect(toggleLabel, findsOneWidget);
    // The combos editor starts hidden (closed AnimatedCrossFade child is not
    // hittable even though it stays in the tree).
    expect(find.text('SELEZIONA COMBINAZIONI').hitTestable(), findsNothing);
    // Toggle on.
    await tester.tap(find.byType(Toggle).hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.text('SELEZIONA COMBINAZIONI').hitTestable(), findsOneWidget);
  });

  testWidgets('last used setup is restored on reopen', (tester) async {
    await bootApp(
      tester,
      prefs: {
        'combat-training:lang': 'it',
        'combat-training:last-timer:v1': '{"rounds":12,"work":45,"rest":15}',
      },
    );
    expect(find.text('×12'), findsOneWidget);
    expect(find.text('00:45'), findsOneWidget);
    expect(find.text('00:15'), findsOneWidget);
    expect(find.text('Ultimo uso'), findsOneWidget);
    // Store still exposes seed data (regression guard).
    final store = tester.element(find.byType(MaterialApp)).read<AppStore>();
    expect(store.data.techniques.length, 37);
  });
}
