-- BEAUTYSLOT — setup piano FREE
-- Eseguire una sola volta nel SQL Editor Supabase.

create table if not exists public.beautyslot_professionisti (
  user_id uuid primary key references auth.users(id) on delete cascade,
  piano text not null default 'free',
  nome_attivita text not null,
  descrizione text,
  email text,
  telefono text,
  instagram text,
  tiktok text,
  facebook text,
  indirizzo text not null,
  cap text,
  comune text not null,
  provincia text,
  paese text not null default 'Italia',
  latitude double precision,
  longitude double precision,
  pubblico text not null default 'unisex'
    check (pubblico in ('donna','uomo','unisex')),
  categorie text[] not null default '{}',
  specializzazioni text[] not null default '{}',
  servizi jsonb not null default '[]'::jsonb,
  orari jsonb not null default '{}'::jsonb,
  logo_url text,
  gallery_urls text[] not null default '{}',
  calendario_attivo boolean not null default false,
  pubblicato boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.beautyslot_professionisti enable row level security;

drop policy if exists beautyslot_prof_select on public.beautyslot_professionisti;
create policy beautyslot_prof_select
on public.beautyslot_professionisti
for select
to anon, authenticated
using (pubblicato = true or auth.uid() = user_id);

drop policy if exists beautyslot_prof_insert on public.beautyslot_professionisti;
create policy beautyslot_prof_insert
on public.beautyslot_professionisti
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists beautyslot_prof_update on public.beautyslot_professionisti;
create policy beautyslot_prof_update
on public.beautyslot_professionisti
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

insert into storage.buckets (id, name, public)
values ('beautyslot-professionisti', 'beautyslot-professionisti', true)
on conflict (id) do update set public = true;

drop policy if exists beautyslot_media_insert on storage.objects;
create policy beautyslot_media_insert
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'beautyslot-professionisti'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists beautyslot_media_update on storage.objects;
create policy beautyslot_media_update
on storage.objects
for update
to authenticated
using (
  bucket_id = 'beautyslot-professionisti'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'beautyslot-professionisti'
  and (storage.foldername(name))[1] = auth.uid()::text
);


alter table public.beautyslot_professionisti add column if not exists tiktok text;
