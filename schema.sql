-- Run this whole file once in Supabase: SQL Editor -> New query -> paste -> Run.

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  full_name text not null default '',
  role text not null default 'client' check (role in ('admin','client')),
  phone text, age int, gender text, height_cm numeric, weight_kg numeric, goal text,
  start_date date, end_date date,
  created_at timestamptz not null default now()
);

create table public.training_plans (
  client_id uuid primary key references public.profiles(id) on delete cascade,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create table public.diet_plans (
  client_id uuid primary key references public.profiles(id) on delete cascade,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create table public.workout_logs (
  client_id uuid not null references public.profiles(id) on delete cascade,
  week int not null,
  day_id text not null,
  ex_id text not null,
  set_no int not null,
  weight text,
  reps text,
  updated_at timestamptz not null default now(),
  primary key (client_id, week, day_id, ex_id, set_no)
);

-- Helper: is the signed-in user an admin? (security definer avoids policy recursion)
create or replace function public.is_admin()
returns boolean language sql security definer set search_path = public stable as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'admin');
$$;

alter table public.profiles       enable row level security;
alter table public.training_plans enable row level security;
alter table public.diet_plans     enable row level security;
alter table public.workout_logs   enable row level security;

-- profiles: a client reads only his own row; only admins can change anything.
create policy "profiles read"        on public.profiles for select using (id = auth.uid() or public.is_admin());
create policy "profiles admin write" on public.profiles for all    using (public.is_admin()) with check (public.is_admin());

-- plans: a client reads only his own; only admins write.
create policy "training read"        on public.training_plans for select using (client_id = auth.uid() or public.is_admin());
create policy "training admin write" on public.training_plans for all    using (public.is_admin()) with check (public.is_admin());
create policy "diet read"            on public.diet_plans     for select using (client_id = auth.uid() or public.is_admin());
create policy "diet admin write"     on public.diet_plans     for all    using (public.is_admin()) with check (public.is_admin());

-- weight log: a client reads/writes only his own rows; admins can read and write all.
create policy "logs read"   on public.workout_logs for select using (client_id = auth.uid() or public.is_admin());
create policy "logs insert" on public.workout_logs for insert with check (client_id = auth.uid() or public.is_admin());
create policy "logs update" on public.workout_logs for update using (client_id = auth.uid() or public.is_admin()) with check (client_id = auth.uid() or public.is_admin());
create policy "logs delete" on public.workout_logs for delete using (client_id = auth.uid() or public.is_admin());

-- After you create the first admin user in Authentication -> Users
-- (email: admin@clients.example.com, any strong password, tick "Auto Confirm User"),
-- run this to make it an admin. Change the username/name if you like.
-- insert into public.profiles (id, username, full_name, role)
-- select id, 'admin', 'Captain Karim Taha', 'admin' from auth.users where email = 'admin@clients.example.com';
