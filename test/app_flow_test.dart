// Uygulamanın tamamını açan duman testi: oturum yokken tanıtım → giriş →
// kayıt → şifre sıfırlama ekranları hatasız açılmalı. (Sunucuya bağlanmaz.)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:peerless/app.dart';
import 'package:peerless/core/settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'http://localhost:54321',
      publishableKey: 'test-key',
      authOptions: const FlutterAuthClientOptions(localStorage: EmptyLocalStorage(), detectSessionInUri: false),
    );
  });

  Future<void> boot(WidgetTester tester, {bool seenIntro = false}) async {
    SharedPreferences.setMockInitialValues({'seen_intro': seenIntro, 'locale': 'tr'});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        retry: (_, _) => null,
        child: const PeerlessApp(),
      ),
    );
    // Oturum kontrolü (initialSession) bitsin.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  testWidgets('İlk açılış: tanıtım ekranları → giriş', (tester) async {
    await boot(tester);
    expect(find.text('Kendi kütüphaneni kur'), findsOneWidget);
    await tester.tap(find.text('İleri'));
    await tester.pumpAndSettle();
    expect(find.text('Okumaya odaklan'), findsOneWidget);
    await tester.tap(find.text('İleri'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Başla'));
    await tester.pumpAndSettle();
    expect(find.text('Tekrar hoş geldin'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Giriş formu doğrulaması ve kayıt / şifre sıfırlama ekranları', (tester) async {
    await boot(tester, seenIntro: true);
    expect(find.text('Tekrar hoş geldin'), findsOneWidget);

    // Boş formla giriş → alan hataları
    await tester.tap(find.widgetWithText(FilledButton, 'Giriş yap'));
    await tester.pumpAndSettle();
    expect(find.text('Geçerli bir e-posta adresi yaz'), findsOneWidget);
    expect(find.text('Bu alan gerekli'), findsOneWidget);

    // Kayıt ekranı: onay kutuları işaretlenmeden devam edilemez
    await tester.tap(find.widgetWithText(TextButton, 'Kayıt ol'));
    await tester.pumpAndSettle();
    expect(find.text('Hesap oluştur'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'ayse@ornek.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Kayıt ol'));
    await tester.pumpAndSettle();
    expect(find.text('Devam etmek için iki kutuyu da işaretle'), findsOneWidget);

    // Geri → şifremi unuttum (pageBack() eski Material'ın geri butonunu arar)
    Navigator.of(tester.element(find.text('Hesap oluştur'))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Şifremi unuttum'));
    await tester.pumpAndSettle();
    expect(find.text('Şifreni sıfırla'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
