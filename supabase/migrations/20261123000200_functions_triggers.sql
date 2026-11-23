-- =====================================================================
-- Peerless — 2/6: Yardımcı fonksiyonlar ve tetikleyiciler
-- Kurallar veritabanında korunur; uygulama yalnızca erken uyarı verir.
-- Hata mesajları kısa kodlardır (ör. 'nickname_reserved'); uygulama
-- bunları TR/EN metne çevirir.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Yardımcılar (private şeması API'de görünmez)
-- ---------------------------------------------------------------------

-- Giriş yapmış kullanıcı admin mi? Admin paneli yalnızca bu true ise görünür.
create or replace function private.is_admin()
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and role = 'admin' and status = 'active'
  );
$$;

-- Giriş yapmış kullanıcı yazabilir mi? (banlı veya silinme bekleyen değil)
create or replace function private.is_active_user()
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and status = 'active' and deletion_requested_at is null
  );
$$;

-- p_blocker, p_blocked'ı engellemiş mi?
create or replace function private.has_blocked(p_blocker uuid, p_blocked uuid)
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.blocks where blocker_id = p_blocker and blocked_id = p_blocked
  );
$$;

-- Profil başkalarına görünür mü? (aktif, silinme beklemiyor, kurulumu tamam)
create or replace function private.is_visible_user(p_user uuid)
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles
    where id = p_user and status = 'active' and deletion_requested_at is null and nickname is not null
  );
$$;

grant usage on schema private to authenticated, service_role;
grant execute on function private.is_admin() to authenticated;
grant execute on function private.is_active_user() to authenticated;
grant execute on function private.has_blocked(uuid, uuid) to authenticated;
grant execute on function private.is_visible_user(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- Bildirim oluşturma: tüm bildirimler buradan geçer
-- ---------------------------------------------------------------------
create or replace function private.notify(
  p_recipient uuid,
  p_type public.notification_type,
  p_actor uuid,
  p_post uuid,
  p_comment uuid,
  p_meta jsonb default '{}'::jsonb
)
returns void
language plpgsql security definer
set search_path = ''
as $$
declare
  v_enabled boolean;
begin
  if p_recipient is null then
    return;
  end if;

  -- Moderasyon bildirimleri kapatılamaz; diğerleri için kurallar:
  if p_type <> 'moderation' then
    -- Kendi eylemin için bildirim oluşmaz.
    if p_actor = p_recipient then
      return;
    end if;
    -- Engellediğin kişiden bildirim gelmez.
    if private.has_blocked(p_recipient, p_actor) then
      return;
    end if;
    -- Alıcının ayarı kapalıysa bildirim oluşmaz.
    select case p_type
             when 'comment' then s.comment
             when 'reply'   then s.reply
             when 'like'    then s."like"
             when 'mention' then s.mention
           end
      into v_enabled
      from public.notification_settings s
     where s.user_id = p_recipient;
    if not coalesce(v_enabled, true) then
      return;
    end if;
    -- Aynı yorum için aynı kişiye ikinci bildirim gitmez (ör. hem yanıt hem @bahsetme).
    if p_comment is not null and exists (
      select 1 from public.notifications n
       where n.recipient_id = p_recipient and n.comment_id = p_comment
    ) then
      return;
    end if;
    -- Beğen-geri al-beğen tekrarında yeni bildirim oluşmaz.
    if p_type = 'like' and exists (
      select 1 from public.notifications n
       where n.recipient_id = p_recipient and n.type = 'like'
         and n.actor_id = p_actor and n.post_id = p_post
    ) then
      return;
    end if;
  end if;

  insert into public.notifications (recipient_id, type, actor_id, post_id, comment_id, meta)
  values (p_recipient, p_type, p_actor, p_post, p_comment, coalesce(p_meta, '{}'::jsonb));
end;
$$;

-- =====================================================================
-- auth.users tetikleyicileri
-- =====================================================================

-- Kayıtta profil ve bildirim ayarları satırı otomatik oluşur.
create or replace function private.handle_new_user()
returns trigger
language plpgsql security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, locale)
  values (
    new.id,
    case when new.raw_user_meta_data ->> 'locale' = 'en' then 'en' else 'tr' end
  );
  insert into public.notification_settings (user_id) values (new.id);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

-- Hesap silme talebinden sonraki 30 gün içinde giriş yapılırsa talep iptal olur.
create or replace function private.handle_user_sign_in()
returns trigger
language plpgsql security definer
set search_path = ''
as $$
begin
  if new.last_sign_in_at is distinct from old.last_sign_in_at then
    update public.profiles
       set deletion_requested_at = null
     where id = new.id and deletion_requested_at is not null;
  end if;
  return new;
end;
$$;

create trigger on_auth_user_signed_in
  after update of last_sign_in_at on auth.users
  for each row execute function private.handle_user_sign_in();

-- =====================================================================
-- profiles
-- =====================================================================
create or replace function private.profiles_before_write()
returns trigger
language plpgsql security definer
set search_path = ''
as $$
begin
  if new.nickname is not null then
    new.nickname := lower(btrim(new.nickname));
  end if;
  if new.display_name is not null then
    new.display_name := nullif(btrim(new.display_name), '');
  end if;
  if new.bio is not null then
    new.bio := nullif(btrim(new.bio), '');
  end if;

  if tg_op = 'UPDATE' and new.nickname is distinct from old.nickname then
    if new.nickname is null then
      raise exception 'nickname_required';
    end if;
    -- İlk seçim serbest; sonraki değişiklikler 30 günde bir.
    if old.nickname is not null then
      if old.nickname_changed_at is not null
         and old.nickname_changed_at > now() - interval '30 days'
         and not private.is_admin() then
        raise exception 'nickname_change_too_soon';
      end if;
      insert into public.nickname_history (nickname, user_id) values (old.nickname, old.id);
      new.nickname_changed_at := now();
    end if;
    -- Başkasının son 30 günde bıraktığı nickname alınamaz.
    if exists (
      select 1 from public.nickname_history h
       where h.nickname = new.nickname
         and h.user_id is distinct from new.id
         and h.released_at > now() - interval '30 days'
    ) then
      raise exception 'nickname_reserved';
    end if;
  end if;
  return new;
end;
$$;

create trigger profiles_before_write
  before insert or update on public.profiles
  for each row execute function private.profiles_before_write();

-- Silinen hesabın nickname'i de 30 gün bekletilir (taklidi önlemek için).
create or replace function private.profiles_before_delete()
returns trigger
language plpgsql security definer
set search_path = ''
as $$
begin
  if old.nickname is not null then
    insert into public.nickname_history (nickname, user_id) values (old.nickname, null);
  end if;
  return old;
end;
$$;

create trigger profiles_before_delete
  before delete on public.profiles
  for each row execute function private.profiles_before_delete();

-- =====================================================================
-- posts
-- =====================================================================
create or replace function private.posts_before_write()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.title := btrim(coalesce(new.title, ''));
  new.excerpt := left(btrim(regexp_replace(coalesce(new.body_text, ''), '\s+', ' ', 'g')), 280);
  if new.personal_note is not null then
    new.personal_note := nullif(btrim(new.personal_note), '');
  end if;
  -- Yalnızca yayındaki içerik sabitlenebilir.
  if new.status <> 'published' then
    new.is_pinned := false;
  end if;

  if tg_op = 'INSERT' then
    new.like_count := 0;
    new.comment_count := 0;
    new.edited_at := null;
    new.published_at := case when new.status = 'published' then now() else null end;
    return new;
  end if;

  -- UPDATE
  if old.status = 'published' and new.status = 'draft' then
    raise exception 'cannot_unpublish';
  end if;
  if old.status <> 'draft' and new.type <> old.type then
    raise exception 'cannot_change_type';
  end if;
  if old.status = 'draft' and new.status = 'published' then
    new.published_at := now();
  end if;

  if new.title is distinct from old.title
     or new.body is distinct from old.body
     or new.personal_note is distinct from old.personal_note
     or new.cover_url is distinct from old.cover_url
     or new.type is distinct from old.type then
    new.updated_at := now();
    -- Yayınlanmış içerik düzenlenince 'düzenlendi' ibaresi.
    if old.status = 'published' and new.status = 'published' then
      new.edited_at := now();
    end if;
  end if;
  return new;
end;
$$;

create trigger posts_before_write
  before insert or update on public.posts
  for each row execute function private.posts_before_write();

-- =====================================================================
-- post_images: içerik başına en fazla 5 görsel; galeri yalnızca projede
-- =====================================================================
create or replace function private.post_images_before_insert()
returns trigger
language plpgsql security definer
set search_path = ''
as $$
declare
  v_type public.post_type;
begin
  select type into v_type from public.posts where id = new.post_id for update;
  if new.kind = 'gallery' and v_type <> 'project' then
    raise exception 'gallery_only_project';
  end if;
  if (select count(*) from public.post_images where post_id = new.post_id) >= 5 then
    raise exception 'too_many_images';
  end if;
  return new;
end;
$$;

create trigger post_images_before_insert
  before insert on public.post_images
  for each row execute function private.post_images_before_insert();

-- =====================================================================
-- post_tags: içerik başına en fazla 5 etiket
-- =====================================================================
create or replace function private.post_tags_before_insert()
returns trigger
language plpgsql security definer
set search_path = ''
as $$
begin
  perform 1 from public.posts where id = new.post_id for update;
  if (select count(*) from public.post_tags where post_id = new.post_id) >= 5 then
    raise exception 'too_many_tags';
  end if;
  return new;
end;
$$;

create trigger post_tags_before_insert
  before insert on public.post_tags
  for each row execute function private.post_tags_before_insert();

-- =====================================================================
-- likes: sayaç + bildirim
-- =====================================================================
create or replace function private.likes_after_change()
returns trigger
language plpgsql security definer
set search_path = ''
as $$
declare
  v_author uuid;
begin
  if tg_op = 'INSERT' then
    update public.posts set like_count = like_count + 1
     where id = new.post_id
     returning author_id into v_author;
    perform private.notify(v_author, 'like', new.user_id, new.post_id, null);
    return null;
  end if;
  update public.posts set like_count = greatest(like_count - 1, 0) where id = old.post_id;
  return null;
end;
$$;

create trigger likes_after_change
  after insert or delete on public.likes
  for each row execute function private.likes_after_change();

-- =====================================================================
-- comments
-- =====================================================================
create or replace function private.comments_before_write()
returns trigger
language plpgsql security definer
set search_path = ''
as $$
declare
  v_parent public.comments%rowtype;
begin
  new.body := btrim(new.body);

  if tg_op = 'INSERT' then
    new.status := 'visible';
    new.edited_at := null;
    -- Tek seviye yanıt: parent yalnızca aynı içerikteki bir ana yorum olabilir.
    if new.parent_id is not null then
      select * into v_parent from public.comments where id = new.parent_id;
      if not found or v_parent.parent_id is not null or v_parent.post_id <> new.post_id then
        raise exception 'invalid_parent';
      end if;
    end if;
    return new;
  end if;

  -- UPDATE
  if new.post_id <> old.post_id or new.parent_id is distinct from old.parent_id
     or new.author_id <> old.author_id then
    raise exception 'immutable_comment_fields';
  end if;
  if new.body is distinct from old.body then
    new.edited_at := now();
  end if;
  return new;
end;
$$;

create trigger comments_before_write
  before insert or update on public.comments
  for each row execute function private.comments_before_write();

-- Yeni yorum: sayaç, yorum/yanıt bildirimi ve @bahsetmeler.
create or replace function private.comments_after_insert()
returns trigger
language plpgsql security definer
set search_path = ''
as $$
declare
  v_post_author uuid;
  v_parent_author uuid;
begin
  update public.posts set comment_count = comment_count + 1
   where id = new.post_id
   returning author_id into v_post_author;

  if new.parent_id is not null then
    select author_id into v_parent_author from public.comments where id = new.parent_id;
    perform private.notify(v_parent_author, 'reply', new.author_id, new.post_id, new.id);
  end if;
  if v_post_author is distinct from v_parent_author then
    perform private.notify(v_post_author, 'comment', new.author_id, new.post_id, new.id);
  end if;

  -- @nickname'leri bul (en fazla 10 kişi). Engellenmiş kişi bahsedemez.
  insert into public.comment_mentions (comment_id, mentioned_user_id)
  select new.id, p.id
    from (
      select distinct rtrim(lower(m[1]), '.') as nick
        from regexp_matches(new.body, '@([A-Za-z0-9_.]{3,21})', 'g') as m
    ) found
    join public.profiles p on p.nickname = found.nick
   where p.id <> new.author_id
     and p.status = 'active'
     and not private.has_blocked(p.id, new.author_id)
   limit 10
  on conflict do nothing;

  return null;
end;
$$;

create trigger comments_after_insert
  after insert on public.comments
  for each row execute function private.comments_after_insert();

-- Sayaç yalnızca görünür yorumları sayar.
create or replace function private.comments_after_update_delete()
returns trigger
language plpgsql security definer
set search_path = ''
as $$
begin
  if tg_op = 'DELETE' then
    if old.status = 'visible' then
      update public.posts set comment_count = greatest(comment_count - 1, 0) where id = old.post_id;
    end if;
    return null;
  end if;
  if old.status = 'visible' and new.status = 'removed' then
    update public.posts set comment_count = greatest(comment_count - 1, 0) where id = new.post_id;
  elsif old.status = 'removed' and new.status = 'visible' then
    update public.posts set comment_count = comment_count + 1 where id = new.post_id;
  end if;
  return null;
end;
$$;

create trigger comments_after_update_delete
  after update of status or delete on public.comments
  for each row execute function private.comments_after_update_delete();

-- @bahsetme bildirimi
create or replace function private.comment_mentions_after_insert()
returns trigger
language plpgsql security definer
set search_path = ''
as $$
declare
  v_comment public.comments%rowtype;
begin
  select * into v_comment from public.comments where id = new.comment_id;
  perform private.notify(new.mentioned_user_id, 'mention', v_comment.author_id, v_comment.post_id, v_comment.id);
  return null;
end;
$$;

create trigger comment_mentions_after_insert
  after insert on public.comment_mentions
  for each row execute function private.comment_mentions_after_insert();
