# Adım 3 — Veritabanı (Supabase)

**Bu adımda öğrenilenler:** SQL tabloları, ilişkiler, Row Level Security (RLS),
tetikleyiciler (trigger), veritabanı fonksiyonları (RPC), dosya depolama kuralları.

## 1. Supabase projesi

1. https://supabase.com → *New project*. **Region: Central EU (Frankfurt)** seç
   (KVKK metninde bölge olarak yazılacak).
2. Veritabanı şifresini güvenli bir yere kaydet (uygulamaya yazılmaz).

## 2. Tabloları oluştur

*Dashboard > SQL Editor > New query*. `supabase/migrations/` içindeki dosyaları
**bu sırayla**, her birini ayrı ayrı yapıştırıp **Run** de:

| Sıra | Dosya | İçerik |
| --- | --- | --- |
| 1 | `20261123000100_schema.sql` | 17 tablo, tipler, indeksler |
| 2 | `20261123000200_functions_triggers.sql` | Sayaçlar, bildirim üretimi, nickname kuralları |
| 3 | `20261123000300_rls.sql` | Erişim kuralları (kim neyi okuyup yazabilir) |
| 4 | `20261123000400_storage.sql` | `avatars`, `covers`, `post-images` alanları |
| 5 | `20261123000500_rpc.sql` | Akış, arama, etiket, admin fonksiyonları |
| 6 | `20261123000600_cron_push.sql` | Günlük hesap silme görevi, push tetikleyicisi |

6. dosyadan önce *Database > Extensions*'tan **pg_cron** ve **pg_net**'i aç.

> CLI tercih edersen: `supabase link --project-ref PROJE-KODUN` ve `supabase db push`.

## 3. Kimlik doğrulama ayarları

*Authentication > Sign In / Providers > Email*:
- **Confirm email: açık** (doğrulanmadan devam edilmez)
- Minimum şifre uzunluğu: 6 (varsayılan)

*Authentication > Emails > Templates* — uygulama bağlantı yerine **kod** kullanır.
Üç şablona kodu ekle:

| Şablon | Eklenecek satır |
| --- | --- |
| Confirm signup | `Doğrulama kodun: {{ .Token }}` |
| Reset password | `Şifre sıfırlama kodun: {{ .Token }}` |
| Change email address | `Onay kodun: {{ .Token }}` |

> Ücretsiz planda Supabase'in kendi e-posta servisi saatte birkaç e-postayla sınırlıdır.
> Gerçek kullanıcılara açmadan önce *Authentication > Emails > SMTP* ile kendi e-posta
> servisini (ör. Resend, Brevo ücretsiz katmanı) bağla.

## 4. Kendini admin yap

Uygulamada kayıt olup nickname seçtikten sonra SQL Editor'de:

```sql
update public.profiles set role = 'admin' where nickname = 'senin_nicknamein';
```

Profil sayfanda kalkan ikonu (Admin paneli) görünür.

## 5. Kurallar nasıl korunuyor?

- **RLS:** Her tabloda açık. Örneğin `posts`: yayındakiler herkese, taslak yalnızca yazarına,
  kaldırılan yalnızca yazarına ve admine; engellediğin kişilerin içerikleri sana gelmez.
- **Sütun yetkileri:** Kullanıcı `like_count`, `role`, `status` gibi alanları hiç değiştiremez.
- **Tetikleyiciler:** Beğeni/yorum sayaçları, bildirimler, @bahsetmeler, nickname'in 30 gün
  kuralı, 'düzenlendi' ibaresi, en fazla 5 görsel/etiket veritabanında uygulanır.
- Uygulama aynı kuralları yalnızca kullanıcıya erken uyarı için tekrarlar.

## 6. Test

`supabase/tests/rls_test.sql` ~90 kontrol içerir (kayıt, nickname, RLS, engelleme,
şikayet, ban, bildirimler, arama, storage). Bilgisayarında PostgreSQL varsa:

```bash
PGHOST=localhost PGUSER=postgres scripts/test_db.sh
```

Son satırda `TÜM VERİTABANI TESTLERİ GEÇTİ ✔` görünmeli.
