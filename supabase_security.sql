-- ============================================================
-- KEAMANAN DATABASE — Dashboard Reklamasi Tambang Aceh
-- Jalankan skrip ini di Supabase: menu "SQL Editor" > New query > Run.
--
-- Tujuan:
--   * Siapa pun (anon key di browser) BOLEH MEMBACA data (viewer).
--   * Hanya user yang LOGIN (Supabase Auth) yang BOLEH MENGUBAH data (admin).
--
-- Setelah menjalankan ini, ikuti langkah di SETUP_KEAMANAN.md untuk
-- membuat user admin dan mengaktifkan USE_SUPABASE_AUTH = true di index.html.
-- ============================================================

-- 1) Aktifkan Row Level Security di semua tabel
alter table public.iup           enable row level security;
alter table public.reklamasi_op  enable row level security;
alter table public.reklamasi_eks enable row level security;
alter table public.drive_links   enable row level security;

-- 2) Bersihkan policy lama (aman dijalankan berulang)
drop policy if exists "read_public"  on public.iup;
drop policy if exists "write_admin"  on public.iup;
drop policy if exists "read_public"  on public.reklamasi_op;
drop policy if exists "write_admin"  on public.reklamasi_op;
drop policy if exists "read_public"  on public.reklamasi_eks;
drop policy if exists "write_admin"  on public.reklamasi_eks;
drop policy if exists "read_public"  on public.drive_links;
drop policy if exists "write_admin"  on public.drive_links;

-- 3) BACA (SELECT): boleh untuk publik (anon + authenticated)
create policy "read_public" on public.iup           for select using (true);
create policy "read_public" on public.reklamasi_op  for select using (true);
create policy "read_public" on public.reklamasi_eks for select using (true);
create policy "read_public" on public.drive_links   for select using (true);

-- 4) TULIS (INSERT / UPDATE / DELETE): HANYA user yang login (authenticated)
create policy "write_admin" on public.iup           for all to authenticated using (true) with check (true);
create policy "write_admin" on public.reklamasi_op  for all to authenticated using (true) with check (true);
create policy "write_admin" on public.reklamasi_eks for all to authenticated using (true) with check (true);
create policy "write_admin" on public.drive_links   for all to authenticated using (true) with check (true);

-- ============================================================
-- CATATAN
-- * Setelah skrip ini aktif, percobaan hapus/ubah data lewat Console
--   browser tanpa login admin akan DITOLAK server (bukan hanya
--   tombolnya yang hilang).
-- * Viewer tetap bisa melihat data karena SELECT diizinkan publik.
-- * Jika ingin membatasi tulis hanya ke admin tertentu (bukan semua
--   user authenticated), ganti "to authenticated" dengan pengecekan
--   klaim/role. Untuk kebutuhan saat ini, cukup begini.
-- ============================================================
