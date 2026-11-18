-- Datenbank-Setup für "Weihnachtsmenü in der Landwehrstrasse"
-- In einem neuen Supabase-Projekt unter "SQL Editor" einfügen und ausführen.
-- Danach SUPABASE_URL und SUPABASE_KEY in index.html anpassen.

create table teams (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  sort_order int not null default 0
);

create table days (
  id uuid primary key default gen_random_uuid(),
  label text not null,              -- z. B. "Heiligabend"
  event_date date not null,
  subtitle text,
  sort_order int not null default 0
);

create table tasks (
  id uuid primary key default gen_random_uuid(),
  day_id uuid not null references days(id) on delete cascade,
  section text not null,            -- lunch | dinner | main | optional | gaps
  kind text not null default 'dish',-- dish | potluck | gaps
  title text not null,
  is_main boolean not null default false,  -- hervorgehobene Karte
  locked boolean not null default false,   -- fest vergeben, nicht freigebbar
  assigned_team_id uuid references teams(id) on delete set null,
  note text default '',
  sort_order int not null default 0
);

create table shopping_items (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references tasks(id) on delete cascade,
  label text not null,
  quantity text default '',
  done boolean not null default false,
  created_at timestamptz not null default now()
);

-- Zugriff ohne Login (wie bisher: jeder mit dem Link kann mitplanen)
alter table teams enable row level security;
alter table days enable row level security;
alter table tasks enable row level security;
alter table shopping_items enable row level security;

create policy "read teams" on teams for select using (true);
create policy "read days"  on days  for select using (true);
create policy "read tasks" on tasks for select using (true);
create policy "update tasks" on tasks for update using (true) with check (true);
create policy "read items"   on shopping_items for select using (true);
create policy "insert items" on shopping_items for insert with check (true);
create policy "update items" on shopping_items for update using (true) with check (true);
create policy "delete items" on shopping_items for delete using (true);

-- Live-Aktualisierung zwischen allen Geräten
alter publication supabase_realtime add table tasks, shopping_items, days;

-- ---------------------------------------------------------------
-- BEISPIELDATEN – durch das echte Menü ersetzen
-- ---------------------------------------------------------------
-- insert into teams (name, sort_order) values ('Team A', 1), ('Team B', 2);
--
-- insert into days (label, event_date, subtitle, sort_order) values
--   ('Heiligabend', '2026-12-24', 'Brotzeit & kaltes Abendessen', 1),
--   ('1. Weihnachtstag', '2026-12-25', 'Festessen', 2);
--
-- insert into tasks (day_id, section, kind, title, is_main, sort_order)
-- select id, 'main', 'dish', 'Hauptgang', true, 1 from days where label = '1. Weihnachtstag';
-- insert into tasks (day_id, section, kind, title, sort_order)
-- select id, 'gaps', 'gaps', 'Was fehlt noch?', 99 from days where label = '1. Weihnachtstag';
