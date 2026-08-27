// Widget test for the blocks-based workout builder.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/data/store.dart';
import 'package:fight_camp/main.dart';
import 'package:fight_camp/models/types.dart';
import 'package:fight_camp/ui/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('create a workout with two blocks and find it saved', (tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'combat-training:lang': 'it'});
    await tester.pumpWidget(const FightCampApp());
    await tester.pumpAndSettle(const Duration(seconds: 1));
    GoRouter.of(tester.element(find.byType(Text).first)).go('/workouts/new');
    await tester.pumpAndSettle();

    // Name the workout.
    await tester.enterText(find.byType(TextField).first, 'TEST BLOCKS');
    await tester.pumpAndSettle();
    // Default round block exists.
    expect(find.textContaining('ROUND'), findsWidgets);

    // Add a circuit block via the block type modal.
    final addBtn = find.widgetWithText(Button, 'AGGIUNGI BLOCCO');
    await tester.ensureVisible(addBtn);
    await tester.tap(addBtn);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Circuito').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('CIRCUITO'), findsWidgets);

    // Save.
    final save = find.widgetWithText(Button, 'SALVA').hitTestable().last;
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Back on the workouts list: the new workout is there with a summary.
    expect(find.text('TEST BLOCKS'), findsOneWidget);
    // Let the save-toast timer expire so no timer is left pending.
    await tester.pump(const Duration(seconds: 4));

    // Store persisted it with two blocks.
    final store = tester.element(find.byType(MaterialApp)).read<AppStore>();
    final w = store.data.workouts.firstWhere((w) => w.name == 'TEST BLOCKS');
    expect(w.blocks.length, 2);
    expect(w.blocks[1].type, BlockType.circuit);
  });
}
