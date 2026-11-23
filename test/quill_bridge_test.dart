// flutter_quill eski Material'ı kullanıyor; uygulama material_ui kullanıyor.
// Bu testler köprünün (QuillMaterialBridge) çalışma anında hata vermediğini doğrular.
// ignore: deprecated_member_use
import 'package:flutter_localizations/flutter_localizations.dart' as framework;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:peerless/core/settings/app_settings.dart';
import 'package:peerless/core/theme/app_theme.dart';
import 'package:peerless/core/theme/reading_styles.dart';
import 'package:peerless/core/theme/tokens.dart';
import 'package:peerless/features/editor/widgets/editor_toolbar.dart';
import 'package:peerless/features/editor/widgets/quill_support.dart';
import 'package:peerless/l10n/app_localizations.dart';

const settings = AppSettings(
  locale: null,
  theme: AppThemeChoice.dark,
  readingFont: ReadingFont.tinos,
  readingSize: ReadingSize.medium,
  readingLineHeight: ReadingLineHeight.normal,
  readingTheme: ReadingTheme.sepia,
  seenIntro: true,
  recentSearches: [],
);

Widget wrap(Widget child) => MaterialApp(
      theme: AppTheme.build(PeerlessPalette.dark),
      locale: const Locale('tr'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
        // ignore: deprecated_member_use
        framework.GlobalMaterialLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  testWidgets('Okuma görünümü biçimli Delta\'yı gösterir', (tester) async {
    final delta = [
      {'insert': 'Bölüm başlığı'},
      {
        'insert': '\n',
        'attributes': {'header': 2},
      },
      {'insert': 'Kalın', 'attributes': {'bold': true}},
      {'insert': ' ve düz metin. '},
      {'insert': 'Link', 'attributes': {'link': 'https://ornek.com'}},
      {'insert': '\nBir alıntı'},
      {
        'insert': '\n',
        'attributes': {'blockquote': true},
      },
      {'insert': 'madde'},
      {
        'insert': '\n',
        'attributes': {'list': 'bullet'},
      },
    ];
    await tester.pumpWidget(wrap(PostBodyView(delta: delta, styles: ReadingStyles.of(settings))));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Bölüm başlığı', findRichText: true), findsOneWidget);
    expect(find.textContaining('Bir alıntı', findRichText: true), findsOneWidget);
  });

  testWidgets('Editör + araç çubuğu: yazma ve kalın yapma', (tester) async {
    final controller = QuillController.basic();
    await tester.pumpWidget(
      wrap(
        Column(
          children: [
            EditorToolbar(controller: controller, onAddImage: () {}, canAddImage: true),
            QuillMaterialBridge(
              child: QuillEditor(
                controller: controller,
                focusNode: FocusNode(),
                scrollController: ScrollController(),
                config: QuillEditorConfig(
                  scrollable: false,
                  minHeight: 100,
                  placeholder: 'Yazmaya başla…',
                  customStyles: quillStyles(ReadingStyles.of(settings, palette: PeerlessPalette.dark)),
                  embedBuilders: const [ImageEmbedBuilder()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    controller.replaceText(0, 0, 'Merhaba dünya', const TextSelection.collapsed(offset: 13));
    controller.updateSelection(const TextSelection(baseOffset: 0, extentOffset: 7), ChangeSource.local);
    await tester.tap(find.byTooltip('Kalın'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final ops = controller.document.toDelta().toJson();
    expect(ops.first['insert'], 'Merhaba');
    expect(ops.first['attributes'], {'bold': true});
    expect(controller.document.toPlainText().trim(), 'Merhaba dünya');

    // Görsel gömme: Delta'ya resim eklenebilmeli
    controller.replaceText(13, 0, BlockEmbed.image('https://ornek.com/a.jpg'), null);
    await tester.pump();
    expect(
      controller.document.toDelta().toJson().any((op) => op['insert'] is Map && op['insert']['image'] != null),
      isTrue,
    );
  });
}
