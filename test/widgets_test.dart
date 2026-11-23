import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:peerless/core/theme/app_theme.dart';
import 'package:peerless/core/theme/tokens.dart';
import 'package:peerless/features/feed/widgets/post_card.dart';
import 'package:peerless/features/post/data/post.dart';
import 'package:peerless/features/profile/data/profile.dart';
import 'package:peerless/l10n/app_localizations.dart';

Widget wrap(Widget child, {Locale locale = const Locale('tr')}) => MaterialApp(
      theme: AppTheme.build(PeerlessPalette.dark),
      locale: locale,
      localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  final post = Post(
    id: 'p1',
    authorId: 'u1',
    type: PostType.thought,
    title: 'Stoacılık ve modern hayat',
    body: const [],
    bodyText: '',
    excerpt: 'Kartın iki satırlık özeti burada görünür.',
    status: PostStatus.published,
    likeCount: 12,
    commentCount: 0,
    publishedAt: DateTime.now().subtract(const Duration(days: 3)),
    author: const ProfileSummary(id: 'u1', nickname: 'mehce', displayName: 'Mehçe'),
  );

  testWidgets('İçerik kartı başlık, özet, yazar ve tarihi gösterir', (tester) async {
    await tester.pumpWidget(wrap(PostCard(post: post, onTap: () {})));
    await tester.pumpAndSettle();
    expect(find.text('Stoacılık ve modern hayat'), findsOneWidget);
    expect(find.text('Kartın iki satırlık özeti burada görünür.'), findsOneWidget);
    expect(find.text('Mehçe'), findsOneWidget);
    expect(find.text('3 gün önce'), findsOneWidget);
    expect(find.text('12'), findsOneWidget); // beğeni sayısı
  });

  testWidgets('Sabitlenmiş rozet yalnızca istenince görünür', (tester) async {
    final pinned = Post.fromJson({...post.toJson(), 'is_pinned': true});
    await tester.pumpWidget(wrap(PostCard(post: pinned, showPinned: true, onTap: () {})));
    await tester.pumpAndSettle();
    expect(find.text('Sabitlendi'), findsOneWidget);

    await tester.pumpWidget(wrap(PostCard(post: pinned, onTap: () {})));
    await tester.pumpAndSettle();
    expect(find.text('Sabitlendi'), findsNothing);
  });

  testWidgets('İngilizce arayüz', (tester) async {
    await tester.pumpWidget(wrap(PostCard(post: post.copyWith(), onTap: () {}), locale: const Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text('3 d ago'), findsOneWidget);
  });
}
