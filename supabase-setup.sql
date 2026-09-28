-- =========================================================
-- Buku Penjualan — setup database Supabase
-- Jalankan SEKALI di Supabase: SQL Editor → New query → tempel semua → Run
-- =========================================================

create table if not exists public.pesanan (
  id          uuid primary key default gen_random_uuid(),
  tanggal     date not null,
  pembeli     text not null,
  items       jsonb not null default '[]'::jsonb,   -- [{menu, harga, qty}]
  total       integer not null default 0,
  dibuat      timestamptz not null default now(),
  dibuat_oleh uuid default auth.uid()
);
create index if not exists pesanan_tanggal_idx on public.pesanan (tanggal);

create table if not exists public.menu (
  id    uuid primary key default gen_random_uuid(),
  nama  text not null,
  harga integer not null default 0,
  ket   text default '',
  urut  integer not null default 0
);

create table if not exists public.pengaturan (
  id      integer primary key default 1 check (id = 1),
  nama    text default '',
  pemilik text default '',
  alamat  text default ''
);

-- Keamanan: hanya pengguna yang sudah login yang bisa membaca & menulis
alter table public.pesanan    enable row level security;
alter table public.menu       enable row level security;
alter table public.pengaturan enable row level security;

drop policy if exists "login boleh semua" on public.pesanan;
drop policy if exists "login boleh semua" on public.menu;
drop policy if exists "login boleh semua" on public.pengaturan;
create policy "login boleh semua" on public.pesanan    for all to authenticated using (true) with check (true);
create policy "login boleh semua" on public.menu       for all to authenticated using (true) with check (true);
create policy "login boleh semua" on public.pengaturan for all to authenticated using (true) with check (true);

-- Update otomatis antar-HP (realtime)
alter publication supabase_realtime add table public.pesanan, public.menu, public.pengaturan;

-- Data usaha (ubah nanti di tab Menu)
insert into public.pengaturan (id) values (1) on conflict (id) do nothing;

-- Daftar menu awal
insert into public.menu (nama, harga, ket, urut) values
  ('Capcay', 15000, '', 0),
  ('Perkedel Jagung (8 biji)', 15000, '', 1),
  ('Tuna Iris Bakar', 25000, 'Parape / rica / ori', 2),
  ('Tuna Saos', 25000, '4 iris', 3),
  ('Tuna Pallumara', 25000, 'Tuna iris', 4),
  ('Bandeng Pallumara/Bakar', 35000, '', 5),
  ('Nila', 25000, '', 6),
  ('Sunu Goreng Tepung/Bakar', 35000, '', 7),
  ('Layang', 15000, '', 8),
  ('Kembung', 15000, '', 9),
  ('Paket Nasi Ayam', 15000, 'Nasi, ayam, tempe/tahu/perkedel, sayur, sambel', 10),
  ('Paket Nasi Ikan', 15000, 'Nasi, tuna iris, tempe/tahu/perkedel, sayur, sambel', 11),
  ('Paket Makan Ber-2', 25000, 'Ayam/ikan 2 ptg, perkedel/tempe/tahu 4, sayur, sambel', 12),
  ('Paket Makan Ber-4', 45000, 'Ayam/ikan 4 ptg, perkedel/tempe/tahu 8, sayur, sambel', 13),
  ('Ayam Per Ekor (65rb)', 65000, 'Cek: menu tertulis 65/130 k per ekor', 14),
  ('Ayam Per Ekor (130rb)', 130000, 'Cek: menu tertulis 65/130 k per ekor', 15),
  ('Ayam 3 Potong', 25000, '', 16),
  ('Sambel Goreng Ayam', 25000, '', 17),
  ('Ayam Likku', 30000, '', 18),
  ('Ayam Asam Manis', 25000, '', 19),
  ('Ayam Semur', 25000, '', 20),
  ('Ayam Kecap', 25000, '', 21),
  ('Ayam Woku', 25000, '', 22),
  ('Ayam Bakar', 25000, 'Kecap / rica', 23),
  ('Ayam Kari', 25000, '', 24),
  ('Ayam Gulai', 25000, '', 25),
  ('Ayam Palekko', 25000, 'Ori / sedang / pedis', 26),
  ('Ayam Teriyaki', 25000, '', 27),
  ('Jum''at Berkah', 10000, 'Mulai 10rb — ketik harga sebenarnya', 28),
  ('Request Menu', 0, 'Ketik harga sesuai pesanan', 29),
  ('Sayur Santan', 10000, 'Dari catatan buku', 30),
  ('Sayur', 10000, 'Dari catatan buku (kadang 5rb)', 31),
  ('Nasi', 5000, 'Dari catatan buku', 32),
  ('Perkedel', 15000, 'Dari catatan buku', 33),
  ('Bento Kentang + Mabi', 30000, 'Dari catatan buku (?)', 34),
  ('Ikan Goreng / Bale', 35000, 'Dari catatan buku (?)', 35),
  ('Paket Camp', 15000, 'Dari catatan buku (?)', 36),
  ('Kado Mi', 20000, 'Dari catatan buku (?)', 37),
  ('Paket A', 15000, 'Dari catatan buku (?)', 38);

-- (Opsional) Contoh data: halaman buku tanggal 25 Juli 2026, total Rp 270.000.
-- Hapus bagian ini kalau tidak mau dimasukkan.
insert into public.pesanan (tanggal, pembeli, items, total) values
  ('2026-07-25', 'Hj. Farida', '[{"menu": "Ayam Woku", "harga": 25000, "qty": 1}, {"menu": "Sayur Santan", "harga": 10000, "qty": 1}]'::jsonb, 35000),
  ('2026-07-25', '0F10 (?)', '[{"menu": "Sayur", "harga": 10000, "qty": 1}, {"menu": "Ikan Goreng / Bale", "harga": 35000, "qty": 1}, {"menu": "Perkedel", "harga": 15000, "qty": 1}]'::jsonb, 60000),
  ('2026-07-25', '0C7 (?)', '[{"menu": "Bento Kentang + Mabi", "harga": 30000, "qty": 1}, {"menu": "Tuna Saos", "harga": 25000, "qty": 1}, {"menu": "Nasi", "harga": 5000, "qty": 1}]'::jsonb, 60000),
  ('2026-07-25', 'EC7 (?)', '[{"menu": "Tuna Pallumara", "harga": 25000, "qty": 1}, {"menu": "Ayam Palekko", "harga": 25000, "qty": 1}, {"menu": "Sayur", "harga": 5000, "qty": 1}]'::jsonb, 55000),
  ('2026-07-25', 'ED6', '[{"menu": "Sayur", "harga": 10000, "qty": 1}]'::jsonb, 10000),
  ('2026-07-25', 'Bakkes (?)', '[{"menu": "Paket Camp", "harga": 15000, "qty": 1}]'::jsonb, 15000),
  ('2026-07-25', 'BDP C8 (?)', '[{"menu": "Kado Mi", "harga": 20000, "qty": 1}, {"menu": "Paket A", "harga": 15000, "qty": 1}]'::jsonb, 35000);
