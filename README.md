# Olist E-Commerce Data Warehouse & Power BI Analytics

![Status](https://img.shields.io/badge/Status-Completed-brightgreen)
![SQL Server](https://img.shields.io/badge/Database-SQL%20Server-blue)
![SSIS](https://img.shields.io/badge/ETL-SSIS-orange)
![Power BI](https://img.shields.io/badge/Visualization-Power%20BI-yellow)
![Model](https://img.shields.io/badge/Model-Galaxy%20Schema-purple)
![Language](https://img.shields.io/badge/Language-SQL-lightgrey)

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Source Dataset: Olist E-Commerce](#source-dataset-olist-e-commerce)
3. [SQL Data Cleaning and Preparation](#sql-data-cleaning-and-preparation)

   * [3.1 Missing Product Category Translations](#31-missing-product-category-translations)
   * [3.2 Duplicate Review IDs](#32-duplicate-review-ids)
4. [Data Warehouse Modeling](#data-warehouse-modeling)

   * [4.1 Galaxy Schema Design](#41-galaxy-schema-design)
   * [4.2 Fact Tables](#42-fact-tables)
   * [4.3 Dimension Tables](#43-dimension-tables)
5. [SSIS ETL Process and Data Quality Handling](#ssis-etl-process-and-data-quality-handling)

   * [5.1 Issue: Orders Without Order-Items](#51-issue-orders-without-order-items)
   * [5.2 Solution: Assigning Unknown Dimension Members](#52-solution-assigning-unknown-dimension-members)
6. [Power BI Modeling and Analytics](#power-bi-modeling-and-analytics)

   * [6.1 Measures and KPIs](#61-measures-and-kpis)
   * [6.2 Dashboard Overview](#62-dashboard-overview)
7. [Screenshots](#screenshots)
8. [Technologies Used](#technologies-used)
9. [Project Structure](#project-structure)
10. [How to Run the Project](#how-to-run-the-project)

---

## 1. Project Overview

This project implements a full Business Intelligence lifecycle using the Olist e-commerce dataset. It includes SQL data cleaning, dimensional warehouse modeling, SSIS ETL packages, and Power BI analytical dashboards.
The goal is to build a complete, reliable analytical environment reflecting customer behavior, delivery performance, product trends, seller activity, and review sentiment.

---

## 2. Source Dataset: Olist E-Commerce

The Olist dataset originates from a major Brazilian e-commerce marketplace aggregator and includes multi-table information describing the entire order lifecycle.

### Key Tables:

* **orders** – Order-level metadata
* **order_items** – Item-level line details
* **products** – Product catalog
* **sellers** – Seller information
* **order_payments** – Payment transactions
* **order_reviews** – Customer review data

These tables together support end-to-end business process analysis.

---

## 3. SQL Data Cleaning and Preparation

### 3.1 Missing Product Category Translations

Some Portuguese product categories did not exist in the translation table.
A SQL audit identified missing values and added English equivalents to ensure consistency.

**Identify missing translations**

```sql
SELECT DISTINCT p.product_category_name
FROM products p
WHERE p.product_category_name NOT IN (
    SELECT t.product_category_name
    FROM product_category_name_translation t
);
```

**Insert missing translations**

```sql
INSERT INTO product_category_name_translation (product_category_name, product_category_name_english)
VALUES 
('pc_gamer', 'PC Gamer'),
('portateis_cozinha_e_preparadores_de_alimentos', 'Kitchen Appliances and Food Processors');
```

---

### 3.2 Duplicate Review IDs

The reviews table contained 814 duplicate `review_id`s.

**Detect duplicates**

```sql
WITH CTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY review_id ORDER BY review_id
        ) AS rn
    FROM dbo.olist_order_reviews_dataset
)
```

**Delete duplicates**

```sql
DELETE FROM CTE WHERE rn > 1;
```

**Add primary key**

```sql
ALTER TABLE dbo.olist_order_reviews_dataset
ADD CONSTRAINT PK_order_reviews PRIMARY KEY (review_id);
```

---

## 4. Data Warehouse Modeling

### 4.1 Galaxy Schema Design

The warehouse uses a **Galaxy (Fact Constellation) Schema** supporting multiple business processes.
Shared conformed dimensions link two main fact tables.

### 4.2 Fact Tables

* **Fact_Order_Items**
  Contains line-level transaction details: product, seller, pricing, freight, timestamps, status, and reviews.

* **Fact_OrderPayments**
  Contains payment transaction data: payment type, installments, and value.

  

### 4.3 Dimension Tables

* Dim_Customer
* Dim_Product
* Dim_Seller
* Dim_Review
* Dim_Date

All dimensions use surrogate keys and support SCD Type 1.

<img width="1148" height="800" alt="DWH Architecture" src="https://github.com/user-attachments/assets/a02a988c-bfbe-4157-ba69-cd1fcde2c454" />

---

## 5. SSIS ETL Process and Data Quality Handling

### 5.1 Issue: Orders Without Order-Items

Some orders existed in the Olist database but had **no corresponding order-items**.
These orders lacked product, seller, and review references—causing lookup failures during SSIS ETL and breaking foreign key constraints.

### 5.2 Solution: Assigning Unknown Dimension Members

To handle this, each dimension includes an **Unknown** record with surrogate key **-1**.
SSIS Lookup components redirect missing matches to the Unknown record.

Advantages:

* Ensures referential integrity
* Allows all fact rows to load
* Makes missing data explicit and traceable

#### Customer_Dim:
<img width="1920" height="1080" alt="Customer_Dim" src="https://github.com/user-attachments/assets/d9261252-ed34-4344-8b0f-789df2755de2" />

#### Product_Dim:
<img width="1920" height="1080" alt="Product_Dim" src="https://github.com/user-attachments/assets/3929e78c-a835-44a0-9562-af97486eafc0" />


#### Seller_Dim:
<img width="1920" height="1080" alt="Seller_Dim" src="https://github.com/user-attachments/assets/475766c9-80df-4a97-88d3-2a118a2b7a65" />


#### Review_Dim:
<img width="1920" height="1080" alt="Review_Dim" src="https://github.com/user-attachments/assets/f204b118-6104-4076-aa12-1cdafa8241ba" />


#### OrderItems_Fact:
<img width="1920" height="1080" alt="Order_items_fact" src="https://github.com/user-attachments/assets/ccccd042-4a74-47cc-a2d8-12158f1e83c2" />


#### OrderPayment_Fact
<img width="1920" height="1080" alt="OrderPayment_Fact" src="https://github.com/user-attachments/assets/64a570aa-2054-437d-8b9e-79725d289f19" />

---

## 6. Power BI Modeling and Analytics

### 6.1 Measures and KPIs

DAX measures developed include:

* Average Delivery Time
* On-Time Delivery Rate
* Delivery Status Breakdown
* Total Revenue (price + freight)
* Order Volume by Delivery Duration
* Percentage of Late Deliveries with Negative Reviews
* Percentage of On-Time Deliveries with Negative Reviews

### 6.2 Dashboard Overview

A multi-page Power BI dashboard visualizes key findings on delivery performance, product trends, seller behavior, review patterns, and revenue insights.

---

## 7. Screenshots

Add your images here:

* Data Warehouse ERD
* Dimension Load Packages
* Fact Load Packages
* SSIS Control Flow
* Power BI Dashboard

---

## 8. Technologies Used

* SQL Server
* SSIS (SQL Server Integration Services)
* Power BI
* DAX
* Dimensional Modeling (Galaxy Schema)
* Git / GitHub

---

## 9. Project Structure

```
├── SQL/
│   ├── cleaning_scripts.sql
│   ├── translation_updates.sql
│   └── constraints_and_keys.sql
├── SSIS/
│   ├── Packages/
│   ├── Dimensions/
│   └── Facts/
├── PowerBI/
│   ├── Dashboard.pbix
│   └── DAX_Measures.txt
└── README.md
```

---

## 10. How to Run the Project

### 1. Set up the database:

* Import Olist raw data into SQL Server
* Run the SQL cleaning scripts
* Build DW schema (dimensions + facts)

### 2. Run the SSIS ETL:

* Load dimension tables first
* Load fact tables next
* Confirm no lookup failures (Unknown = -1)

### 3. Open the Power BI report:

* Connect to SQL Server DW
* Refresh all tables
* Review dashboards and KPIs

---

If you want, I can **add badges for languages, tools, license, or contributors**, or help you **upload this to GitHub** with proper formatting.
