# Proyek Data Warehouse: Perancangan Gudang Data dan Analisis Multidimensi Performa Bisnis E-Commerce Olist Brazil Menggunakan Star Schema dan Atoti OLAP Cube 

## Deskripsi Proyek

Proyek ini merupakan implementasi arsitektur **Data Warehouse (Star Schema)** menggunakan dataset **Brazilian E-Commerce Public Dataset by Olist**.

Sistem dibangun menggunakan **Supabase (PostgreSQL)** sebagai repositori data terpusat dan **Atoti** sebagai platform analisis multidimensi (OLAP). Proyek ini mensimulasikan proses Data Warehouse mulai dari **Data Staging (ETL)**, **Periodic Loading**, **Database Optimization**, hingga **OLAP Dashboard & Business Intelligence**.

---

## Penyusun

Proyek ini disusun dan dibuat oleh Kelompok 11 sebagai bagian dari tugas mata kuliah Data Warehouse dan beranggotakan:

1. Ruthtatia Grace Astridia (24031554072)	

2. Bilqis Fadiyah Nisrina (24031554216)

3. Frelin Theresia Pania (24031554220)

---

## Dataset

Dataset yang digunakan adalah **Brazilian E-Commerce Public Dataset by Olist**. Dataset ini berisi data transaksi e-commerce di Brasil selama periode tahun 2016–2018 yang mencakup informasi:

* Customer Data (informasi pelanggan)
* Order Data (informasi pesanan)
* Order Items Data (detail produk pada setiap pesanan)
* Product Data (informasi produk)
* Seller Data (informasi penjual)
* Payment Data (informasi pembayaran)
* Review Data (ulasan dan rating pelanggan)
* Geolocation Data (lokasi pelanggan dan penjual)
* Product Category Translation Data (terjemahan kategori produk)

**Dataset Kaggle:**

Link Dataset: [(https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) ](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

---

## Arsitektur Data Warehouse

```text
Raw Dataset
     │
     ▼
Data Staging (ETL)
     │
     ▼
Star Schema
     │
     ▼
Periodic Load
     │
     ▼
Supabase PostgreSQL
     │
 ┌───┼─────────┐
 ▼   ▼         ▼
Partitioning  Indexing  Materialized View
     │
     ▼
Atoti OLAP Cube
     │
     ▼
Dashboard & Business Insight
```

---

# Data Pipeline

## 1. Data Staging (ETL)

Tahap ETL dilakukan menggunakan Python dan Pandas untuk menyiapkan data sebelum dimuat ke dalam Data Warehouse.

### Data Profiling

Pemeriksaan dilakukan terhadap:

* Jumlah baris dan kolom
* Missing value
* Data duplikat
* Tipe data atribut
* Integritas relasi antar tabel

### Hasil Validasi

* Tidak ditemukan duplikasi pada `customer_id`
* Tidak ditemukan duplikasi pada `order_id`
* Tidak ditemukan order tanpa customer
* Relasi antar tabel valid untuk proses integrasi

---

### Data Cleaning

#### Penanganan Missing Value

**Tabel Products**

* Missing value numerik diisi menggunakan median
* `product_category_name` yang kosong diisi dengan `"Unknown Category"`

**Tabel Reviews**

* `review_comment_title` yang kosong diisi dengan `"No Title"`
* `review_comment_message` yang kosong diisi dengan `"No Review"`

#### Transformasi Datetime

Kolom tanggal pada tabel Orders dan Reviews dikonversi ke format datetime untuk mendukung analisis berbasis waktu.

---

### Feature Engineering

Dibuat atribut waktu tambahan:

* `year`
* `month`
* `day`
* `quarter`
* `date`

Atribut ini digunakan untuk mendukung analisis berdasarkan hierarki waktu.

---

### Integrasi Data

Seluruh tabel digabungkan menggunakan proses join untuk membentuk tabel staging terintegrasi.

| Metrik       | Nilai   |
| ------------ | ------- |
| Jumlah Baris | 119.143 |
| Jumlah Kolom | 44      |

---

### Pembentukan Star Schema

#### Fact Table

##### fact_sales

Berisi:

* order_id
* customer_id
* product_id
* seller_id
* payment_value
* review_score
* year
* month
* quarter
* date

#### Dimension Tables

##### dim_customer

* customer_id
* customer_city
* customer_state

##### dim_product

Berisi informasi produk.

##### dim_seller

Berisi informasi penjual.

##### dim_time

* date
* year
* month
* day
* quarter

---

## 2. Simulasi Periodic Load

Untuk mensimulasikan proses periodic loading pada lingkungan Data Warehouse, data transaksi dibagi menjadi beberapa batch berdasarkan periode waktu.

| Batch   | Periode                          | Jumlah Data |
| ------- | -------------------------------- | ----------- |
| Batch 1 | Hingga Tahun 2017                | 49.536      |
| Batch 2 | Januari – April 2018             | 30.234      |
| Batch 3 | Mei 2018 – Akhir Periode Dataset | 27.677      |

Pembagian ini mensimulasikan proses pemuatan data secara berkala yang umum digunakan pada implementasi Data Warehouse.

---

## 3. Database Implementation & Performance Optimization (Supabase)

Setelah proses ETL selesai dilakukan, data hasil staging diekspor ke format CSV dan dimuat ke dalam **Supabase**, yaitu platform cloud database yang menggunakan **PostgreSQL** sebagai database engine.

Supabase berfungsi sebagai repositori utama Data Warehouse yang menyimpan seluruh tabel fakta dan dimensi hasil proses ETL.

### Loading Data ke Supabase

#### Fact Table

* fact_sales

#### Dimension Tables

* dim_customer
* dim_product
* dim_seller
* dim_time

Seluruh tabel diimplementasikan menggunakan struktur Star Schema.

---

### Table Partitioning

Untuk meningkatkan performa query, tabel fakta `fact_sales` dipartisi menggunakan metode **List Partitioning** berdasarkan atribut `year`.

#### fact_sales_2016_2017

Menampung data transaksi tahun:

* 2016
* 2017

#### fact_sales_2018

Menampung data transaksi tahun:

* 2018

Strategi ini memungkinkan PostgreSQL menerapkan **Partition Pruning** sehingga hanya partisi yang relevan yang dipindai ketika query dijalankan.

---

### Materialized View

#### mv_ringkasan_penjualan

View ini menyimpan hasil agregasi:

* COUNT total transaksi
* SUM total pendapatan
* AVG review_score

berdasarkan kategori produk.

Materialized View digunakan untuk mempercepat proses analisis dan visualisasi dashboard.

---

### B-Tree Indexing

#### idx_fact_sales_customer

Dibangun pada kolom:

* customer_id

Tujuan implementasi:

* Mempercepat pencarian data
* Mempercepat proses join
* Mengurangi full table scan
* Meningkatkan performa query

---

### Query Optimization & Benchmarking

Pengujian dilakukan menggunakan:

```sql
EXPLAIN ANALYZE
```

Strategi optimasi yang diuji:

* Table Partitioning
* B-Tree Indexing
* Materialized View

Hasil benchmark menunjukkan waktu eksekusi query rata-rata:

| Kondisi          | Waktu Eksekusi |
| ---------------- | -------------- |
| Setelah Optimasi | 0.05 – 0.06 ms |

---

## 4. Data Presentation & OLAP (Atoti)

Tahap akhir dilakukan menggunakan Atoti untuk membangun lingkungan OLAP dan dashboard analitik.

### Hal-hal yang Dilakukan

* Pembangunan Kubus OLAP
* Pembuatan Custom Measures
* Slice and Dice Analysis
* Drill Down Analysis
* Dashboard Interaktif
* Penyusunan Insight Bisnis

Output tahap ini berupa visualisasi data dan insight yang mendukung pengambilan keputusan bisnis.

---

## Konsep yang Diimplementasikan

* Data Warehouse
* ETL (Extract, Transform, Load)
* Star Schema
* Periodic Load
* Table Partitioning
* Materialized View
* B-Tree Indexing
* Query Optimization
* OLAP Cube
* Business Intelligence Dashboard
