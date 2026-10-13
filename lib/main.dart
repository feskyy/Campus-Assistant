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
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(authControllerProvider);
      if (session == SessionMode.signedOut &&
          state.matchedLocation != '/login') {
        return '/login';
      }
      if (session != SessionMode.signedOut &&
          state.matchedLocation == '/login') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      for (final kind in ['news', 'event', 'lesson'])
        GoRoute(
          path: '/$kind/:id',
          builder: (_, state) =>
              DetailScreen(kind: kind, id: state.pathParameters['id']!),
        ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/schedule',
                builder: (_, _) => const ScheduleScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/feed',
                builder: (_, state) => FeedScreen(
                  initialEvents: state.uri.queryParameters['tab'] == 'events',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/map', builder: (_, _) => const MapScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
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
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(appSettingsProvider).themeMode,
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;
  static const labels = [
    'Главная',
    'Расписание',
    'Лента',
    'Каталог',
    'Настройки',
  ];
  static const icons = [
    Icons.home_outlined,
    Icons.calendar_today_outlined,
    Icons.article_outlined,
    Icons.near_me_outlined,
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
      final wide = constraints.maxWidth >= 840;
      return Scaffold(
        body: wide
            ? Row(
                children: [
                  NavigationRail(
                    selectedIndex: navigationShell.currentIndex,
                    labelType: NavigationRailLabelType.all,
                    onDestinationSelected: navigationShell.goBranch,
                    leading: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Icon(Icons.school_outlined),
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
      );
    },
  );
}
