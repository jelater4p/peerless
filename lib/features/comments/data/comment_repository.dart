import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../profile/data/profile.dart';

@immutable
class Comment {
  const Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.body,
    required this.createdAt,
    this.parentId,
    this.editedAt,
    this.author,
  });

  factory Comment.fromJson(Map<String, dynamic> j) => Comment(
        id: j['id'] as String,
        postId: j['post_id'] as String,
        authorId: j['author_id'] as String,
        parentId: j['parent_id'] as String?,
        body: j['body'] as String,
        createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
        editedAt: j['edited_at'] == null ? null : DateTime.parse(j['edited_at'] as String).toLocal(),
        author: j['author'] is Map<String, dynamic> ? ProfileSummary.fromJson(j['author'] as Map<String, dynamic>) : null,
      );

  final String id;
  final String postId;
  final String authorId;
  final String? parentId;
  final String body;
  final DateTime createdAt;
  final DateTime? editedAt;
  final ProfileSummary? author;
}

/// Ana yorum ve altındaki (tek seviye) yanıtlar.
@immutable
class CommentThread {
  const CommentThread(this.root, this.replies);
  final Comment root;
  final List<Comment> replies;
}

class CommentRepository {
  CommentRepository(this._client);
  final SupabaseClient _client;

  static const _select = '*, author:profiles!comments_author_id_fkey(${ProfileSummary.select})';

  Future<List<CommentThread>> threads(String postId) async {
    final rows = await _client
        .from('comments')
        .select(_select)
        .eq('post_id', postId)
        .eq('status', 'visible')
        .order('created_at');
    final all = rows.map(Comment.fromJson).toList();
    final roots = all.where((c) => c.parentId == null).toList();
    return [
      for (final r in roots) CommentThread(r, all.where((c) => c.parentId == r.id).toList()),
    ];
  }

  Future<Comment> add({required String postId, required String body, String? parentId}) async {
    final row = await _client
        .from('comments')
        .insert({
          'post_id': postId,
          'author_id': _client.auth.currentUser!.id,
          'parent_id': parentId,
          'body': body.trim(),
        })
        .select(_select)
        .single();
    return Comment.fromJson(row);
  }

  Future<void> edit(String id, String body) => _client.from('comments').update({'body': body.trim()}).eq('id', id);

  Future<void> delete(String id) => _client.from('comments').delete().eq('id', id);
}

final commentRepositoryProvider =
    Provider<CommentRepository>((ref) => CommentRepository(ref.watch(supabaseProvider)));
