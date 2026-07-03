-- ============================================================================
-- Políticas RLS para usuarios autenticados (app interna)
-- Ejecutar en Supabase → SQL Editor.
-- La Edge Function `create-user` usa service_role y omite RLS (no necesita
-- política para insertar en users).
-- ============================================================================

-- USERS: leer todos (integrantes del dashboard + asignar responsables)
alter table public.users enable row level security;
drop policy if exists users_select_auth on public.users;
create policy users_select_auth on public.users
  for select to authenticated using (true);
-- cada quien actualiza su propia fila (editar perfil)
drop policy if exists users_update_self on public.users;
create policy users_update_self on public.users
  for update to authenticated using (auth_id = auth.uid()) with check (auth_id = auth.uid());

-- TASKS: leer / crear / completar / borrar
alter table public.tasks enable row level security;
drop policy if exists tasks_select_auth on public.tasks;
create policy tasks_select_auth on public.tasks
  for select to authenticated using (true);
drop policy if exists tasks_insert_auth on public.tasks;
create policy tasks_insert_auth on public.tasks
  for insert to authenticated with check (true);
drop policy if exists tasks_update_auth on public.tasks;
create policy tasks_update_auth on public.tasks
  for update to authenticated using (true) with check (true);
drop policy if exists tasks_delete_auth on public.tasks;
create policy tasks_delete_auth on public.tasks
  for delete to authenticated using (true);

-- TASK_RESPONSABLES: leer / asignar / quitar
alter table public.task_responsables enable row level security;
drop policy if exists tr_select_auth on public.task_responsables;
create policy tr_select_auth on public.task_responsables
  for select to authenticated using (true);
drop policy if exists tr_insert_auth on public.task_responsables;
create policy tr_insert_auth on public.task_responsables
  for insert to authenticated with check (true);
drop policy if exists tr_delete_auth on public.task_responsables;
create policy tr_delete_auth on public.task_responsables
  for delete to authenticated using (true);

-- SUBSISTEMAS: leer
alter table public.subsistemas enable row level security;
drop policy if exists subsistemas_select_auth on public.subsistemas;
create policy subsistemas_select_auth on public.subsistemas
  for select to authenticated using (true);
