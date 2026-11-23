import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';

/// Giriş/kayıt ekranlarının ortak düzeni: logo, başlık, açıklama, form.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.title, this.subtitle, required this.children, this.showBack = false});
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showBack ? AppBar() : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Space.space4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!showBack) ...[
                    const Align(alignment: Alignment.centerLeft, child: PeerlessLogo(size: 48)),
                    const SizedBox(height: Space.space6),
                  ],
                  Text(title, style: context.text.headlineSmall),
                  if (subtitle != null) ...[
                    const SizedBox(height: Space.space2),
                    Text(subtitle!, style: context.text.bodyMedium?.copyWith(color: context.colors.inkMuted)),
                  ],
                  const SizedBox(height: Space.space6),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Şifre alanı (göster/gizle).
class PasswordField extends StatefulWidget {
  const PasswordField({super.key, required this.controller, required this.label, this.validator, this.onSubmitted, this.autofillHints});
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _hidden,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      onFieldSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          onPressed: () => setState(() => _hidden = !_hidden),
          icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: context.colors.inkMuted),
        ),
      ),
    );
  }
}

/// Basit e-posta kontrolü (asıl kontrolü Supabase yapar).
bool looksLikeEmail(String v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());

/// Supabase varsayılanı: en az 6 karakter.
const minPasswordLength = 6;
