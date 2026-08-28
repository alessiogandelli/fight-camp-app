import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app_args.dart';
import 'data/store.dart';
import 'l10n/app_localizations.dart';
import 'lib/haptics.dart';
import 'models/types.dart';
import 'pages/combos_page.dart';
import 'pages/combo_builder_page.dart';
import 'pages/complete_page.dart';
import 'pages/live_page.dart';
import 'pages/progress_page.dart';
import 'pages/settings_page.dart';
import 'pages/stretch_routine_builder_page.dart';
import 'pages/train_page.dart';
import 'pages/workouts_page.dart';
import 'pages/workout_builder_page.dart';
import 'ui/theme.dart';
import 'ui/toast.dart';
import 'ui/widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(overlayStyle);
  // The app is portrait-only except on the live session screen, which
  // unlocks landscape for bag-side propping (see LivePage).
  SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
  runApp(const FightCampApp());
}

class FightCampApp extends StatelessWidget {
  const FightCampApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureProvider<AppStore?>(
      create: (_) => AppStore.create(),
      initialData: null,
      child: Consumer<AppStore?>(builder: (context, store, _) {
        if (store == null) {
          return MaterialApp(
            theme: buildTheme(),
            home: const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.accent))),
          );
        }
        return ChangeNotifierProvider.value(
          value: store,
          child: Consumer<AppStore>(builder: (context, s, _) {
            return MaterialApp.router(
              routerConfig: _router,
              theme: buildTheme(),
              // The store's language (system-detected on first launch, then
              // user-settable) drives localization for both lookup systems.
              locale: Locale(s.lang.code),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => ToastProvider(child: child ?? const SizedBox.shrink()),
            );
          }),
        );
      }),
    );
  }
}

final _rootKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => ShellScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/', builder: (_, __) => const TrainPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/workouts',
            builder: (_, __) => const WorkoutsPage(),
            routes: [
              GoRoute(path: 'new', builder: (_, __) => const WorkoutBuilderPage()),
              GoRoute(path: ':id', builder: (_, s) => WorkoutBuilderPage(workoutId: s.pathParameters['id'])),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/library',
            builder: (_, __) => const CombosPage(),
            routes: [
              GoRoute(path: 'new', builder: (_, __) => ComboBuilderPage()),
              GoRoute(path: ':id', builder: (_, s) => ComboBuilderPage(comboId: s.pathParameters['id'])),
              GoRoute(
                path: 'routine',
                builder: (_, __) => const StretchRoutineBuilderPage(),
                routes: [
                  GoRoute(path: 'new', builder: (_, __) => const StretchRoutineBuilderPage()),
                  GoRoute(path: ':id', builder: (_, s) => StretchRoutineBuilderPage(routineId: s.pathParameters['id'])),
                ],
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/progress', builder: (_, __) => const ProgressPage()),
        ]),
      ],
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootKey,
      builder: (_, __) => const SettingsPage(),
    ),
    GoRoute(
      path: '/live',
      parentNavigatorKey: _rootKey,
      builder: (_, s) {
        final args = s.extra as LiveArgs?;
        return LivePage(config: args?.config, resumeElapsedMs: args?.resumeElapsedMs);
      },
    ),
    GoRoute(
      path: '/complete',
      parentNavigatorKey: _rootKey,
      builder: (_, s) {
        final args = s.extra as CompleteArgs?;
        return CompletePage(args: args);
      },
    ),
  ],
);

const _tabs = <String, ({IconData icon, String Function(AppLocalizations l) label})>{
  '/': (icon: Icons.flash_on_rounded, label: _navTrain),
  '/workouts': (icon: Icons.calendar_month_rounded, label: _navWorkouts),
  '/library': (icon: Icons.format_list_numbered_rounded, label: _navLibrary),
  '/progress': (icon: Icons.bar_chart_rounded, label: _navProgress),
};

String _navTrain(AppLocalizations l) => l.navTrain;
String _navWorkouts(AppLocalizations l) => l.navWorkouts;
String _navLibrary(AppLocalizations l) => l.navLibrary;
String _navProgress(AppLocalizations l) => l.navProgress;

class ShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const ShellScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    context.watch<AppStore>();
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              decoration: const BoxDecoration(
                color: Color(0xE609090B),
                border: Border(bottom: BorderSide(color: AppColors.line)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/'),
                    child: const Text.rich(
                      TextSpan(text: 'FIGHT ', children: [TextSpan(text: 'CAMP', style: TextStyle(color: AppColors.accent))]),
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1.5),
                    ),
                  ),
                  const Spacer(),
                  IconButton2(Icons.settings_outlined, size: 22, onTap: () => context.push('/settings')),
                ],
              ),
            ),
            Expanded(child: navigationShell),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.panel,
          indicatorColor: Colors.transparent,
          height: 64,
          labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: states.contains(WidgetState.selected) ? AppColors.accent : AppColors.mut,
              )),
          iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
                size: 22,
                color: states.contains(WidgetState.selected) ? AppColors.accent : AppColors.mut,
              )),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (i) {
            Haptics.selection();
            navigationShell.goBranch(
              i,
              initialLocation: i == navigationShell.currentIndex,
            );
          },
          destinations: [
            for (final e in _tabs.entries)
              NavigationDestination(
                icon: Icon(e.value.icon),
                selectedIcon: Icon(e.value.icon),
                label: e.value.label(l).toUpperCase(),
              ),
          ],
        ),
      ),
    );
  }
}
