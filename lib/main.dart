import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glass_bottom_navigation/glass_bottom_navigation.dart';
import 'package:go_router/go_router.dart';
// `GlassBarItem` also exists in glass_bottom_navigation; hide the unused one.
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart'
    hide GlassBarItem;
import 'package:provider/provider.dart';

import 'app_args.dart';
import 'data/store.dart';
import 'l10n/app_localizations.dart';
import 'models/types.dart';
import 'pages/combos_page.dart';
import 'pages/complete_page.dart';
import 'pages/history_page.dart';
import 'pages/live_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/progress_page.dart';
import 'pages/settings_page.dart';
import 'pages/train_page.dart';
import 'pages/workouts_page.dart';
import 'ui/splash_screen.dart';
import 'ui/theme.dart';
import 'ui/toast.dart';
import 'ui/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(overlayStyle);
  // The app is portrait-only except on the live session screen, which
  // unlocks landscape for bag-side propping (see LivePage).
  SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
  // Pre-warm the liquid glass shaders so the first frame has no white flash.
  await LiquidGlassWidgets.initialize();
  runApp(
    LiquidGlassWidgets.wrap(
      child: const FightCampApp(),
      brightnessResolver: Theme.maybeBrightnessOf,
    ),
  );
}

class FightCampApp extends StatelessWidget {
  const FightCampApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureProvider<AppStore?>(
      create: (_) => AppStore.create(),
      initialData: null,
      child: Consumer<AppStore?>(
        builder: (context, store, _) {
          if (store == null) {
            return MaterialApp(theme: buildTheme(), home: const SplashScreen());
          }
          return ChangeNotifierProvider.value(
            value: store,
            child: Consumer<AppStore>(
              builder: (context, s, _) {
                // Expose the store to the router's redirect so it can gate the
                // first-run onboarding without rebuilding the router.
                _storeRef = s;
                return MaterialApp.router(
                  routerConfig: _router,
                  theme: buildTheme(),
                  // The store's language (system-detected on first launch, then
                  // user-settable) drives localization for both lookup systems.
                  locale: Locale(s.lang.code),
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  builder: (context, child) =>
                      ToastProvider(child: child ?? const SizedBox.shrink()),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

final _rootKey = GlobalKey<NavigatorState>();

/// Set by [FightCampApp] once the store has loaded, so the router can read the
/// onboarding flag synchronously during redirects.
AppStore? _storeRef;

final GoRouter _router = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/',
  redirect: (context, state) {
    final seen = _storeRef?.onboardingSeen ?? true;
    if (!seen && state.matchedLocation != '/onboarding') return '/onboarding';
    return null;
  },
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ShellScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/', builder: (_, __) => const TrainPage())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/workouts',
              builder: (_, __) => const WorkoutsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/library', builder: (_, __) => const CombosPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/progress',
              builder: (_, __) => const ProgressPage(),
              routes: [
                GoRoute(
                  path: 'history',
                  builder: (_, __) => const HistoryPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootKey,
      builder: (_, __) => const SettingsPage(),
    ),
    GoRoute(
      path: '/onboarding',
      parentNavigatorKey: _rootKey,
      builder: (_, __) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/live',
      parentNavigatorKey: _rootKey,
      builder: (_, s) {
        final args = s.extra as LiveArgs?;
        return LivePage(
          config: args?.config,
          resumeElapsedMs: args?.resumeElapsedMs,
          autostart: args?.autostart ?? false,
        );
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

const _tabs =
    <
      String,
      ({
        IconData icon,
        IconData selectedIcon,
        String Function(AppLocalizations l) label,
      })
    >{
      '/': (
        icon: Icons.flash_on_outlined,
        selectedIcon: Icons.flash_on_rounded,
        label: _navTrain,
      ),
      '/workouts': (
        icon: Icons.calendar_month_outlined,
        selectedIcon: Icons.calendar_month_rounded,
        label: _navWorkouts,
      ),
      '/library': (
        icon: Icons.format_list_numbered_outlined,
        selectedIcon: Icons.format_list_numbered_rounded,
        label: _navLibrary,
      ),
      '/progress': (
        icon: Icons.bar_chart_outlined,
        selectedIcon: Icons.bar_chart_rounded,
        label: _navProgress,
      ),
    };

String _navTrain(AppLocalizations l) => l.navTrain;
String _navWorkouts(AppLocalizations l) => l.navWorkouts;
String _navLibrary(AppLocalizations l) => l.navLibrary;
String _navProgress(AppLocalizations l) => l.navProgress;

/// SF Symbols used by the native Liquid Glass bottom bar on iOS 26+. Keys match
/// [_tabs]. Android and iOS < 26 use the Material icons in the Flutter
/// fallback.
const _sfSymbols = <String, String>{
  '/': 'bolt.fill',
  '/workouts': 'calendar',
  '/library': 'list.number',
  '/progress': 'chart.bar.fill',
};

class ShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const ShellScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    context.watch<AppStore>();
    final l = AppLocalizations.of(context)!;
    return GlassScaffold(
      backgroundColor: AppColors.bg,
      statusBarStyle: GlassStatusBarStyle.light,
      extendBody: true,
      // Fade content out more strongly behind the bar so it stays legible.
      bottomEdgeFadeExtent: 40,
      maxSigma: 24,
      // GlassScaffold renders a CupertinoPageScaffold, so pages lose the
      // Material ancestor that a Material Scaffold would provide. A transparent
      // Material keeps InkWell/splash working without painting a background.
      //
      // Every tab shares the same fixed top glow behind the content, and pages
      // run full-bleed to the physical top edge. The frosted header (last in the
      // stack) blurs pages as they scroll under it, so content dissolves into
      // the bar instead of colliding with the wordmark; each page still clears
      // the header with its own top padding at rest.
      body: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: MediaQuery.of(context).padding.top + kHeroGlowHeight,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.glow, AppColors.bg],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(child: navigationShell),
            Positioned(top: 0, left: 0, right: 0, child: _header(context)),
          ],
        ),
      ),
      // Native Apple Liquid Glass on iOS 26+ (real UITabBar with UIGlassEffect);
      // a Flutter glass fallback on Android and iOS < 26.
      //
      // The package hardcodes its icon/label sizes (20 / 11) with no style
      // knobs, so scale the whole bar down slightly instead of forking it. The
      // layout box is unchanged, so the glass clearance metrics still hold.
      bottomBar: Transform.scale(
        scale: 0.88,
        alignment: Alignment.bottomCenter,
        child: GlassBottomBar(
          items: [
            for (final e in _tabs.entries)
              GlassBarItem(
                icon: e.value.icon,
                label: e.value.label(l),
                nativeSymbolName: _sfSymbols[e.key],
              ),
          ],
          currentIndex: navigationShell.currentIndex,
          onTap: (i) => navigationShell.goBranch(
            i,
            initialLocation: i == navigationShell.currentIndex,
          ),
          // Full width so the bar is not left-aligned with a gap on the right.
          style: const GlassBottomNavStyle(
            accent: AppColors.primary,
            radius: 26,
            widthFactor: 1.0,
            edgePadding: 12,
          ),
        ),
      ),
    );
  }

  /// Fixed header that fully occludes page content in the top zone (status bar
  /// + header row), so pages slide *behind* it instead of overlapping the
  /// wordmark. The panel reproduces the shared top glow gradient exactly, so at
  /// rest nothing changes (the home gradient still reaches the screen edge with
  /// no seam at the header's bottom).
  Widget _header(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final panelHeight = top + kAppHeaderHeight;
    // Colour the shared glow has at the panel's bottom edge; using it as the
    // gradient end keeps the panel pixel-identical to the glow behind it.
    final seam = Color.lerp(
      AppColors.glow,
      AppColors.bg,
      panelHeight / (top + kHeroGlowHeight),
    )!;
    return SizedBox(
      height: panelHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.glow, seam],
                ),
              ),
            ),
          ),
          Positioned(
            top: top,
            left: 0,
            right: 0,
            height: kAppHeaderHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/'),
                    child: const Text.rich(
                      TextSpan(
                        text: 'FIGHT ',
                        children: [
                          TextSpan(
                            text: 'CAMP',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton2(
                    Icons.settings_outlined,
                    size: 22,
                    onTap: () => context.push('/settings'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
