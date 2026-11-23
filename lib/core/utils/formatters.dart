import 'package:intl/intl.dart';

import '../l10n.dart';

/// "az önce", "5 dk önce", "3 gün önce"; bir haftadan eskiyse tarih.
String relativeTime(AppLocalizations l, DateTime? date) {
  if (date == null) return '';
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return l.timeJustNow;
  if (diff.inHours < 1) return l.timeMinutes(diff.inMinutes);
  if (diff.inDays < 1) return l.timeHours(diff.inHours);
  if (diff.inDays < 7) return l.timeDays(diff.inDays);
  return DateFormat.yMMMd(l.localeName).format(date);
}

String fullDate(AppLocalizations l, DateTime? date) =>
    date == null ? '' : DateFormat.yMMMMd(l.localeName).format(date);

/// Türkçe kurallarıyla küçük harf (I → ı, İ → i). Etiketler için kullanılır.
String lowerTr(String s, {bool turkish = true}) {
  final x = turkish ? s.replaceAll('I', 'ı') : s;
  return x.replaceAll('İ', 'i').toLowerCase();
}

/// Etiket metnini temizler: '#' ve boşlukları atar, küçük harfe çevirir.
String normalizeTag(String raw, {bool turkish = true}) {
  final t = raw.trim().replaceAll(RegExp(r'^#+'), '').replaceAll(RegExp(r'[#,@]'), '');
  return lowerTr(t, turkish: turkish).trim();
}

/// Sayıları kısaltır: 1200 → 1,2B (TR) / 1.2K (EN)
String compactCount(AppLocalizations l, int n) =>
    n < 1000 ? '$n' : NumberFormat.compact(locale: l.localeName).format(n);
