// Profili düzenle: fotoğraf, kapak, görünen ad, nickname (30 günde bir), biyografi.
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/image_picking.dart';
import '../../../core/widgets/common.dart';
import '../data/profile_repository.dart';
import '../widgets/nickname_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final _profile = ref.read(myProfileProvider)!;
  late final _nickname = TextEditingController(text: _profile.nickname);
  late final _displayName = TextEditingController(text: _profile.displayName);
  late final _bio = TextEditingController(text: _profile.bio);
  Uint8List? _newAvatar;
  Uint8List? _newCover;
  bool _removeAvatar = false;
  bool _removeCover = false;
  NicknameCheck _check = NicknameCheck.idle;
  bool _saving = false;

  @override
  void dispose() {
    _nickname.dispose();
    _displayName.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _check == NicknameCheck.taken) return;
    setState(() => _saving = true);
    final repo = ref.read(profileRepositoryProvider);
    try {
      final fields = <String, dynamic>{
        'display_name': _displayName.text.trim(),
        'bio': _bio.text.trim().isEmpty ? null : _bio.text.trim(),
      };
      if (_nickname.text != _profile.nickname) fields['nickname'] = _nickname.text;
      if (_newAvatar != null) {
        fields['avatar_url'] = await repo.uploadAvatar(_newAvatar!);
      } else if (_removeAvatar) {
        fields['avatar_url'] = null;
        await repo.removeStorageFile('avatars', 'avatar.jpg');
      }
      if (_newCover != null) {
        fields['cover_url'] = await repo.uploadCover(_newCover!);
      } else if (_removeCover) {
        fields['cover_url'] = null;
        await repo.removeStorageFile('covers', 'cover.jpg');
      }
      await repo.update(fields);
      final updated = await repo.getMyProfile();
      if (updated != null) ref.read(sessionProvider.notifier).setProfile(updated);
      if (mounted) {
        showSnack(context.l10n.saved);
        context.pop();
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _imageMenu({required bool avatar}) async {
    final l = context.l10n;
    final hasImage = avatar
        ? (_newAvatar != null || (_profile.avatarUrl != null && !_removeAvatar))
        : (_newCover != null || (_profile.coverUrl != null && !_removeCover));
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.imagePlus),
              title: Text(avatar ? l.changePhoto : l.changeCover),
              onTap: () => Navigator.pop(ctx, 'change'),
            ),
            if (hasImage)
              ListTile(
                leading: Icon(LucideIcons.trash2, color: context.colors.danger),
                title: Text(l.remove, style: TextStyle(color: context.colors.danger)),
                onTap: () => Navigator.pop(ctx, 'remove'),
              ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'remove') {
      setState(() {
        if (avatar) {
          _newAvatar = null;
          _removeAvatar = true;
        } else {
          _newCover = null;
          _removeCover = true;
        }
      });
      return;
    }
    final bytes = await pickCroppedImage(context, avatar: avatar);
    if (bytes == null) return;
    setState(() {
      if (avatar) {
        _newAvatar = bytes;
        _removeAvatar = false;
      } else {
        _newCover = bytes;
        _removeCover = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final nextChange = _profile.nextNicknameChangeAt;

    Widget cover = _newCover != null
        ? Image.memory(_newCover!, fit: BoxFit.cover)
        : (_profile.coverUrl != null && !_removeCover)
            ? NetImage(url: _profile.coverUrl!, radius: 0)
            : ColoredBox(color: c.accentSoft);
    Widget avatar = _newAvatar != null
        ? ClipOval(child: Image.memory(_newAvatar!, width: 88, height: 88, fit: BoxFit.cover))
        : UserAvatar(url: _removeAvatar ? null : _profile.avatarUrl, name: _profile.name, size: 88);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.editProfile),
        actions: [
          TextButton(onPressed: _saving ? null : _save, child: Text(l.save)),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          children: [
            GestureDetector(
              onTap: () => _imageMenu(avatar: false),
              child: AspectRatio(
                aspectRatio: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    cover,
                    Center(child: Icon(LucideIcons.camera, color: c.ink)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Space.space4),
            Center(
              child: GestureDetector(
                onTap: () => _imageMenu(avatar: true),
                child: Stack(
                  children: [
                    avatar,
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
                        child: Icon(LucideIcons.camera, size: 16, color: c.onAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Space.space4),
              child: Column(
                children: [
                  TextFormField(
                    controller: _displayName,
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [LengthLimitingTextInputFormatter(50)],
                    decoration: InputDecoration(labelText: l.displayName),
                    validator: (v) => (v ?? '').trim().isEmpty ? l.errRequired : null,
                  ),
                  const SizedBox(height: Space.space4),
                  NicknameField(
                    controller: _nickname,
                    currentNickname: _profile.nickname,
                    enabled: nextChange == null,
                    onStatus: (s) => _check = s,
                  ),
                  if (nextChange != null)
                    Padding(
                      padding: const EdgeInsets.only(top: Space.space2),
                      child: Text(l.nicknameNextChange(fullDate(l, nextChange)), style: context.text.bodySmall),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: Space.space2),
                      child: Text(l.nicknameChangeRule, style: context.text.bodySmall),
                    ),
                  const SizedBox(height: Space.space4),
                  TextFormField(
                    controller: _bio,
                    maxLines: 4,
                    minLines: 2,
                    inputFormatters: [LengthLimitingTextInputFormatter(160)],
                    decoration: InputDecoration(labelText: l.bio, helperText: l.bioHelp),
                  ),
                  const SizedBox(height: Space.space6),
                  LoadingButton(label: l.save, loading: _saving, onPressed: _save),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
