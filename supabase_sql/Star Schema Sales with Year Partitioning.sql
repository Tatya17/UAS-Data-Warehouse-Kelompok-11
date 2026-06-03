-- 1. Buat Tabel Dimensi Pelanggan
CREATE TABLE dim_customer (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

-- 2. Buat Tabel Dimensi Produk
CREATE TABLE dim_product (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100)
);

-- 3. Buat Tabel Dimensi Penjual
CREATE TABLE dim_seller (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

-- 4. Buat Tabel Dimensi Waktu
CREATE TABLE dim_time (
    date DATE PRIMARY KEY,
    year INT,
    month INT,
    day INT,
    quarter INT
);

-- 5. Buat Tabel Fakta Penjualan (Dipartisi Berdasarkan Kolom 'year' untuk OLAP lanjut)
CREATE TABLE fact_sales (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    payment_value NUMERIC,
    review_score NUMERIC,
    year INT,
    month INT,
    quarter INT,
    date DATE
) PARTITION BY LIST (year);

-- 6. Membuat Sub-Tabel Partisi Penampung Data (Wajib karena menggunakan Partition)
CREATE TABLE fact_sales_2016_2017 PARTITION OF fact_sales FOR VALUES IN (2016, 2017);
CREATE TABLE fact_sales_2018 PARTITION OF fact_sales FOR VALUES IN (2018);