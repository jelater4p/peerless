// İçerik okuma/yazma: akış, profil listeleri, taslaklar, yayınlama,
// beğeni, kaydetme, sabitleme, etiketler ve görseller.
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import 'post.dart';

enum FeedSort { latest, popular }

class PostRepository {
  PostRepository(this._client);
  final SupabaseClient _client;

  static const pageSize = 20;

  String get _uid => _client.auth.currentUser!.id;

  List<Post> _posts(List<dynamic> rows) =>
      rows.map((r) => Post.fromJson(r as Map<String, dynamic>)).toList();

  /// Ana akış: tür sekmesi + etiket + sıralama, 20'şer.
  Future<List<Post>> feed({PostType? type, String? tag, FeedSort sort = FeedSort.latest, int offset = 0, int limit = pageSize}) async {
    final rows = await _client.rpc('get_feed', params: {
      'p_type': type?.name,
      'p_tag': tag,
      'p_sort': sort == FeedSort.popular ? 'popular' : 'new',
      'p_limit': limit,
      'p_offset': offset,
    }).select(Post.cardSelect);
    return _posts(rows);
  }

  /// Bir kullanıcının yayındaki içerikleri (profil sekmeleri).
  Future<List<Post>> userPosts(String userId, {PostType? type, bool excludePinned = false, int offset = 0}) async {
    var q = _client.from('posts').select(Post.cardSelect).eq('author_id', userId).eq('status', 'published');
    if (type != null) q = q.eq('type', type.name);
    if (excludePinned) q = q.eq('is_pinned', false);
    final rows = await q.order('published_at', ascending: false).range(offset, offset + pageSize - 1);
    return _posts(rows);
  }

  Future<Post?> pinnedPost(String userId) async {
    final row = await _client
        .from('posts')
        .select(Post.cardSelect)
        .eq('author_id', userId)
        .eq('is_pinned', true)
        .maybeSingle();
    return row == null ? null : Post.fromJson(row);
  }

  Future<Post?> getPost(String id) async {
    final row = await _client.from('posts').select(Post.fullSelect).eq('id', id).maybeSingle();
    return row == null ? null : Post.fromJson(row);
  }

  /// Taslaklarım (en son düzenlenen başta).
  Future<List<Post>> myDrafts() async {
    final rows = await _client
        .from('posts')
        .select(Post.cardSelect)
        .eq('author_id', _uid)
        .eq('status', 'draft')
        .order('updated_at', ascending: false);
    return _posts(rows);
  }

  /// Kaydedilenler (yalnızca kullanıcı görür).
  Future<List<Post>> bookmarks({int offset = 0}) async {
    final rows = await _client
        .from('bookmarks')
        .select('created_at, post:posts(${Post.cardSelect})')
        .eq('user_id', _uid)
        .order('created_at', ascending: false)
        .range(offset, offset + pageSize - 1);
    return rows.map((r) => r['post']).whereType<Map<String, dynamic>>().map(Post.fromJson).toList();
  }

  // --- Yazma ------------------------------------------------------------

  /// Yeni taslak oluşturur (editör açılınca ilk kayıtta).
  Future<String> createDraft({required PostType type, required Map<String, dynamic> fields}) async {
    final row = await _client
        .from('posts')
        .insert({...fields, 'author_id': _uid, 'type': type.name, 'status': 'draft'})
        .select('id')
        .single();
    return row['id'] as String;
  }

  /// Alanları günceller (taslak otomatik kaydı, yayınlama, düzenleme).
  Future<void> updatePost(String id, Map<String, dynamic> fields) async {
    await _client.from('posts').update(fields).eq('id', id);
  }

  Future<void> deletePost(String id) async {
    // Önce dosyalar: post-images/<uid>/<post_id>/...
    final folder = '$_uid/$id';
    try {
      final files = await _client.storage.from('post-images').list(path: folder);
      if (files.isNotEmpty) {
        await _client.storage.from('post-images').remove(files.map((f) => '$folder/${f.name}').toList());
      }
    } catch (_) {
      // Dosya silinemese de içerik silinir.
    }
    await _client.from('posts').delete().eq('id', id);
  }

  Future<void> setTags(String postId, List<String> tags) =>
      _client.rpc('set_post_tags', params: {'p_post_id': postId, 'p_tags': tags});

  Future<void> setPinned(String postId, bool pinned) =>
      _client.rpc('set_pinned_post', params: {'p_post_id': postId, 'p_pinned': pinned});

  /// Etiket önerileri (mevcut etiketlerden, önek eşleşmesi).
  Future<List<String>> suggestTags(String prefix) async {
    final p = prefix.replaceAll('%', '').replaceAll('_', r'\_');
    if (p.isEmpty) return const [];
    final rows = await _client.from('tags').select('name').ilike('name', '$p%').order('name').limit(8);
    return rows.map((r) => r['name'] as String).toList();
  }

  /// Popüler etiketler (akış filtresi için): son içeriklerde en çok geçenler.
  Future<List<String>> popularTags() async {
    final rows = await _client.rpc('get_feed', params: {'p_limit': 50}).select('tags(name)');
    final counts = <String, int>{};
    for (final r in rows) {
      for (final t in (r['tags'] as List? ?? const [])) {
        final n = t['name'] as String;
        counts[n] = (counts[n] ?? 0) + 1;
      }
    }
    final list = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return list.take(15).map((e) => e.key).toList();
  }

  // --- Görseller ----------------------------------------------------------

  /// `post-images/<uid>/<post_id>/<zaman>.jpg` yükler, herkese açık URL döner.
  Future<String> uploadImage(String postId, Uint8List jpeg) async {
    final path = '$_uid/$postId/${DateTime.now().microsecondsSinceEpoch}.jpg';
    await _client.storage.from('post-images').uploadBinary(
          path,
          jpeg,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return _client.storage.from('post-images').getPublicUrl(path);
  }

  Future<List<PostImage>> images(String postId) async {
    final rows = await _client.from('post_images').select().eq('post_id', postId).order('position');
    return rows.map(PostImage.fromJson).toList();
  }

  Future<PostImage> addImageRecord(String postId, String url, ImageKind kind, int position) async {
    final row = await _client
        .from('post_images')
        .insert({'post_id': postId, 'url': url, 'kind': kind.name, 'position': position})
        .select()
        .single();
    return PostImage.fromJson(row);
  }

  Future<void> removeImage(PostImage image) async {
    await _client.from('post_images').delete().eq('id', image.id);
    final path = storagePathFromUrl(image.url, 'post-images');
    if (path != null) {
      try {
        await _client.storage.from('post-images').remove([path]);
      } catch (_) {}
    }
  }

  // --- Beğeni ve kaydetme ---------------------------------------------------

  Future<Set<String>> likedAmong(List<String> postIds) async {
    if (postIds.isEmpty) return {};
    final rows = await _client.from('likes').select('post_id').eq('user_id', _uid).inFilter('post_id', postIds);
    return rows.map((r) => r['post_id'] as String).toSet();
  }

  Future<bool> isLiked(String postId) async => (await likedAmong([postId])).isNotEmpty;

  Future<void> like(String postId) => _client.from('likes').insert({'user_id': _uid, 'post_id': postId});

  Future<void> unlike(String postId) =>
      _client.from('likes').delete().eq('user_id', _uid).eq('post_id', postId);

  Future<bool> isBookmarked(String postId) async {
    final row = await _client
        .from('bookmarks')
        .select('post_id')
        .eq('user_id', _uid)
        .eq('post_id', postId)
        .maybeSingle();
    return row != null;
  }

  Future<void> bookmark(String postId) => _client.from('bookmarks').insert({'user_id': _uid, 'post_id': postId});

  Future<void> unbookmark(String postId) =>
      _client.from('bookmarks').delete().eq('user_id', _uid).eq('post_id', postId);

  // --- Arama --------------------------------------------------------------

  Future<List<Post>> search(String query, {int offset = 0}) async {
    final rows = await _client.rpc('search_posts', params: {
      'p_query': query,
      'p_limit': pageSize,
      'p_offset': offset,
    }).select(Post.cardSelect);
    return _posts(rows);
  }
}

final postRepositoryProvider = Provider<PostRepository>((ref) => PostRepository(ref.watch(supabaseProvider)));
