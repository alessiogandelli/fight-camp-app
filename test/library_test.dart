// Tests for the Library tab: bag combos vs stretching routines sections.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/main.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('library shows stretching routines in their own section', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'combat-training:lang': 'it'});
    await tester.pumpWidget(const FightCampApp());
    await tester.pumpAndSettle(const Duration(seconds: 1));
    GoRouter.of(tester.element(find.byType(Text).first)).go('/library');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Segmented sections present.
    expect(find.text('SACCO'), findsOneWidget);
    expect(find.text('STRETCHING'), findsOneWidget);

    // Bag section (default): seed combos visible, stretching routine hidden.
    expect(find.text('COMBO 01'), findsOneWidget);
    expect(find.text('FULL BODY STRETCH'), findsNothing);

    // Switch to Stretching: the seeded routine appears.
    await tester.tap(find.text('STRETCHING'));
    await tester.pumpAndSettle();
    expect(find.text('FULL BODY STRETCH'), findsOneWidget);
    expect(find.text('COMBO 01'), findsNothing);

    // Routine lists its stretching exercises.
    expect(find.text('PANCAKE'), findsOneWidget);

    // Stretching routines render their illustration images.
    expect(find.byType(SvgPicture), findsWidgets);
  });
}
