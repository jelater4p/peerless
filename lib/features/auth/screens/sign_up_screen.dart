import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../data/auth_repository.dart';
import '../widgets/auth_scaffold.dart';

/// Kayıt formu: e-posta, şifre, kullanım koşulları + KVKK onayı, yaş onayı (16+).
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _acceptTerms = false;
  bool _ageOk = false;
  bool _showChecksError = false;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _form.currentState!.validate();
    setState(() => _showChecksError = !(_acceptTerms && _ageOk));
    if (!valid || !_acceptTerms || !_ageOk) return;
    setState(() => _loading = true);
    try {
      final locale = Localizations.localeOf(context).languageCode == 'tr' ? 'tr' : 'en';
      await ref.read(authRepositoryProvider).signUp(email: _email.text, password: _password.text, locale: locale);
      if (mounted) context.pushReplacement('${Routes.verify}?email=${Uri.encodeComponent(_email.text.trim())}');
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final linkStyle = TextStyle(color: c.accent, decoration: TextDecoration.underline);

    return AuthScaffold(
      title: l.signUpTitle,
      subtitle: l.signUpSubtitle,
      showBack: true,
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
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (v) => (v ?? '').length < minPasswordLength ? l.errPasswordShort(minPasswordLength) : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Space.space4),
        CheckboxListTile(
          value: _acceptTerms,
          onChanged: (v) => setState(() => _acceptTerms = v ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: c.accent,
          title: Text.rich(
            TextSpan(
              style: context.text.bodyMedium,
              children: [
                TextSpan(
                  text: l.termsOfUse,
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()..onTap = () => context.push('${Routes.signIn}/legal/terms'),
                ),
                TextSpan(text: l.and),
                TextSpan(
                  text: l.privacyNotice,
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()..onTap = () => context.push('${Routes.signIn}/legal/kvkk'),
                ),
                TextSpan(text: l.acceptSuffix),
              ],
            ),
          ),
        ),
        CheckboxListTile(
          value: _ageOk,
          onChanged: (v) => setState(() => _ageOk = v ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: c.accent,
          title: Text(l.ageConfirm, style: context.text.bodyMedium),
        ),
        if (_showChecksError)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.space2),
            child: Text(l.errAcceptRequired, style: TextStyle(color: c.danger, fontSize: 12)),
          ),
        const SizedBox(height: Space.space2),
        LoadingButton(label: l.signUp, loading: _loading, onPressed: _submit),
      ],
    );
  }
}
