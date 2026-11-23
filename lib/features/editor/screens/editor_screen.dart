// İçerik editörü. Dört tür de aynı zengin metin editörünü kullanır;
// alıntıda 'kişisel yorum', projede 'görsel galerisi' ek alanı açılır.
// Taslaklar yazarken birkaç saniyede bir buluta otomatik kaydedilir.
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/connectivity/connectivity.dart';
import '../../../core/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/reading_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/image_picking.dart';
import '../../../core/widgets/common.dart';
import '../../post/data/post.dart';
import '../../post/data/post_repository.dart';
import '../../post/post_events.dart';
import '../widgets/editor_toolbar.dart';
import '../widgets/quill_support.dart';

enum _SaveState { idle, saving, saved, failed }

const maxImagesPerPost = 5;
const maxTagsPerPost = 5;

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key, this.postId, this.initialType});
  final String? postId;
  final PostType? initialType;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final _title = TextEditingController();
  final _note = TextEditingController();
  final _tagInput = TextEditingController();
  final _bodyFocus = FocusNode();
  final _bodyScroll = ScrollController();
  QuillController? _body;

  String? _postId;
  Future<String>? _creating;
  PostType _type = PostType.thought;
  PostStatus _status = PostStatus.draft;
  String? _coverUrl;
  List<PostImage> _images = [];
  List<String> _tags = [];
  List<String> _tagSuggestions = [];

  bool _loading = true;
  Object? _loadError;
  bool _dirty = false;
  bool _tagsDirty = false;
  bool _publishing = false;
  bool _uploading = false;
  _SaveState _saveState = _SaveState.idle;
  Timer? _autosave;
  Timer? _tagDebounce;

  PostRepository get _repo => ref.read(postRepositoryProvider);
  bool get _isDraft => _status == PostStatus.draft;
  int get _imageCount => _images.length;

  @override
  void initState() {
    super.initState();
    _postId = widget.postId;
    _type = widget.initialType ?? PostType.thought;
    _title.addListener(_changed);
    _note.addListener(_changed);
    _init();
  }

  Future<void> _init() async {
    if (_postId == null) {
      _attachBody(QuillController.basic());
      setState(() => _loading = false);
      return;
    }
    try {
      final post = await _repo.getPost(_postId!);
      if (post == null) throw Exception('not found');
      _title.text = post.title;
      _note.text = post.personalNote ?? '';
      _type = post.type;
      _status = post.status;
      _coverUrl = post.coverUrl;
      _images = [...post.images];
      _tags = [...post.tags];
      Document doc;
      try {
        doc = post.body.isEmpty ? Document() : Document.fromJson(post.body);
      } catch (_) {
        doc = Document();
      }
      _attachBody(QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0)));
      _dirty = false;
    } catch (e) {
      _loadError = e;
    }
    if (mounted) setState(() => _loading = false);
  }

  void _attachBody(QuillController c) {
    _body = c;
    c.document.changes.listen((_) => _changed());
  }

  @override
  void dispose() {
    _autosave?.cancel();
    _tagDebounce?.cancel();
    _title.dispose();
    _note.dispose();
    _tagInput.dispose();
    _bodyFocus.dispose();
    _bodyScroll.dispose();
    _body?.dispose();
    super.dispose();
  }

  // --- Kaydetme --------------------------------------------------------

  void _changed() {
    if (_loading) return;
    _dirty = true;
    if (_saveState != _SaveState.idle && mounted) setState(() => _saveState = _SaveState.idle);
    // Yalnızca taslaklar otomatik kaydedilir; yayındaki içerik 'Güncelle' ile.
    if (_isDraft) {
      _autosave?.cancel();
      _autosave = Timer(const Duration(seconds: 3), _saveDraft);
    }
  }

  bool get _hasContent => _title.text.trim().isNotEmpty || _plainText.trim().isNotEmpty || _note.text.trim().isNotEmpty;

  String get _plainText => (_body?.document.toPlainText() ?? '').replaceAll('￼', '').trim();

  List<dynamic> get _delta => _body?.document.toDelta().toJson() ?? const [];

  Map<String, dynamic> get _fields => {
        'title': _title.text.trim(),
        'body': _delta,
        'body_text': _plainText,
        'personal_note': _type == PostType.quote && _note.text.trim().isNotEmpty ? _note.text.trim() : null,
        'cover_url': _coverUrl,
      };

  /// İlk kayıtta veritabanında taslak satırı oluşturur (tek sefer).
  Future<String> _ensurePostId() {
    if (_postId != null) return Future.value(_postId);
    return _creating ??= _repo.createDraft(type: _type, fields: _fields).then((id) {
      _postId = id;
      _dirty = false;
      return id;
    });
  }

  Future<void> _saveDraft() async {
    if (!_isDraft || !mounted) return;
    if (_postId == null && !_hasContent) return;
    if (!_dirty && !_tagsDirty) return;
    setState(() => _saveState = _SaveState.saving);
    try {
      final id = await _ensurePostId();
      if (_dirty) {
        _dirty = false;
        await _repo.updatePost(id, {..._fields, 'type': _type.name});
        await _syncInlineImages(id);
      }
      if (_tagsDirty) {
        _tagsDirty = false;
        await _repo.setTags(id, _tags);
      }
      if (mounted) setState(() => _saveState = _SaveState.saved);
    } catch (e) {
      _dirty = true;
      if (mounted) setState(() => _saveState = _SaveState.failed);
    }
  }

  /// Editörden silinen metin içi görselleri veritabanından ve depodan da siler.
  Future<void> _syncInlineImages(String postId) async {
    final used = <String>{};
    for (final op in _delta) {
      final insert = (op as Map)['insert'];
      if (insert is Map && insert['image'] is String) used.add(insert['image'] as String);
    }
    final stale = _images.where((i) => i.kind == ImageKind.inline && !used.contains(i.url)).toList();
    for (final img in stale) {
      await _repo.removeImage(img);
      _images.remove(img);
    }
  }

  String? _validateForPublish(AppLocalizations l) {
    if (_title.text.trim().isEmpty) return l.errTitleRequired;
    if (_plainText.isEmpty && !_delta.any((op) => (op as Map)['insert'] is Map)) return l.errBodyRequired;
    return null;
  }

  Future<void> _publish() async {
    final l = context.l10n;
    final problem = _validateForPublish(l);
    if (problem != null) {
      showSnack(problem);
      return;
    }
    _autosave?.cancel();
    setState(() => _publishing = true);
    try {
      final id = await _ensurePostId();
      await _repo.updatePost(id, {
        ..._fields,
        if (_isDraft) 'type': _type.name,
        'status': 'published',
      });
      await _syncInlineImages(id);
      await _repo.setTags(id, _tags);
      _dirty = false;
      _tagsDirty = false;
      ref.read(postsVersionProvider.notifier).bump();
      showSnack(_isDraft ? l.published : l.updated);
      if (!mounted) return;
      if (_isDraft) {
        context.pushReplacement(Routes.post(id));
      } else {
        context.pop();
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  Future<void> _deleteDraft() async {
    final l = context.l10n;
    final ok = await confirmDialog(context, title: l.deleteDraftTitle, confirmLabel: l.delete, destructive: true);
    if (!ok) return;
    _autosave?.cancel();
    try {
      if (_postId != null) await _repo.deletePost(_postId!);
      ref.read(postsVersionProvider.notifier).bump();
      _dirty = false;
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  /// Geri çıkarken: taslak kaydedilir; yayındaki içerikte kaydedilmemiş
  /// değişiklik varsa onay istenir.
  Future<void> _onExit() async {
    _autosave?.cancel();
    if (_isDraft) {
      await _saveDraft();
      if (mounted) context.pop();
      return;
    }
    if (_dirty || _tagsDirty) {
      final l = context.l10n;
      final discard = await confirmDialog(
        context,
        title: l.discardChangesTitle,
        message: l.discardChangesBody,
        confirmLabel: l.discard,
        destructive: true,
      );
      if (!discard) return;
    }
    if (mounted) context.pop();
  }

  // --- Görseller -------------------------------------------------------

  Future<PostImage?> _uploadImage(ImageKind kind) async {
    if (_imageCount >= maxImagesPerPost) {
      showSnack(context.l10n.errTooManyImages);
      return null;
    }
    final bytes = await pickPostImage(context);
    if (bytes == null || !mounted) return null;
    setState(() => _uploading = true);
    try {
      final id = await _ensurePostId();
      final url = await _repo.uploadImage(id, bytes);
      final position = _images.where((i) => i.kind == kind).length;
      final image = await _repo.addImageRecord(id, url, kind, position);
      setState(() => _images.add(image));
      return image;
    } catch (e) {
      if (mounted) showError(context, e);
      return null;
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _addCover() async {
    final img = await _uploadImage(ImageKind.cover);
    if (img == null) return;
    final old = _images.where((i) => i.kind == ImageKind.cover && i.id != img.id).toList();
    for (final o in old) {
      await _repo.removeImage(o);
      _images.remove(o);
    }
    setState(() => _coverUrl = img.url);
    _changed();
  }

  Future<void> _removeCover() async {
    final covers = _images.where((i) => i.kind == ImageKind.cover).toList();
    for (final c in covers) {
      await _repo.removeImage(c);
      _images.remove(c);
    }
    setState(() => _coverUrl = null);
    _changed();
  }

  Future<void> _addInlineImage() async {
    final body = _body!;
    final index = body.selection.baseOffset < 0 ? body.document.length - 1 : body.selection.baseOffset;
    final img = await _uploadImage(ImageKind.inline);
    if (img == null) return;
    body.replaceText(index, 0, BlockEmbed.image(img.url), TextSelection.collapsed(offset: index + 1));
  }

  Future<void> _addGalleryImage() async {
    await _uploadImage(ImageKind.gallery);
    _changed();
  }

  Future<void> _removeGalleryImage(PostImage img) async {
    try {
      await _repo.removeImage(img);
      setState(() => _images.remove(img));
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  // --- Etiketler -------------------------------------------------------

  void _addTag(String raw) {
    final turkish = Localizations.localeOf(context).languageCode == 'tr';
    final tag = normalizeTag(raw, turkish: turkish);
    _tagInput.clear();
    setState(() => _tagSuggestions = []);
    if (tag.isEmpty || _tags.contains(tag)) return;
    if (tag.length > 30) return showSnack(context.l10n.errTagTooLong);
    if (_tags.length >= maxTagsPerPost) return showSnack(context.l10n.errTooManyTags);
    setState(() => _tags.add(tag));
    _tagsDirty = true;
    _changed();
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
    _tagsDirty = true;
    _changed();
  }

  void _onTagInput(String value) {
    if (value.endsWith(',') || value.endsWith(' ')) {
      _addTag(value.substring(0, value.length - 1));
      return;
    }
    _tagDebounce?.cancel();
    _tagDebounce = Timer(const Duration(milliseconds: 300), () async {
      final q = normalizeTag(value, turkish: Localizations.localeOf(context).languageCode == 'tr');
      if (q.isEmpty) return setState(() => _tagSuggestions = []);
      try {
        final list = await _repo.suggestTags(q);
        if (mounted) setState(() => _tagSuggestions = list.where((t) => !_tags.contains(t)).toList());
      } catch (_) {}
    });
  }

  // --- Arayüz ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final offline = isOffline(ref);

    if (_loading) return const Scaffold(body: LoadingView());
    if (_loadError != null) {
      return Scaffold(appBar: AppBar(), body: ErrorState(error: _loadError!, onRetry: () {
        setState(() {
          _loading = true;
          _loadError = null;
        });
        _init();
      }));
    }

    final settings = ref.watch(appSettingsProvider);
    final r = ReadingStyles.of(settings, palette: c);
    final statusText = switch (_saveState) {
      _SaveState.saving => l.saving,
      _SaveState.saved => l.savedDraft,
      _SaveState.failed => l.saveFailed,
      _SaveState.idle => '',
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onExit();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(LucideIcons.x), onPressed: _onExit, tooltip: l.close),
          title: Text(statusText, style: context.text.bodySmall),
          actions: [
            if (_isDraft)
              IconButton(
                tooltip: l.deleteDraftTitle,
                icon: Icon(LucideIcons.trash2, color: c.inkMuted),
                onPressed: _deleteDraft,
              ),
            Padding(
              padding: const EdgeInsets.only(right: Space.space2),
              child: FilledButton(
                onPressed: offline || _publishing || _uploading ? null : _publish,
                style: FilledButton.styleFrom(minimumSize: const Size(0, 36)),
                child: _publishing
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_isDraft ? l.publish : l.update),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            const OfflineBanner(),
            if (_uploading) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(Space.space4, Space.space3, Space.space4, Space.space8),
                children: [
                  if (_isDraft) _typeSelector(l),
                  const SizedBox(height: Space.space3),
                  _coverSection(l, c),
                  TextField(
                    controller: _title,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    inputFormatters: [LengthLimitingTextInputFormatter(150)],
                    style: r.title,
                    decoration: InputDecoration(
                      hintText: l.titleHint,
                      hintStyle: r.title.copyWith(color: c.inkMuted),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: Space.space4),
                  QuillMaterialBridge(
                    child: QuillEditor(
                      controller: _body!,
                      focusNode: _bodyFocus,
                      scrollController: _bodyScroll,
                      config: QuillEditorConfig(
                        scrollable: false,
                        minHeight: 200,
                        placeholder: _type == PostType.quote ? l.quoteBodyHint : l.bodyHint,
                        customStyles: quillStyles(_type == PostType.quote ? r.withBody(r.quote) : r),
                        embedBuilders: const [ImageEmbedBuilder()],
                      ),
                    ),
                  ),
                  if (_type == PostType.quote) ...[
                    const SizedBox(height: Space.space6),
                    TextField(
                      controller: _note,
                      maxLines: null,
                      minLines: 2,
                      inputFormatters: [LengthLimitingTextInputFormatter(2000)],
                      decoration: InputDecoration(labelText: l.personalNote, helperText: l.personalNoteHint),
                    ),
                  ],
                  if (_type == PostType.project) ...[
                    const SizedBox(height: Space.space6),
                    _gallerySection(l, c),
                  ],
                  const SizedBox(height: Space.space6),
                  _tagsSection(l, c),
                  const SizedBox(height: Space.space4),
                  Text(l.imageLimitInfo(_imageCount, maxImagesPerPost), style: context.text.bodySmall),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: EditorToolbar(
                controller: _body!,
                onAddImage: _addInlineImage,
                canAddImage: !offline && !_uploading && _imageCount < maxImagesPerPost,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeSelector(AppLocalizations l) {
    return Wrap(
      spacing: Space.space2,
      children: [
        for (final t in PostType.values)
          ChoiceChip(
            avatar: Icon(t.icon, size: 16),
            label: Text(t.label(l)),
            selected: _type == t,
            onSelected: (_) {
              if (_type == t) return;
              if (t != PostType.project && _images.any((i) => i.kind == ImageKind.gallery)) {
                showSnack(l.galleryOnlyProject);
                return;
              }
              setState(() => _type = t);
              _changed();
            },
          ),
      ],
    );
  }

  Widget _coverSection(AppLocalizations l, PeerlessPalette c) {
    if (_coverUrl == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: _uploading || _imageCount >= maxImagesPerPost ? null : _addCover,
          icon: const Icon(LucideIcons.imagePlus, size: 18),
          label: Text(l.addCover),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.space4),
      child: Stack(
        children: [
          NetImage(url: _coverUrl!, width: double.infinity, height: 180),
          Positioned(
            top: Space.space2,
            right: Space.space2,
            child: IconButton.filledTonal(
              tooltip: l.remove,
              onPressed: _removeCover,
              icon: const Icon(LucideIcons.x, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gallerySection(AppLocalizations l, PeerlessPalette c) {
    final gallery = _images.where((i) => i.kind == ImageKind.gallery).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.gallery, style: context.text.labelLarge),
        const SizedBox(height: Space.space2),
        Wrap(
          spacing: Space.space2,
          runSpacing: Space.space2,
          children: [
            for (final g in gallery)
              Stack(
                children: [
                  NetImage(url: g.url, width: 96, height: 96),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => _removeGalleryImage(g),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(color: c.bg, shape: BoxShape.circle),
                        child: Icon(LucideIcons.x, size: 14, color: c.ink),
                      ),
                    ),
                  ),
                ],
              ),
            if (_imageCount < maxImagesPerPost)
              InkWell(
                onTap: _uploading ? null : _addGalleryImage,
                borderRadius: Radii.mdAll,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(border: Border.all(color: c.hairline), borderRadius: Radii.mdAll),
                  child: Icon(LucideIcons.plus, color: c.inkMuted),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _tagsSection(AppLocalizations l, PeerlessPalette c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.tags, style: context.text.labelLarge),
        const SizedBox(height: Space.space2),
        if (_tags.isNotEmpty)
          Wrap(
            spacing: Space.space2,
            runSpacing: Space.space2,
            children: [
              for (final t in _tags)
                InputChip(label: Text('#$t'), onDeleted: () => _removeTag(t)),
            ],
          ),
        if (_tags.length < maxTagsPerPost) ...[
          const SizedBox(height: Space.space2),
          TextField(
            controller: _tagInput,
            onChanged: _onTagInput,
            onSubmitted: _addTag,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: l.tagHint,
              prefixIcon: Icon(LucideIcons.hash, size: 18, color: c.inkMuted),
              isDense: true,
            ),
          ),
          if (_tagSuggestions.isNotEmpty)
            Wrap(
              spacing: Space.space2,
              children: [
                for (final s in _tagSuggestions) ActionChip(label: Text('#$s'), onPressed: () => _addTag(s)),
              ],
            ),
        ],
        const SizedBox(height: Space.space1),
        Text(l.tagRule(maxTagsPerPost), style: context.text.bodySmall),
      ],
    );
  }
}
