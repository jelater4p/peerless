# Adım 10 — Bildirimler (Firebase Cloud Messaging + Edge Functions)

**Bu adımda öğrenilenler:** Push bildirimleri, sunucusuz fonksiyonlar (Edge Functions),
gizli değer yönetimi (Vault, secrets), zamanlanmış görevler.

## Nasıl çalışır?

1. Biri yorum yapar / beğenir / bahseder → veritabanı tetikleyicisi `notifications`
   tablosuna satır ekler (alıcının ayarı kapalıysa eklemez).
2. Yeni satır → `pg_net` ile **push** Edge Function'ı çağrılır.
3. Fonksiyon alıcının cihaz anahtarlarını bulur ve Firebase'e (FCM v1) gönderir.
4. Uygulama içi bildirim listesi ve rozet her durumda çalışır (Firebase kurulmasa da).

Firebase ayarları yapılmazsa uygulama push olmadan çalışmaya devam eder.

## 1. Firebase projesi

1. https://console.firebase.google.com → *Projeyi ekle* (Analytics gerekmez).
2. *Android uygulaması ekle* → paket adı: `com.peerless.app`.
3. İnen `google-services.json` dosyasından şu değerleri `env.json`'a yaz
   (dosyanın kendisini projeye eklemene gerek yok):

| env.json | google-services.json içinde |
| --- | --- |
| `FIREBASE_API_KEY` | `client[0].api_key[0].current_key` |
| `FIREBASE_APP_ID` | `client[0].client_info.mobilesdk_app_id` |
| `FIREBASE_MESSAGING_SENDER_ID` | `project_info.project_number` |
| `FIREBASE_PROJECT_ID` | `project_info.project_id` |

4. *Proje ayarları > Hizmet hesapları > Yeni özel anahtar oluştur* → bir JSON iner.
   Bu dosya gizlidir; GitHub'a koyma, kimseyle paylaşma.

## 2. Edge Function'ları yükle

Supabase CLI kur (https://supabase.com/docs/guides/cli), sonra proje klasöründe:

```bash
supabase login
```
```bash
supabase link --project-ref PROJE-KODUN
```

Uzun rastgele bir metin üret (ör. bir şifre yöneticisiyle 40 karakter) ve gizli değerleri kaydet:

```bash
supabase secrets set WEBHOOK_SECRET=UZUN-RASTGELE-METIN
```
```bash
supabase secrets set FIREBASE_SERVICE_ACCOUNT="$(cat indirilen-hizmet-hesabi.json)"
```

Fonksiyonları yükle:

```bash
supabase functions deploy push --no-verify-jwt
```
```bash
supabase functions deploy purge-deleted-accounts --no-verify-jwt
```

(`--no-verify-jwt`: fonksiyonlar kendi `x-webhook-secret` kontrolünü yapar.)

## 3. Veritabanına adresi ve gizli metni ver (Vault)

SQL Editor'de (aynı `WEBHOOK_SECRET` değeriyle):

```sql
select vault.create_secret('https://PROJE-KODUN.supabase.co', 'project_url');
select vault.create_secret('UZUN-RASTGELE-METIN', 'webhook_secret');
```

Bunlar eklenince hem push bildirimleri hem de her gece 03:17'de (UTC) çalışan
**hesap silme** görevi (30 günü dolan hesapları dosyalarıyla birlikte siler) devreye girer.

## 4. Dene

İki hesapla giriş yap; birinin içeriğini diğeriyle beğen. Telefon bildirimi gelmeli ve
bildirime dokununca içerik açılmalı. Gelmiyorsa: *Edge Functions > push > Logs*.
