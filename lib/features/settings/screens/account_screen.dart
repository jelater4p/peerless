// Hesap: e-posta değiştirme (yeni adrese kodla doğrulama), şifre değiştirme,
// hesabı silme (30 gün bekleme; bu sürede giriş yapılırsa iptal).
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/widgets/auth_scaffold.dart';
import '../../profile/data/profile_repository.dart';
import '../sign_out.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    final email = ref.watch(authRepositoryProvider).currentEmail ?? '';
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsAccount)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(LucideIcons.mail),
            title: Text(l.changeEmail),
            subtitle: Text(email),
            onTap: () => _changeEmail(context, ref),
          ),
          ListTile(
            leading: const Icon(LucideIcons.lock),
            title: Text(l.changePassword),
            onTap: () => _changePassword(context, ref),
          ),
          const Hairline(),
          ListTile(
            leading: Icon(LucideIcons.trash2, color: c.danger),
            title: Text(l.deleteAccount, style: TextStyle(color: c.danger)),
            subtitle: Text(l.deleteAccountHint),
            onTap: () => _deleteAccount(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _changeEmail(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final repo = ref.read(authRepositoryProvider);
    final emailCtl = TextEditingController();
    final newEmail = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.changeEmail),
        content: TextField(
          controller: emailCtl,
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          decoration: InputDecoration(labelText: l.newEmail),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, emailCtl.text.trim()), child: Text(l.sendCode)),
        ],
      ),
    );
    if (newEmail == null || !context.mounted) return;
    if (!looksLikeEmail(newEmail)) return showSnack(l.errInvalidEmail);
    try {
      await repo.requestEmailChange(newEmail);
    } catch (e) {
      if (context.mounted) showError(context, e);
      return;
    }
    if (!context.mounted) return;
    final codeCtl = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l.verifyTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.emailChangeCodeSent(newEmail)),
            const SizedBox(height: Space.space3),
            TextField(
              controller: codeCtl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              decoration: InputDecoration(labelText: l.code),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, codeCtl.text.trim()), child: Text(l.verify)),
        ],
      ),
    );
    if (code == null || code.isEmpty) return;
    try {
      await repo.verifyEmailChange(newEmail: newEmail, code: code);
      showSnack(l.emailChanged);
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  Future<void> _changePassword(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final ctl = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.changePassword),
        content: PasswordField(controller: ctl, label: l.newPassword),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, ctl.text), child: Text(l.save)),
        ],
      ),
    );
    if (password == null) return;
    if (password.length < minPasswordLength) return showSnack(l.errPasswordShort(minPasswordLength));
    try {
      await ref.read(authRepositoryProvider).changePassword(password);
      showSnack(l.passwordUpdated);
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final ok = await confirmDialog(
      context,
      title: l.deleteAccountConfirmTitle,
      message: l.deleteAccountConfirmBody,
      confirmLabel: l.deleteAccount,
      destructive: true,
    );
    if (!ok) return;
    try {
      await ref.read(profileRepositoryProvider).requestAccountDeletion();
      showSnack(l.deleteAccountRequested);
      await signOutEverywhere(ref);
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }
}
