CREATE TABLE Dim_Customer (
    customer_SK INT IDENTITY(1,1) PRIMARY KEY,
    customer_id NVARCHAR(50) NOT NULL, -- Business Key
    customer_unique_id NVARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city NVARCHAR(100),
    customer_state NVARCHAR(10),
    
   start_date       DATETIME NOT NULL DEFAULT (Getdate()),   -- SCD
    end_date         DATETIME NULL,                           -- SCD
    is_current       TINYINT NOT NULL DEFAULT (1),            -- SCD

);



CREATE TABLE Dim_Seller (
    seller_SK INT IDENTITY(1,1) PRIMARY KEY,
    seller_id NVARCHAR(50) NOT NULL, -- Business Key
    seller_zip_code_prefix INT,
    seller_city NVARCHAR(100),
    seller_state NVARCHAR(10),
    
    start_date       DATETIME NOT NULL DEFAULT (Getdate()),   -- SCD
    end_date         DATETIME NULL,                           -- SCD
    is_current       TINYINT NOT NULL DEFAULT (1),            -- SCD
);



CREATE TABLE Dim_Product (
    product_SK INT IDENTITY(1,1) PRIMARY KEY,
    product_id NVARCHAR(50) NOT NULL, -- Business Key
    product_category_name NVARCHAR(200),
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT,

    start_date       DATETIME NOT NULL DEFAULT (Getdate()),   -- SCD
    end_date         DATETIME NULL,                           -- SCD
    is_current       TINYINT NOT NULL DEFAULT (1),            -- SCD
);


ALTER TABLE Dim_Review
ALTER COLUMN review_comment_message NVARCHAR(250)

CREATE TABLE Dim_Review (
    review_SK INT IDENTITY(1,1) PRIMARY KEY,
    review_id NVARCHAR(50) NOT NULL, -- Business Key
    review_score TINYINT,
    review_comment_title NVARCHAR(255),
    review_comment_message NVARCHAR(250),
    review_creation_date datetime2(7),
    review_answer_timestamp datetime2(7),

    start_date       DATETIME NOT NULL DEFAULT (Getdate()),   -- SCD
    end_date         DATETIME NULL,                           -- SCD
    is_current       TINYINT NOT NULL DEFAULT (1),            -- SCD
);




CREATE TABLE Fact_Orders (
    order_SK INT IDENTITY(1,1) PRIMARY KEY,
    order_id NVARCHAR(50) NOT NULL, -- Business key (for lookup)

    customer_SK INT,
    seller_SK INT,
    product_SK INT,
    review_SK INT,
    purchase_timestamp_SK INT,
	delivered_carrier_SK INT,
	order_delivered_customer_SK INT,
	order_estimated_delivery_SK INT,
    
    price DECIMAL(18,2),
    freight_value DECIMAL(18,2),
    payment_value DECIMAL(18,2)
);




CREATE TABLE Fact_OrderPayments (
    payment_SK INT IDENTITY(1,1) PRIMARY KEY,
    
    order_id VARCHAR(50) NOT NULL,    -- For order SK lookup
    customer_SK INT,
    date_SK INT,                      -- purchase date mapped to Dim_Date
    
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value DECIMAL(18,2),
    
    start_date DATE NOT NULL,
    end_date DATE NULL,
    is_current BIT NOT NULL
);








