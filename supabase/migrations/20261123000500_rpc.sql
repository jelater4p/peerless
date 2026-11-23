-- =====================================================================
-- Peerless — 5/6: Uygulamanın çağırdığı fonksiyonlar (RPC)
-- Dart'ta: supabase.rpc('fonksiyon_adi', params: {...})
-- =====================================================================

-- ---------------------------------------------------------------------
-- Nickname uygun mu? (biçim, başkasında olmaması, 30 günlük bekleme)
-- ---------------------------------------------------------------------
create or replace function public.is_nickname_available(p_nickname text)
returns boolean
language sql stable security definer
set search_path = ''
as $$
  with n as (select lower(btrim(p_nickname)) as nick)
  select n.nick ~ '^[a-z0-9_.]{3,20}$'
     and not exists (
       select 1 from public.profiles p
        where p.nickname = n.nick and p.id <> (select auth.uid())
     )
     and not exists (
       select 1 from public.nickname_history h
        where h.nickname = n.nick
          and h.user_id is distinct from (select auth.uid())
          and h.released_at > now() - interval '30 days'
     )
  from n;
$$;

-- ---------------------------------------------------------------------
-- Hesap silme talebi: 30 gün sonra kesinleşir (purge-deleted-accounts).
-- Bu sürede giriş yapılırsa talep iptal olur (auth.users tetikleyicisi).
-- ---------------------------------------------------------------------
create or replace function public.request_account_deletion()
returns void
language plpgsql security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null then
    raise exception 'not_authenticated';
  end if;
  update public.profiles
     set deletion_requested_at = now()
   where id = v_uid;
  update public.posts set is_pinned = false where author_id = v_uid and is_pinned;
  delete from public.device_tokens where user_id = v_uid;
  -- Diğer cihazlardaki oturumları da kapat.
  begin
    delete from auth.sessions where user_id = v_uid;
  exception when others then
    raise warning 'oturumlar kapatılamadı: %', sqlerrm;
  end;
end;
$$;

-- ---------------------------------------------------------------------
-- Push bildirimi için cihaz anahtarını kaydet (cihaz el değiştirirse taşınır).
-- ---------------------------------------------------------------------
create or replace function public.register_device_token(p_token text, p_platform text default 'android')
returns void
language plpgsql security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is null then
    raise exception 'not_authenticated';
  end if;
  if p_token is null or btrim(p_token) = '' then
    return;
  end if;
  insert into public.device_tokens (token, user_id, platform, updated_at)
  values (p_token, (select auth.uid()), coalesce(nullif(p_platform, ''), 'android'), now())
  on conflict (token) do update
    set user_id = excluded.user_id,
        platform = excluded.platform,
        updated_at = now();
end;
$$;

-- ---------------------------------------------------------------------
-- İçeriğin etiketlerini topluca ayarla (en fazla 5, küçük harf).
-- Uygulama Türkçe büyük/küçük harf dönüşümünü (I→ı, İ→i) önceden yapar.
-- ---------------------------------------------------------------------
create or replace function public.set_post_tags(p_post_id uuid, p_tags text[])
returns void
language plpgsql security definer
set search_path = ''
as $$
declare
  v_names text[];
begin
  if not exists (
    select 1 from public.posts
     where id = p_post_id and author_id = (select auth.uid()) and status <> 'removed'
  ) or not private.is_active_user() then
    raise exception 'not_post_author';
  end if;

  select coalesce(array_agg(distinct s.n), '{}')
    into v_names
    from (
      select lower(btrim(regexp_replace(t, '^#+', ''))) as n
        from unnest(coalesce(p_tags, '{}'::text[])) as t
    ) s
   where s.n <> '';

  if coalesce(array_length(v_names, 1), 0) > 5 then
    raise exception 'too_many_tags';
  end if;

  insert into public.tags (name)
  select unnest(v_names)
  on conflict (name) do nothing;

  delete from public.post_tags where post_id = p_post_id;
  insert into public.post_tags (post_id, tag_id)
  select p_post_id, t.id from public.tags t where t.name = any (v_names);
end;
$$;

-- ---------------------------------------------------------------------
-- Profilde sabitle / sabitlemeyi kaldır (profil başına 1 içerik).
-- ---------------------------------------------------------------------
create or replace function public.set_pinned_post(p_post_id uuid, p_pinned boolean default true)
returns void
language plpgsql
set search_path = ''
as $$
begin
  if not exists (
    select 1 from public.posts where id = p_post_id and author_id = (select auth.uid())
  ) then
    raise exception 'not_post_author';
  end if;
  if p_pinned and not exists (
    select 1 from public.posts where id = p_post_id and status = 'published'
  ) then
    raise exception 'pin_requires_published';
  end if;
  if p_pinned then
    update public.posts set is_pinned = false
     where author_id = (select auth.uid()) and is_pinned and id <> p_post_id;
  end if;
  update public.posts set is_pinned = p_pinned
   where id = p_post_id and author_id = (select auth.uid());
end;
$$;

-- ---------------------------------------------------------------------
-- Ana akış: tür sekmesi + etiket filtresi + sıralama (en yeni / popüler).
-- Popüler: son 7 günde yayınlanmış içerikler, beğeni sayısına göre.
-- security invoker: RLS uygulanır (engellenenler, banlılar görünmez).
-- ---------------------------------------------------------------------
create or replace function public.get_feed(
  p_type   public.post_type default null,
  p_tag    text default null,
  p_sort   text default 'new',
  p_limit  integer default 20,
  p_offset integer default 0
)
returns setof public.posts
language sql stable
set search_path = ''
as $$
  select p.*
    from public.posts p
   where p.status = 'published'
     and (p_type is null or p.type = p_type)
     and (
       p_tag is null
       or exists (
         select 1 from public.post_tags pt
           join public.tags t on t.id = pt.tag_id
          where pt.post_id = p.id and t.name = p_tag
       )
     )
     and (p_sort <> 'popular' or p.published_at > now() - interval '7 days')
   order by
     case when p_sort = 'popular' then p.like_count end desc nulls last,
     p.published_at desc,
     p.id
   limit least(greatest(coalesce(p_limit, 20), 1), 50)
  offset greatest(coalesce(p_offset, 0), 0);
$$;

-- ---------------------------------------------------------------------
-- İçerik arama (başlık ve metin; TR + EN; yazdıkça önek eşleşmesi).
-- ---------------------------------------------------------------------
create or replace function public.search_posts(p_query text, p_limit integer default 20, p_offset integer default 0)
returns setof public.posts
language plpgsql stable
set search_path = ''
as $$
declare
  v_terms text;
  v_query tsquery;
begin
  -- Kelimeleri ayır, tsquery özel karakterlerini temizle, her birine önek (:*) ekle.
  select string_agg(w || ':*', ' & ')
    into v_terms
    from (
      select regexp_replace(lower(x), '[&|!():*<>''"\\]', '', 'g') as w
        from regexp_split_to_table(coalesce(p_query, ''), '\s+') as x
    ) words
   where w <> '';

  if v_terms is null then
    return;
  end if;

  v_query := to_tsquery('simple'::regconfig, v_terms)
          || to_tsquery('turkish'::regconfig, v_terms)
          || to_tsquery('english'::regconfig, v_terms);

  return query
    select p.*
      from public.posts p
     where p.status = 'published'
       and p.search @@ v_query
     order by ts_rank(p.search, v_query) desc, p.published_at desc
     limit least(greatest(coalesce(p_limit, 20), 1), 50)
    offset greatest(coalesce(p_offset, 0), 0);
end;
$$;

-- ---------------------------------------------------------------------
-- Kişi arama: nickname ve görünen ada göre kısmi eşleşme (pg_trgm).
-- ---------------------------------------------------------------------
create or replace function public.search_profiles(p_query text, p_limit integer default 3)
returns setof public.profiles
language sql stable
set search_path = ''
as $$
  with q as (
    select lower(btrim(regexp_replace(coalesce(p_query, ''), '^@', ''))) as raw
  ), e as (
    select raw, replace(replace(replace(raw, '\', '\\'), '%', '\%'), '_', '\_') as esc from q
  )
  select p.*
    from public.profiles p, e
   where e.raw <> ''
     and p.nickname is not null
     and (p.nickname ilike '%' || e.esc || '%' or p.display_name ilike '%' || e.esc || '%')
     and not private.has_blocked((select auth.uid()), p.id)
   order by
     (p.nickname = e.raw) desc,
     (p.nickname ilike e.esc || '%') desc,
     extensions.similarity(p.nickname, e.raw) desc,
     p.nickname
   limit least(greatest(coalesce(p_limit, 3), 1), 50);
$$;

-- =====================================================================
-- Admin paneli
-- =====================================================================

-- Şikayetler hedef bazında gruplanmış olarak (aynı içeriğe 3 şikayet = 1 satır).
create or replace function public.admin_list_reports(p_status public.report_status default 'open')
returns table (
  target_type       public.report_target,
  target_id         uuid,
  report_count      bigint,
  first_reported_at timestamptz,
  last_reported_at  timestamptz,
  target_user_id    uuid,
  target_nickname   text,
  post_id           uuid,
  preview           text,
  target_status     text
)
language plpgsql stable security definer
set search_path = ''
as $$
begin
  if not private.is_admin() then
    raise exception 'not_admin';
  end if;

  return query
  with grouped as (
    select r.target_type, r.target_id,
           count(*) as report_count,
           min(r.created_at) as first_reported_at,
           max(r.created_at) as last_reported_at
      from public.reports r
     where r.status = p_status
     group by r.target_type, r.target_id
  )
  select g.target_type,
         g.target_id,
         g.report_count,
         g.first_reported_at,
         g.last_reported_at,
         coalesce(po.author_id, c.author_id, pr.id),
         u.nickname,
         coalesce(po.id, c.post_id),
         case g.target_type
           when 'post' then po.title
           when 'comment' then c.body
           else concat_ws(' — ', pr.display_name, pr.bio)
         end,
         case g.target_type
           when 'post' then po.status::text
           when 'comment' then c.status::text
           else pr.status::text
         end
    from grouped g
    left join public.posts po    on g.target_type = 'post'    and po.id = g.target_id
    left join public.comments c  on g.target_type = 'comment' and c.id = g.target_id
    left join public.profiles pr on g.target_type = 'profile' and pr.id = g.target_id
    left join public.profiles u  on u.id = coalesce(po.author_id, c.author_id, pr.id)
   order by g.first_reported_at;
end;
$$;

-- Şikayeti sonuçlandır: 'dismiss' (reddet), 'remove_content', 'warn', 'ban'.
-- Aynı hedefe ait tüm açık şikayetler birlikte kapanır.
create or replace function public.admin_moderate(
  p_target_type public.report_target,
  p_target_id   uuid,
  p_action      text,
  p_note        text default null
)
returns void
language plpgsql security definer
set search_path = ''
as $$
declare
  v_admin       uuid := (select auth.uid());
  v_target_user uuid;
  v_post_id     uuid;
  v_comment_id  uuid;
  v_report_id   uuid;
begin
  if not private.is_admin() then
    raise exception 'not_admin';
  end if;
  if p_action not in ('dismiss', 'remove_content', 'warn', 'ban') then
    raise exception 'invalid_action';
  end if;

  -- Hedefin sahibini bul
  if p_target_type = 'post' then
    select author_id, id into v_target_user, v_post_id from public.posts where id = p_target_id;
  elsif p_target_type = 'comment' then
    select author_id, post_id, id into v_target_user, v_post_id, v_comment_id
      from public.comments where id = p_target_id;
  else
    v_target_user := p_target_id;
  end if;

  select id into v_report_id
    from public.reports
   where target_type = p_target_type and target_id = p_target_id and status = 'open'
   order by created_at
   limit 1;

  if p_action = 'dismiss' then
    update public.reports set status = 'dismissed'
     where target_type = p_target_type and target_id = p_target_id and status = 'open';
    return;
  end if;

  if v_target_user is null then
    raise exception 'target_not_found';
  end if;
  if v_target_user = v_admin then
    raise exception 'cannot_moderate_self';
  end if;

  if p_action = 'remove_content' then
    if p_target_type = 'post' then
      update public.posts set status = 'removed' where id = p_target_id;
    elsif p_target_type = 'comment' then
      update public.comments set status = 'removed' where id = p_target_id;
    else
      -- Profilde kaldırılacak içerik: görünen ad, biyografi, fotoğraf ve kapak.
      update public.profiles
         set display_name = null, bio = null, avatar_url = null, cover_url = null
       where id = p_target_id;
    end if;
  elsif p_action = 'ban' then
    perform private.ban_user(v_target_user);
  end if;

  insert into public.moderation_actions (admin_id, target_user_id, report_id, action, note)
  values (v_admin, v_target_user, v_report_id, p_action::public.moderation_action_type, nullif(btrim(p_note), ''));

  update public.reports set status = 'actioned'
   where target_type = p_target_type and target_id = p_target_id and status = 'open';

  perform private.notify(
    v_target_user, 'moderation', v_admin, v_post_id, v_comment_id,
    jsonb_build_object('action', p_action, 'note', nullif(btrim(p_note), ''), 'target_type', p_target_type)
  );
end;
$$;

-- Kalıcı ban: profil kapanır, oturumlar sonlanır, tekrar giriş engellenir.
create or replace function private.ban_user(p_user uuid)
returns void
language plpgsql security definer
set search_path = ''
as $$
begin
  update public.profiles set status = 'banned' where id = p_user;
  update public.posts set is_pinned = false where author_id = p_user and is_pinned;
  delete from public.device_tokens where user_id = p_user;
  begin
    -- Supabase Auth girişi reddeder (banned_until gelecekte olduğu sürece).
    update auth.users set banned_until = now() + interval '100 years' where id = p_user;
    delete from auth.sessions where user_id = p_user;
  exception when others then
    raise warning 'auth ban uygulanamadı: %', sqlerrm;
  end;
end;
$$;

-- ---------------------------------------------------------------------
-- Yetkiler: RPC'leri yalnızca giriş yapmış kullanıcılar çağırabilir.
-- ---------------------------------------------------------------------
revoke execute on function public.is_nickname_available(text) from public, anon;
revoke execute on function public.request_account_deletion() from public, anon;
revoke execute on function public.register_device_token(text, text) from public, anon;
revoke execute on function public.set_post_tags(uuid, text[]) from public, anon;
revoke execute on function public.set_pinned_post(uuid, boolean) from public, anon;
revoke execute on function public.get_feed(public.post_type, text, text, integer, integer) from public, anon;
revoke execute on function public.search_posts(text, integer, integer) from public, anon;
revoke execute on function public.search_profiles(text, integer) from public, anon;
revoke execute on function public.admin_list_reports(public.report_status) from public, anon;
revoke execute on function public.admin_moderate(public.report_target, uuid, text, text) from public, anon;

grant execute on function public.is_nickname_available(text) to authenticated;
grant execute on function public.request_account_deletion() to authenticated;
grant execute on function public.register_device_token(text, text) to authenticated;
grant execute on function public.set_post_tags(uuid, text[]) to authenticated;
grant execute on function public.set_pinned_post(uuid, boolean) to authenticated;
grant execute on function public.get_feed(public.post_type, text, text, integer, integer) to authenticated;
grant execute on function public.search_posts(text, integer, integer) to authenticated;
grant execute on function public.search_profiles(text, integer) to authenticated;
grant execute on function public.admin_list_reports(public.report_status) to authenticated;
grant execute on function public.admin_moderate(public.report_target, uuid, text, text) to authenticated;

-- private şemasındaki iç fonksiyonları dışarıya kapat.
revoke execute on function private.notify(uuid, public.notification_type, uuid, uuid, uuid, jsonb) from public;
revoke execute on function private.ban_user(uuid) from public;
