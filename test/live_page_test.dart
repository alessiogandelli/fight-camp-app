// Live session screen: landscape layout and swipe navigation.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/main.dart';
import 'package:fight_camp/ui/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> bootApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({'combat-training:lang': 'it'});
  await tester.pumpWidget(const FightCampApp());
  await tester.pumpAndSettle(const Duration(seconds: 1));
  GoRouter.of(tester.element(find.byType(Text).first)).go('/');
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

Future<void> startFreeRound(WidgetTester tester) async {
  final libero = find.text('Libero');
  await tester.ensureVisible(libero);
  await tester.pumpAndSettle();
  await tester.tap(libero);
  await tester.pumpAndSettle();

  // Train-page start button → navigates to the live idle screen.
  final startBtn = find.widgetWithText(Button, 'AVVIA').hitTestable().last;
  await tester.ensureVisible(startBtn);
  await tester.pumpAndSettle();
  await tester.tap(startBtn);
  await tester.pumpAndSettle();

  // Idle-screen start button → actually starts the session.
  await tester.tap(find.text('AVVIA').hitTestable().last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('live screen renders in landscape without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await bootApp(tester);
    await startFreeRound(tester);

    // Rotate to landscape mid-session.
    tester.view.physicalSize = const Size(1800, 800);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    expect(find.byIcon(Icons.skip_previous_rounded), findsOneWidget);
  });

  testWidgets('swiping left on the timer skips the prep segment', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await bootApp(tester);
    await startFreeRound(tester);

    // Prep (3s) is active: header shows PREPARAZIONE.
    expect(find.text('PREPARAZIONE'), findsWidgets);

    // Swipe left across the timer to skip straight to work.
    await tester.fling(find.text('3'), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('ROUND 1 DI 5'), findsOneWidget);
  });
}
