// Editör araç çubuğu: başlık, kalın, italik, alıntı bloğu, liste, link, görsel.
import 'package:flutter_quill/flutter_quill.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';

class EditorToolbar extends StatelessWidget {
  const EditorToolbar({super.key, required this.controller, required this.onAddImage, required this.canAddImage});
  final QuillController controller;
  final VoidCallback onAddImage;
  final bool canAddImage;

  bool _has(Attribute a) {
    final attrs = controller.getSelectionStyle().attributes;
    final current = attrs[a.key];
    return current != null && current.value == a.value;
  }

  void _toggle(Attribute a) {
    controller.formatSelection(_has(a) ? Attribute.clone(a, null) : a);
  }

  Future<void> _link(BuildContext context) async {
    final l = context.l10n;
    final input = TextEditingController(text: 'https://');
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.addLink),
        content: TextField(controller: input, keyboardType: TextInputType.url, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, input.text.trim()), child: Text(l.ok)),
        ],
      ),
    );
    if (url == null || url.isEmpty || url == 'https://') return;
    final sel = controller.selection;
    if (sel.isCollapsed) {
      // Seçili metin yoksa linkin kendisi metin olarak eklenir.
      controller.replaceText(sel.baseOffset, 0, url, TextSelection.collapsed(offset: sel.baseOffset + url.length));
      controller.formatText(sel.baseOffset, url.length, LinkAttribute(url));
    } else {
      controller.formatSelection(LinkAttribute(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        Widget btn(IconData icon, String tip, VoidCallback? onTap, {bool active = false}) => IconButton(
              tooltip: tip,
              onPressed: onTap,
              isSelected: active,
              style: IconButton.styleFrom(
                backgroundColor: active ? c.accentSoft : null,
                foregroundColor: active ? c.accent : c.ink,
                shape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
              ),
              icon: Icon(icon, size: 20),
            );
        return DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface,
            border: Border(top: BorderSide(color: c.hairline), bottom: BorderSide(color: c.hairline)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Space.space2),
            child: Row(
              children: [
                btn(LucideIcons.heading, l.fmtHeading, () => _toggle(Attribute.h2), active: _has(Attribute.h2)),
                btn(LucideIcons.bold, l.fmtBold, () => _toggle(Attribute.bold), active: _has(Attribute.bold)),
                btn(LucideIcons.italic, l.fmtItalic, () => _toggle(Attribute.italic), active: _has(Attribute.italic)),
                btn(LucideIcons.textQuote, l.fmtQuote, () => _toggle(Attribute.blockQuote),
                    active: _has(Attribute.blockQuote)),
                btn(LucideIcons.list, l.fmtBullets, () => _toggle(Attribute.ul), active: _has(Attribute.ul)),
                btn(LucideIcons.listOrdered, l.fmtNumbers, () => _toggle(Attribute.ol), active: _has(Attribute.ol)),
                btn(LucideIcons.link, l.addLink, () => _link(context)),
                btn(LucideIcons.imagePlus, l.addImage, canAddImage ? onAddImage : null),
                btn(LucideIcons.undo2, l.undo, controller.hasUndo ? controller.undo : null),
                btn(LucideIcons.redo2, l.redo, controller.hasRedo ? controller.redo : null),
              ],
            ),
          ),
        );
      },
    );
  }
}
