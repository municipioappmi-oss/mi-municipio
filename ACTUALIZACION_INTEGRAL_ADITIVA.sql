-- MI MUNICIPIO | Migración aditiva de integración
-- Destino: weosqhohvstctwdnahac (Mi Municipio Nuevo)
-- No elimina ni reemplaza tablas, columnas, políticas ni registros existentes.
-- Revisar en staging antes de ejecutar en producción.

begin;

alter table public.profiles
  add column if not exists address text,
  add column if not exists avatar_path text;

create table if not exists public.user_notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  body text not null,
  notification_type text not null default 'general',
  related_report_id uuid references public.reports(id) on delete set null,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.user_notifications enable row level security;

drop policy if exists profiles_system_admin_read on public.profiles;
create policy profiles_system_admin_read on public.profiles
  for select to authenticated using (
    exists (select 1 from public.profiles p
      where p.user_id = (select auth.uid()) and p.role = 'system_admin')
  );

drop policy if exists notifications_read_own on public.user_notifications;
create policy notifications_read_own on public.user_notifications
  for select to authenticated using (user_id = (select auth.uid()));

drop policy if exists notifications_update_own on public.user_notifications;
create policy notifications_update_own on public.user_notifications
  for update to authenticated using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

drop policy if exists notifications_insert_admin on public.user_notifications;
create policy notifications_insert_admin on public.user_notifications
  for insert to authenticated with check (public.is_admin());

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('profile-photos', 'profile-photos', false, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;

drop policy if exists profile_photos_read_own on storage.objects;
create policy profile_photos_read_own on storage.objects
  for select to authenticated using (
    bucket_id = 'profile-photos' and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists profile_photos_insert_own on storage.objects;
create policy profile_photos_insert_own on storage.objects
  for insert to authenticated with check (
    bucket_id = 'profile-photos' and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists profile_photos_update_own on storage.objects;
create policy profile_photos_update_own on storage.objects
  for update to authenticated using (
    bucket_id = 'profile-photos' and (storage.foldername(name))[1] = (select auth.uid())::text
  ) with check (
    bucket_id = 'profile-photos' and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists profile_photos_delete_own on storage.objects;
create policy profile_photos_delete_own on storage.objects
  for delete to authenticated using (
    bucket_id = 'profile-photos' and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create index if not exists user_notifications_user_created_idx
  on public.user_notifications (user_id, created_at desc);
create index if not exists user_notifications_unread_idx
  on public.user_notifications (user_id) where read_at is null;

commit;

-- IMPORTANTE: esta migración añade infraestructura para foto de perfil y notificaciones.
-- La separación de alcance territorial del rol delegation_admin requiere validar primero
-- los valores reales de profiles.municipality y las reglas de negocio; no se modifica aquí
-- ninguna función SECURITY DEFINER ni política de reportes existente.