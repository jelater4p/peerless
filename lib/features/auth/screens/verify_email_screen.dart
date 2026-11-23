import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../data/auth_repository.dart';
import '../widgets/auth_scaffold.dart';

/// E-posta doğrulama: e-postadaki kod girilmeden devam edilmez.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});
  final String email;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _code = TextEditingController();
  bool _loading = false;
  int _cooldown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _cooldown--);
      if (_cooldown <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_code.text.trim().length < 6) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).verifySignUp(email: widget.email, code: _code.text);
      // Oturum açıldı → router nickname ekranına yönlendirir.
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    try {
      await ref.read(authRepositoryProvider).resendSignUpCode(widget.email);
      _startCooldown();
      if (mounted) showSnack(context.l10n.codeResent);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AuthScaffold(
      title: l.verifyTitle,
      subtitle: l.verifySubtitle(widget.email),
      showBack: true,
      children: [
        TextField(
          controller: _code,
          keyboardType: TextInputType.number,
          autofillHints: const [AutofillHints.oneTimeCode],
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
          textAlign: TextAlign.center,
          style: context.text.headlineSmall?.copyWith(letterSpacing: 8),
          decoration: const InputDecoration(hintText: '······'),
          // Kod uzunluğu Supabase ayarına göre 6–10 hane olabilir; otomatik gönderilmez.
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _verify(),
        ),
        const SizedBox(height: Space.space4),
        LoadingButton(label: l.verify, loading: _loading, onPressed: _code.text.length >= 6 ? _verify : null),
        const SizedBox(height: Space.space4),
        Center(
          child: TextButton(
            onPressed: _cooldown > 0 ? null : _resend,
            child: Text(
              _cooldown > 0 ? l.resendCodeIn(_cooldown) : l.resendCode,
              style: TextStyle(color: _cooldown > 0 ? context.colors.inkMuted : context.colors.accent),
            ),
          ),
        ),
        const SizedBox(height: Space.space2),
        Text(l.checkSpam, style: context.text.bodySmall, textAlign: TextAlign.center),
      ],
    );
  }
}
