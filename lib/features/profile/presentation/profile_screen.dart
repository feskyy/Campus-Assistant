import 'package:campus_assistant/core/data/notifications.dart';
import 'package:campus_assistant/core/data/app_settings.dart';
import 'package:campus_assistant/core/data/auth_state.dart';
import 'package:campus_assistant/core/data/firebase_services.dart';
import 'package:campus_assistant/shared/widgets/page_body.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final user = authenticated ? FirebaseAuth.instance.currentUser : null;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль и настройки')),
      body: PageBody(
        maxWidth: 680,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName ?? 'Гость',
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? 'Демонстрационный режим',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (user != null) ...[
                      const SizedBox(height: 16),
                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .snapshots(),
                        builder: (context, snapshot) => Text(
                          snapshot.hasError
                              ? 'Не удалось загрузить профиль Firestore'
                              : snapshot.data?.data()?['name'] as String? ??
                                    user.displayName ??
                                    'Имя не указано',
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
                                    title: const Text('Имя'),
                                    content: TextField(
                                      controller: controller,
                                      maxLength: 100,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext),
                                        child: const Text('Отмена'),
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
                                        child: const Text('Сохранить'),
                                      ),
                                    ],
                                  ),
                                );
                                controller.dispose();
                                if (name != null && mounted) {
                                  await perform(() async {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user.uid)
                                        .set({
                                          'name': name,
                                        }, SetOptions(merge: true));
                                    await user.updateDisplayName(name);
                                  });
                                }
                              },
                        child: const Text('Изменить имя'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SettingsGroup(
              title: 'Учёба',
              children: [
                ListTile(
                  leading: const Icon(Icons.people_outline_rounded),
                  title: const Text('Выбранная группа'),
                  subtitle: Text(settings.selectedGroup),
                ),
              ],
            ),
            _SettingsGroup(
              title: 'Приложение',
              children: [
                ListTile(
                  leading: const Icon(Icons.contrast_rounded),
                  title: const Text('Тема'),
                  subtitle: DropdownButton<ThemeMode>(
                    value: settings.themeMode,
                    isExpanded: true,
                    underline: const SizedBox(),
                    onChanged: busy
                        ? null
                        : (value) {
                            if (value != null) {
                              perform(
                                () => ref
                                    .read(appSettingsProvider.notifier)
                                    .setThemeMode(value),
                              );
                            }
                          },
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('Системная'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Светлая'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Тёмная'),
                      ),
                    ],
                  ),
                ),
                const Divider(indent: 56),
                const ListTile(
                  leading: Icon(Icons.language_outlined),
                  title: Text('Язык: русский'),
                  subtitle: Text('Другие языки пока не реализованы'),
                ),
                const Divider(indent: 56),
                if (user != null && androidPushSupported)
                  SwitchListTile(
                    title: const Text('Push-уведомления'),
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
                  const ListTile(
                    leading: Icon(Icons.notifications_none_rounded),
                    title: Text('Push-уведомления недоступны'),
                    subtitle: Text('Подключение ещё не настроено'),
                  ),
              ],
            ),
            _SettingsGroup(
              title: 'Информация',
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('О приложении'),
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
                      const Text(
                        'Расписание, новости и каталог кампуса. Демонстрационные данные отмечены отдельно.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (busy) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.logout_rounded),
              onPressed: busy
                  ? null
                  : () => perform(
                      () => ref.read(authControllerProvider.notifier).signOut(),
                    ),
              label: Text(
                authenticated ? 'Выйти из аккаунта' : 'Завершить демонстрацию',
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
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    ),
  );
}
