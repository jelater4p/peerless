# Adım 13 — Test, imzalı APK ve dağıtım

**Bu adımda öğrenilenler:** Otomatik testler, uygulama imzalama, sürümleme, dağıtım.

## 1. Testler

```bash
flutter analyze
```
```bash
flutter test
```

`test/` klasöründe: birim testleri (kurallar, modeller, tema kontrastı), widget testleri
(içerik kartı, editör), uygulama akış testi (tanıtım → giriş → kayıt → şifre sıfırlama).

## 2. İmza anahtarı (bir kez)

Android, güncellemelerin aynı anahtarla imzalanmasını ister. **Bu anahtarı kaybedersen
kullanıcılar uygulamayı güncelleyemez** — yedeğini güvenli bir yerde (şifre yöneticisi,
şifreli bulut) sakla.

```bash
keytool -genkey -v -keystore ~/peerless-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias peerless
```

`android/key.properties` dosyasını oluştur (git'e eklenmez):

```
storePassword=ANAHTAR-DEPOSU-SIFRESI
keyPassword=ANAHTAR-SIFRESI
keyAlias=peerless
storeFile=/home/KULLANICI/peerless-release.jks
```

`android/app/build.gradle.kts` bu dosya varsa otomatik olarak gerçek anahtarla imzalar.

## 3. APK üret

1. `pubspec.yaml` içinde sürümü artır: `version: 1.0.1+2`
2. Derle:
   ```bash
   flutter build apk --release --dart-define-from-file=env.json
   ```
3. Çıktı: `build/app/outputs/flutter-apk/app-release.apk`

## 4. Dağıt

- APK'yı bir yere yükle (ör. GitHub Releases).
- Kullanıcı telefonda *Bilinmeyen kaynaklardan yükleme* iznini açmalı.
- Güncellemeler otomatik gelmez: **Admin paneli > Uygulama sürümü** sekmesinde
  *Son sürüm* = `1.0.1`, *APK indirme linki* = yüklediğin adres → kullanıcılar açılışta
  "Yeni sürüm var" uyarısı görür. *En düşük sürüm*'ü yükseltirsen eski sürümler devam edemez.

## 5. Google Play'e geçmeden önce

- [ ] Yasal metinlerdeki `[Ad Soyad]`, `[iletisim@ornek.com]`, `[bölge]`, `[aktarım aracı]`,
      `[süre]`, `[tarih]` yerlerini doldur (`lib/features/settings/legal_texts.dart`) ve bir
      hukukçuya kontrol ettir.
- [ ] KVKK yurt dışı aktarım aracını ve VERBİS muafiyetini netleştir.
- [ ] Kendi SMTP servisini bağla (Adım 3).
- [ ] Logo: şu an geçici "P" ikonu.
- [ ] Play Console için `flutter build appbundle` (AAB) kullan.
