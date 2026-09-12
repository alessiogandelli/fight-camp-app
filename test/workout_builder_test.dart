// Widget test for the single-configuration workout builder.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/data/store.dart';
import 'package:fight_camp/main.dart';
import 'package:fight_camp/ui/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('create a workout with a timer config and find it saved', (
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

    // Open the Workout tab and launch the builder from its FAB.
    await tester.tap(find.text('WORKOUT').last);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Name the workout.
    await tester.enterText(find.byType(TextField).first, 'TEST WORKOUT');
    await tester.pumpAndSettle();

    // Save.
    final save = find.widgetWithText(Button, 'SALVA').hitTestable().last;
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Back on the workouts list: the new workout is there with a summary.
    expect(find.text('TEST WORKOUT'), findsOneWidget);
    // Let the save-toast timer expire so no timer is left pending.
    await tester.pump(const Duration(seconds: 4));

    // Store persisted it with the default uniform configuration.
    final store = tester.element(find.byType(MaterialApp)).read<AppStore>();
    final w = store.data.workouts.firstWhere((w) => w.name == 'TEST WORKOUT');
    expect(w.workDuration, 180);
    expect(w.restDuration, 60);
    expect(w.rounds, 3);
    expect(w.combinationIds, isEmpty);
  });

  testWidgets('create a routine from the workout builder and select it', (
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

    await tester.tap(find.text('WORKOUT').last);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Name the workout, then open the routine builder from inside it.
    await tester.enterText(find.byType(TextField).first, 'ROUTINE WORKOUT');
    await tester.pumpAndSettle();

    final newRoutine = find
        .widgetWithText(Button, 'NUOVA ROUTINE')
        .hitTestable();
    await tester.ensureVisible(newRoutine);
    await tester.tap(newRoutine);
    await tester.pumpAndSettle();

    // Routine builder: name it and add one exercise from the catalog.
    await tester.enterText(find.byType(TextField).last, 'TEST ROUTINE');
    await tester.pumpAndSettle();
    await tester.tap(find.text('PANCAKE'));
    await tester.pumpAndSettle();

    final saveRoutine = find.widgetWithText(Button, 'SALVA').hitTestable().last;
    await tester.ensureVisible(saveRoutine);
    await tester.tap(saveRoutine);
    await tester.pumpAndSettle();

    // The new routine is now selected in the workout builder.
    expect(find.text('TEST ROUTINE'), findsWidgets);

    // Save the workout and confirm the routine reference persisted.
    final saveWorkout = find.widgetWithText(Button, 'SALVA').hitTestable().last;
    await tester.ensureVisible(saveWorkout);
    await tester.tap(saveWorkout);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 4));

    final store = tester.element(find.byType(MaterialApp)).read<AppStore>();
    final routine = store.data.combinations.firstWhere(
      (c) => c.name == 'TEST ROUTINE',
    );
    final w = store.data.workouts.firstWhere(
      (w) => w.name == 'ROUTINE WORKOUT',
    );
    expect(w.routineId, routine.id);
    expect(w.rounds, 1);
  });
}
