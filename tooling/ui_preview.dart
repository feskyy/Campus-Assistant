// Isolated visual-review entry point. Production authentication is unchanged.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_assistant/main.dart';
import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/router/routes.dart';
import 'package:campus_assistant/core/data/firebase_services.dart';
import 'package:campus_assistant/core/data/campus_state.dart';
import 'package:campus_assistant/core/data/local_store.dart';
import 'package:campus_assistant/core/di/storage_providers.dart';

class PreviewSession extends AuthController {
  @override
  SessionMode build() => Uri.base.queryParameters['screen'] == Routes.login
      ? SessionMode.signedOut
      : SessionMode.demo;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final store = await HiveLocalStore.open();
  final previewTime = DateTime.tryParse(Uri.base.queryParameters['at'] ?? '');
  await prefs.setString(
    'locale_code',
    Uri.base.queryParameters['locale'] ?? 'ru',
  );
  await prefs.setString(
    'theme_mode',
    Uri.base.queryParameters['theme'] ?? 'light',
  );
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      localStoreProvider.overrideWithValue(store),
      firebaseReadyProvider.overrideWithValue(true),
      authControllerProvider.overrideWith(PreviewSession.new),
      firebaseUserProvider.overrideWith((ref) => Stream.value(null)),
      if (previewTime != null)
        clockProvider.overrideWith((ref) => Stream.value(previewTime)),
    ],
  );
  if (Uri.base.queryParameters['screen'] != Routes.login) {
    container.read(authControllerProvider.notifier).enterDemo();
  }
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const CampusAssistantApp(),
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final screen = Uri.base.queryParameters['screen'] ?? Routes.home;
    container
        .read(routerProvider)
        .goNamed(
          screen,
          pathParameters:
              screen == Routes.lesson ||
                  screen == Routes.subject ||
                  screen == Routes.teacher ||
                  screen == Routes.news ||
                  screen == Routes.event
              ? {'id': Uri.base.queryParameters['id'] ?? 'l1'}
              : {},
          queryParameters: screen == Routes.map
              ? {
                  if (Uri.base.queryParameters['building'] != null)
                    'building': Uri.base.queryParameters['building']!,
                  if (Uri.base.queryParameters['room'] != null)
                    'room': Uri.base.queryParameters['room']!,
                }
              : {},
        );
  });
}
