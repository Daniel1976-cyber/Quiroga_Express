-- Ejecutar en el SQL Editor de CADA nuevo proyecto Supabase
-- (Dashboard de Supabase -> SQL Editor -> pegar y correr)

create table if not exists productos (
  id bigint generated always as identity primary key,
  nombre text not null,
  categoria text not null,
  subcategoria text default 'General',
  precio numeric not null,          -- precio en USD
  disponible boolean default true,
  img text,
  descripcion text,
  created_at timestamp with time zone default now()
);

-- Solo necesaria si la tienda usa tasa de cambio (STORE_SHOW_EXCHANGE_RATE=true)
create table if not exists exchange_rates (
  rate_date date primary key,
  rate numeric not null
);

-- Categorías: el admin las crea desde el panel ("+ Nueva categoría").
-- STORE_CATEGORIES del .env solo se usa para poblar esta tabla la primera
-- vez que arranca la tienda, si está vacía.
create table if not exists categorias (
  id text primary key,       -- slug generado del nombre, ej: "alimentos"
  nombre text not null
);

-- Bucket de imágenes: créalo desde Dashboard -> Storage -> New bucket
-- usando el mismo nombre que pongas en SUPABASE_BUCKET del .env.local,
-- marcado como "Public bucket".

-- Row Level Security: por simplicidad estas tablas se acceden con la
-- anon key en modo lectura pública. Si quieres bloquear escritura desde
-- el navegador (recomendado), activa RLS y solo permite SELECT al rol anon:

alter table productos enable row level security;
create policy "Lectura pública de productos" on productos
  for select using (true);

alter table exchange_rates enable row level security;
create policy "Lectura pública de tasa" on exchange_rates
  for select using (true);

alter table categorias enable row level security;
create policy "Lectura pública de categorias" on categorias
  for select using (true);

-- Las escrituras (insert/update/delete) del panel admin DEBEN pasar por
-- rutas del backend que usen supabaseService (SUPABASE_SERVICE_ROLE),
-- nunca el cliente `supabase` (anon key). Con RLS activo, un insert/update
-- hecho con la anon key será rechazado por Supabase con un error de
-- política — si ves "Error al guardar" en el panel admin, revisa que la
-- ruta correspondiente en api/index.js use supabaseService y no supabase.
