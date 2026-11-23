// Şikayet etme (herkes) ve admin paneli işlemleri.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';

enum ReportTarget { post, comment, profile }

/// Admin listesinde bir satır: aynı hedefe gelen şikayetler gruplanır.
@immutable
class ReportItem {
  const ReportItem({
    required this.targetType,
    required this.targetId,
    required this.reportCount,
    required this.firstReportedAt,
    this.targetUserId,
    this.targetNickname,
    this.postId,
    this.preview,
    this.targetStatus,
  });

  factory ReportItem.fromJson(Map<String, dynamic> j) => ReportItem(
        targetType: ReportTarget.values.firstWhere((t) => t.name == j['target_type']),
        targetId: j['target_id'] as String,
        reportCount: (j['report_count'] as num).toInt(),
        firstReportedAt: DateTime.parse(j['first_reported_at'] as String).toLocal(),
        targetUserId: j['target_user_id'] as String?,
        targetNickname: j['target_nickname'] as String?,
        postId: j['post_id'] as String?,
        preview: j['preview'] as String?,
        targetStatus: j['target_status'] as String?,
      );

  final ReportTarget targetType;
  final String targetId;
  final int reportCount;
  final DateTime firstReportedAt;
  final String? targetUserId;
  final String? targetNickname;
  final String? postId;
  final String? preview;
  final String? targetStatus;
}

enum ModerationAction { dismiss, removeContent, warn, ban }

extension on ModerationAction {
  String get wire => switch (this) {
        ModerationAction.dismiss => 'dismiss',
        ModerationAction.removeContent => 'remove_content',
        ModerationAction.warn => 'warn',
        ModerationAction.ban => 'ban',
      };
}

class ModerationRepository {
  ModerationRepository(this._client);
  final SupabaseClient _client;

  /// Şikayet et. Aynı hedef daha önce şikayet edildiyse false döner.
  Future<bool> report(ReportTarget target, String targetId) async {
    try {
      await _client.from('reports').insert({
        'reporter_id': _client.auth.currentUser!.id,
        'target_type': target.name,
        'target_id': targetId,
      });
      return true;
    } on PostgrestException catch (e) {
      if (e.code == '23505') return false;
      rethrow;
    }
  }

  Future<List<ReportItem>> listReports({String status = 'open'}) async {
    final rows = await _client.rpc('admin_list_reports', params: {'p_status': status});
    return (rows as List).map((r) => ReportItem.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<void> moderate(ReportItem item, ModerationAction action, {String? note}) => _client.rpc(
        'admin_moderate',
        params: {
          'p_target_type': item.targetType.name,
          'p_target_id': item.targetId,
          'p_action': action.wire,
          'p_note': note,
        },
      );
}

final moderationRepositoryProvider =
    Provider<ModerationRepository>((ref) => ModerationRepository(ref.watch(supabaseProvider)));
