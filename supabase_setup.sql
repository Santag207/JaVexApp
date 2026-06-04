-- ============================================================================
-- XAEApp · Configuración de Supabase
-- Ejecutar en el panel de Supabase (SQL Editor) en este orden.
-- Requiere haber creado antes, manualmente, las cuentas en
-- Authentication > Users (mismo email/password que la tabla `users`,
-- con "Auto Confirm User" activado) y haber DESACTIVADO "Confirm email"
-- en Authentication > Providers > Email.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- FASE A — Vínculo de perfiles con Supabase Auth
-- ----------------------------------------------------------------------------

-- 1) Columna que enlaza el perfil (tabla `users`) con la cuenta de Auth.
alter table public.users
  add column if not exists auth_id uuid unique references auth.users(id);

-- 2) Vincular cada perfil con su cuenta de Auth por email (case-insensitive).
--    Correr DESPUÉS de crear las cuentas en Authentication > Users.
update public.users u
   set auth_id = a.id
  from auth.users a
 where lower(a.email) = lower(u.email)
   and u.auth_id is null;

-- 3) RLS en `users`: cada usuario sólo lee/edita su propia fila.
alter table public.users enable row level security;

drop policy if exists "users self read"   on public.users;
drop policy if exists "users self update" on public.users;

create policy "users self read"
  on public.users for select
  using (auth.uid() = auth_id);

create policy "users self update"
  on public.users for update
  using (auth.uid() = auth_id);

-- NOTA: las tablas `tasks`, `members`, `items`, `registeredItems`,
-- `subsistemas` NO tienen RLS habilitado, por lo que siguen siendo accesibles
-- por la sesión autenticada igual que antes. Si en el futuro se habilita RLS
-- en ellas, añadir políticas de lectura para el rol `authenticated`, p. ej.:
--   alter table public.tasks enable row level security;
--   create policy "tasks read" on public.tasks for select to authenticated using (true);

-- 4) (DIFERIDO, tras validar que todo funciona) eliminar el password en texto
--    plano de la tabla de perfiles — la autenticación ya la maneja Supabase Auth:
-- alter table public.users drop column if exists password;


-- ----------------------------------------------------------------------------
-- FASE B — Formularios de tipo archivo (Sistema de Gestión Documental)
-- ----------------------------------------------------------------------------

-- 5) Bucket de Storage PRIVADO para los archivos de formularios.
insert into storage.buckets (id, name, public)
values ('form-files', 'form-files', false)
on conflict (id) do nothing;

-- 6) Tabla de metadatos de cada archivo subido, referenciado al usuario.
create table if not exists public.form_file_submissions (
  id            bigint generated always as identity primary key,
  user_auth_id  uuid not null default auth.uid() references auth.users(id),
  form_type     text not null,                       -- 'document_management'
  section_key   text not null,                       -- presidencia | lider_proyecto | grupo_proyecto | individual
  file_name     text not null,
  storage_path  text not null,
  uploaded_at   timestamptz not null default now()
);

alter table public.form_file_submissions enable row level security;

drop policy if exists "form files own insert" on public.form_file_submissions;
drop policy if exists "form files own read"   on public.form_file_submissions;

create policy "form files own insert"
  on public.form_file_submissions for insert
  with check (auth.uid() = user_auth_id);

create policy "form files own read"
  on public.form_file_submissions for select
  using (auth.uid() = user_auth_id);

-- 7) Políticas de Storage: cada usuario sólo sube/lee dentro de su carpeta,
--    cuyo nombre es su email. Ruta: {email}/{form_type}/{section_key}/...
drop policy if exists "form-files own insert" on storage.objects;
drop policy if exists "form-files own read"   on storage.objects;

create policy "form-files own insert"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'form-files'
    and (storage.foldername(name))[1] = (auth.jwt() ->> 'email')
  );

create policy "form-files own read"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'form-files'
    and (storage.foldername(name))[1] = (auth.jwt() ->> 'email')
  );

-- ----------------------------------------------------------------------------
-- FASE 2 (futuro, NO crear aún) — formularios de texto:
-- create table public.form_text_submissions (
--   id bigint generated always as identity primary key,
--   user_auth_id uuid not null default auth.uid() references auth.users(id),
--   form_type text not null,
--   answers jsonb not null,
--   submitted_at timestamptz not null default now()
-- );
-- ----------------------------------------------------------------------------
