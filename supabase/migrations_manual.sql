-- ============================================================================
-- Cambios de esquema para: rol superuser + responsables/estado de tareas
-- Ejecutar en Supabase → SQL Editor. Reemplaza <correo-del-superuser>.
-- ============================================================================

-- 1) Rol de permisos en users ('normal' | 'superuser')
alter table public.users
  add column if not exists role text not null default 'normal';

-- Marca al primer superuser (cámbialo por el correo real):
update public.users
  set role = 'superuser'
  where email = '<correo-del-superuser>';

-- 2) Estado e historial de las tareas
alter table public.tasks
  add column if not exists estado text not null default 'pendiente';  -- 'pendiente' | 'completada'
alter table public.tasks
  add column if not exists completada_en timestamptz null;

-- 3) Responsables de cada tarea (varios usuarios por tarea)
create table if not exists public.task_responsables (
  task_id bigint not null references public.tasks(id) on delete cascade,
  user_id bigint not null references public.users(id) on delete cascade,
  constraint task_responsables_pkey primary key (task_id, user_id)
);

-- Nota sobre RLS:
-- Si tienes RLS activado en estas tablas, asegúrate de tener políticas que
-- permitan a los usuarios autenticados: SELECT en users/tasks/task_responsables,
-- INSERT/UPDATE en tasks y task_responsables (para crear/completar pendientes).
-- La Edge Function `create-user` usa service_role y omite RLS.
