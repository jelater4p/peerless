import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/comment_repository.dart';

/// Bir içeriğin yorumları (ana yorum + tek seviye yanıtlar).
class CommentsController extends AsyncNotifier<List<CommentThread>> {
  CommentsController(this.postId);
  final String postId;

  CommentRepository get _repo => ref.read(commentRepositoryProvider);

  @override
  FutureOr<List<CommentThread>> build() => ref.watch(commentRepositoryProvider).threads(postId);

  Future<void> reload() async {
    state = await AsyncValue.guard(() => _repo.threads(postId));
  }

  Future<void> add(String body, {String? parentId}) async {
    await _repo.add(postId: postId, body: body, parentId: parentId);
    await reload();
  }

  Future<void> edit(String id, String body) async {
    await _repo.edit(id, body);
    await reload();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    await reload();
  }
}

final commentsProvider =
    AsyncNotifierProvider.family<CommentsController, List<CommentThread>, String>(CommentsController.new);

/// Toplam görünür yorum sayısı (ana + yanıt).
int commentTotal(List<CommentThread> threads) =>
    threads.fold(0, (sum, t) => sum + 1 + t.replies.length);
