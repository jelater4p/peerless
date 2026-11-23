-- =====================================================================
-- Peerless veritabanı kural testleri (yerel Postgres + supabase_stub.sql)
-- Her kontrol başarısız olursa hata verip durur. Kullanım: scripts/test_db.sh
-- =====================================================================
\set ON_ERROR_STOP on
set client_min_messages = warning;

-- Yardımcılar -----------------------------------------------------------
create function public.t_login(p_user uuid) returns void
language plpgsql as $$
begin
  perform set_config('request.jwt.claims', json_build_object('sub', p_user, 'role', 'authenticated')::text, false);
end $$;
grant execute on function public.t_login(uuid) to authenticated;

create function public.t_assert(p_ok boolean, p_msg text) returns void
language plpgsql as $$
begin
  if not coalesce(p_ok, false) then
    raise exception 'TEST BAŞARISIZ: %', p_msg;
  end if;
end $$;
grant execute on function public.t_assert(boolean, text) to authenticated;

-- Beklenen hata kodu/mesajıyla başarısız olmalı
create function public.t_expect_error(p_sql text, p_contains text, p_msg text) returns void
language plpgsql as $$
begin
  begin
    execute p_sql;
  exception when others then
    if p_contains is null or sqlerrm ilike '%' || p_contains || '%' then
      return;
    end if;
    raise exception 'TEST BAŞARISIZ: % (beklenmeyen hata: %)', p_msg, sqlerrm;
  end;
  raise exception 'TEST BAŞARISIZ: % (hata bekleniyordu)', p_msg;
end $$;
grant execute on function public.t_expect_error(text, text, text) to authenticated;

-- Kullanıcılar ------------------------------------------------------------
insert into auth.users (id, email, raw_user_meta_data) values
  ('00000000-0000-0000-0000-00000000000a', 'ayse@test', '{"locale":"tr"}'),
  ('00000000-0000-0000-0000-00000000000b', 'bora@test', '{"locale":"en"}'),
  ('00000000-0000-0000-0000-00000000000c', 'cem@test',  '{}'),
  ('00000000-0000-0000-0000-0000000000ad', 'admin@test', '{}');

select t_assert((select count(*) from public.profiles) = 4, 'kayıtta profil oluşmalı');
select t_assert((select count(*) from public.notification_settings) = 4, 'kayıtta bildirim ayarı oluşmalı');
select t_assert((select locale from public.profiles where id = '00000000-0000-0000-0000-00000000000b') = 'en', 'locale meta veriden gelmeli');

update public.profiles set role = 'admin' where id = '00000000-0000-0000-0000-0000000000ad';

set role authenticated;

-- Onboarding: nickname seçimi -------------------------------------------
select t_login('00000000-0000-0000-0000-00000000000a');
select t_assert(public.is_nickname_available('Ayse'), 'boş nickname uygun olmalı');
select t_assert(not public.is_nickname_available('ay'), '2 karakter uygun olmamalı');
select t_assert(not public.is_nickname_available('ayşe'), 'Türkçe karakter uygun olmamalı');
update public.profiles set nickname = 'Ayse', display_name = '  Ayşe Yılmaz ' where id = auth.uid();
select t_assert((select nickname from public.profiles where id = auth.uid()) = 'ayse', 'nickname küçük harfe çevrilmeli');
select t_assert((select display_name from public.profiles where id = auth.uid()) = 'Ayşe Yılmaz', 'görünen ad kırpılmalı');
select t_assert((select nickname_changed_at from public.profiles where id = auth.uid()) is null, 'ilk seçim değişiklik sayılmamalı');
select t_expect_error($$ update public.profiles set role = 'admin' where id = auth.uid() $$, 'permission denied', 'kullanıcı kendi rolünü değiştirememeli');
select t_expect_error($$ update public.profiles set status = 'active' where id = auth.uid() $$, 'permission denied', 'kullanıcı status değiştirememeli');

select t_login('00000000-0000-0000-0000-00000000000b');
select t_assert(not public.is_nickname_available('AYSE'), 'alınmış nickname (büyük harf) uygun olmamalı');
select t_expect_error($$ update public.profiles set nickname = 'ayse' where id = auth.uid() $$, 'duplicate', 'aynı nickname alınamamalı');
update public.profiles set nickname = 'bora', display_name = 'Bora' where id = auth.uid();

select t_login('00000000-0000-0000-0000-00000000000c');
update public.profiles set nickname = 'cem', display_name = 'Cem' where id = auth.uid();

select t_login('00000000-0000-0000-0000-0000000000ad');
update public.profiles set nickname = 'yonetici', display_name = 'Yönetici' where id = auth.uid();

-- Nickname değiştirme: 30 günde bir + eski nickname 30 gün bekletilir
select t_login('00000000-0000-0000-0000-00000000000a');
update public.profiles set nickname = 'ayse_y' where id = auth.uid();
select t_assert((select nickname_changed_at from public.profiles where id = auth.uid()) is not null, 'değişiklik zamanı yazılmalı');
select t_expect_error($$ update public.profiles set nickname = 'ayse_z' where id = auth.uid() $$, 'nickname_change_too_soon', '30 gün dolmadan tekrar değişmemeli');
select t_login('00000000-0000-0000-0000-00000000000c');
select t_assert(not public.is_nickname_available('ayse'), 'bırakılan nickname 30 gün başkasına verilmemeli');

-- İçerik ---------------------------------------------------------------
select t_login('00000000-0000-0000-0000-00000000000a');
insert into public.posts (id, author_id, type, title, body, body_text, personal_note, status)
values ('10000000-0000-0000-0000-000000000001', auth.uid(), 'quote', 'Özgürlük üzerine', '[{"insert":"Kitap okumak\n"}]',
        'Kitap okumak   özgürlüktür. Kütüphaneler sessizdir.', 'Çok sevdiğim bir söz', 'published');
select t_assert((select published_at is not null and excerpt = 'Kitap okumak özgürlüktür. Kütüphaneler sessizdir.'
                   from public.posts where id = '10000000-0000-0000-0000-000000000001'), 'yayın tarihi ve özet üretilmeli');
insert into public.posts (id, author_id, type, title, status)
values ('10000000-0000-0000-0000-000000000002', auth.uid(), 'thought', '', 'draft');
select t_expect_error($$ insert into public.posts (author_id, type, title, personal_note) values (auth.uid(), 'thought', 'x', 'not') $$,
                      'posts_personal_note_quote_only', 'kişisel not yalnızca alıntıda');
select t_expect_error($$ insert into public.posts (author_id, type, title, status) values (auth.uid(), 'thought', '', 'published') $$,
                      'posts_published_has_title', 'başlıksız yayınlanamamalı');
select t_expect_error($$ insert into public.posts (author_id, type, title, status) values (auth.uid(), 'thought', 'x', 'removed') $$,
                      'row-level security', 'kullanıcı removed durumunda içerik oluşturamamalı');
select t_expect_error($$ update public.posts set like_count = 999 where id = '10000000-0000-0000-0000-000000000001' $$,
                      'permission denied', 'sayaç elle değiştirilememeli');
select t_expect_error($$ insert into public.posts (author_id, type, title) values ('00000000-0000-0000-0000-00000000000b', 'thought', 'x') $$,
                      'row-level security', 'başkası adına içerik oluşturulamamalı');

-- Düzenleme → 'düzenlendi'
update public.posts set title = 'Özgürlük üzerine notlar' where id = '10000000-0000-0000-0000-000000000001';
select t_assert((select edited_at is not null from public.posts where id = '10000000-0000-0000-0000-000000000001'), 'yayın sonrası düzenleme edited_at doldurmalı');
update public.posts set title = 'Taslak başlık' where id = '10000000-0000-0000-0000-000000000002';
select t_assert((select edited_at is null from public.posts where id = '10000000-0000-0000-0000-000000000002'), 'taslak düzenleme edited_at doldurmamalı');
select t_expect_error($$ update public.posts set status = 'draft' where id = '10000000-0000-0000-0000-000000000001' $$,
                      'cannot_unpublish', 'yayından taslağa dönülmemeli');

-- Etiketler
select public.set_post_tags('10000000-0000-0000-0000-000000000001', array['#Felsefe', 'özgürlük', 'felsefe', ' kitap ']);
select t_assert((select count(*) from public.post_tags where post_id = '10000000-0000-0000-0000-000000000001') = 3, 'etiketler tekilleştirilmeli');
select t_expect_error($$ select public.set_post_tags('10000000-0000-0000-0000-000000000001', array['a','b','c','d','e','f']) $$,
                      'too_many_tags', 'en fazla 5 etiket');

-- Görseller: en fazla 5; galeri yalnızca projede
insert into public.post_images (post_id, url, kind, position)
select '10000000-0000-0000-0000-000000000001', 'https://x/' || g, 'inline', g from generate_series(1, 5) g;
select t_expect_error($$ insert into public.post_images (post_id, url, kind) values ('10000000-0000-0000-0000-000000000001', 'https://x/6', 'inline') $$,
                      'too_many_images', 'en fazla 5 görsel');
select t_expect_error($$ insert into public.post_images (post_id, url, kind) values ('10000000-0000-0000-0000-000000000002', 'https://x/g', 'gallery') $$,
                      'gallery_only_project', 'galeri yalnızca projede');

-- Sabitleme: en fazla 1
select public.set_pinned_post('10000000-0000-0000-0000-000000000001', true);
select t_assert((select is_pinned from public.posts where id = '10000000-0000-0000-0000-000000000001'), 'sabitlenmeli');
select t_expect_error($$ select public.set_pinned_post('10000000-0000-0000-0000-000000000002', true) $$,
                      'pin_requires_published', 'taslak sabitlenememeli');
select t_assert((select is_pinned from public.posts where id = '10000000-0000-0000-0000-000000000001'), 'taslak denemesi sabitlenmişi bozmamalı');

-- Görünürlük: taslak yalnızca yazarına
select t_login('00000000-0000-0000-0000-00000000000b');
select t_assert((select count(*) from public.posts) = 1, 'başkasının taslağı görünmemeli');
select t_assert((select count(*) from public.get_feed()) = 1, 'akışta yayındaki içerik görünmeli');
select t_assert((select count(*) from public.get_feed(p_tag => 'felsefe')) = 1, 'etiket filtresi çalışmalı');
select t_assert((select count(*) from public.get_feed(p_type => 'thought')) = 0, 'tür filtresi çalışmalı');
select t_assert((select count(*) from public.get_feed(p_sort => 'popular')) = 1, 'popüler akış çalışmalı');
-- RLS başkasının satırını sessizce filtreler (0 satır güncellenir).
update public.posts set title = 'hack' where id = '10000000-0000-0000-0000-000000000001';
select t_assert((select title from public.posts where id = '10000000-0000-0000-0000-000000000001') = 'Özgürlük üzerine notlar', 'başlık değişmemiş olmalı');

-- Arama
select t_assert((select count(*) from public.search_posts('özgür')) = 1, 'önek araması (TR) çalışmalı');
select t_assert((select count(*) from public.search_posts('kütüphane')) = 1, 'metin içinde arama çalışmalı');
select t_assert((select count(*) from public.search_posts('kitap okum')) = 1, 'çok kelimeli arama çalışmalı');
select t_assert((select count(*) from public.search_posts('zzzz')) = 0, 'alakasız arama boş dönmeli');
select t_assert((select count(*) from public.search_posts('&|!():*')) = 0, 'özel karakterler hata vermemeli');
select t_assert((select nickname from public.search_profiles('AYS') limit 1) = 'ayse_y', 'kişi araması kısmi eşleşmeli');
select t_assert((select count(*) from public.search_profiles('ayşe')) = 1, 'görünen ada göre aranmalı');
select t_assert((select count(*) from public.search_profiles('%')) = 0, 'joker karakter kaçışlanmalı');

-- Beğeni ve sayaç + bildirim
insert into public.likes (user_id, post_id) values (auth.uid(), '10000000-0000-0000-0000-000000000001');
select t_expect_error($$ insert into public.likes (user_id, post_id) values (auth.uid(), '10000000-0000-0000-0000-000000000001') $$,
                      'duplicate', 'bir kez beğeni');
select t_assert((select like_count from public.posts where id = '10000000-0000-0000-0000-000000000001') = 1, 'beğeni sayacı artmalı');
delete from public.likes where user_id = auth.uid() and post_id = '10000000-0000-0000-0000-000000000001';
insert into public.likes (user_id, post_id) values (auth.uid(), '10000000-0000-0000-0000-000000000001');
select t_assert((select like_count from public.posts where id = '10000000-0000-0000-0000-000000000001') = 1, 'beğeni geri al/beğen sayacı doğru');

-- Yorum, yanıt, @bahsetme
insert into public.comments (id, post_id, author_id, body)
values ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', auth.uid(), 'Harika bir alıntı @cem bak');
select t_expect_error($$ insert into public.comments (post_id, author_id, body) values ('10000000-0000-0000-0000-000000000001', auth.uid(), '   ') $$,
                      'comments_body_length', 'boş yorum olmamalı');
select t_expect_error($$ insert into public.comments (post_id, author_id, body) values ('10000000-0000-0000-0000-000000000002', auth.uid(), 'taslağa yorum') $$,
                      'row-level security', 'taslağa yorum yapılamamalı');

select t_login('00000000-0000-0000-0000-00000000000c');
insert into public.comments (id, post_id, author_id, parent_id, body)
values ('20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', auth.uid(),
        '20000000-0000-0000-0000-000000000001', 'Katılıyorum @bora @ayse_y.');
select t_expect_error($$ insert into public.comments (post_id, author_id, parent_id, body) values ('10000000-0000-0000-0000-000000000001', auth.uid(), '20000000-0000-0000-0000-000000000002', 'iç içe') $$,
                      'invalid_parent', 'yanıta yanıt verilememeli');
select t_assert((select comment_count from public.posts where id = '10000000-0000-0000-0000-000000000001') = 2, 'yorum sayacı 2 olmalı');
update public.comments set body = 'Katılıyorum @bora' where id = '20000000-0000-0000-0000-000000000002';
select t_assert((select edited_at is not null from public.comments where id = '20000000-0000-0000-0000-000000000002'), 'yorum düzenlenince edited_at');

-- Bildirimler (her kullanıcı yalnızca kendininkini görür)
select t_login('00000000-0000-0000-0000-00000000000a');
select t_assert((select count(*) from public.notifications where type = 'like') = 1, 'beğeni bildirimi tek olmalı');
select t_assert((select count(*) from public.notifications where type = 'comment') = 2, 'ayse: 2 yorum bildirimi');
select t_assert((select count(*) from public.notifications where type = 'mention') = 0, 'ayse: aynı yorum için ikinci (mention) bildirimi olmamalı');
update public.notifications set read_at = now();
select t_assert((select count(*) from public.notifications where read_at is null) = 0, 'okundu işaretlenmeli');
select t_expect_error($$ update public.notifications set type = 'like' $$, 'permission denied', 'yalnızca read_at güncellenebilir');

select t_login('00000000-0000-0000-0000-00000000000b');
select t_assert((select count(*) from public.notifications where type = 'reply') = 1, 'bora: yanıt bildirimi');
select t_assert((select count(*) from public.notifications) = 1, 'bora: başkasının bildirimini görmemeli; tekrar yok');

select t_login('00000000-0000-0000-0000-00000000000c');
select t_assert((select count(*) from public.notifications where type = 'mention') = 1, 'cem: bahsetme bildirimi');
select t_assert((select count(*) from public.notifications) = 1, 'cem: kendi eylemi için bildirim yok');

-- Bildirim ayarı kapalıysa bildirim oluşmaz
select t_login('00000000-0000-0000-0000-00000000000a');
update public.notification_settings set "like" = false where user_id = auth.uid();
select t_login('00000000-0000-0000-0000-00000000000c');
insert into public.likes (user_id, post_id) values (auth.uid(), '10000000-0000-0000-0000-000000000001');
select t_login('00000000-0000-0000-0000-00000000000a');
select t_assert((select count(*) from public.notifications where type = 'like') = 1, 'ayar kapalıyken beğeni bildirimi oluşmamalı');

-- Engelleme ----------------------------------------------------------------
-- ayse, cem'i engeller: cem'in yorumlarını görmez; cem, ayse'nin içeriğine yorum/beğeni yapamaz.
insert into public.blocks (blocker_id, blocked_id) values (auth.uid(), '00000000-0000-0000-0000-00000000000c');
select t_expect_error($$ insert into public.blocks (blocker_id, blocked_id) values (auth.uid(), auth.uid()) $$, 'blocks_not_self', 'kendini engelleyemez');
select t_assert((select count(*) from public.comments where author_id = '00000000-0000-0000-0000-00000000000c') = 0, 'engellenenin yorumu görünmemeli');
select t_assert((select count(*) from public.search_profiles('cem')) = 0, 'engellenen aramada görünmemeli');

select t_login('00000000-0000-0000-0000-00000000000c');
select t_assert((select count(*) from public.posts where id = '10000000-0000-0000-0000-000000000001') = 1, 'engellenen, engelleyenin içeriğini görebilir');
select t_expect_error($$ insert into public.comments (post_id, author_id, body) values ('10000000-0000-0000-0000-000000000001', auth.uid(), 'selam') $$,
                      'row-level security', 'engellenen yorum yapamamalı');
delete from public.likes where user_id = auth.uid();
select t_expect_error($$ insert into public.likes (user_id, post_id) values (auth.uid(), '10000000-0000-0000-0000-000000000001') $$,
                      'row-level security', 'engellenen beğenememeli');
select t_assert((select count(*) from public.blocks) = 0, 'engellenen, engel listesini görmemeli');

-- Şikayet ve moderasyon ---------------------------------------------------
select t_login('00000000-0000-0000-0000-00000000000b');
insert into public.reports (reporter_id, target_type, target_id) values (auth.uid(), 'post', '10000000-0000-0000-0000-000000000001');
select t_expect_error($$ insert into public.reports (reporter_id, target_type, target_id) values (auth.uid(), 'post', '10000000-0000-0000-0000-000000000001') $$,
                      'reports_once', 'bir kez şikayet');
select t_assert((select count(*) from public.reports) = 0, 'kullanıcı şikayetleri okuyamamalı');
select t_expect_error($$ select * from public.admin_list_reports() $$, 'not_admin', 'admin olmayan rapor listesini göremez');
select t_expect_error($$ select public.admin_moderate('post', '10000000-0000-0000-0000-000000000001', 'remove_content') $$, 'not_admin', 'admin olmayan moderasyon yapamaz');

select t_login('00000000-0000-0000-0000-00000000000c');
insert into public.reports (reporter_id, target_type, target_id) values (auth.uid(), 'post', '10000000-0000-0000-0000-000000000001');

select t_login('00000000-0000-0000-0000-0000000000ad');
select t_assert((select report_count from public.admin_list_reports()) = 2, 'aynı hedefin şikayetleri gruplanmalı');
select t_assert((select target_nickname from public.admin_list_reports()) = 'ayse_y', 'hedef sahibi görünmeli');
select public.admin_moderate('post', '10000000-0000-0000-0000-000000000001', 'remove_content', 'Telif ihlali');
select t_assert((select count(*) from public.admin_list_reports()) = 0, 'açık şikayet kalmamalı');
select t_assert((select count(*) from public.moderation_actions) = 1, 'yaptırım kaydı oluşmalı');

select t_login('00000000-0000-0000-0000-00000000000b');
select t_assert((select count(*) from public.posts where id = '10000000-0000-0000-0000-000000000001') = 0, 'kaldırılan içerik başkasına görünmemeli');
select t_assert((select count(*) from public.get_feed()) = 0, 'kaldırılan içerik akışta görünmemeli');

select t_login('00000000-0000-0000-0000-00000000000a');
select t_assert((select status from public.posts where id = '10000000-0000-0000-0000-000000000001') = 'removed', 'yazar kaldırılan içeriği görür');
select t_assert((select not is_pinned from public.posts where id = '10000000-0000-0000-0000-000000000001'), 'kaldırılan içerik sabitlenmiş kalmamalı');
select t_assert((select meta ->> 'action' from public.notifications where type = 'moderation') = 'remove_content', 'moderasyon bildirimi gelmeli');
update public.posts set title = 'geri' where id = '10000000-0000-0000-0000-000000000001';
select t_assert((select title from public.posts where id = '10000000-0000-0000-0000-000000000001') = 'Özgürlük üzerine notlar', 'kaldırılan içerik değişmemeli');

-- Ban
select t_login('00000000-0000-0000-0000-00000000000b');
insert into public.reports (reporter_id, target_type, target_id) values (auth.uid(), 'profile', '00000000-0000-0000-0000-00000000000c');
select t_login('00000000-0000-0000-0000-0000000000ad');
select public.admin_moderate('profile', '00000000-0000-0000-0000-00000000000c', 'ban', null);
select t_login('00000000-0000-0000-0000-00000000000b');
select t_assert((select count(*) from public.profiles where nickname = 'cem') = 0, 'banlı profil görünmemeli');
select t_login('00000000-0000-0000-0000-00000000000c');
select t_expect_error($$ insert into public.posts (author_id, type, title) values (auth.uid(), 'thought', 'x') $$,
                      'row-level security', 'banlı kullanıcı yazamamalı');

-- Hesap silme talebi
select t_login('00000000-0000-0000-0000-00000000000b');
select public.request_account_deletion();
select t_login('00000000-0000-0000-0000-00000000000a');
select t_assert((select count(*) from public.profiles where nickname = 'bora') = 0, 'silinme bekleyen profil görünmemeli');

-- Uygulama ayarı: herkes okur, yalnızca admin yazar
reset role;
set role anon;
select t_assert((select count(*) from public.app_config) = 1, 'anon app_config okuyabilmeli');
select t_expect_error($$ select count(*) from public.posts $$, 'permission denied', 'anon içerik okuyamamalı');
reset role;
set role authenticated;
select t_login('00000000-0000-0000-0000-00000000000a');
update public.app_config set latest_version = '9.9.9';
select t_assert((select latest_version from public.app_config) = '1.0.0', 'admin olmayan app_config değiştirememeli');

-- Storage: yalnızca kendi klasörüne yazar
insert into storage.objects (bucket_id, name) values ('avatars', '00000000-0000-0000-0000-00000000000a/avatar.jpg');
select t_expect_error($$ insert into storage.objects (bucket_id, name) values ('avatars', '00000000-0000-0000-0000-00000000000b/avatar.jpg') $$,
                      'row-level security', 'başkasının klasörüne yüklenememeli');

reset role;

-- Giriş yapınca silme talebi iptal olur
update auth.users set last_sign_in_at = now() where id = '00000000-0000-0000-0000-00000000000b';
select t_assert((select deletion_requested_at is null from public.profiles where id = '00000000-0000-0000-0000-00000000000b'), 'girişte silme talebi iptal olmalı');

-- Ban auth tarafına yansımalı
select t_assert((select banned_until > now() from auth.users where id = '00000000-0000-0000-0000-00000000000c'), 'auth ban uygulanmalı');

-- Push: vault değerleri varken bildirim Edge Function'ı tetikler
insert into vault.secrets values ('project_url', 'https://ornek.supabase.co'), ('webhook_secret', 's3cret');
select private.notify('00000000-0000-0000-0000-00000000000a', 'moderation', null, null, null, '{"action":"warn"}');
select t_assert((select count(*) from net.calls where url = 'https://ornek.supabase.co/functions/v1/push') = 1, 'push çağrısı yapılmalı');
select t_assert((select count(*) from cron.job where jobname = 'purge-deleted-accounts') = 1, 'hesap silme görevi zamanlanmalı');

-- Hesap tamamen silinince tüm veriler gider, nickname 30 gün bekletilir
delete from auth.users where id = '00000000-0000-0000-0000-00000000000a';
select t_assert((select count(*) from public.posts where author_id = '00000000-0000-0000-0000-00000000000a') = 0, 'içerikler silinmeli');
select t_assert((select count(*) from public.nickname_history where nickname = 'ayse_y' and user_id is null) = 1, 'nickname bekletilmeli');

\echo 'TÜM VERİTABANI TESTLERİ GEÇTİ ✔'
