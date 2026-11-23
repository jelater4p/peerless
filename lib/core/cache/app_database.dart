// Çevrimdışı önbellek (drift / SQLite): son yüklenen akış ve açılan içerikler
// internetsiz de görünsün diye telefonda saklanır.
// Tablo değişirse kod üretimi: dart run build_runner build
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/post/data/post.dart';

part 'app_database.g.dart';

/// Açılmış içeriklerin tam hali.
class CachedPosts extends Table {
  TextColumn get id => text()();
  TextColumn get data => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Listelerin ilk sayfası (ör. `feed:all:latest`, `user:<id>:all`).
class CachedLists extends Table {
  TextColumn get listKey => text()();
  TextColumn get data => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {listKey};
}

@DriftDatabase(tables: [CachedPosts, CachedLists])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'peerless_cache'));

  @override
  int get schemaVersion => 1;

  Future<void> savePost(Post post) => into(cachedPosts).insertOnConflictUpdate(
        CachedPostsCompanion.insert(id: post.id, data: jsonEncode(post.toJson()), cachedAt: DateTime.now()),
      );

  Future<Post?> getPost(String id) async {
    final row = await (select(cachedPosts)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : Post.fromJson(jsonDecode(row.data) as Map<String, dynamic>);
  }

  Future<void> saveList(String key, List<Post> posts) => into(cachedLists).insertOnConflictUpdate(
        CachedListsCompanion.insert(
          listKey: key,
          data: jsonEncode(posts.map((p) => p.toJson()).toList()),
          cachedAt: DateTime.now(),
        ),
      );

  Future<List<Post>?> getList(String key) async {
    final row = await (select(cachedLists)..where((t) => t.listKey.equals(key))).getSingleOrNull();
    if (row == null) return null;
    return (jsonDecode(row.data) as List).map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// 30 günden eski kayıtları temizler.
  Future<void> prune() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    await (delete(cachedPosts)..where((t) => t.cachedAt.isSmallerThanValue(cutoff))).go();
    await (delete(cachedLists)..where((t) => t.cachedAt.isSmallerThanValue(cutoff))).go();
  }

  /// Çıkış yapınca önbellek silinir.
  Future<void> clearAll() async {
    await delete(cachedPosts).go();
    await delete(cachedLists).go();
  }
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  db.prune();
  ref.onDispose(db.close);
  return db;
});
