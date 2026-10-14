import 'package:campus_assistant/l10n/ui_text.dart';
import 'package:campus_assistant/core/data/local_store.dart';
import 'package:campus_assistant/core/domain/local_store.dart';
import 'package:campus_assistant/core/di/storage_providers.dart';

import 'dart:async';

import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/firebase_services.dart';
import 'package:campus_assistant/core/theme/app_theme.dart';
import 'package:campus_assistant/core/theme/campus_tokens.dart';

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
  const _StartupData(this.prefs, this.firebaseError, this.store);
  final SharedPreferences prefs;
  final LocalStore store;
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
    final store = widget.preferencesLoader == null
        ? await HiveLocalStore.open()
        : testStoreFor(prefs);
    await migrateLegacyStorage(prefs, store);
    final firebaseError = await initializeFirebase().timeout(
      const Duration(seconds: 15),
      onTimeout: () =>
          'Firebase не отвечает. Вход недоступен; можно открыть демонстрацию.',
    );
    return _StartupData(prefs, firebaseError, store);
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
            localStoreProvider.overrideWithValue(data.store),
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
        home: Builder(
          builder: (context) => Scaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(CampusTokens.of(context).space24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.school_rounded,
                        size: CampusTokens.of(context).categoryDiameter,
                        color: CampusTokens.of(context).accent,
                      ),
                      SizedBox(height: CampusTokens.of(context).space16),
                      Text(
                        'Campus Assistant',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: CampusTokens.of(context).space24),
                      if (!snapshot.hasError) ...[
                        const CircularProgressIndicator(),
                        SizedBox(height: CampusTokens.of(context).space16),
                        Text(tr(context, 'Загружаем настройки…')),
                      ] else ...[
                        Text(
                          tr(
                            context,
                            'Не удалось загрузить локальные данные. Проверьте доступ к хранилищу браузера и повторите попытку.',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: CampusTokens.of(context).space16),
                        FilledButton(
                          onPressed: () {
                            final retry = load();
                            setState(() {
                              startup = retry;
                            });
                          },
                          child: Text(tr(context, 'Повторить')),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
