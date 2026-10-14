import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.localeCode = 'ru',
    this.notificationsEnabled = false,
    this.notificationsOwner = '',
    this.selectedGroup = 'CS-221',
  });
  final ThemeMode themeMode;
  final String localeCode, selectedGroup, notificationsOwner;
  final bool notificationsEnabled;
  AppSettings copyWith({
    ThemeMode? themeMode,
    String? localeCode,
    bool? notificationsEnabled,
    String? notificationsOwner,
    String? selectedGroup,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    localeCode: localeCode ?? this.localeCode,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    notificationsOwner: notificationsOwner ?? this.notificationsOwner,
    selectedGroup: selectedGroup ?? this.selectedGroup,
  );
}

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences must be overridden'),
);
final appSettingsProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );

class AppSettingsController extends Notifier<AppSettings> {
  Future<void> _pending = Future.value();
  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final themeName = prefs.getString('theme_mode');
    return AppSettings(
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == themeName,
        orElse: () => ThemeMode.system,
      ),
      localeCode: prefs.getString('locale_code') == 'en' ? 'en' : 'ru',
      selectedGroup: prefs.getString('selected_group') ?? 'CS-221',
      notificationsEnabled: prefs.getBool('notifications_enabled') ?? false,
      notificationsOwner: prefs.getString('notifications_owner') ?? '',
    );
  }

  Future<void> _save(
    Future<bool> Function(SharedPreferences) write,
    AppSettings Function(AppSettings) update,
  ) {
    final prefs = ref.read(sharedPreferencesProvider);
    final operation = _pending.then((_) async {
      if (!await write(prefs)) {
        throw const FormatException('Не удалось сохранить настройки');
      }
      if (ref.mounted) state = update(state);
    });
    _pending = operation.catchError((Object _) {});
    return operation;
  }

  Future<void> setLocale(String code) => _save(
    (prefs) => prefs.setString('locale_code', code == 'en' ? 'en' : 'ru'),
    (value) => value.copyWith(localeCode: code == 'en' ? 'en' : 'ru'),
  );
  Future<void> setThemeMode(ThemeMode mode) => _save(
    (prefs) => prefs.setString('theme_mode', mode.name),
    (value) => value.copyWith(themeMode: mode),
  );
  Future<void> setSelectedGroup(String group) => _save(
    (prefs) => prefs.setString('selected_group', group),
    (value) => value.copyWith(selectedGroup: group),
  );
  Future<void> setNotifications(bool enabled, {required String owner}) => _save(
    (prefs) async {
      if (!await prefs.setString('notifications_owner', owner)) return false;
      return prefs.setBool('notifications_enabled', enabled);
    },
    (value) => value.copyWith(
      notificationsEnabled: enabled,
      notificationsOwner: owner,
    ),
  );
}
