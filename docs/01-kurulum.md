# Adım 1 — Kurulum

**Bu adımda öğrenilenler:** Flutter geliştirme ortamı, bir Flutter projesinin yapısı,
gizli ayarların koddan ayrı tutulması, Git.

## 1. Flutter ve Android Studio

1. **Flutter SDK** (3.50 veya üstü): https://docs.flutter.dev/get-started/install adresindeki
   adımları izle. Kurulumdan sonra terminalde kontrol et:
   ```bash
   flutter doctor
   ```
   Tüm satırlar ✓ olmalı (Chrome / Xcode satırları önemli değil; Android için Android toolchain gerekir).
2. **Android Studio**: Kur, açılışta *SDK Manager*'dan en güncel Android SDK'yı ve
   *Android SDK Command-line Tools*'u seç. Ardından lisansları kabul et:
   ```bash
   flutter doctor --android-licenses
   ```
3. Android Studio > Plugins: **Flutter** ve **Dart** eklentilerini kur.
4. Bir test cihazı: Android Studio > Device Manager'dan bir emülatör oluştur ya da
   telefonunda *Geliştirici seçenekleri > USB hata ayıklama*'yı açıp USB ile bağla.

## 2. Projeyi aç

```bash
git clone https://github.com/jelater4p/peerless.git
```
```bash
cd peerless
```
```bash
flutter pub get
```

Android Studio'da *Open* ile klasörü aç.

## 3. Gizli ayarlar: `env.json`

Supabase adresi ve anahtarı koda yazılmaz; derlerken `env.json` dosyasından okunur
(`lib/core/config/env.dart`). Bu dosya `.gitignore`'da olduğu için GitHub'a gitmez.

```bash
cp env.example.json env.json
```

`env.json` içini doldur (değerler Supabase Dashboard > Project Settings > API Keys'te):

| Alan | Ne yazılır |
| --- | --- |
| `SUPABASE_URL` | `https://xxxx.supabase.co` |
| `SUPABASE_PUBLISHABLE_KEY` | **Publishable key** (`sb_publishable_...`) ya da eski **anon public** key |
| `FIREBASE_*` | Boş bırakılabilir; push bildirimleri için [10-bildirimler.md](10-bildirimler.md) |
| `CONTACT_EMAIL` | Ayarlar > Hakkında'da görünen iletişim adresi |

> **Asla** `service_role` / `secret` anahtarını buraya ya da uygulamaya yazma. O anahtar
> tüm güvenlik kurallarını atlar. Uygulamadaki anahtar herkese açık olabilir; asıl koruma
> veritabanındaki RLS kurallarıdır (Adım 3).

## 4. Çalıştır

```bash
flutter run --dart-define-from-file=env.json
```

Android Studio'da her seferinde yazmamak için: *Run > Edit Configurations > Additional run args*
alanına `--dart-define-from-file=env.json` ekle.

`env.json` olmadan çalıştırırsan uygulama ne yapman gerektiğini söyleyen bir ekran açar.

## 5. Proje ayarları

- **Paket adı (applicationId):** `com.peerless.app` — Play Store'a çıktıktan sonra değiştirilemez
  (`android/app/build.gradle.kts`).
- **Sürüm:** `pubspec.yaml` içindeki `version: 1.0.0+1` → `1.0.0` görünen sürüm, `+1` derleme numarası.
  Her yeni APK'da ikisini de artır.
