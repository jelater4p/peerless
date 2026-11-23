import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../profile/data/profile.dart';

enum NotificationKind { comment, reply, like, mention, moderation }

@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.createdAt,
    this.actor,
    this.postId,
    this.postTitle,
    this.commentId,
    this.meta = const {},
    this.readAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'] as String,
        kind: NotificationKind.values.firstWhere((k) => k.name == j['type'], orElse: () => NotificationKind.comment),
        createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
        actor: j['actor'] is Map<String, dynamic> ? ProfileSummary.fromJson(j['actor'] as Map<String, dynamic>) : null,
        postId: j['post_id'] as String?,
        postTitle: (j['post'] as Map?)?['title'] as String?,
        commentId: j['comment_id'] as String?,
        meta: (j['meta'] as Map?)?.cast<String, dynamic>() ?? const {},
        readAt: j['read_at'] == null ? null : DateTime.parse(j['read_at'] as String).toLocal(),
      );

  final String id;
  final NotificationKind kind;
  final DateTime createdAt;
  final ProfileSummary? actor;
  final String? postId;
  final String? postTitle;
  final String? commentId;
  final Map<String, dynamic> meta;
  final DateTime? readAt;

  bool get isUnread => readAt == null;
}

@immutable
class NotificationSettings {
  const NotificationSettings({this.comment = true, this.reply = true, this.like = true, this.mention = true});

  factory NotificationSettings.fromJson(Map<String, dynamic> j) => NotificationSettings(
        comment: j['comment'] as bool? ?? true,
        reply: j['reply'] as bool? ?? true,
        like: j['like'] as bool? ?? true,
        mention: j['mention'] as bool? ?? true,
      );

  final bool comment;
  final bool reply;
  final bool like;
  final bool mention;
}

class NotificationRepository {
  NotificationRepository(this._client);
  final SupabaseClient _client;

  static const pageSize = 30;
  String get _uid => _client.auth.currentUser!.id;

  Future<List<AppNotification>> list({int offset = 0}) async {
    final rows = await _client
        .from('notifications')
        .select('*, actor:profiles!notifications_actor_id_fkey(${ProfileSummary.select}), post:posts(title)')
        .eq('recipient_id', _uid)
        .order('created_at', ascending: false)
        .range(offset, offset + pageSize - 1);
    return rows.map(AppNotification.fromJson).toList();
  }

  Future<int> unreadCount() async {
    final res = await _client
        .from('notifications')
        .select('id')
        .eq('recipient_id', _uid)
        .isFilter('read_at', null)
        .count(CountOption.exact);
    return res.count;
  }

  Future<void> markAllRead() => _client
      .from('notifications')
      .update({'read_at': DateTime.now().toUtc().toIso8601String()})
      .eq('recipient_id', _uid)
      .isFilter('read_at', null);

  Future<NotificationSettings> settings() async {
    final row = await _client.from('notification_settings').select().eq('user_id', _uid).maybeSingle();
    return row == null ? const NotificationSettings() : NotificationSettings.fromJson(row);
  }

  /// field: comment | reply | like | mention
  Future<void> updateSetting(String field, bool value) =>
      _client.from('notification_settings').update({field: value}).eq('user_id', _uid);

  Future<void> registerDeviceToken(String token) =>
      _client.rpc('register_device_token', params: {'p_token': token, 'p_platform': 'android'});

  Future<void> removeDeviceToken(String token) => _client.from('device_tokens').delete().eq('token', token);

  /// Yeni bildirim gelince (Realtime) haber verir; rozet sayısını yenilemek için.
  RealtimeChannel subscribe(void Function() onInsert) {
    return _client
        .channel('notifications:$_uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'recipient_id', value: _uid),
          callback: (_) => onInsert(),
        )
        .subscribe();
  }
}

final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) => NotificationRepository(ref.watch(supabaseProvider)));
