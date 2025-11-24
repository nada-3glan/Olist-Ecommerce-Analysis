/* ========================================================================================================================================================================
   =================================================================== Data Cleaning Script - Olist =======================================================================
   ======================================================================================================================================================================= */

-----------------------------------------------------------------------------First Problem----------------------------------------------------------------------------------
-- Step 1: Check which product categories in the 'products' table 
-- do NOT have a matching translation in the 'product_category_name_translation' table.


SELECT DISTINCT p.product_category_name
FROM products p
WHERE p.product_category_name NOT IN (
    SELECT t.product_category_name
    FROM product_category_name_translation t
);



-- Step 2: Count how many products belong to specific categories 
-- that are missing translations (for example: 'pc_gamer' and 'portateis_cozinha_e_preparadores_de_alimentos').


SELECT COUNT(p.product_category_name)
FROM products p
WHERE p.product_category_name = 'pc_gamer' 
	OR p.product_category_name = 'portateis_cozinha_e_preparadores_de_alimentos';


-- Step 3: Insert missing category translations into the 'product_category_name_translation' table 
-- to ensure all product categories have corresponding English translations.

INSERT INTO product_category_name_translation (product_category_name, product_category_name_english)
VALUES 
('pc_gamer', 'PC Gamer'),
('portateis_cozinha_e_preparadores_de_alimentos', 'Kitchen Appliances and Food Processors');



-------------------------------------------------------------------Secnod Problem-------------------------------------------------------------------------------------------

-- Step 1: Identify duplicate review_id values in the order reviews table.
-- The goal is to detect cases where the same review_id appears multiple times.

WITH CTE AS (
    SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY review_id ORDER BY review_id
		) AS rn
    FROM dbo.olist_order_reviews_dataset
)

-- Step 2: Remove 814 duplicate reviews.
-- Keep only the first occurrence of each review_id and delete the rest.
-- This ensures that each review_id is unique before defining it as a Primary Key.

DELETE FROM CTE WHERE rn > 1;

-- Step 3: Add a Primary Key constraint to ensure uniqueness for future loads.

ALTER TABLE dbo.olist_order_reviews_dataset
ADD CONSTRAINT PK_order_reviews PRIMARY KEY (review_id);


