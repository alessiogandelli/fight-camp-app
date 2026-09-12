// Tests for the Library tab: bag combos and the stretching exercise catalog.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/main.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('library shows bag combos and a stretching exercise catalog', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'fight-camp:lang': 'it',
      'fight-camp:onboarding-seen': true,
    });
    await tester.pumpWidget(const FightCampApp());
    await tester.pumpAndSettle(const Duration(seconds: 1));
    GoRouter.of(tester.element(find.byType(Text).first)).go('/library');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Segmented sections present.
    expect(find.text('SACCO'), findsOneWidget);
    expect(find.text('STRETCHING'), findsOneWidget);

    // Bag section (default): seed combos visible, no stretching exercises.
    expect(find.text('COMBO 01'), findsOneWidget);
    expect(find.text('PANCAKE'), findsNothing);

    // Switch to Stretching: the exercise catalog appears, routines do not.
    await tester.tap(find.text('STRETCHING'));
    await tester.pumpAndSettle();
    expect(find.text('PANCAKE'), findsOneWidget);
    expect(find.text('FARFALLA'), findsOneWidget);
    expect(find.text('FULL BODY STRETCH'), findsNothing);
    expect(find.text('COMBO 01'), findsNothing);

    // Exercises render their illustration images, and there is no routine FAB.
    expect(find.byType(SvgPicture), findsWidgets);
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
