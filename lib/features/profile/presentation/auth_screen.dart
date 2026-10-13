import 'package:campus_assistant/core/theme/campus_style.dart';

import 'package:campus_assistant/core/data/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginState();
}

class _LoginState extends ConsumerState<LoginScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController(),
      confirmation = TextEditingController();
  bool register = false, busy = false, hidePassword = true;
  String? message;
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  Future<void> run(Future<void> Function() action, {String? success}) async {
    setState(() {
      busy = true;
      message = null;
    });
    try {
      await action();
      if (mounted) setState(() => message = success);
    } catch (error) {
      if (mounted) setState(() => message = authError(error));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = ref.watch(firebaseReadyProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: CampusStyle.hero(context),
                        borderRadius: BorderRadius.circular(
                          CampusStyle.heroRadius,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 36,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'CAMPUS ASSISTANT',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  letterSpacing: 1.5,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            register ? 'Регистрация' : 'Вход в приложение',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Учебный день — в одном месте.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (!ready)
                      Text(
                        ref.watch(firebaseErrorProvider) ??
                            'Firebase не настроен. Вход недоступен.',
                        textAlign: TextAlign.center,
                      ),
                    if (ready) ...[
                      if (register) ...[
                        TextFormField(
                          controller: name,
                          maxLength: 100,
                          decoration: const InputDecoration(
                            labelText: 'Имя',
                            errorMaxLines: 3,
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Введите имя'
                              : null,
                        ),
                        const SizedBox(height: 24),
                      ],
                      TextFormField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          errorMaxLines: 3,
                        ),
                        validator: (value) =>
                            RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(value?.trim() ?? '')
                            ? null
                            : 'Введите корректный email',
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: password,
                        obscureText: hidePassword,
                        decoration: InputDecoration(
                          labelText: 'Пароль',
                          suffixIcon: IconButton(
                            tooltip: hidePassword
                                ? 'Показать пароль'
                                : 'Скрыть пароль',
                            onPressed: () =>
                                setState(() => hidePassword = !hidePassword),
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                          errorMaxLines: 3,
                        ),
                        validator: (value) => (value?.length ?? 0) >= 6
                            ? null
                            : 'Минимум 6 символов',
                      ),
                      const SizedBox(height: 24),
                      if (register) ...[
                        TextFormField(
                          controller: confirmation,
                          obscureText: hidePassword,
                          decoration: const InputDecoration(
                            labelText: 'Повторите пароль',
                            errorMaxLines: 3,
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Повторите пароль'
                              : value != password.text
                              ? 'Пароли не совпадают'
                              : null,
                        ),
                        const SizedBox(height: 24),
                      ],
                      FilledButton(
                        onPressed: busy
                            ? null
                            : () {
                                if (form.currentState!.validate()) {
                                  run(
                                    () => register
                                        ? ref
                                              .read(authRepositoryProvider)
                                              .register(
                                                name.text,
                                                email.text,
                                                password.text,
                                              )
                                        : ref
                                              .read(authRepositoryProvider)
                                              .signIn(
                                                email.text,
                                                password.text,
                                              ),
                                  );
                                }
                              },
                        child: Text(register ? 'Создать аккаунт' : 'Войти'),
                      ),
                      TextButton(
                        onPressed: busy
                            ? null
                            : () => setState(() {
                                register = !register;
                                message = null;
                              }),
                        child: Text(
                          register ? 'Уже есть аккаунт' : 'Регистрация',
                        ),
                      ),
                      OutlinedButton(
                        onPressed: busy
                            ? null
                            : () =>
                                  run(ref.read(authRepositoryProvider).google),
                        child: const Text('Войти через Google'),
                      ),
                      TextButton(
                        onPressed: busy
                            ? null
                            : () {
                                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                    .hasMatch(email.text.trim())) {
                                  setState(
                                    () => message = 'Введите корректный email',
                                  );
                                  return;
                                }
                                run(
                                  () => ref
                                      .read(authRepositoryProvider)
                                      .resetPassword(email.text),
                                  success: 'Если аккаунт существует, письмо для восстановления отправлено.',
                                );
                              },
                        child: const Text('Восстановить пароль'),
                      ),
                    ],
                    if (busy) ...[
                      const SizedBox(height: 24),
                      const CircularProgressIndicator(),
                    ],
                    if (message != null) ...[
                      const SizedBox(height: 24),
                      Text(message!, textAlign: TextAlign.center),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
