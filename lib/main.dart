import 'package:campus_assistant/features/schedule/presentation/entity_detail_screen.dart';
import 'package:campus_assistant/core/theme/campus_tokens.dart';
import 'package:campus_assistant/learning/design/design_showcase_screen.dart';
import 'package:campus_assistant/core/di/sync_providers.dart';
import 'package:campus_assistant/l10n/app_localizations.dart';
import 'package:campus_assistant/core/router/routes.dart';
import 'package:campus_assistant/core/presentation/not_found_screen.dart';
import 'package:campus_assistant/learning/week3/favorite_demos.dart';
import 'package:campus_assistant/core/presentation/startup_screen.dart';
import 'package:campus_assistant/core/data/notifications.dart';

import 'package:campus_assistant/features/profile/presentation/auth_screen.dart';
export 'package:campus_assistant/features/profile/presentation/auth_screen.dart';
import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/core/theme/app_theme.dart';
import 'package:campus_assistant/features/feed/presentation/feed_screen.dart';
import 'package:campus_assistant/features/feed/presentation/detail_screen.dart';
import 'package:campus_assistant/features/home/presentation/home_screen.dart';
import 'package:campus_assistant/features/map/presentation/map_screen.dart';
import 'package:campus_assistant/features/profile/presentation/profile_screen.dart';
import 'package:campus_assistant/features/schedule/presentation/schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CampusBootstrap(child: CampusAssistantApp()));
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(ref.read(authControllerProvider));
  ref.listen(authControllerProvider, (_, value) => refresh.value = value);
  final router = GoRouter(
    initialLocation: Routes.paths[Routes.login],
    errorBuilder: (_, _) => const NotFoundScreen(),
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(authControllerProvider);
      if (session == SessionMode.signedOut &&
          state.matchedLocation != Routes.paths[Routes.login]!) {
        return Routes.paths[Routes.login]!;
      }
      if (session != SessionMode.signedOut &&
          state.matchedLocation == Routes.paths[Routes.login]!) {
        return Routes.paths[Routes.home]!;
      }
      return null;
    },
    routes: [
      GoRoute(
        name: Routes.design,
        path: Routes.paths[Routes.design]!,
        builder: (_, _) => const DesignShowcaseScreen(),
      ),
      GoRoute(
        name: Routes.week3,
        path: Routes.paths[Routes.week3]!,
        builder: (_, _) => const Week3Screen(),
      ),
      GoRoute(
        name: Routes.login,
        path: Routes.paths[Routes.login]!,
        builder: (_, _) => const LoginScreen(),
      ),
      for (final kind in [Routes.news, Routes.event, Routes.lesson])
        GoRoute(
          name: kind,
          path: Routes.paths[kind]!,
          builder: (_, state) =>
              DetailScreen(kind: kind, id: state.pathParameters['id']!),
        ),
      for (final kind in [Routes.subject, Routes.teacher])
        GoRoute(
          name: kind,
          path: Routes.paths[kind]!,
          builder: (_, state) =>
              EntityDetailScreen(kind: kind, id: state.pathParameters['id']!),
        ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: Routes.home,
                path: Routes.paths[Routes.home]!,
                builder: (_, _) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: Routes.schedule,
                path: Routes.paths[Routes.schedule]!,
                builder: (_, _) => const ScheduleScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: Routes.feed,
                path: Routes.paths[Routes.feed]!,
                builder: (_, state) => FeedScreen(
                  initialEvents: state.uri.queryParameters['tab'] == 'events',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: Routes.map,
                path: Routes.paths[Routes.map]!,
                builder: (_, state) => MapScreen(
                  room: state.uri.queryParameters['room'],
                  building: state.uri.queryParameters['building'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: Routes.profile,
                path: Routes.paths[Routes.profile]!,
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

final messengerKey = GlobalKey<ScaffoldMessengerState>();

class CampusAssistantApp extends ConsumerWidget {
  const CampusAssistantApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(userSyncCoordinatorProvider);
    ref.listen(notificationRoutesProvider, (_, value) {
      value.whenData(
        (destination) => ref
            .read(routerProvider)
            .goNamed(
              destination.name,
              pathParameters: destination.pathParameters,
              queryParameters: destination.queryParameters,
            ),
      );
    });
    ref.listen(notificationMessagesProvider, (_, value) {
      value.whenData(
        (text) => messengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(text)),
        ),
      );
    });
    return MaterialApp.router(
      scaffoldMessengerKey: messengerKey,
      title: 'Campus Assistant',
      locale: Locale(ref.watch(appSettingsProvider).localeCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(appSettingsProvider).themeMode,
      themeAnimationDuration: CampusTokens.light.motionDuration(context),
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;
  static const icons = [
    Icons.home_rounded,
    Icons.calendar_today_rounded,
    Icons.article_rounded,
    Icons.near_me_rounded,
    Icons.person_outline_rounded,
  ];
  static const activeIcons = [
    Icons.home_rounded,
    Icons.calendar_today_rounded,
    Icons.article_rounded,
    Icons.near_me_rounded,
    Icons.person_rounded,
  ];
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final l10n = AppLocalizations.of(context)!;
      final labels = [
        l10n.home,
        l10n.schedule,
        l10n.feed,
        l10n.navMap,
        l10n.navProfile,
      ];
      final t = CampusTokens.of(context);
      final wide = constraints.maxWidth >= t.wideBreakpoint;
      return Scaffold(
        body: wide
            ? Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(t.cardRadius),
                    child: NavigationRail(
                      selectedIndex: navigationShell.currentIndex,
                      labelType: NavigationRailLabelType.all,
                      onDestinationSelected: navigationShell.goBranch,
                      leading: Padding(
                        padding: EdgeInsets.symmetric(vertical: t.space24),
                        child: Icon(Icons.school_rounded),
                      ),
                      destinations: List.generate(
                        labels.length,
                        (i) => NavigationRailDestination(
                          icon: Icon(icons[i]),
                          selectedIcon: Icon(activeIcons[i]),
                          label: Text(labels[i]),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: navigationShell),
                ],
              )
            : navigationShell,
        bottomNavigationBar: wide
            ? null
            : DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(t.cardRadius),
                  ),
                  child: NavigationBar(
                    selectedIndex: navigationShell.currentIndex,
                    onDestinationSelected: navigationShell.goBranch,
                    destinations: List.generate(
                      labels.length,
                      (i) => NavigationDestination(
                        icon: Icon(icons[i], size: 22),
                        selectedIcon: Icon(activeIcons[i], size: 22),
                        label: labels[i],
                      ),
                    ),
                  ),
                ),
              ),
      );
    },
  );
}
