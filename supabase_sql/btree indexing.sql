-- 1. Pengujian Awal Sebelum Indeks (Membaca Struktur Partisi)
EXPLAIN ANALYZE
SELECT * FROM fact_sales WHERE customer_id = '06b8999e2fba1a1fbc88172c00ba8bc7';

-- 2. Penerapan Indeks B-Tree pada Kolom Pencarian Utama
CREATE INDEX IF NOT EXISTS idx_fact_sales_customer ON fact_sales(customer_id);

-- 3. Pengujian Ulang Setelah Indeks Sukses Tertanam (Hasil Meluncur ke 0.05ms)
EXPLAIN ANALYZE
SELECT * FROM fact_sales WHERE customer_id = '06b8999e2fba1a1fbc88172c00ba8bc7';

-- Kueri Pencarian Opsional Tambahan
SELECT * FROM fact_sales WHERE customer_id = '7c340e69a21d50c7744365c19cfb322a';