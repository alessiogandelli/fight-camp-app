// Tests for the Progress page (pulse + analytics + history entry point).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/main.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> bootProgress(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({
    'fight-camp:lang': 'it',
    'fight-camp:onboarding-seen': true,
  });
  await tester.pumpWidget(const FightCampApp());
  await tester.pumpAndSettle(const Duration(seconds: 1));
  GoRouter.of(tester.element(find.byType(Text).first)).go('/progress');
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

void main() {
  testWidgets('progress shows pulse, analytics and the history card', (
    tester,
  ) async {
    await bootProgress(tester);

    // Motivational pulse.
    expect(find.text('STREAK SETTIMANALE'), findsOneWidget);
    expect(find.text('ALLENAMENTI QUESTA SETTIMANA'), findsOneWidget);
    expect(find.text('OBIETTIVO SETTIMANALE'), findsOneWidget);

    // Deep analytics and the history entry point.
    expect(find.text('Statistiche'), findsOneWidget);
    expect(find.text('STORICO'), findsOneWidget);
    expect(find.text('VEDI TUTTO'), findsOneWidget);

    // Empty state on the history card.
    expect(find.text('Nessuna sessione'), findsOneWidget);
  });

  testWidgets('view all opens the dedicated history page', (tester) async {
    await bootProgress(tester);

    await tester.tap(find.text('VEDI TUTTO'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Back to Progress from the history page.
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    // History page header + embedded section title.
    expect(find.text('STORICO'), findsWidgets);
    // The log-session FAB lives on the history page.
    expect(find.byIcon(Icons.add), findsWidgets);
  });
}
