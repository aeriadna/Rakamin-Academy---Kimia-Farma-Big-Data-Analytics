CREATE SCHEMA kimiafarma;

CREATE TABLE `rakamin-kf-analytics-479310.kimiafarma.kf_kantor_cabang` ( 
  branch_id INT,
  branch_category STRING,
  branch_name STRING,
  kota STRING,
  provinsi STRING,
  rating FLOAT64,
  PRIMARY KEY (branch_id) NOT ENFORCED
);

CREATE TABLE `rakamin-kf-analytics-479310.kimiafarma.kf_product` ( 
  product_id STRING,
  product_name STRING,
  product_category STRING,
  price INT64,
  PRIMARY KEY (product_id) NOT ENFORCED
);

CREATE TABLE `rakamin-kf-analytics-479310.kimiafarma.kf_final_transaction` (
  transaction_id STRING,
  dates DATE,
  branch_id INT,
  customer_name STRING,
  product_id STRING,
  price INT64,
  discount_percentage FLOAT64,
  rating FLOAT64,
  PRIMARY KEY (transaction_id) NOT ENFORCED,
  FOREIGN KEY (branch_id) REFERENCES`rakamin-kf-analytics-479310.kimiafarma.kf_kantor_cabang`(branch_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION NOT ENFORCED,
  FOREIGN KEY (product_id) REFERENCES `rakamin-kf-analytics-479310.kimiafarma.kf_product`(product_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION NOT ENFORCED
);

CREATE TABLE `rakamin-kf-analytics-479310.kimiafarma.kf_inventory` ( 
  inventory_id STRING,
  branch_id INT,
  product_id STRING,
  product_name STRING,
  opname_stock INT64,
  PRIMARY KEY (inventory_id) NOT ENFORCED,
  FOREIGN KEY (branch_id) REFERENCES `rakamin-kf-analytics-479310.kimiafarma.kf_kantor_cabang`(branch_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION NOT ENFORCED,
  FOREIGN KEY (product_id) REFERENCES `rakamin-kf-analytics-479310.kimiafarma.kf_product`(product_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION NOT ENFORCED
);

CREATE OR REPLACE VIEW `rakamin-kf-analytics-479310`.kimiafarma.kf_tabel_analisa AS
WITH
  base AS (
    SELECT
      ft.transaction_id,
      ft.dates AS tanggal_transaksi,
      kc.branch_id,
      kc.branch_name,
      kc.kota,
      kc.provinsi,
      kc.rating AS rating_cabang,
      ft.customer_name,
      p.product_id,
      p.product_name,
      p.price AS actual_price,
      ft.discount_percentage,
      ft.rating AS rating_transaksi,
      CASE
        WHEN p.price <= 50000 THEN 0.10
        WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15
        WHEN p.price > 100000 AND p.price <= 300000 THEN 0.20
        WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25
        WHEN p.price > 500000 THEN 0.30
      END AS persentase_gross_laba,
      p.price * (1 - ft.discount_percentage) AS nett_sales
    FROM
      `rakamin-kf-analytics-479310`.kimiafarma.kf_final_transaction AS ft
      JOIN
      `rakamin-kf-analytics-479310`.kimiafarma.kf_kantor_cabang AS kc
      ON ft.branch_id = kc.branch_id
      JOIN
      `rakamin-kf-analytics-479310`.kimiafarma.kf_product AS p
      ON ft.product_id = p.product_id
  )
SELECT
  *,
  (nett_sales * persentase_gross_laba) AS nett_profit
FROM
  base;
