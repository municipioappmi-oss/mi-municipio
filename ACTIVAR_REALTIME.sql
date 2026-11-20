-- MI MUNICIPIO: habilitar sincronización en tiempo real.
-- Script aditivo: no modifica ni elimina registros, tablas, roles ni políticas RLS.
-- Ejecutar una sola vez en el SQL Editor del proyecto Mi Municipio Nuevo.

do $$
declare
  tbl text;
  realtime_tables text[] := array[
    'reports',
    'report_assignments',
    'report_status_history',
    'report_files',
    'announcements',
    'user_notifications',
    'categories',
    'departments',
    'surveys',
    'survey_questions'
  ];
begin
  if not exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    raise exception 'No existe la publicación supabase_realtime en este proyecto.';
  end if;

  foreach tbl in array realtime_tables loop
    if to_regclass(format('public.%I', tbl)) is not null
       and not exists (
         select 1
         from pg_publication_tables
         where pubname = 'supabase_realtime'
           and schemaname = 'public'
           and tablename = tbl
       ) then
      execute format('alter publication supabase_realtime add table public.%I', tbl);
    end if;
  end loop;
end $$;