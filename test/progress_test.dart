// Tests for the Progress page (training story sections + history entry point).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/data/store.dart';
import 'package:fight_camp/l10n/app_localizations.dart';
import 'package:fight_camp/main.dart';
import 'package:fight_camp/models/seed.dart';
import 'package:fight_camp/models/types.dart';
import 'package:fight_camp/pages/progress_page.dart';
import 'package:fight_camp/ui/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppStore> bootProgress(
  WidgetTester tester, {
  Size size = const Size(800, 1800),
}) async {
  tester.view.physicalSize = size;
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
  return tester.element(find.byType(MaterialApp)).read<AppStore>();
}

/// Progress page in isolation (no app shell), so a short/narrow viewport
/// exercises only this page and not the non-scrollable home page.
Future<AppStore> bootProgressOnly(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final store = AppStore(seedData(), Lang.it);
  await tester.pumpWidget(
    ChangeNotifierProvider<AppStore>.value(
      value: store,
      child: MaterialApp(
        theme: buildTheme(),
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: ProgressPage()),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return store;
}

SessionRecord _session({
  int daysAgo = 0,
  int rounds = 4,
  int duration = 1800,
  List<NameRef>? combos,
}) => SessionRecord(
  id: 'sess-$daysAgo-$rounds',
  date: DateTime.now().subtract(Duration(days: daysAgo)).millisecondsSinceEpoch,
  type: WorkoutType.heavyBag,
  source: 'manual',
  name: 'SACCO',
  roundsCompleted: rounds,
  totalRounds: rounds,
  duration: duration,
  workDuration: duration,
  load: 0,
  combosUsed: combos,
);

void main() {
  testWidgets('progress shows an intentional empty state with no sessions', (
    tester,
  ) async {
    await bootProgress(tester);

    expect(find.text('PROGRESSI'), findsWidgets);
    expect(find.text('Nessuna sessione'), findsOneWidget);
    expect(find.text('REGISTRA UNA SESSIONE'), findsOneWidget);
    // The range selector only appears once there is data to plot.
    expect(find.text('SETTIMANA'), findsNothing);
  });

  testWidgets('progress tells the training story with seeded sessions', (
    tester,
  ) async {
    final store = await bootProgress(tester);
    store.addSession(
      _session(
        daysAgo: 0,
        rounds: 4,
        combos: [const NameRef('c1', 'JAB CROSS')],
      ),
    );
    store.addSession(_session(daysAgo: 7, rounds: 3));
    await tester.pumpAndSettle();

    // Range selector.
    expect(find.text('SETTIMANA'), findsOneWidget);
    expect(find.text('4 SETTIMANE'), findsOneWidget);
    expect(find.text('TUTTO'), findsOneWidget);

    // The story, in order.
    expect(find.text('QUESTA SETTIMANA'), findsOneWidget);
    expect(find.text('COSTANZA'), findsOneWidget);
    expect(find.text('VOLUME DI ALLENAMENTO'), findsOneWidget);
    expect(find.text('PROGRESSO'), findsOneWidget);
    expect(find.text('COMBINAZIONI PIÙ USATE'), findsOneWidget);
    expect(find.text('JAB CROSS'), findsOneWidget);
    expect(find.text('RECORD PERSONALI'), findsOneWidget);
    expect(find.text('DETTAGLIO'), findsOneWidget);

    // History entry point.
    expect(find.text('STORICO'), findsOneWidget);
    expect(find.text('VEDI TUTTO'), findsOneWidget);
  });

  testWidgets('all-time range relabels the trend section', (tester) async {
    final store = await bootProgress(tester);
    store.addSession(_session(daysAgo: 0));
    store.addSession(_session(daysAgo: 7, rounds: 3));
    await tester.pumpAndSettle();

    await tester.tap(find.text('TUTTO'));
    await tester.pumpAndSettle();

    expect(find.text('TOTALI'), findsOneWidget);
    expect(find.text('PROGRESSO'), findsNothing);
  });

  testWidgets('view all opens the dedicated history page', (tester) async {
    final store = await bootProgress(tester);
    store.addSession(_session(daysAgo: 0));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('VEDI TUTTO'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('VEDI TUTTO'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Back to Progress from the history page.
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    // History page header + embedded section title.
    expect(find.text('STORICO'), findsWidgets);
    // The log-session FAB lives on the history page.
    expect(find.byIcon(Icons.add), findsWidgets);
  });

  testWidgets('progress lays out on a narrow phone without overflow', (
    tester,
  ) async {
    final store = await bootProgressOnly(tester, const Size(320, 640));
    store.addSession(
      _session(
        daysAgo: 0,
        rounds: 8,
        combos: [const NameRef('c1', 'JAB CROSS')],
      ),
    );
    store.addSession(_session(daysAgo: 7, rounds: 3));
    await tester.pumpAndSettle();

    // The whole page is laid out (Column in a scroll view), so any overflow
    // in the sections would surface as a test failure here.
    expect(find.text('VOLUME DI ALLENAMENTO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
