# Peerless

Herkesin profilinin kendi kütüphanesi olduğu, okuma odaklı bir Android uygulaması:
**alıntılar, düşünceler, tezler ve projeler.** Medium'dan esinlenir; takip sistemi yoktur,
keşif sekmeler, etiketler ve sıralamayla yapılır.

- **Mobil:** Flutter 3.50 (Android öncelikli) · Riverpod · go_router · flutter_quill
- **Backend:** Supabase (Auth, Postgres + RLS, Storage, Edge Functions, pg_cron)
- **Bildirim:** Firebase Cloud Messaging
- **Dil:** Türkçe + İngilizce (ilk günden)

Bu depo, proje planındaki 13 adımlık yol haritasının tamamını içerir. Her adımda ne
yapıldığı ve ne öğrenildiği [`docs/`](docs/) klasöründe anlatılır.

## Hızlı başlangıç

1. Flutter ve Android Studio'yu kur → [docs/01-kurulum.md](docs/01-kurulum.md)
2. Supabase projesini kur, veritabanını oluştur → [docs/03-veritabani.md](docs/03-veritabani.md)
3. Ayar dosyasını hazırla:
   ```bash
   cp env.example.json env.json
   ```
   `env.json` içine Supabase **Project URL** ve **Publishable key**'i yaz (git'e eklenmez).
4. Paketleri indir ve çalıştır:
   ```bash
   flutter pub get
   ```
   ```bash
   flutter run --dart-define-from-file=env.json
   ```
5. (İsteğe bağlı) Push bildirimleri → [docs/10-bildirimler.md](docs/10-bildirimler.md)
6. APK üretimi ve dağıtım → [docs/13-apk-dagitim.md](docs/13-apk-dagitim.md)

## Klasör yapısı

```
lib/
  main.dart, app.dart        Başlangıç, tema, dil, router bağlantısı
  core/                      Ortak altyapı
    theme/                   Design System token'ları → ThemeData, okuma stilleri
    router/                  go_router: ekranlar ve yönlendirme kuralları
    session/                 Oturum durumu (giriş, onboarding, ban)
    settings/                Cihazda saklanan tercihler (dil, tema, okuma ayarları)
    cache/                   drift (SQLite) çevrimdışı önbellek
    widgets/, utils/, errors/, connectivity/, update/
  l10n/                      app_tr.arb, app_en.arb (çeviriler)
  features/                  Her özellik kendi data / ekran / widget klasörüyle
    auth, profile, feed, post, editor, comments, search,
    notifications, admin, settings, home
supabase/
  migrations/                6 SQL dosyası: şema, tetikleyiciler, RLS, storage, RPC, cron
  functions/                 Edge Functions: push, purge-deleted-accounts
  tests/                     Veritabanı kural testleri (yerel Postgres)
assets/fonts/                Paketlenen fontlar + lisansları
docs/                        Adım adım kurulum ve öğrenme notları
```

## Testler

```bash
flutter analyze
```
```bash
flutter test
```
Veritabanı kurallarını (RLS, tetikleyiciler) yerel bir PostgreSQL'de test etmek için:
```bash
PGHOST=localhost PGUSER=postgres scripts/test_db.sh
```

## Plandan bilinçli farklar

| Konu | Plan | Uygulama | Neden |
| --- | --- | --- | --- |
| E-posta doğrulama / şifre sıfırlama | Belirtilmemiş | E-postadaki **6 haneli kodla** | Derin link (deep link) kurulumu gerektirmez; yeni başlayan için daha az ayar |
| `notifications` tablosu | 8 alan | + `meta` (jsonb) | Moderasyon bildiriminde yaptırım türü ve admin notu gösterilebilsin |
| Material kütüphanesi | — | `material_ui` paketi | Flutter 3.50'de Material ayrı pakete taşındı; editör (flutter_quill) henüz geçmediği için küçük bir uyum köprüsü var (`lib/features/editor/widgets/quill_support.dart`) |
| Push anahtarı | — | Klasik FCM token API'si | firebase_messaging 17'nin yeni FID API'si çok yeni; kanıtlanmış yol seçildi |
| Yasal metinler | Taslak | Uygulamada taslak hâliyle | `[Ad Soyad]` vb. yerler Google Play öncesi doldurulacak |
