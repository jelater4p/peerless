-- =====================================================================
-- Peerless — 1/6: Şema (tipler, 17 tablo, indeksler)
-- Planın "Veri modeli ve erişim kuralları" bölümünün son hali.
-- Supabase SQL Editor'de sırayla çalıştırılır (bkz. docs/03-veritabani.md).
-- =====================================================================

-- Kısmi eşleşmeli nickname araması için (pg_trgm)
create extension if not exists pg_trgm with schema extensions;

-- API'ye açılmayan yardımcı fonksiyonlar bu şemada durur.
create schema if not exists private;

-- ---------------------------------------------------------------------
-- Sabit değer listeleri (enum)
-- ---------------------------------------------------------------------
create type public.user_role as enum ('user', 'admin');
create type public.user_status as enum ('active', 'banned');
create type public.post_type as enum ('quote', 'thought', 'thesis', 'project');
create type public.post_status as enum ('draft', 'published', 'removed');
create type public.image_kind as enum ('cover', 'inline', 'gallery');
create type public.comment_status as enum ('visible', 'removed');
create type public.notification_type as enum ('comment', 'reply', 'like', 'mention', 'moderation');
create type public.report_target as enum ('post', 'comment', 'profile');
create type public.report_status as enum ('open', 'dismissed', 'actioned');
create type public.moderation_action_type as enum ('remove_content', 'warn', 'ban');

-- =====================================================================
-- Kullanıcılar
-- =====================================================================

-- Her auth kullanıcısı için bir profil satırı (kayıtta tetikleyiciyle oluşur).
create table public.profiles (
  id                    uuid primary key references auth.users (id) on delete cascade,
  nickname              text,
  display_name          text,
  bio                   text,
  avatar_url            text,
  cover_url             text,
  locale                text not null default 'tr',
  role                  public.user_role not null default 'user',
  status                public.user_status not null default 'active',
  nickname_changed_at   timestamptz,
  deletion_requested_at timestamptz,
  created_at            timestamptz not null default now(),
  -- Tetikleyici nickname'i küçük harfe çevirir; bu yüzden benzersizlik
  -- büyük/küçük harf duyarsızdır.
  constraint profiles_nickname_format check (nickname is null or nickname ~ '^[a-z0-9_.]{3,20}$'),
  constraint profiles_display_name_length check (display_name is null or char_length(display_name) between 1 and 50),
  constraint profiles_bio_length check (bio is null or char_length(bio) <= 160),
  constraint profiles_locale check (locale in ('tr', 'en'))
);
create unique index profiles_nickname_key on public.profiles (nickname);
create index profiles_nickname_trgm on public.profiles using gin (nickname extensions.gin_trgm_ops);
create index profiles_display_name_trgm on public.profiles using gin (display_name extensions.gin_trgm_ops);

-- Bırakılan nickname'ler 30 gün boyunca başkasına verilmez.
create table public.nickname_history (
  id          bigint generated always as identity primary key,
  nickname    text not null,
  user_id     uuid references public.profiles (id) on delete set null,
  released_at timestamptz not null default now()
);
create index nickname_history_nickname_idx on public.nickname_history (nickname, released_at desc);

create table public.blocks (
  blocker_id uuid not null references public.profiles (id) on delete cascade,
  blocked_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  constraint blocks_not_self check (blocker_id <> blocked_id)
);
create index blocks_blocked_idx on public.blocks (blocked_id);

-- Push bildirimi için cihaz (FCM) anahtarları. Bir anahtar tek cihaza aittir.
create table public.device_tokens (
  token      text primary key,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  platform   text not null default 'android',
  updated_at timestamptz not null default now()
);
create index device_tokens_user_idx on public.device_tokens (user_id);

create table public.notification_settings (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  comment boolean not null default true,
  reply   boolean not null default true,
  "like"  boolean not null default true,
  mention boolean not null default true
);

-- =====================================================================
-- İçerik
-- =====================================================================

create table public.posts (
  id            uuid primary key default gen_random_uuid(),
  author_id     uuid not null references public.profiles (id) on delete cascade,
  type          public.post_type not null,
  title         text not null default '',
  body          jsonb not null default '[]'::jsonb,   -- flutter_quill Delta (JSON)
  body_text     text not null default '',             -- düz metin (arama ve özet için)
  excerpt       text not null default '',             -- tetikleyici body_text'ten üretir
  personal_note text,                                 -- yalnızca alıntı türünde
  cover_url     text,
  status        public.post_status not null default 'draft',
  is_pinned     boolean not null default false,
  like_count    integer not null default 0,
  comment_count integer not null default 0,
  published_at  timestamptz,
  edited_at     timestamptz,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  -- Türkçe + İngilizce kök bulma ve 'simple' (kelimenin aynısı) birlikte.
  search tsvector generated always as (
    setweight(to_tsvector('simple'::regconfig, title), 'A') ||
    setweight(to_tsvector('turkish'::regconfig, title), 'A') ||
    setweight(to_tsvector('english'::regconfig, title), 'A') ||
    setweight(to_tsvector('simple'::regconfig, body_text), 'B') ||
    setweight(to_tsvector('turkish'::regconfig, body_text), 'B') ||
    setweight(to_tsvector('english'::regconfig, body_text), 'B')
  ) stored,
  constraint posts_title_length check (char_length(title) <= 150),
  constraint posts_body_text_length check (char_length(body_text) <= 100000),
  constraint posts_personal_note_quote_only check (personal_note is null or type = 'quote'),
  constraint posts_personal_note_length check (personal_note is null or char_length(personal_note) <= 2000),
  constraint posts_published_has_title check (status = 'draft' or char_length(btrim(title)) > 0),
  constraint posts_pinned_published check (not is_pinned or status = 'published')
);
-- Kullanıcı başına en fazla 1 sabitlenmiş içerik
create unique index posts_one_pinned_per_author on public.posts (author_id) where is_pinned;
create index posts_feed_idx on public.posts (status, published_at desc);
create index posts_type_feed_idx on public.posts (type, status, published_at desc);
create index posts_author_idx on public.posts (author_id, status, published_at desc);
create index posts_search_idx on public.posts using gin (search);

create table public.post_images (
  id         uuid primary key default gen_random_uuid(),
  post_id    uuid not null references public.posts (id) on delete cascade,
  url        text not null,
  kind       public.image_kind not null,
  position   integer not null default 0,
  created_at timestamptz not null default now()
);
create index post_images_post_idx on public.post_images (post_id, kind, position);

create table public.tags (
  id         bigint generated always as identity primary key,
  name       text not null unique,
  created_at timestamptz not null default now(),
  constraint tags_name_format check (
    name = lower(name) and name = btrim(name)
    and char_length(name) between 1 and 30
    and name !~ '[#,@]'
  )
);
create index tags_name_trgm on public.tags using gin (name extensions.gin_trgm_ops);

create table public.post_tags (
  post_id uuid not null references public.posts (id) on delete cascade,
  tag_id  bigint not null references public.tags (id) on delete cascade,
  primary key (post_id, tag_id)
);
create index post_tags_tag_idx on public.post_tags (tag_id);

-- =====================================================================
-- Etkileşim
-- =====================================================================

create table public.likes (
  user_id    uuid not null references public.profiles (id) on delete cascade,
  post_id    uuid not null references public.posts (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, post_id)
);
create index likes_post_idx on public.likes (post_id);

create table public.bookmarks (
  user_id    uuid not null references public.profiles (id) on delete cascade,
  post_id    uuid not null references public.posts (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, post_id)
);
create index bookmarks_user_idx on public.bookmarks (user_id, created_at desc);
create index bookmarks_post_idx on public.bookmarks (post_id);

create table public.comments (
  id         uuid primary key default gen_random_uuid(),
  post_id    uuid not null references public.posts (id) on delete cascade,
  author_id  uuid not null references public.profiles (id) on delete cascade,
  parent_id  uuid references public.comments (id) on delete cascade,
  body       text not null,
  status     public.comment_status not null default 'visible',
  edited_at  timestamptz,
  created_at timestamptz not null default now(),
  constraint comments_body_length check (char_length(btrim(body)) between 1 and 1000)
);
create index comments_post_idx on public.comments (post_id, created_at);
create index comments_parent_idx on public.comments (parent_id);
create index comments_author_idx on public.comments (author_id);

create table public.comment_mentions (
  comment_id        uuid not null references public.comments (id) on delete cascade,
  mentioned_user_id uuid not null references public.profiles (id) on delete cascade,
  primary key (comment_id, mentioned_user_id)
);
create index comment_mentions_user_idx on public.comment_mentions (mentioned_user_id);

create table public.notifications (
  id           uuid primary key default gen_random_uuid(),
  recipient_id uuid not null references public.profiles (id) on delete cascade,
  type         public.notification_type not null,
  actor_id     uuid references public.profiles (id) on delete cascade,
  post_id      uuid references public.posts (id) on delete cascade,
  comment_id   uuid references public.comments (id) on delete cascade,
  -- Plana ek: moderasyon bildiriminde yaptırım türü ve admin notu
  -- ({"action": "warn", "note": "...", "target_type": "post"}).
  meta         jsonb not null default '{}'::jsonb,
  read_at      timestamptz,
  created_at   timestamptz not null default now()
);
create index notifications_recipient_idx on public.notifications (recipient_id, created_at desc);
create index notifications_unread_idx on public.notifications (recipient_id) where read_at is null;
create index notifications_actor_idx on public.notifications (actor_id);
create index notifications_post_idx on public.notifications (post_id);
create index notifications_comment_idx on public.notifications (comment_id);

-- =====================================================================
-- Moderasyon ve uygulama
-- =====================================================================

create table public.reports (
  id          uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles (id) on delete cascade,
  target_type public.report_target not null,
  target_id   uuid not null,
  status      public.report_status not null default 'open',
  created_at  timestamptz not null default now(),
  -- Bir kullanıcı aynı hedefi yalnızca bir kez şikayet eder.
  constraint reports_once unique (reporter_id, target_type, target_id)
);
create index reports_open_idx on public.reports (status, created_at);
create index reports_target_idx on public.reports (target_type, target_id);

create table public.moderation_actions (
  id             uuid primary key default gen_random_uuid(),
  admin_id       uuid references public.profiles (id) on delete set null,
  target_user_id uuid references public.profiles (id) on delete cascade,
  report_id      uuid references public.reports (id) on delete set null,
  action         public.moderation_action_type not null,
  note           text,
  created_at     timestamptz not null default now()
);
create index moderation_actions_target_idx on public.moderation_actions (target_user_id, created_at desc);

-- Tek satırlık uygulama ayarı: 'yeni sürüm var' uyarısı için.
create table public.app_config (
  id             smallint primary key default 1,
  latest_version text not null default '1.0.0',
  min_version    text not null default '1.0.0',
  apk_url        text,
  updated_at     timestamptz not null default now(),
  constraint app_config_single_row check (id = 1)
);
insert into public.app_config (id) values (1);
