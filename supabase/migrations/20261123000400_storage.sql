-- =====================================================================
-- Peerless — 4/6: Dosya depolama (Storage)
--   avatars      <user_id>/avatar.jpg            herkes okur, sahibi yazar (512px)
--   covers       <user_id>/cover.jpg             herkes okur, sahibi yazar
--   post-images  <user_id>/<post_id>/<dosya>     herkes okur, sahibi yazar
-- Görseller yüklemeden önce uygulamada sıkıştırılır.
-- =====================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('avatars',     'avatars',     true, 2097152, array['image/jpeg', 'image/png', 'image/webp']),
  ('covers',      'covers',      true, 5242880, array['image/jpeg', 'image/png', 'image/webp']),
  ('post-images', 'post-images', true, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- Okuma: herkese açık (public bucket). Listeleme/üzerine yazma için de
-- giriş yapmış kullanıcıya select izni gerekir.
create policy "peerless_images_select"
  on storage.objects for select to authenticated
  using (bucket_id in ('avatars', 'covers', 'post-images'));

-- Yazma: yalnızca kendi klasörüne (<user_id>/...).
create policy "peerless_images_insert_own"
  on storage.objects for insert to authenticated
  with check (
    bucket_id in ('avatars', 'covers', 'post-images')
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "peerless_images_update_own"
  on storage.objects for update to authenticated
  using (
    bucket_id in ('avatars', 'covers', 'post-images')
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id in ('avatars', 'covers', 'post-images')
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "peerless_images_delete_own"
  on storage.objects for delete to authenticated
  using (
    bucket_id in ('avatars', 'covers', 'post-images')
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
