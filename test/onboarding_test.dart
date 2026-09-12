// First-run onboarding: gating, skip, and the persisted flag.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('first run shows onboarding; skip lands on home and persists', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // No onboarding flag: a fresh install.
    SharedPreferences.setMockInitialValues({'fight-camp:lang': 'it'});

    await tester.pumpWidget(const FightCampApp());
    // Let the store load, then the router redirect to /onboarding.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 400));

    // Slide 1 is shown (repeating visuals mean we must not pumpAndSettle).
    expect(find.text('Allenati con il timer'), findsOneWidget);
    expect(find.text('SALTA'), findsOneWidget);

    await tester.tap(find.text('SALTA'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // We are on the main shell now.
    expect(find.byType(NavigationBar), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('fight-camp:onboarding-seen'), isTrue);
  });

  testWidgets('onboarding is not shown when already seen', (tester) async {
    // The Home is non-scrollable now and needs height to fit in tests.
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'fight-camp:lang': 'it',
      'fight-camp:onboarding-seen': true,
    });
    await tester.pumpWidget(const FightCampApp());
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Allenati con il timer'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
