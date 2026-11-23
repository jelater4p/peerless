import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/widgets/nickname_field.dart';
import '../data/auth_repository.dart';
import '../widgets/auth_scaffold.dart';

/// Onboarding: benzersiz @nickname + görünen ad (zorunlu).
class SetupNicknameScreen extends ConsumerStatefulWidget {
  const SetupNicknameScreen({super.key});

  @override
  ConsumerState<SetupNicknameScreen> createState() => _SetupNicknameScreenState();
}

class _SetupNicknameScreenState extends ConsumerState<SetupNicknameScreen> {
  final _form = GlobalKey<FormState>();
  final _nickname = TextEditingController();
  final _displayName = TextEditingController();
  NicknameCheck _check = NicknameCheck.idle;
  bool _loading = false;

  @override
  void dispose() {
    _nickname.dispose();
    _displayName.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate() || _check == NicknameCheck.taken) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.update({'nickname': _nickname.text, 'display_name': _displayName.text.trim()});
      final profile = await repo.getMyProfile();
      if (profile != null) ref.read(sessionProvider.notifier).setProfile(profile, onboarding: true);
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
      title: l.setupNicknameTitle,
      subtitle: l.setupNicknameSubtitle,
      children: [
        Form(
          key: _form,
          child: Column(
            children: [
              NicknameField(controller: _nickname, onStatus: (s) => _check = s),
              const SizedBox(height: Space.space4),
              TextFormField(
                controller: _displayName,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                decoration: InputDecoration(labelText: l.displayName, helperText: l.displayNameHelp),
                validator: (v) => (v ?? '').trim().isEmpty ? l.errRequired : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.space6),
        LoadingButton(label: l.continueLabel, loading: _loading, onPressed: _submit),
        const SizedBox(height: Space.space4),
        Center(
          child: TextButton(
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            child: Text(l.signOut),
          ),
        ),
      ],
    );
  }
}
