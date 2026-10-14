import 'package:campus_assistant/shared/widgets/ui/ui.dart' as ui;
import 'package:campus_assistant/l10n/ui_text.dart';
import 'package:campus_assistant/core/theme/campus_tokens.dart';

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
              padding: EdgeInsets.all(CampusTokens.of(context).space24),
              child: Form(
                key: form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ui.HeroBanner(
                      title: register
                          ? tr(context, 'Регистрация')
                          : tr(context, 'Вход в приложение'),
                      subtitle: tr(context, 'Учебный день — в одном месте.'),
                      action: Text(
                        'CAMPUS ASSISTANT',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    SizedBox(height: CampusTokens.of(context).space24),
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
                          autofillHints: const [AutofillHints.name],
                          textInputAction: TextInputAction.next,
                          maxLength: 100,
                          decoration: InputDecoration(
                            labelText: tr(context, 'Имя'),
                            errorMaxLines: 3,
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? tr(context, 'Введите имя')
                              : null,
                        ),
                        SizedBox(height: CampusTokens.of(context).space24),
                      ],
                      TextFormField(
                        controller: email,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.alternate_email_rounded),
                          errorMaxLines: 3,
                        ),
                        validator: (value) =>
                            RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(value?.trim() ?? '')
                            ? null
                            : tr(context, 'Введите корректный email'),
                      ),
                      SizedBox(height: CampusTokens.of(context).space24),
                      TextFormField(
                        controller: password,
                        autofillHints: [
                          register
                              ? AutofillHints.newPassword
                              : AutofillHints.password,
                        ],
                        textInputAction: register
                            ? TextInputAction.next
                            : TextInputAction.done,
                        obscureText: hidePassword,
                        decoration: InputDecoration(
                          labelText: tr(context, 'Пароль'),
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            tooltip: hidePassword
                                ? tr(context, 'Показать пароль')
                                : tr(context, 'Скрыть пароль'),
                            onPressed: () =>
                                setState(() => hidePassword = !hidePassword),
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                            ),
                          ),
                          errorMaxLines: 3,
                        ),
                        validator: (value) => (value?.length ?? 0) >= 6
                            ? null
                            : tr(context, 'Минимум 6 символов'),
                      ),
                      SizedBox(height: CampusTokens.of(context).space24),
                      if (register) ...[
                        TextFormField(
                          controller: confirmation,
                          obscureText: hidePassword,
                          decoration: InputDecoration(
                            labelText: tr(context, 'Повторите пароль'),
                            errorMaxLines: 3,
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? tr(context, 'Повторите пароль')
                              : value != password.text
                              ? tr(context, 'Пароли не совпадают')
                              : null,
                        ),
                        SizedBox(height: CampusTokens.of(context).space24),
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
                        child: Text(
                          register
                              ? tr(context, 'Создать аккаунт')
                              : tr(context, 'Войти'),
                        ),
                      ),
                      TextButton(
                        onPressed: busy
                            ? null
                            : () => setState(() {
                                register = !register;
                                message = null;
                              }),
                        child: Text(
                          register
                              ? tr(context, 'Уже есть аккаунт')
                              : tr(context, 'Регистрация'),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: busy
                            ? null
                            : () =>
                                  run(ref.read(authRepositoryProvider).google),
                        child: Text(tr(context, 'Войти через Google')),
                      ),
                      TextButton(
                        onPressed: busy
                            ? null
                            : () {
                                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                    .hasMatch(email.text.trim())) {
                                  setState(
                                    () => message = tr(
                                      context,
                                      'Введите корректный email',
                                    ),
                                  );
                                  return;
                                }
                                run(
                                  () => ref
                                      .read(authRepositoryProvider)
                                      .resetPassword(email.text),
                                  success: tr(
                                    context,
                                    'Если аккаунт существует, письмо для восстановления отправлено.',
                                  ),
                                );
                              },
                        child: Text(tr(context, 'Восстановить пароль')),
                      ),
                    ],
                    if (busy) ...[
                      SizedBox(height: CampusTokens.of(context).space24),
                      const CircularProgressIndicator(),
                    ],
                    if (message != null) ...[
                      SizedBox(height: CampusTokens.of(context).space24),
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
