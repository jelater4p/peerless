import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/image_picking.dart';
import '../../../core/widgets/common.dart';
import '../../profile/data/profile_repository.dart';
import '../widgets/auth_scaffold.dart';

/// Onboarding son adım: profil fotoğrafı + biyografi (atlanabilir).
class SetupProfileScreen extends ConsumerStatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  ConsumerState<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends ConsumerState<SetupProfileScreen> {
  final _bio = TextEditingController();
  Uint8List? _avatar;
  bool _loading = false;

  @override
  void dispose() {
    _bio.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final bytes = await pickCroppedImage(context, avatar: true);
    if (bytes != null) setState(() => _avatar = bytes);
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      final fields = <String, dynamic>{};
      if (_avatar != null) fields['avatar_url'] = await repo.uploadAvatar(_avatar!);
      if (_bio.text.trim().isNotEmpty) fields['bio'] = _bio.text.trim();
      if (fields.isNotEmpty) {
        await repo.update(fields);
        final p = await repo.getMyProfile();
        if (p != null) ref.read(sessionProvider.notifier).setProfile(p);
      }
      ref.read(sessionProvider.notifier).finishOnboarding();
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
    final profile = ref.watch(myProfileProvider);

    return AuthScaffold(
      title: l.setupProfileTitle,
      subtitle: l.setupProfileSubtitle,
      children: [
        Center(
          child: GestureDetector(
            onTap: _pick,
            child: Stack(
              children: [
                _avatar != null
                    ? ClipOval(child: Image.memory(_avatar!, width: 112, height: 112, fit: BoxFit.cover))
                    : UserAvatar(url: null, name: profile?.name ?? '', size: 112),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(Space.space2),
                    decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
                    child: Icon(LucideIcons.camera, size: 18, color: c.onAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Space.space6),
        TextField(
          controller: _bio,
          maxLines: 3,
          minLines: 2,
          inputFormatters: [LengthLimitingTextInputFormatter(160)],
          decoration: InputDecoration(labelText: l.bio, helperText: l.bioHelp),
        ),
        const SizedBox(height: Space.space6),
        LoadingButton(label: l.finish, loading: _loading, onPressed: _save),
        const SizedBox(height: Space.space2),
        Center(
          child: TextButton(
            onPressed: _loading ? null : () => ref.read(sessionProvider.notifier).finishOnboarding(),
            child: Text(l.skip, style: TextStyle(color: c.inkMuted)),
          ),
        ),
      ],
    );
  }
}
