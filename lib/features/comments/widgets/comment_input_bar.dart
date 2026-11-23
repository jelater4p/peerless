// Alttaki yorum yazma çubuğu: yanıt hedefi, @nickname otomatik tamamlama.
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/connectivity/connectivity.dart';
import '../../../core/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../../profile/data/profile.dart';
import '../../profile/data/profile_repository.dart';
import '../comments_controller.dart';
import '../data/comment_repository.dart';

class CommentInputBar extends ConsumerStatefulWidget {
  const CommentInputBar({
    super.key,
    required this.postId,
    required this.replyRoot,
    required this.replyTarget,
    required this.onCancelReply,
    required this.onSent,
    this.focusNode,
  });

  final String postId;

  /// Yanıt verilen ana yorum (null = yeni ana yorum).
  final Comment? replyRoot;

  /// Yanıtlanan kişi (ana yorum ya da bir yanıt).
  final Comment? replyTarget;
  final VoidCallback onCancelReply;
  final VoidCallback onSent;
  final FocusNode? focusNode;

  @override
  ConsumerState<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends ConsumerState<CommentInputBar> {
  final _controller = TextEditingController();
  bool _sending = false;
  List<Profile> _suggestions = const [];
  Timer? _debounce;

  @override
  void didUpdateWidget(covariant CommentInputBar old) {
    super.didUpdateWidget(old);
    // Bir yanıta yanıt verilirken kişinin nickname'i otomatik eklenir.
    final target = widget.replyTarget;
    if (target != null && target != old.replyTarget && target.id != widget.replyRoot?.id) {
      final nick = target.author?.nickname;
      if (nick != null && !_controller.text.contains('@$nick')) {
        _controller.text = '@$nick ${_controller.text}';
        _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// İmlecin bulunduğu kelime '@' ile başlıyorsa kişi önerir.
  void _onChanged(String text) {
    setState(() {});
    _debounce?.cancel();
    final word = _currentWord();
    if (word == null || !word.startsWith('@') || word.length < 3) {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final list = await ref.read(profileRepositoryProvider).search(word.substring(1), limit: 5);
        if (mounted) setState(() => _suggestions = list);
      } catch (_) {}
    });
  }

  String? _currentWord() {
    final sel = _controller.selection.baseOffset;
    if (sel < 0) return null;
    final before = _controller.text.substring(0, sel);
    final m = RegExp(r'(@[\w.]*)$').firstMatch(before);
    return m?.group(1);
  }

  void _applySuggestion(Profile p) {
    final sel = _controller.selection.baseOffset;
    final before = _controller.text.substring(0, sel);
    final after = _controller.text.substring(sel);
    final replaced = before.replaceFirst(RegExp(r'@[\w.]*$'), '@${p.nickname} ');
    _controller.text = replaced + after;
    _controller.selection = TextSelection.collapsed(offset: replaced.length);
    setState(() => _suggestions = const []);
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref.read(commentsProvider(widget.postId).notifier).add(text, parentId: widget.replyRoot?.id);
      _controller.clear();
      widget.onSent();
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final offline = isOffline(ref);
    final target = widget.replyTarget;

    return Material(
      color: c.surface,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hairline(),
            if (_suggestions.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    for (final p in _suggestions)
                      ListTile(
                        dense: true,
                        leading: UserAvatar(url: p.avatarUrl, name: p.name, size: 28),
                        title: Text(p.name),
                        subtitle: Text('@${p.nickname}'),
                        onTap: () => _applySuggestion(p),
                      ),
                  ],
                ),
              ),
            if (target != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.space4, Space.space2, Space.space2, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.replyingTo(target.author?.name ?? ''),
                        style: context.text.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(LucideIcons.x, size: 16, color: c.inkMuted),
                      onPressed: widget.onCancelReply,
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.space4, Space.space2, Space.space2, Space.space2),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: widget.focusNode,
                      enabled: !offline,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      inputFormatters: [LengthLimitingTextInputFormatter(1000)],
                      onChanged: _onChanged,
                      decoration: InputDecoration(
                        hintText: offline ? l.offlineBanner : l.writeComment,
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: Space.space1),
                  IconButton(
                    onPressed: offline || _sending || _controller.text.trim().isEmpty ? null : _send,
                    icon: _sending
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(LucideIcons.send, color: c.accent),
                    tooltip: l.send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
