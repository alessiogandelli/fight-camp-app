// Tests for the unified Timer page (ADR 0001): manual config, optional
// combinations and last-used persistence.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/data/store.dart';
import 'package:fight_camp/main.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> bootApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {
    'fight-camp:lang': 'it',
    'fight-camp:onboarding-seen': true,
  },
}) async {
  // A real phone surface with safe areas: the Home is non-scrollable and
  // must fit here (iPhone 15/16-class screen, 393×852).
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1.0;
  tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(prefs);
  await tester.pumpWidget(const FightCampApp());
  await tester.pumpAndSettle(const Duration(seconds: 1));
  // Global GoRouter: force back to the home tab.
  GoRouter.of(tester.element(find.byType(Text).first)).go('/');
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

void main() {
  testWidgets('timer shows work, rest, rounds and total duration', (
    tester,
  ) async {
    await bootApp(tester);
    // Default setup → 03:00 work, 01:00 rest, 5 rounds, 19:00 total.
    expect(find.text('03:00'), findsOneWidget);
    expect(find.text('01:00'), findsOneWidget);
    expect(find.text('19:00'), findsOneWidget);
    // The rounds value appears once in the settings card and once in the stats.
    expect(find.text('5'), findsNWidgets(2));
    // No preset chips, no extra-tools card on the Home page.
    expect(find.text('Libero'), findsNothing);
    expect(find.text('STRUMENTI EXTRA'), findsNothing);
    expect(find.text('Ultimo uso'), findsNothing);
  });

  testWidgets('tapping the rounds plus button adjusts the value', (
    tester,
  ) async {
    await bootApp(tester);
    await tester.tap(find.byKey(const Key('rounds-plus')));
    await tester.pumpAndSettle();
    expect(find.text('6'), findsNWidgets(2));
    expect(find.text('23:00'), findsOneWidget);
  });

  testWidgets('dragging the work scrubber changes the value', (tester) async {
    await bootApp(tester);
    final rect = tester.getRect(find.byKey(const Key('work-scrubber')));
    await tester.dragFrom(
      Offset(rect.left + 1, rect.center.dy),
      Offset(rect.width - 2, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('05:00'), findsOneWidget);
    expect(find.text('29:00'), findsOneWidget);
  });

  testWidgets('typing a work value opens the editor and applies it', (
    tester,
  ) async {
    await bootApp(tester);
    await tester.tap(find.byKey(const Key('work-value')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '7:30');
    await tester.tap(find.text('SALVA'));
    await tester.pumpAndSettle();
    expect(find.text('07:30'), findsOneWidget);
    // 5 rounds × 450s + 4 rests × 60s = 41:30.
    expect(find.text('41:30'), findsOneWidget);
  });

  testWidgets('tapping the combinations row opens the combo picker', (
    tester,
  ) async {
    await bootApp(tester);
    final combosRow = find.text('Combinazioni');
    expect(combosRow, findsOneWidget);
    await tester.tap(combosRow);
    await tester.pumpAndSettle();
    expect(find.text('SELEZIONA COMBINAZIONI'), findsOneWidget);
  });

  testWidgets('last used setup is restored on reopen', (tester) async {
    await bootApp(
      tester,
      prefs: {
        'fight-camp:lang': 'it',
        'fight-camp:onboarding-seen': true,
        'fight-camp:last-timer:v1': '{"rounds":12,"work":45,"rest":15}',
      },
    );
    expect(find.text('00:45'), findsOneWidget);
    expect(find.text('00:15'), findsOneWidget);
    // 12 rounds × 45s + 11 rests × 15s = 11:45.
    expect(find.text('11:45'), findsOneWidget);
    expect(find.text('12'), findsNWidgets(2));
    // Store still exposes seed data (regression guard).
    final store = tester.element(find.byType(MaterialApp)).read<AppStore>();
    expect(store.data.techniques.length, 48);
  });
}
