// Widget tests for the redesigned Progress dashboard, log and detail sheet.
import 'package:fight_camp/data/store.dart';
import 'package:fight_camp/l10n/app_localizations.dart';
import 'package:fight_camp/main.dart';
import 'package:fight_camp/models/seed.dart';
import 'package:fight_camp/models/types.dart';
import 'package:fight_camp/pages/progress_page.dart';
import 'package:fight_camp/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

DateTime _day(int offset, int hour) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + offset, hour);
}

SessionRecord _session({
  required String id,
  required String group,
  required DateTime start,
  required int durationSec,
  required WorkoutType type,
  required String name,
  String source = 'timer',
  int? rounds,
  int? rpe,
  int load = 0,
  RunningExtra? running,
  List<NameRef>? combos,
  List<StrengthEntry>? strength,
  String? notes,
}) => SessionRecord(
  id: id,
  date: start.millisecondsSinceEpoch + durationSec * 1000,
  type: type,
  source: source,
  name: name,
  roundsCompleted: rounds,
  duration: durationSec,
  rpe: rpe,
  load: load,
  running: running,
  combosUsed: combos,
  strength: strength,
  notes: notes,
  groupId: group,
);

({List<SessionRecord> sessions, List<HealthLink> links}) _fixture({
  bool uncategorized = false,
}) {
  final bagStart = _day(0, 8);
  final runStart = _day(-1, 18);
  final oldStrengthStart = _day(-40, 10);
  final sessions = [
    _session(
      id: 'warm',
      group: 'bag-training',
      start: bagStart,
      durationSec: 10 * 60,
      type: WorkoutType.conditioning,
      name: 'WARM UP',
    ),
    _session(
      id: 'bag',
      group: 'bag-training',
      start: bagStart.add(const Duration(minutes: 12)),
      durationSec: 30 * 60,
      type: WorkoutType.heavyBag,
      name: 'BAG',
      rounds: 6,
      rpe: 8,
      load: 240,
      combos: const [NameRef('c1', 'JAB CROSS')],
    ),
    _session(
      id: 'stretch',
      group: 'bag-training',
      start: bagStart.add(const Duration(minutes: 45)),
      durationSec: 10 * 60,
      type: WorkoutType.stretching,
      name: 'STRETCH',
    ),
    _session(
      id: 'run',
      group: 'run-training',
      start: runStart,
      durationSec: 30 * 60,
      type: WorkoutType.running,
      name: 'EASY RUN',
      source: 'health',
      running: const RunningExtra(distanceKm: 5, paceSecPerKm: 360),
    ),
    _session(
      id: 'strength',
      group: 'strength-training',
      start: oldStrengthStart,
      durationSec: 45 * 60,
      type: WorkoutType.strength,
      name: 'LIFT',
      source: 'manual',
      strength: const [
        StrengthEntry(exercise: 'bench press', sets: 3, reps: 8),
      ],
      notes: 'shoulder felt good',
    ),
    if (uncategorized)
      _session(
        id: 'unknown',
        group: 'unknown-training',
        start: _day(-2, 12),
        durationSec: 20 * 60,
        type: WorkoutType.other,
        name: 'UNKNOWN',
      ),
  ];
  final links = [
    HealthLink(
      externalId: 'health-run',
      groupId: 'run-training',
      start: runStart.millisecondsSinceEpoch,
      end: runStart.millisecondsSinceEpoch + 30 * 60 * 1000,
      activity: 'RUNNING',
      sourceName: 'Watch',
      distanceKm: 5,
      energyKcal: 320,
      avgHr: 150,
    ),
  ];
  return (sessions: sessions, links: links);
}

AppStore _store({
  required List<SessionRecord> sessions,
  List<HealthLink> links = const [],
  Lang lang = Lang.it,
}) {
  final seed = seedData();
  return AppStore(
    AppData(
      version: seed.version,
      techniques: seed.techniques,
      combinations: seed.combinations,
      workouts: seed.workouts,
      sessions: sessions,
      plans: seed.plans,
      settings: seed.settings,
      healthLinks: links,
    ),
    lang,
  );
}

Future<AppStore> _pumpProgress(
  WidgetTester tester, {
  List<SessionRecord> sessions = const [],
  List<HealthLink> links = const [],
  Size size = const Size(900, 2400),
  Lang lang = Lang.it,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final store = _store(sessions: sessions, links: links, lang: lang);
  await tester.pumpWidget(
    ChangeNotifierProvider<AppStore>.value(
      value: store,
      child: MaterialApp(
        theme: buildTheme(),
        locale: Locale(lang.code),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: ProgressPage()),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return store;
}

void main() {
  testWidgets('empty Progress has one intentional empty state', (tester) async {
    await _pumpProgress(tester);

    expect(find.text('PROGRESSI'), findsOneWidget);
    expect(find.text('Nessun allenamento'), findsOneWidget);
    expect(find.text('REGISTRA UNA SESSIONE'), findsOneWidget);
    expect(find.text('4 settimane'), findsOneWidget);
  });

  testWidgets('dashboard shows summary, goal, load, activity and mix', (
    tester,
  ) async {
    final f = _fixture();
    await _pumpProgress(tester, sessions: f.sessions, links: f.links);

    expect(find.text('TEMPO DI ALLENAMENTO'), findsOneWidget);
    expect(find.text('ALLENAMENTI'), findsOneWidget);
    expect(find.text('GIORNI ATTIVI'), findsOneWidget);
    expect(find.text('OBIETTIVO SETTIMANALE'), findsOneWidget);
    expect(find.text('CARICO · MEDIA SETTIMANA'), findsOneWidget);
    expect(find.text('Dati insufficienti'), findsOneWidget);
    expect(find.text('ATTIVITÀ'), findsOneWidget);
    expect(find.text('TIPI DI ALLENAMENTO'), findsOneWidget);
    expect(find.text('DIARIO'), findsOneWidget);

    // Mix durations use real values, never placeholder markup.
    expect(find.text('[h m]'), findsNothing);
    expect(find.textContaining('50m'), findsWidgets);

    // The old unrelated dashboard cards are gone.
    expect(find.text('COSTANZA'), findsNothing);
    expect(find.text('PROGRESSO'), findsNothing);
    expect(find.text('RECORD PERSONALI'), findsNothing);
    expect(find.text('VOLUME DI ALLENAMENTO'), findsNothing);
  });

  testWidgets('period menu changes the dashboard range', (tester) async {
    final f = _fixture();
    await _pumpProgress(tester, sessions: f.sessions, links: f.links);

    expect(find.text('LIFT'), findsNothing);
    await tester.tap(find.text('4 settimane'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tutto'));
    await tester.pumpAndSettle();

    expect(find.text('LIFT'), findsWidgets);
    expect(find.text('Tutto'), findsOneWidget);
  });

  testWidgets('tapping a day filters the log and shows the day chip', (
    tester,
  ) async {
    final f = _fixture();
    await _pumpProgress(tester, sessions: f.sessions, links: f.links);
    final today = _day(0, 8);

    await tester.tap(find.byKey(ValueKey('progress-day-${_key(today)}')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('log-filter-selected-day')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('log-training-bag-training')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('log-training-run-training')),
      findsNothing,
    );
  });

  testWidgets('training mix opens the log filtered to that type', (
    tester,
  ) async {
    final f = _fixture();
    await _pumpProgress(tester, sessions: f.sessions, links: f.links);

    await tester.tap(find.byKey(const ValueKey('progress-mix-running')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('log-training-run-training')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('log-training-bag-training')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('log-filter-running')), findsOneWidget);
  });

  testWidgets('log type chip filters without opening a new page', (
    tester,
  ) async {
    final f = _fixture();
    await _pumpProgress(tester, sessions: f.sessions, links: f.links);
    await tester.ensureVisible(
      find.byKey(const ValueKey('log-filter-running')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('log-filter-running')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('log-training-run-training')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('log-training-bag-training')),
      findsNothing,
    );
    expect(find.byIcon(Icons.arrow_back), findsNothing);
  });

  testWidgets('filter sheet applies search and source filters', (tester) async {
    final f = _fixture();
    await _pumpProgress(tester, sessions: f.sessions, links: f.links);
    await tester.tap(find.text('4 settimane'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tutto'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    expect(find.text('FILTRI'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'shoulder');
    await tester.tap(find.text('SALVA'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('log-training-strength-training')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('log-training-bag-training')),
      findsNothing,
    );

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apple Salute'));
    await tester.enterText(find.byType(TextField).last, '');
    await tester.tap(find.text('SALVA'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('log-training-run-training')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('log-training-strength-training')),
      findsNothing,
    );
  });

  testWidgets('uncategorized banner lets the user classify sessions', (
    tester,
  ) async {
    final f = _fixture(uncategorized: true);
    await _pumpProgress(tester, sessions: f.sessions, links: f.links);

    expect(find.text('1 sessione non classificata'), findsOneWidget);
    await tester.tap(find.text('Classificale'));
    await tester.pumpAndSettle();
    expect(find.text('CLASSIFICA SESSIONI'), findsOneWidget);

    await tester.tap(find.text('Scegli tipo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('🥊 Sacco pesante').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('SALVA CLASSIFICAZIONE'));
    await tester.pumpAndSettle();

    expect(find.text('1 sessione non classificata'), findsNothing);
  });

  testWidgets('run log row opens the rich, opaque detail sheet', (
    tester,
  ) async {
    final f = _fixture();
    await _pumpProgress(tester, sessions: f.sessions, links: f.links);
    await tester.ensureVisible(
      find.byKey(const ValueKey('log-training-run-training')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('log-training-run-training')));
    await tester.pumpAndSettle();

    expect(find.text('EASY RUN'), findsWidgets);
    expect(find.text('DISTANZA'), findsWidgets);
    expect(find.text('5.0 km'), findsWidgets);
    expect(find.text('PACE'), findsOneWidget);
    expect(find.text('6:00 /km'), findsOneWidget);
    expect(find.text('FC MEDIA'), findsOneWidget);
    expect(find.text('ENERGIA'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('JAB CROSS'), findsNothing);
  });

  testWidgets('training detail exposes sessions and add-note action', (
    tester,
  ) async {
    final f = _fixture();
    await _pumpProgress(tester, sessions: f.sessions, links: f.links);
    await tester.ensureVisible(
      find.byKey(const ValueKey('log-training-bag-training')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('log-training-bag-training')));
    await tester.pumpAndSettle();

    expect(find.text('SESSIONI'), findsOneWidget);
    expect(find.text('AGGIUNGI UNA NOTA'), findsOneWidget);
    expect(find.text('JAB CROSS'), findsOneWidget);
    expect(find.text('RPE 8'), findsNothing);
  });

  testWidgets('Overview and Log live on /progress without a History route', (
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
    final navContext = tester.element(find.byType(Text).first);
    GoRouter.of(navContext).go('/progress');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final context = tester.element(find.byType(ProgressPage));
    expect(
      GoRouter.of(context).routerDelegate.currentConfiguration.uri.path,
      '/progress',
    );
    expect(find.byIcon(Icons.arrow_back), findsNothing);
  });

  testWidgets('English labels are localized', (tester) async {
    await _pumpProgress(tester, lang: Lang.en);

    expect(find.text('PROGRESS'), findsOneWidget);
    expect(find.text('4 weeks'), findsOneWidget);
    expect(find.text('No workouts'), findsOneWidget);
  });

  testWidgets('dashboard lays out without overflow on a narrow phone', (
    tester,
  ) async {
    final f = _fixture(uncategorized: true);
    await _pumpProgress(
      tester,
      sessions: f.sessions,
      links: f.links,
      size: const Size(320, 640),
    );

    expect(find.text('TEMPO DI ALLENAMENTO'), findsOneWidget);
    expect(find.text('Classificale'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail sheet lays out without overflow on a narrow phone', (
    tester,
  ) async {
    final f = _fixture();
    await _pumpProgress(
      tester,
      sessions: f.sessions,
      links: f.links,
      size: const Size(320, 640),
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('log-training-run-training')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('log-training-run-training')));
    await tester.pumpAndSettle();

    expect(find.text('EASY RUN'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('period arrows navigate to previous blocks and back', (
    tester,
  ) async {
    final today = _day(0, 8);
    final previous = _day(-45, 9);
    final anchor = _day(-75, 9);
    final sessions = [
      _session(
        id: 'now',
        group: 'now',
        start: today,
        durationSec: 30 * 60,
        type: WorkoutType.heavyBag,
        name: 'NOW',
      ),
      _session(
        id: 'previous',
        group: 'previous',
        start: previous,
        durationSec: 30 * 60,
        type: WorkoutType.muayThai,
        name: 'PREVIOUS BLOCK',
      ),
      _session(
        id: 'anchor',
        group: 'anchor',
        start: anchor,
        durationSec: 20 * 60,
        type: WorkoutType.running,
        name: 'OLDER',
      ),
    ];
    await _pumpProgress(tester, sessions: sessions);

    expect(find.byKey(const ValueKey('log-training-now')), findsOneWidget);
    expect(find.byKey(const ValueKey('log-training-previous')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('progress-period-back')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('log-training-now')), findsNothing);
    expect(find.byKey(const ValueKey('log-training-previous')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('progress-period-forward')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('log-training-now')), findsOneWidget);
  });
}

String _key(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
