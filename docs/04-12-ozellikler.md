# Adım 4–12 — Özellikler ve öğrenme notları

Her bölümde: **dosyalar**, **nasıl çalışır**, **öğrenilen konu**.

## 4. Kayıt ve onboarding

**Dosyalar:** `lib/features/auth/`, `lib/core/session/session_controller.dart`,
`lib/core/router/app_router.dart`

Akış: tanıtım (yalnızca ilk açılış) → giriş/kayıt → e-posta kodu → nickname + görünen ad
(zorunlu) → fotoğraf + biyografi (atlanabilir) → ana akış.

- `SessionController` oturumu dinler ve durumu üretir: `signedOut`, `needsNickname`, `ready`…
- Router'daki `redirect` bu duruma bakarak kullanıcıyı doğru ekrana gönderir. Ekranlar
  birbirine "şimdi şuraya git" demez; durum değişir, router yönlendirir.
- Nickname alanı yazdıkça `is_nickname_available` RPC'siyle uygunluğu kontrol eder (400 ms bekleyerek).

**Öğrenilen:** Supabase Auth, go_router `redirect` + `refreshListenable`, Riverpod `Notifier`.

## 5. Profil (kütüphane)

**Dosyalar:** `lib/features/profile/`

Kapak (3:1), fotoğraf, görünen ad, @nickname, biyografi, sabitlenmiş içerik, tür sekmeleri;
kendi profilinde yalnızca sana görünen **Kaydedilenler**. Fotoğraf galeri/kameradan seçilir,
kırpılır (`image_cropper`), 512px'e küçültülüp sıkıştırılır (`flutter_image_compress`) ve
`avatars/<kullanıcı-id>/avatar.jpg` olarak yüklenir.

**Öğrenilen:** Supabase Storage, görsel işleme, `NestedScrollView` + sekmeler.

## 6. Editör ve yayınlama

**Dosyalar:** `lib/features/editor/`

- Ortak zengin metin editörü (`flutter_quill`): başlık, kalın/italik, alıntı bloğu, liste,
  link, metin içi görsel. İçerik veritabanına Delta (JSON) olarak, aramada kullanılmak üzere
  düz metin olarak da kaydedilir.
- Alıntıda **kişisel yorum**, projede **görsel galerisi** alanı açılır.
- Taslaklar yazmayı bıraktıktan 3 sn sonra otomatik kaydedilir; ilk kayıtta taslak satırı oluşur.
- Yayındaki içerik "Güncelle" ile kaydedilir ve 'düzenlendi' ibaresi alır.
- İçerik başına en fazla 5 görsel (kapak + metin içi + galeri) ve 5 etiket; mevcut etiketler önerilir.

**Öğrenilen:** Zengin metin, zamanlayıcıyla (debounce) otomatik kayıt, dosya yükleme sırası.

## 7. Akış ve içerik detayı

**Dosyalar:** `lib/features/feed/`, `lib/features/post/`

- Akış: tür sekmeleri + popüler etiket çipleri + sıralama (En yeni / Popüler = son 7 günün
  en çok beğenilenleri). 20'şer içerik, sonsuz kaydırma, aşağı çekip yenileme.
- Okuma ekranı: font, yazı boyutu, satır aralığı ve tema (Koyu / Açık / Sepya) ayarlanabilir;
  seçimler telefonda saklanır.

**Öğrenilen:** Sayfalama (offset), Riverpod ile veri yükleme, RPC (`get_feed`).

## 8. Beğeni, kaydetme, yorumlar, @bahsetme

**Dosyalar:** `lib/features/comments/`, `post_detail_screen.dart`

- Beğeni anında arayüzde değişir, hata olursa geri alınır (iyimser güncelleme).
- Yorumlar tek seviye yanıtlıdır; kendi yorumunu düzenler/siler, içerik sahibi kendi
  içeriğindeki yorumları silebilir.
- `@` yazınca kişi önerileri çıkar; @nickname'ler veritabanında tetikleyiciyle bulunup
  bildirim üretilir.

**Öğrenilen:** İlişkili tablolar, tetikleyicilerle sayaç tutma.

## 9. Arama

**Dosyalar:** `lib/features/search/`, `search_posts` / `search_profiles` RPC'leri

Tek kutu; yazmayı bıraktıktan 300 ms sonra arar. Üstte en fazla 3 kişi (pg_trgm kısmi
eşleşme), altında içerikler (Türkçe + İngilizce tam metin arama, önek eşleşmesi). Kutu
boşken son 10 arama (telefonda) ve haftanın popülerleri.

**Öğrenilen:** Postgres tam metin arama (`tsvector`, `tsquery`), trigram arama.

## 10. Bildirimler

Ayrı belge: [10-bildirimler.md](10-bildirimler.md)

## 11. Moderasyon, engelleme ve admin paneli

**Dosyalar:** `lib/features/admin/`, `admin_list_reports` / `admin_moderate` RPC'leri

- "Şikayet et" tek dokunuştur; ikinci kez basınca "Bu içeriği zaten şikayet ettin".
- Admin paneli (yalnızca `is_admin()` true ise): aynı hedefe gelen şikayetler tek satırda;
  Reddet / İçeriği kaldır / Uyarı ver / Kalıcı ban. Kullanıcıya moderasyon bildirimi gider.
- Ban: profil kapanır, oturumlar sonlanır, tekrar giriş engellenir.
- Engelleme: engellediğin kişinin içerik ve yorumlarını görmezsin; o da senin içeriklerine
  yorum, beğeni ve @bahsetme yapamaz.
- Admin panelindeki **Uygulama sürümü** sekmesinden "Yeni sürüm var" uyarısı yönetilir.

**Öğrenilen:** Roller ve yetkiler, `security definer` fonksiyonlar.

## 12. Okuma ayarları ve çevrimdışı önbellek

**Dosyalar:** `lib/core/settings/app_settings.dart`, `lib/core/cache/app_database.dart`,
`lib/core/connectivity/connectivity.dart`

- Tercihler `shared_preferences` ile telefonda saklanır.
- Akışların ilk sayfası ve açılan içerikler `drift` (SQLite) ile önbelleğe yazılır;
  internet yokken bunlar gösterilir, üstte **Bağlantı yok** şeridi çıkar, yazma/beğenme/yorum kapanır.
- Önbellek tablosu değişirse kod üretimi:
  ```bash
  dart run build_runner build
  ```

**Öğrenilen:** Yerel veritabanı, kod üretimi, bağlantı durumu dinleme.
