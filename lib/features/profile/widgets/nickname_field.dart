import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../data/profile_repository.dart';

/// Nickname kuralı: a-z, 0-9, _ ve . ; 3–20 karakter (küçük harfe çevrilir).
final nicknamePattern = RegExp(r'^[a-z0-9_.]{3,20}$');

enum NicknameCheck { idle, checking, available, taken }

/// Yazdıkça uygunluğu kontrol eden nickname alanı.
class NicknameField extends ConsumerStatefulWidget {
  const NicknameField({super.key, required this.controller, this.currentNickname, this.onStatus, this.enabled = true});
  final TextEditingController controller;

  /// Düzenlemede kullanıcının şu anki nickname'i (uygun sayılır).
  final String? currentNickname;
  final ValueChanged<NicknameCheck>? onStatus;
  final bool enabled;

  @override
  ConsumerState<NicknameField> createState() => _NicknameFieldState();
}

class _NicknameFieldState extends ConsumerState<NicknameField> {
  Timer? _debounce;
  NicknameCheck _status = NicknameCheck.idle;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _set(NicknameCheck s) {
    if (!mounted) return;
    setState(() => _status = s);
    widget.onStatus?.call(s);
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (!nicknamePattern.hasMatch(value)) return _set(NicknameCheck.idle);
    if (value == widget.currentNickname) return _set(NicknameCheck.available);
    _set(NicknameCheck.checking);
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final ok = await ref.read(profileRepositoryProvider).isNicknameAvailable(value);
        if (widget.controller.text == value) _set(ok ? NicknameCheck.available : NicknameCheck.taken);
      } catch (_) {
        _set(NicknameCheck.idle);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final suffix = switch (_status) {
      NicknameCheck.checking => const Padding(
          padding: EdgeInsets.all(14),
          child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      NicknameCheck.available => Icon(LucideIcons.check, color: c.accent),
      NicknameCheck.taken => Icon(LucideIcons.x, color: c.danger),
      NicknameCheck.idle => null,
    };
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      autocorrect: false,
      enableSuggestions: false,
      inputFormatters: [
        _LowerCaseFormatter(),
        FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9_.]')),
        LengthLimitingTextInputFormatter(20),
      ],
      onChanged: _onChanged,
      decoration: InputDecoration(
        labelText: l.nickname,
        prefixText: '@',
        helperText: _status == NicknameCheck.taken ? null : l.nicknameHelp,
        errorText: _status == NicknameCheck.taken ? l.errNicknameTaken : null,
        suffixIcon: suffix,
      ),
      validator: (v) => nicknamePattern.hasMatch(v ?? '') ? null : l.nicknameHelp,
    );
  }
}

class _LowerCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(text: newValue.text.replaceAll('I', 'i').replaceAll('İ', 'i').toLowerCase());
}
