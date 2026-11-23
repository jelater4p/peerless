-- =====================================================================
-- Peerless — 6/6: Zamanlanmış görevler ve push bildirimi tetikleyicisi
--
-- Ön koşullar (bkz. docs/10-bildirimler.md ve docs/03-veritabani.md):
--   1. Dashboard > Database > Extensions: pg_cron ve pg_net açık olmalı
--      (aşağıdaki create extension satırları da açmayı dener).
--   2. Vault'a iki gizli değer eklenmeli (SQL Editor'de, bu dosyadan ayrı):
--        select vault.create_secret('https://PROJE-KODUN.supabase.co', 'project_url');
--        select vault.create_secret('UZUN-RASTGELE-BIR-METIN', 'webhook_secret');
--      Aynı webhook_secret değeri Edge Function'lara da verilir:
--        supabase secrets set WEBHOOK_SECRET=UZUN-RASTGELE-BIR-METIN
--   Bu değerler yoksa tetikleyici sessizce hiçbir şey yapmaz; uygulama
--   bildirimleri yine uygulama içinde görünür.
-- =====================================================================

create extension if not exists pg_net;
create extension if not exists pg_cron;

-- Bir Edge Function'ı arka planda çağırır (pg_net, isteği bekletmez).
create or replace function private.invoke_edge_function(p_name text, p_body jsonb default '{}'::jsonb)
returns void
language plpgsql security definer
set search_path = ''
as $$
declare
  v_url    text;
  v_secret text;
begin
  select decrypted_secret into v_url from vault.decrypted_secrets where name = 'project_url';
  select decrypted_secret into v_secret from vault.decrypted_secrets where name = 'webhook_secret';
  if v_url is null or v_secret is null then
    return;
  end if;
  perform net.http_post(
    url := rtrim(v_url, '/') || '/functions/v1/' || p_name,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-webhook-secret', v_secret
    ),
    body := coalesce(p_body, '{}'::jsonb),
    timeout_milliseconds := 5000
  );
exception when others then
  -- Push gönderilemese bile asıl işlem (yorum, beğeni...) başarısız olmamalı.
  raise warning 'edge function çağrılamadı (%): %', p_name, sqlerrm;
end;
$$;

revoke execute on function private.invoke_edge_function(text, jsonb) from public;

-- Yeni bildirim satırı → 'push' Edge Function'ı FCM ile telefona gönderir.
create or replace function private.notifications_after_insert()
returns trigger
language plpgsql security definer
set search_path = ''
as $$
begin
  perform private.invoke_edge_function('push', jsonb_build_object('notification_id', new.id));
  return null;
end;
$$;

create trigger notifications_after_insert
  after insert on public.notifications
  for each row execute function private.notifications_after_insert();

-- Hesap silme: her gün 03:17'de (UTC) 30 günü dolan hesapları ve
-- tüm verilerini (dosyalar dahil) siler.
select cron.schedule(
  'purge-deleted-accounts',
  '17 3 * * *',
  $$ select private.invoke_edge_function('purge-deleted-accounts'); $$
);

-- Bildirim rozeti canlı güncellensin (Supabase Realtime; RLS'e uyar,
-- herkes yalnızca kendi bildirimlerinin olayını alır).
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    alter publication supabase_realtime add table public.notifications;
  end if;
end $$;
