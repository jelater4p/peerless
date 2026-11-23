import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../data/auth_repository.dart';
import '../widgets/auth_scaffold.dart';

/// Şifre sıfırlama: 1) e-posta → kod gönder, 2) kod + yeni şifre.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  bool _codeSent = false;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final l = context.l10n;
    final repo = ref.read(authRepositoryProvider);
    try {
      if (!_codeSent) {
        await repo.sendPasswordResetCode(_email.text);
        setState(() => _codeSent = true);
      } else {
        await repo.resetPassword(email: _email.text, code: _code.text, newPassword: _password.text);
        // Kod doğrulanınca oturum açılır; router ana akışa geçer.
        showSnack(l.passwordUpdated);
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
      title: l.forgotTitle,
      subtitle: _codeSent ? l.forgotCodeSent(_email.text.trim()) : l.forgotSubtitle,
      showBack: true,
      children: [
        Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _email,
                enabled: !_codeSent,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: l.email),
                validator: (v) => looksLikeEmail(v ?? '') ? null : l.errInvalidEmail,
              ),
              if (_codeSent) ...[
                const SizedBox(height: Space.space3),
                TextFormField(
                  controller: _code,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                  decoration: InputDecoration(labelText: l.code),
                  validator: (v) => (v ?? '').length < 6 ? l.errCodeInvalid : null,
                ),
                const SizedBox(height: Space.space3),
                PasswordField(
                  controller: _password,
                  label: l.newPassword,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (v) => (v ?? '').length < minPasswordLength ? l.errPasswordShort(minPasswordLength) : null,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: Space.space6),
        LoadingButton(label: _codeSent ? l.updatePassword : l.sendCode, loading: _loading, onPressed: _submit),
      ],
    );
  }
}
