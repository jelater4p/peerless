// Uygulama içi admin paneli: yalnızca is_admin() true dönen hesaplara görünür.
// Şikayetler (hedef bazında gruplanmış) + yaptırımlar; uygulama sürümü ayarı.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../post/post_events.dart';
import '../data/moderation_repository.dart';

final openReportsProvider = FutureProvider.autoDispose<List<ReportItem>>(
  (ref) => ref.watch(moderationRepositoryProvider).listReports(),
);

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.adminPanel),
          bottom: TabBar(tabs: [Tab(text: l.reports), Tab(text: l.appVersion)]),
        ),
        body: const TabBarView(children: [_ReportsTab(), _AppConfigTab()]),
      ),
    );
  }
}

class _ReportsTab extends ConsumerWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final async = ref.watch(openReportsProvider);
    return RefreshIndicator(
      onRefresh: () => ref.refresh(openReportsProvider.future),
      child: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(openReportsProvider)),
        data: (items) => items.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 120),
                  EmptyState(icon: LucideIcons.shieldCheck, title: l.noOpenReports),
                ],
              )
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Hairline(),
                itemBuilder: (_, i) => _ReportTile(item: items[i]),
              ),
      ),
    );
  }
}

class _ReportTile extends ConsumerWidget {
  const _ReportTile({required this.item});
  final ReportItem item;

  Future<void> _act(BuildContext context, WidgetRef ref, ModerationAction action) async {
    final l = context.l10n;
    String? note;
    if (action != ModerationAction.dismiss) {
      final controller = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(_actionLabel(l, action)),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(labelText: l.adminNoteOptional),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(_actionLabel(l, action), style: TextStyle(color: ctx.colors.danger)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      note = controller.text.trim();
    }
    try {
      await ref.read(moderationRepositoryProvider).moderate(item, action, note: note);
      ref.invalidate(openReportsProvider);
      ref.read(postsVersionProvider.notifier).bump();
      showSnack(l.moderationDone);
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  void _view(BuildContext context) {
    switch (item.targetType) {
      case ReportTarget.post:
      case ReportTarget.comment:
        if (item.postId != null) context.push(Routes.post(item.postId!));
      case ReportTarget.profile:
        context.push(Routes.user(item.targetId));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    final typeLabel = switch (item.targetType) {
      ReportTarget.post => l.reportTargetPost,
      ReportTarget.comment => l.reportTargetComment,
      ReportTarget.profile => l.reportTargetProfile,
    };
    return Padding(
      padding: const EdgeInsets.all(Space.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                switch (item.targetType) {
                  ReportTarget.post => LucideIcons.fileText,
                  ReportTarget.comment => LucideIcons.messageCircle,
                  ReportTarget.profile => LucideIcons.user,
                },
                size: 16,
                color: c.inkMuted,
              ),
              const SizedBox(width: Space.space2),
              Text(typeLabel, style: context.text.labelMedium),
              const Spacer(),
              Text(l.reportCount(item.reportCount), style: context.text.labelSmall?.copyWith(color: c.danger)),
            ],
          ),
          const SizedBox(height: Space.space2),
          Text(
            (item.preview?.trim().isEmpty ?? true) ? '—' : item.preview!,
            style: context.text.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Space.space1),
          Text(
            '@${item.targetNickname ?? '?'} · ${relativeTime(l, item.firstReportedAt)}'
            '${item.targetStatus != null && item.targetStatus != 'visible' && item.targetStatus != 'published' && item.targetStatus != 'active' ? ' · ${item.targetStatus}' : ''}',
            style: context.text.bodySmall,
          ),
          const SizedBox(height: Space.space2),
          Wrap(
            spacing: Space.space2,
            runSpacing: Space.space2,
            children: [
              OutlinedButton(onPressed: () => _view(context), child: Text(l.view)),
              OutlinedButton(onPressed: () => _act(context, ref, ModerationAction.dismiss), child: Text(l.dismiss)),
              OutlinedButton(
                onPressed: () => _act(context, ref, ModerationAction.removeContent),
                child: Text(l.removeContent),
              ),
              OutlinedButton(onPressed: () => _act(context, ref, ModerationAction.warn), child: Text(l.warn)),
              OutlinedButton(
                onPressed: () => _act(context, ref, ModerationAction.ban),
                style: OutlinedButton.styleFrom(foregroundColor: c.danger),
                child: Text(l.ban),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _actionLabel(AppLocalizations l, ModerationAction a) => switch (a) {
      ModerationAction.dismiss => l.dismiss,
      ModerationAction.removeContent => l.removeContent,
      ModerationAction.warn => l.warn,
      ModerationAction.ban => l.ban,
    };

/// 'Yeni sürüm var' uyarısının ayarı (app_config tablosu).
class _AppConfigTab extends ConsumerStatefulWidget {
  const _AppConfigTab();

  @override
  ConsumerState<_AppConfigTab> createState() => _AppConfigTabState();
}

class _AppConfigTabState extends ConsumerState<_AppConfigTab> {
  final _latest = TextEditingController();
  final _min = TextEditingController();
  final _url = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _latest.dispose();
    _min.dispose();
    _url.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final row = await ref.read(supabaseProvider).from('app_config').select().eq('id', 1).single();
      _latest.text = row['latest_version'] as String? ?? '';
      _min.text = row['min_version'] as String? ?? '';
      _url.text = row['apk_url'] as String? ?? '';
    } catch (e) {
      if (mounted) showError(context, e);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(supabaseProvider).from('app_config').update({
        'latest_version': _latest.text.trim(),
        'min_version': _min.text.trim(),
        'apk_url': _url.text.trim().isEmpty ? null : _url.text.trim(),
      }).eq('id', 1);
      if (mounted) showSnack(context.l10n.saved);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (_loading) return const LoadingView();
    return ListView(
      padding: const EdgeInsets.all(Space.space4),
      children: [
        Text(l.appVersionHelp, style: context.text.bodySmall),
        const SizedBox(height: Space.space4),
        TextField(controller: _latest, decoration: InputDecoration(labelText: l.latestVersion, hintText: '1.0.1')),
        const SizedBox(height: Space.space3),
        TextField(controller: _min, decoration: InputDecoration(labelText: l.minVersion, hintText: '1.0.0')),
        const SizedBox(height: Space.space3),
        TextField(
          controller: _url,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(labelText: l.apkUrl, hintText: 'https://…/peerless-1.0.1.apk'),
        ),
        const SizedBox(height: Space.space6),
        LoadingButton(label: l.save, loading: _saving, onPressed: _save),
      ],
    );
  }
}
