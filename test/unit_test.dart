import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:peerless/core/supabase/supabase_providers.dart';
import 'package:peerless/core/theme/app_theme.dart';
import 'package:peerless/core/theme/tokens.dart';
import 'package:peerless/core/update/update_checker.dart';
import 'package:peerless/core/utils/formatters.dart';
import 'package:peerless/features/post/data/post.dart';
import 'package:peerless/features/profile/widgets/nickname_field.dart';
import 'package:peerless/l10n/app_localizations.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('Sürüm karşılaştırma', () {
    test('daha yeni sürüm algılanır', () {
      expect(isNewerVersion('1.0.1', '1.0.0'), isTrue);
      expect(isNewerVersion('1.2.10', '1.2.9'), isTrue);
      expect(isNewerVersion('2.0.0', '1.9.9'), isTrue);
    });
    test('aynı ya da eski sürüm yeni sayılmaz', () {
      expect(isNewerVersion('1.0.0', '1.0.0'), isFalse);
      expect(isNewerVersion('1.0.0', '1.0.1'), isFalse);
      expect(isNewerVersion('1.0.0+5', '1.0.0'), isFalse);
    });
  });

  group('Etiket ve nickname kuralları', () {
    test('etiket temizlenir ve Türkçe küçük harfe çevrilir', () {
      expect(normalizeTag('#Felsefe'), 'felsefe');
      expect(normalizeTag('  ISPARTA '), 'ısparta');
      expect(normalizeTag('İstanbul'), 'istanbul');
      expect(normalizeTag('ISTANBUL', turkish: false), 'istanbul');
      expect(normalizeTag('a,b@c'), 'abc');
    });
    test('nickname deseni', () {
      expect(nicknamePattern.hasMatch('ayse_y.1'), isTrue);
      expect(nicknamePattern.hasMatch('ay'), isFalse);
      expect(nicknamePattern.hasMatch('ayşe'), isFalse);
      expect(nicknamePattern.hasMatch('Ayse'), isFalse);
      expect(nicknamePattern.hasMatch('a' * 21), isFalse);
    });
  });

  test('Storage URL\'den dosya yolu çıkarılır', () {
    const url = 'https://x.supabase.co/storage/v1/object/public/post-images/u1/p1/a.jpg?v=3';
    expect(storagePathFromUrl(url, 'post-images'), 'u1/p1/a.jpg');
    expect(storagePathFromUrl(url, 'avatars'), isNull);
  });

  test('Post JSON gidiş-dönüş (çevrimdışı önbellek için)', () {
    final json = {
      'id': 'p1',
      'author_id': 'u1',
      'type': 'quote',
      'title': 'Başlık',
      'body': [
        {'insert': 'Merhaba\n'},
      ],
      'body_text': 'Merhaba',
      'excerpt': 'Merhaba',
      'status': 'published',
      'personal_note': 'not',
      'like_count': 3,
      'comment_count': 1,
      'published_at': '2026-11-20T10:00:00Z',
      'author': {'id': 'u1', 'nickname': 'ayse', 'display_name': 'Ayşe', 'avatar_url': null},
      'tags': [
        {'name': 'felsefe'},
      ],
      'post_images': [
        {'id': 'i2', 'url': 'b', 'kind': 'gallery', 'position': 1},
        {'id': 'i1', 'url': 'a', 'kind': 'cover', 'position': 0},
      ],
    };
    final post = Post.fromJson(json);
    expect(post.type, PostType.quote);
    expect(post.author?.name, 'Ayşe');
    expect(post.tags, ['felsefe']);
    expect(post.images.first.id, 'i1');
    expect(post.gallery.single.url, 'b');
    final again = Post.fromJson(post.toJson());
    expect(again.title, post.title);
    expect(again.likeCount, 3);
    expect(again.publishedAt, post.publishedAt);
    expect(again.tags, post.tags);
  });

  test('Göreli zaman TR/EN', () {
    final tr = lookupAppLocalizations(const Locale('tr'));
    final en = lookupAppLocalizations(const Locale('en'));
    final now = DateTime.now();
    expect(relativeTime(tr, now), 'az önce');
    expect(relativeTime(tr, now.subtract(const Duration(days: 3))), '3 gün önce');
    expect(relativeTime(en, now.subtract(const Duration(hours: 2))), '2 h ago');
    expect(tr.commentsCount(0), 'Yorum yok');
    expect(en.commentsCount(1), '1 comment');
  });

  group('Tema', () {
    for (final (name, p) in [
      ('koyu', PeerlessPalette.dark),
      ('açık', PeerlessPalette.light),
      ('sepya', PeerlessPalette.sepia),
    ]) {
      test('$name temada metin kontrastı en az 4.5:1', () {
        expect(contrast(p.ink, p.bg), greaterThanOrEqualTo(4.5));
        expect(contrast(p.ink, p.surface), greaterThanOrEqualTo(4.5));
        expect(contrast(p.inkMuted, p.bg), greaterThanOrEqualTo(4.5));
        expect(contrast(p.inkMuted, p.surface), greaterThanOrEqualTo(4.5));
        expect(contrast(p.onAccent, p.accent), greaterThanOrEqualTo(4.5));
        expect(contrast(p.ink, p.accentSoft), greaterThanOrEqualTo(4.5));
      });
      test('$name tema ThemeData üretir', () {
        final theme = AppTheme.build(p);
        expect(theme.extension<PeerlessColors>()!.palette, p);
        expect(theme.scaffoldBackgroundColor, p.bg);
      });
    }
  });
}
