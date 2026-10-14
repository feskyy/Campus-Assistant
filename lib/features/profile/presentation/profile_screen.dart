import 'package:campus_assistant/shared/widgets/ui/ui.dart' as ui;
import 'package:campus_assistant/core/theme/campus_tokens.dart';
import 'package:campus_assistant/l10n/ui_text.dart';
import 'package:campus_assistant/l10n/app_localizations.dart';
import 'package:campus_assistant/core/di/firebase_providers.dart';
import 'package:campus_assistant/core/router/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_assistant/core/data/notifications.dart';
import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/core/data/firebase_services.dart';
import 'package:campus_assistant/shared/widgets/page_body.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<ProfileScreen> {
  bool busy = false;
  Future<void> perform(Future<void> Function() action) async {
    setState(() => busy = true);
    try {
      await action();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(authError(error))));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final authenticated =
        ref.watch(authControllerProvider) == SessionMode.authenticated;
    final users = ref.watch(userRepositoryProvider);
    final user = authenticated ? users.currentUser : null;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.profileTitle)),
      body: PageBody(
        maxWidth: 680,
        child: ListView(
          padding: EdgeInsets.all(CampusTokens.of(context).space16),
          children: [
            ui.CampusCard(
              padding: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(
                  CampusTokens.of(context).space16 +
                      CampusTokens.of(context).space4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.person_outline_rounded,
                            size: 28,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        SizedBox(width: CampusTokens.of(context).space16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName ?? tr(context, 'Гость'),
                                style: theme.textTheme.titleLarge,
                              ),
                              SizedBox(height: CampusTokens.of(context).space4),
                              Text(
                                user?.email ??
                                    tr(context, 'Демонстрационный режим'),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (user != null) ...[
                      SizedBox(height: CampusTokens.of(context).space16),
                      StreamBuilder<String?>(
                        stream: users.watchName(user.uid),
                        builder: (context, snapshot) => Text(
                          snapshot.hasError
                              ? tr(
                                  context,
                                  'Не удалось загрузить профиль Firestore',
                                )
                              : snapshot.data ??
                                    user.displayName ??
                                    tr(context, 'Имя не указано'),
                        ),
                      ),
                      TextButton(
                        onPressed: busy
                            ? null
                            : () async {
                                final controller = TextEditingController(
                                  text: user.displayName,
                                );
                                final name = await showDialog<String>(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    title: Text(tr(context, 'Имя')),
                                    content: TextField(
                                      controller: controller,
                                      maxLength: 100,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext),
                                        child: Text(tr(context, 'Отмена')),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (controller.text
                                              .trim()
                                              .isNotEmpty) {
                                            Navigator.pop(
                                              dialogContext,
                                              controller.text.trim(),
                                            );
                                          }
                                        },
                                        child: Text(tr(context, 'Сохранить')),
                                      ),
                                    ],
                                  ),
                                );
                                controller.dispose();
                                if (name != null && mounted) {
                                  await perform(() async {
                                    await users.updateName(user.uid, name);
                                  });
                                }
                              },
                        child: Text(tr(context, 'Изменить имя')),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(
              height:
                  CampusTokens.of(context).space8 +
                  CampusTokens.of(context).space4,
            ),
            _SettingsGroup(
              title: tr(context, 'Учёба'),
              children: [
                ListTile(
                  leading: const Icon(Icons.people_outline_rounded),
                  title: Text(tr(context, 'Выбранная группа')),
                  subtitle: Text(settings.selectedGroup),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.goNamed(Routes.schedule),
                ),
              ],
            ),
            _SettingsGroup(
              title: tr(context, 'Приложение'),
              children: [
                ListTile(
                  leading: const Icon(Icons.contrast_rounded),
                  title: Text(tr(context, 'Тема')),
                  subtitle: ui.SegmentedPill<ThemeMode>(
                    value: settings.themeMode,
                    options: [
                      ui.SegmentOption(
                        value: ThemeMode.system,
                        label: tr(context, 'Системная'),
                      ),
                      ui.SegmentOption(
                        value: ThemeMode.light,
                        label: tr(context, 'Светлая'),
                      ),
                      ui.SegmentOption(
                        value: ThemeMode.dark,
                        label: tr(context, 'Тёмная'),
                      ),
                    ],
                    onChanged: (value) => perform(
                      () => ref
                          .read(appSettingsProvider.notifier)
                          .setThemeMode(value),
                    ),
                  ),
                ),
                const Divider(indent: 56),
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: Text(AppLocalizations.of(context)!.language),
                  subtitle: DropdownButton<String>(
                    value: settings.localeCode,
                    items: const [
                      DropdownMenuItem(value: 'ru', child: Text('Русский')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        perform(
                          () => ref
                              .read(appSettingsProvider.notifier)
                              .setLocale(value),
                        );
                      }
                    },
                  ),
                ),
                const Divider(indent: 56),
                if (user != null && androidPushSupported)
                  SwitchListTile(
                    title: Text(tr(context, 'Push-уведомления')),
                    secondary: const Icon(Icons.notifications_none_rounded),
                    value:
                        settings.notificationsEnabled &&
                        settings.notificationsOwner == user.uid,
                    onChanged: busy
                        ? null
                        : (enabled) => perform(() async {
                            await ref
                                .read(notificationServiceProvider)
                                .setEnabled(user.uid, enabled);
                            await ref
                                .read(appSettingsProvider.notifier)
                                .setNotifications(enabled, owner: user.uid);
                          }),
                  )
                else
                  ListTile(
                    leading: Icon(Icons.notifications_none_rounded),
                    title: Text(tr(context, 'Push-уведомления недоступны')),
                    subtitle: Text(tr(context, 'Подключение ещё не настроено')),
                  ),
              ],
            ),
            _SettingsGroup(
              title: tr(context, 'Информация'),
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_rounded),
                  title: Text(strings(context).designTitle),
                  onTap: () => context.pushNamed(Routes.design),
                ),
                ListTile(
                  title: Text(tr(context, 'Неделя 3: состояние')),
                  onTap: () => context.pushNamed(Routes.week3),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: Text(tr(context, 'О приложении')),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Campus Assistant',
                    applicationVersion: '1.0.0',
                    applicationIcon: Icon(
                      Icons.school_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    children: [
                      Text(
                        tr(
                          context,
                          'Расписание, новости и каталог кампуса. Демонстрационные данные отмечены отдельно.',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (busy) const LinearProgressIndicator(),
            SizedBox(height: CampusTokens.of(context).space8),
            OutlinedButton.icon(
              icon: const Icon(Icons.logout_rounded),
              onPressed: busy
                  ? null
                  : () => perform(
                      () => ref.read(authControllerProvider.notifier).signOut(),
                    ),
              label: Text(
                authenticated
                    ? tr(context, 'Выйти из аккаунта')
                    : tr(context, 'Завершить демонстрацию'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: CampusTokens.of(context).space16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: CampusTokens.of(context).space4,
            bottom: CampusTokens.of(context).space8,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ui.CampusCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    ),
  );
}
