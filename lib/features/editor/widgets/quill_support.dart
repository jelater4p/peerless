// flutter_quill için ortak parçalar: Material köprüsü, görsel gömme,
// okuma stilleri ve salt-okunur gövde görünümü.
//
// Not: Flutter 3.50 ile Material ayrı bir pakete (material_ui) taşındı.
// flutter_quill henüz eski `package:flutter/material.dart` sınıflarını
// kullanıyor; bu yüzden editörü eski Material'ın Theme + Material
// widget'larıyla sarıyoruz. flutter_quill material_ui'a geçince bu köprü kalkar.
// ignore: deprecated_member_use
import 'package:flutter/material.dart' as legacy;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/reading_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';

/// Eski Material'a ihtiyaç duyan flutter_quill widget'larını sarar.
class QuillMaterialBridge extends StatelessWidget {
  const QuillMaterialBridge({super.key, required this.child, this.palette});
  final Widget child;
  final PeerlessPalette? palette;

  @override
  Widget build(BuildContext context) {
    final p = palette ?? context.colors;
    final scheme = legacy.ColorScheme.fromSeed(seedColor: p.accent, brightness: p.brightness).copyWith(
      primary: p.accent,
      onPrimary: p.onAccent,
      surface: p.surface,
      onSurface: p.ink,
      outline: p.hairline,
    );
    return legacy.Theme(
      data: legacy.ThemeData(
        brightness: p.brightness,
        colorScheme: scheme,
        fontFamily: Fonts.sans,
        canvasColor: p.surface,
        textSelectionTheme: legacy.TextSelectionThemeData(
          cursorColor: p.accent,
          selectionColor: p.accent.withValues(alpha: 0.3),
          selectionHandleColor: p.accent,
        ),
      ),
      child: legacy.Material(type: legacy.MaterialType.transparency, child: child),
    );
  }
}

/// Metin içi görselleri gösterir (Delta'da {"insert": {"image": url}}).
class ImageEmbedBuilder extends EmbedBuilder {
  const ImageEmbedBuilder();

  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final url = embedContext.node.value.data as String;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.space3),
      child: NetImage(url: url, width: double.infinity, fit: BoxFit.fitWidth),
    );
  }
}

/// Okuma ayarlarına göre (font, boyut, satır aralığı, tema) Quill stilleri.
DefaultStyles quillStyles(ReadingStyles r) {
  const none = HorizontalSpacing(0, 0);
  const tight = VerticalSpacing(0, 0);
  final body = r.body;
  final gap = (body.fontSize ?? 18) * 0.7;
  return DefaultStyles(
    paragraph: DefaultTextBlockStyle(body, none, VerticalSpacing(0, gap), tight, null),
    placeHolder: DefaultTextBlockStyle(body.copyWith(color: r.palette.inkMuted), none, tight, tight, null),
    h1: DefaultTextBlockStyle(r.heading, none, VerticalSpacing(gap, gap / 2), tight, null),
    h2: DefaultTextBlockStyle(r.heading.copyWith(fontSize: (r.heading.fontSize ?? 22) - 3), none,
        VerticalSpacing(gap, gap / 2), tight, null),
    h3: DefaultTextBlockStyle(r.heading.copyWith(fontSize: (r.heading.fontSize ?? 22) - 5), none,
        VerticalSpacing(gap, gap / 2), tight, null),
    quote: DefaultTextBlockStyle(
      r.quote,
      const HorizontalSpacing(Space.space4, Space.space4),
      VerticalSpacing(gap / 2, gap),
      const VerticalSpacing(Space.space2, Space.space2),
      BoxDecoration(color: r.palette.accentSoft, borderRadius: Radii.mdAll),
    ),
    lists: DefaultListBlockStyle(body, none, VerticalSpacing(0, gap), tight, null, null),
    bold: const TextStyle(fontWeight: FontWeight.w700),
    italic: const TextStyle(fontStyle: FontStyle.italic),
    link: TextStyle(color: r.palette.accent, decoration: TextDecoration.underline, decorationColor: r.palette.accent),
  );
}

/// İçerik gövdesini salt-okunur gösterir.
class PostBodyView extends StatefulWidget {
  const PostBodyView({super.key, required this.delta, required this.styles});
  final List<dynamic> delta;
  final ReadingStyles styles;

  @override
  State<PostBodyView> createState() => _PostBodyViewState();
}

class _PostBodyViewState extends State<PostBodyView> {
  late QuillController _controller = _build();
  final _focus = FocusNode();
  final _scroll = ScrollController();

  QuillController _build() {
    Document doc;
    try {
      doc = widget.delta.isEmpty ? Document() : Document.fromJson(widget.delta);
    } catch (_) {
      doc = Document();
    }
    return QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0), readOnly: true);
  }

  @override
  void didUpdateWidget(covariant PostBodyView old) {
    super.didUpdateWidget(old);
    if (!identical(old.delta, widget.delta)) {
      _controller.dispose();
      _controller = _build();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QuillMaterialBridge(
      palette: widget.styles.palette,
      child: QuillEditor(
        controller: _controller,
        focusNode: _focus,
        scrollController: _scroll,
        config: QuillEditorConfig(
          scrollable: false,
          showCursor: false,
          enableInteractiveSelection: true,
          customStyles: quillStyles(widget.styles),
          embedBuilders: const [ImageEmbedBuilder()],
        ),
      ),
    );
  }
}
