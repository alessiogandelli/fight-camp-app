// Tests for the merged Progress page (Stats + History in one tab).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/main.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('progress page shows summary, stats and history sections', (tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'fight-camp:lang': 'it'});
    await tester.pumpWidget(const FightCampApp());
    await tester.pumpAndSettle(const Duration(seconds: 1));
    GoRouter.of(tester.element(find.byType(Text).first)).go('/progress');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Summary cards.
    expect(find.text('SESSIONI SETTIMANA'), findsOneWidget);
    expect(find.text('SERIE ATTUALE'), findsOneWidget);
    // Stats and history sections are both present.
    expect(find.text('Statistiche'), findsOneWidget); // stats.title
    expect(find.text('STORICO'), findsOneWidget); // history.title
    // Empty states since no sessions exist yet.
    expect(find.textContaining('Ancora nessuno storico'), findsOneWidget);
    expect(find.text('Nessuna sessione'), findsOneWidget);
  });
}
