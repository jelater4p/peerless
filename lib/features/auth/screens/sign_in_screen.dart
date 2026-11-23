import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../data/auth_repository.dart';
import '../widgets/auth_scaffold.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(sessionProvider).wasBanned) showSnack(context.l10n.errBanned);
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).signIn(email: _email.text, password: _password.text);
      // Yönlendirmeyi router yapar (oturum değişince).
    } on AuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'email_not_confirmed') {
        // Doğrulanmamış hesap: yeni kod gönder ve doğrulama ekranına git.
        try {
          await ref.read(authRepositoryProvider).resendSignUpCode(_email.text);
        } catch (_) {}
        if (mounted) context.push('${Routes.verify}?email=${Uri.encodeComponent(_email.text.trim())}');
      } else {
        showError(context, e);
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AuthScaffold(
      title: l.signInTitle,
      subtitle: l.signInSubtitle,
      children: [
        Form(
          key: _form,
          child: AutofillGroup(
            child: Column(
              children: [
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: l.email),
                  validator: (v) => looksLikeEmail(v ?? '') ? null : l.errInvalidEmail,
                ),
                const SizedBox(height: Space.space3),
                PasswordField(
                  controller: _password,
                  label: l.password,
                  autofillHints: const [AutofillHints.password],
                  validator: (v) => (v ?? '').isEmpty ? l.errRequired : null,
                  onSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(onPressed: () => context.push(Routes.forgot), child: Text(l.forgotPassword)),
        ),
        const SizedBox(height: Space.space2),
        LoadingButton(label: l.signIn, loading: _loading, onPressed: _submit),
        const SizedBox(height: Space.space6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l.noAccount, style: context.text.bodyMedium?.copyWith(color: context.colors.inkMuted)),
            TextButton(onPressed: () => context.push(Routes.signUp), child: Text(l.signUp)),
          ],
        ),
      ],
    );
  }
}
