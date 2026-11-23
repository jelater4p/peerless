import 'package:material_ui/material_ui.dart';

import '../../profile/data/profile.dart';

/// İçerik türleri. Akışta yalnızca küçük bir ikonla ayırt edilir.
enum PostType {
  quote,
  thought,
  thesis,
  project;

  static PostType fromName(String? v) =>
      PostType.values.firstWhere((t) => t.name == v, orElse: () => PostType.thought);
}

enum PostStatus {
  draft,
  published,
  removed;

  static PostStatus fromName(String? v) =>
      PostStatus.values.firstWhere((t) => t.name == v, orElse: () => PostStatus.draft);
}

enum ImageKind { cover, inline, gallery }

@immutable
class PostImage {
  const PostImage({required this.id, required this.url, required this.kind, required this.position});

  factory PostImage.fromJson(Map<String, dynamic> j) => PostImage(
        id: j['id'] as String,
        url: j['url'] as String,
        kind: ImageKind.values.firstWhere((k) => k.name == j['kind'], orElse: () => ImageKind.inline),
        position: (j['position'] as num?)?.toInt() ?? 0,
      );

  final String id;
  final String url;
  final ImageKind kind;
  final int position;

  Map<String, dynamic> toJson() => {'id': id, 'url': url, 'kind': kind.name, 'position': position};
}

/// posts tablosundaki bir satır (+ yazar, etiketler, görseller).
@immutable
class Post {
  const Post({
    required this.id,
    required this.authorId,
    required this.type,
    required this.title,
    required this.body,
    required this.bodyText,
    required this.excerpt,
    required this.status,
    this.personalNote,
    this.coverUrl,
    this.isPinned = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.publishedAt,
    this.editedAt,
    this.createdAt,
    this.updatedAt,
    this.author,
    this.tags = const [],
    this.images = const [],
  });

  factory Post.fromJson(Map<String, dynamic> j) {
    final author = j['author'];
    final tags = j['tags'];
    final images = j['post_images'];
    return Post(
      id: j['id'] as String,
      authorId: j['author_id'] as String,
      type: PostType.fromName(j['type'] as String?),
      title: (j['title'] as String?) ?? '',
      body: (j['body'] as List?) ?? const [],
      bodyText: (j['body_text'] as String?) ?? '',
      excerpt: (j['excerpt'] as String?) ?? '',
      status: PostStatus.fromName(j['status'] as String?),
      personalNote: j['personal_note'] as String?,
      coverUrl: j['cover_url'] as String?,
      isPinned: (j['is_pinned'] as bool?) ?? false,
      likeCount: (j['like_count'] as num?)?.toInt() ?? 0,
      commentCount: (j['comment_count'] as num?)?.toInt() ?? 0,
      publishedAt: _date(j['published_at']),
      editedAt: _date(j['edited_at']),
      createdAt: _date(j['created_at']),
      updatedAt: _date(j['updated_at']),
      author: author is Map<String, dynamic> ? ProfileSummary.fromJson(author) : null,
      tags: tags is List
          ? tags.map((t) => t is Map ? t['name'] as String : t.toString()).toList()
          : const [],
      images: images is List
          ? (images.map((e) => PostImage.fromJson(e as Map<String, dynamic>)).toList()
            ..sort((a, b) => a.position.compareTo(b.position)))
          : const [],
    );
  }

  final String id;
  final String authorId;
  final PostType type;
  final String title;

  /// flutter_quill Delta (JSON listesi)
  final List<dynamic> body;
  final String bodyText;
  final String excerpt;
  final PostStatus status;
  final String? personalNote;
  final String? coverUrl;
  final bool isPinned;
  final int likeCount;
  final int commentCount;
  final DateTime? publishedAt;
  final DateTime? editedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ProfileSummary? author;
  final List<String> tags;
  final List<PostImage> images;

  bool get isDraft => status == PostStatus.draft;
  bool get isPublished => status == PostStatus.published;
  bool get isRemoved => status == PostStatus.removed;
  List<PostImage> get gallery => images.where((i) => i.kind == ImageKind.gallery).toList();

  Post copyWith({int? likeCount, int? commentCount, bool? isPinned, PostStatus? status}) => Post(
        id: id,
        authorId: authorId,
        type: type,
        title: title,
        body: body,
        bodyText: bodyText,
        excerpt: excerpt,
        status: status ?? this.status,
        personalNote: personalNote,
        coverUrl: coverUrl,
        isPinned: isPinned ?? this.isPinned,
        likeCount: likeCount ?? this.likeCount,
        commentCount: commentCount ?? this.commentCount,
        publishedAt: publishedAt,
        editedAt: editedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
        author: author,
        tags: tags,
        images: images,
      );

  /// Çevrimdışı önbelleğe yazmak için.
  Map<String, dynamic> toJson() => {
        'id': id,
        'author_id': authorId,
        'type': type.name,
        'title': title,
        'body': body,
        'body_text': bodyText,
        'excerpt': excerpt,
        'status': status.name,
        'personal_note': personalNote,
        'cover_url': coverUrl,
        'is_pinned': isPinned,
        'like_count': likeCount,
        'comment_count': commentCount,
        'published_at': publishedAt?.toUtc().toIso8601String(),
        'edited_at': editedAt?.toUtc().toIso8601String(),
        'created_at': createdAt?.toUtc().toIso8601String(),
        'updated_at': updatedAt?.toUtc().toIso8601String(),
        'author': author?.toJson(),
        'tags': tags.map((t) => {'name': t}).toList(),
        'post_images': images.map((i) => i.toJson()).toList(),
      };

  /// Akış kartı için seçim (gövde hariç, daha hafif).
  static const cardSelect =
      'id, author_id, type, title, excerpt, cover_url, status, is_pinned, like_count, comment_count, '
      'published_at, edited_at, created_at, updated_at, '
      'author:profiles!posts_author_id_fkey(${ProfileSummary.select}), tags(name)';

  /// Detay ekranı için tam seçim.
  static const fullSelect = '*, author:profiles!posts_author_id_fkey(${ProfileSummary.select}), '
      'tags(name), post_images(id, url, kind, position)';
}

DateTime? _date(Object? v) => v == null ? null : DateTime.tryParse(v as String)?.toLocal();
