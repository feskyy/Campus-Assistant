import 'dart:async';

import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/firebase_services.dart';
import 'package:campus_assistant/core/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Paint immediately; do not wait for plugins before the first app frame.
class CampusBootstrap extends StatefulWidget {
  const CampusBootstrap({
    super.key,
    required this.child,
    this.preferencesLoader,
  });
  final Widget child;
  final Future<SharedPreferences> Function()? preferencesLoader;
  @override
  State<CampusBootstrap> createState() => _BootstrapState();
}

class _StartupData {
  const _StartupData(this.prefs, this.firebaseError);
  final SharedPreferences prefs;
  final String? firebaseError;
}

class _BootstrapState extends State<CampusBootstrap> {
  late Future<_StartupData> startup;
  @override
  void initState() {
    super.initState();
    startup = load();
  }

  Future<_StartupData> load() async {
    final prefs =
        await (widget.preferencesLoader ?? SharedPreferences.getInstance)()
            .timeout(const Duration(seconds: 10));
    final firebaseError = await initializeFirebase().timeout(
      const Duration(seconds: 15),
      onTimeout: () =>
          'Firebase не отвечает. Вход недоступен; можно открыть демонстрацию.',
    );
    return _StartupData(prefs, firebaseError);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_StartupData>(
    future: startup,
    builder: (context, snapshot) {
      final data = snapshot.data;
      if (data != null) {
        return ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(data.prefs),
            firebaseReadyProvider.overrideWithValue(data.firebaseError == null),
            firebaseErrorProvider.overrideWithValue(data.firebaseError),
          ],
          child: widget.child,
        );
      }
      return MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Campus Assistant',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!snapshot.hasError) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text('Загружаем настройки…'),
                    ] else ...[
                      const Text(
                        'Не удалось загрузить локальные данные. Проверьте доступ к хранилищу браузера и повторите попытку.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          final retry = load();
                          setState(() {
                            startup = retry;
                          });
                        },
                        child: const Text('Повторить'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
