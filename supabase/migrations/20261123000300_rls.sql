-- =====================================================================
-- Peerless — 3/6: Erişim kuralları (Row Level Security) ve yetkiler
-- Her tabloda RLS açık. Giriş yapmadan (anon) hiçbir içerik okunamaz.
-- Kural: (select auth.uid()) yazımı, fonksiyonun satır başına değil
-- sorgu başına bir kez çalışmasını sağlar (performans).
-- =====================================================================

alter table public.profiles              enable row level security;
alter table public.nickname_history      enable row level security;
alter table public.blocks                enable row level security;
alter table public.device_tokens         enable row level security;
alter table public.notification_settings enable row level security;
alter table public.posts                 enable row level security;
alter table public.post_images           enable row level security;
alter table public.tags                  enable row level security;
alter table public.post_tags             enable row level security;
alter table public.likes                 enable row level security;
alter table public.bookmarks             enable row level security;
alter table public.comments              enable row level security;
alter table public.comment_mentions      enable row level security;
alter table public.notifications         enable row level security;
alter table public.reports               enable row level security;
alter table public.moderation_actions    enable row level security;
alter table public.app_config            enable row level security;

-- Supabase varsayılan olarak anon/authenticated rollerine tüm tablo
-- yetkilerini verir. Önce hepsini geri alıp yalnızca gerekenleri veriyoruz;
-- böylece RLS'e ek olarak sütun bazında da koruma olur.
revoke all on all tables in schema public from anon, authenticated;

-- ---------------------------------------------------------------------
-- profiles — okuma: giriş yapmış herkes (banlı / silinme bekleyen hariç)
--            yazma: yalnızca kendi satırı; role ve status yalnızca admin (RPC)
-- ---------------------------------------------------------------------
grant select on public.profiles to authenticated;
grant update (nickname, display_name, bio, avatar_url, cover_url, locale) on public.profiles to authenticated;

create policy profiles_select on public.profiles
  for select to authenticated
  using (
    id = (select auth.uid())
    or private.is_visible_user(id)
    or (select private.is_admin())
  );

create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()) and (select private.is_active_user()));

-- nickname_history: politika yok → yalnızca veritabanı fonksiyonları erişir.

-- ---------------------------------------------------------------------
-- blocks — yalnızca engelleyen görür ve yazar
-- ---------------------------------------------------------------------
grant select, insert, delete on public.blocks to authenticated;

create policy blocks_select_own on public.blocks
  for select to authenticated using (blocker_id = (select auth.uid()));
create policy blocks_insert_own on public.blocks
  for insert to authenticated with check (blocker_id = (select auth.uid()));
create policy blocks_delete_own on public.blocks
  for delete to authenticated using (blocker_id = (select auth.uid()));

-- ---------------------------------------------------------------------
-- device_tokens, notification_settings, bookmarks — yalnızca sahibi
-- ---------------------------------------------------------------------
grant select, insert, update, delete on public.device_tokens to authenticated;
create policy device_tokens_own on public.device_tokens
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

grant select on public.notification_settings to authenticated;
grant update (comment, reply, "like", mention) on public.notification_settings to authenticated;
create policy notification_settings_select_own on public.notification_settings
  for select to authenticated using (user_id = (select auth.uid()));
create policy notification_settings_update_own on public.notification_settings
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

grant select, insert, delete on public.bookmarks to authenticated;
create policy bookmarks_select_own on public.bookmarks
  for select to authenticated using (user_id = (select auth.uid()));
create policy bookmarks_insert_own on public.bookmarks
  for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and exists (select 1 from public.posts p where p.id = post_id and p.status = 'published')
  );
create policy bookmarks_delete_own on public.bookmarks
  for delete to authenticated using (user_id = (select auth.uid()));

-- ---------------------------------------------------------------------
-- posts — published olanlar herkese; draft yalnızca yazarına;
--         removed yalnızca yazarına ve admine; engellediğin kişilerin
--         içerikleri sana gelmez. Yazma: yalnızca yazarı (banlı yazamaz);
--         status = removed yalnızca admin (moderasyon RPC'si).
-- ---------------------------------------------------------------------
grant select, delete on public.posts to authenticated;
grant insert (id, type, title, body, body_text, personal_note, cover_url, status)
  on public.posts to authenticated;
grant insert (author_id) on public.posts to authenticated;
grant update (type, title, body, body_text, personal_note, cover_url, status, is_pinned)
  on public.posts to authenticated;

create policy posts_select on public.posts
  for select to authenticated
  using (
    author_id = (select auth.uid())
    or (
      status = 'published'
      and private.is_visible_user(author_id)
      and not private.has_blocked((select auth.uid()), author_id)
    )
    or (status <> 'draft' and (select private.is_admin()))
  );

create policy posts_insert_own on public.posts
  for insert to authenticated
  with check (
    author_id = (select auth.uid())
    and status <> 'removed'
    and (select private.is_active_user())
  );

create policy posts_update_own on public.posts
  for update to authenticated
  using (author_id = (select auth.uid()) and status <> 'removed')
  with check (
    author_id = (select auth.uid())
    and status <> 'removed'
    and (select private.is_active_user())
  );

create policy posts_delete_own on public.posts
  for delete to authenticated using (author_id = (select auth.uid()));

-- ---------------------------------------------------------------------
-- post_images, post_tags — okuma: bağlı olduğu içerik gibi;
--                          yazma: yalnızca içeriğin yazarı
-- ---------------------------------------------------------------------
grant select, insert, update, delete on public.post_images to authenticated;
create policy post_images_select on public.post_images
  for select to authenticated
  using (exists (select 1 from public.posts p where p.id = post_id));
create policy post_images_write_author on public.post_images
  for all to authenticated
  using (exists (select 1 from public.posts p where p.id = post_id and p.author_id = (select auth.uid())))
  with check (exists (select 1 from public.posts p where p.id = post_id and p.author_id = (select auth.uid())));

grant select, insert, delete on public.post_tags to authenticated;
create policy post_tags_select on public.post_tags
  for select to authenticated
  using (exists (select 1 from public.posts p where p.id = post_id));
create policy post_tags_insert_author on public.post_tags
  for insert to authenticated
  with check (exists (select 1 from public.posts p where p.id = post_id and p.author_id = (select auth.uid())));
create policy post_tags_delete_author on public.post_tags
  for delete to authenticated
  using (exists (select 1 from public.posts p where p.id = post_id and p.author_id = (select auth.uid())));

-- tags — herkes okur; yeni etiket yalnızca set_post_tags() RPC'siyle eklenir.
grant select on public.tags to authenticated;
create policy tags_select on public.tags for select to authenticated using (true);

-- ---------------------------------------------------------------------
-- likes — okuma: herkes; yazma: kendi adına, seni engelleyen kişinin
--         içeriğine yazılamaz
-- ---------------------------------------------------------------------
grant select, insert, delete on public.likes to authenticated;
create policy likes_select on public.likes for select to authenticated using (true);
create policy likes_insert_own on public.likes
  for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and (select private.is_active_user())
    and exists (
      select 1 from public.posts p
       where p.id = post_id
         and p.status = 'published'
         and not private.has_blocked(p.author_id, (select auth.uid()))
    )
  );
create policy likes_delete_own on public.likes
  for delete to authenticated using (user_id = (select auth.uid()));

-- ---------------------------------------------------------------------
-- comments — görünür yorumlar herkese; engellediğin kişilerinki sana gelmez.
--   Ekleme: kendi adına, seni engelleyen yazarın içeriğine yazılamaz.
--   Düzenleme: yorum sahibi. Silme: yorum sahibi, içerik sahibi veya admin.
-- ---------------------------------------------------------------------
grant select, delete on public.comments to authenticated;
grant insert (id, post_id, author_id, parent_id, body) on public.comments to authenticated;
grant update (body) on public.comments to authenticated;

create policy comments_select on public.comments
  for select to authenticated
  using (
    author_id = (select auth.uid())
    or (select private.is_admin())
    or (
      status = 'visible'
      and not private.has_blocked((select auth.uid()), author_id)
      and exists (select 1 from public.posts p where p.id = post_id)
    )
  );

create policy comments_insert_own on public.comments
  for insert to authenticated
  with check (
    author_id = (select auth.uid())
    and (select private.is_active_user())
    and exists (
      select 1 from public.posts p
       where p.id = post_id
         and p.status = 'published'
         and not private.has_blocked(p.author_id, (select auth.uid()))
    )
  );

create policy comments_update_own on public.comments
  for update to authenticated
  using (author_id = (select auth.uid()) and status = 'visible')
  with check (author_id = (select auth.uid()) and (select private.is_active_user()));

create policy comments_delete on public.comments
  for delete to authenticated
  using (
    author_id = (select auth.uid())
    or exists (select 1 from public.posts p where p.id = post_id and p.author_id = (select auth.uid()))
    or (select private.is_admin())
  );

-- comment_mentions — yorumu görebilen görür; yalnızca tetikleyici yazar.
grant select on public.comment_mentions to authenticated;
create policy comment_mentions_select on public.comment_mentions
  for select to authenticated
  using (exists (select 1 from public.comments c where c.id = comment_id));

-- ---------------------------------------------------------------------
-- notifications — yalnızca alıcı; satırları yalnızca veritabanı
--                 tetikleyicileri oluşturur; alıcı sadece read_at günceller
-- ---------------------------------------------------------------------
grant select, delete on public.notifications to authenticated;
grant update (read_at) on public.notifications to authenticated;
create policy notifications_select_own on public.notifications
  for select to authenticated using (recipient_id = (select auth.uid()));
create policy notifications_update_own on public.notifications
  for update to authenticated
  using (recipient_id = (select auth.uid()))
  with check (recipient_id = (select auth.uid()));
create policy notifications_delete_own on public.notifications
  for delete to authenticated using (recipient_id = (select auth.uid()));

-- ---------------------------------------------------------------------
-- reports — ekleme: giriş yapmış herkes (bir kez); okuma/güncelleme: admin
-- ---------------------------------------------------------------------
grant insert (reporter_id, target_type, target_id) on public.reports to authenticated;
grant select on public.reports to authenticated;
create policy reports_insert_own on public.reports
  for insert to authenticated
  with check (reporter_id = (select auth.uid()) and (select private.is_active_user()));
create policy reports_select_admin on public.reports
  for select to authenticated using ((select private.is_admin()));

-- moderation_actions — yalnızca admin okur; yazma moderasyon RPC'leriyle.
grant select on public.moderation_actions to authenticated;
create policy moderation_actions_select_admin on public.moderation_actions
  for select to authenticated using ((select private.is_admin()));

-- ---------------------------------------------------------------------
-- app_config — herkes okur (giriş yapmadan da), admin yazar
-- ---------------------------------------------------------------------
grant select on public.app_config to anon, authenticated;
grant update (latest_version, min_version, apk_url) on public.app_config to authenticated;
create policy app_config_select on public.app_config for select to anon, authenticated using (true);
create policy app_config_update_admin on public.app_config
  for update to authenticated
  using ((select private.is_admin()))
  with check ((select private.is_admin()));
