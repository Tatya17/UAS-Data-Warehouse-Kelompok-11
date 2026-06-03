
-- 1.menghapusyg lama karena ada yang salah struktur kolomnya
DROP MATERIALIZED VIEW IF EXISTS mv_ringkasan_penjualan;

-- 2. Kita bangun ulang Materialized View baru yang DIJAMIN pas dengan tabel faktamu
CREATE MATERIALIZED VIEW mv_ringkasan_penjualan AS
SELECT 
    p.product_category_name,
    COUNT(f.order_id) AS total_transaksi,
    SUM(f.payment_value) AS total_omset, -- Kolom ini sekarang fix masuk!
    AVG(f.review_score) AS rata_rata_rating
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_category_name;

-- 3. Kueri untuk mengecek 10 kategori produk dengan omset tertinggi
SELECT * FROM mv_ringkasan_penjualan 
ORDER BY total_omset DESC 
LIMIT 10;