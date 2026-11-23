// Uygulamanın her yerinde kullanılan küçük ortak widget'lar.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/post/data/post.dart';
import '../errors/error_text.dart';
import '../l10n.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Ekranın altında kısa mesaj gösterir. Navigasyon sonrası da çalışsın diye
/// MaterialApp'e bağlı global anahtar kullanılır.
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void showSnack(String message) {
  scaffoldMessengerKey.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

void showError(BuildContext context, Object error) => showSnack(errorText(context.l10n, error));

/// Geçici logo: accent zemin üzerinde Playfair Display ile "P".
class PeerlessLogo extends StatelessWidget {
  const PeerlessLogo({super.key, this.size = 64});
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(size * 0.22)),
      child: Text(
        'P',
        style: TextStyle(
          fontFamily: Fonts.display,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.62,
          height: 1,
          color: c.onAccent,
        ),
      ),
    );
  }
}

/// Yuvarlak profil fotoğrafı; yoksa adın baş harfi.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.url, required this.name, this.size = 40});
  final String? url;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final letter = name.replaceAll('@', '').trim();
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: c.accentSoft,
      child: Text(
        letter.isEmpty ? '?' : letter.characters.first.toUpperCase(),
        style: TextStyle(color: c.ink, fontWeight: FontWeight.w600, fontSize: size * 0.42),
      ),
    );
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: url == null || url!.isEmpty
            ? fallback
            : CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                placeholder: (_, _) => fallback,
                errorWidget: (_, _, _) => fallback,
              ),
      ),
    );
  }
}

/// Önbellekli ağ görseli (8px köşe).
class NetImage extends StatelessWidget {
  const NetImage({super.key, required this.url, this.width, this.height, this.fit = BoxFit.cover, this.radius = Radii.md});
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, _) => Container(width: width, height: height, color: c.surface),
        errorWidget: (_, _, _) => Container(
          width: width,
          height: height,
          color: c.surface,
          alignment: Alignment.center,
          child: Icon(LucideIcons.image, color: c.inkMuted),
        ),
      ),
    );
  }
}

extension PostTypeUi on PostType {
  /// Tür ikonları: alıntı tırnak, düşünce ampul, tez kitap, proje klasör.
  IconData get icon => switch (this) {
        PostType.quote => LucideIcons.quote,
        PostType.thought => LucideIcons.lightbulb,
        PostType.thesis => LucideIcons.bookOpen,
        PostType.project => LucideIcons.folder,
      };

  String label(AppLocalizations l) => switch (this) {
        PostType.quote => l.typeQuote,
        PostType.thought => l.typeThought,
        PostType.thesis => l.typeThesis,
        PostType.project => l.typeProject,
      };

  String pluralLabel(AppLocalizations l) => switch (this) {
        PostType.quote => l.typeQuotes,
        PostType.thought => l.typeThoughts,
        PostType.thesis => l.typeTheses,
        PostType.project => l.typeProjects,
      };
}

/// Boş liste / sonuç yok görünümü.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.action});
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Space.space8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: c.inkMuted),
            const SizedBox(height: Space.space4),
            Text(title, style: context.text.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: Space.space2),
              Text(message!, style: context.text.bodyMedium?.copyWith(color: c.inkMuted), textAlign: TextAlign.center),
            ],
            if (action != null) ...[const SizedBox(height: Space.space6), action!],
          ],
        ),
      ),
    );
  }
}

/// Hata görünümü + tekrar dene.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, this.onRetry});
  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return EmptyState(
      icon: isNetworkError(error) ? LucideIcons.wifiOff : LucideIcons.info,
      title: errorText(l, error),
      action: onRetry == null ? null : OutlinedButton(onPressed: onRetry, child: Text(l.retry)),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5)));
}

/// Yüklenirken dönen çark gösteren birincil buton.
class LoadingButton extends StatelessWidget {
  const LoadingButton({super.key, required this.label, required this.onPressed, this.loading = false, this.expand = true});
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.inkMuted),
            )
          : Text(label),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Onay penceresi. Yıkıcı eylemlerde onay butonu danger renginde.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  String? message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final c = context.colors;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: message == null ? null : Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(ctx.l10n.cancel, style: TextStyle(color: c.inkMuted)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel, style: TextStyle(color: destructive ? c.danger : c.accent)),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// İnce ayırıcı çizgi (gölge yerine).
class Hairline extends StatelessWidget {
  const Hairline({super.key, this.indent = 0});
  final double indent;

  @override
  Widget build(BuildContext context) => Divider(height: 1, thickness: 1, indent: indent, color: context.colors.hairline);
}
