USE zepto_project;

-- Creating table to store data
DROP TABLE IF EXISTS zepto;
CREATE TABLE zepto (
sku_id INT AUTO_INCREMENT PRIMARY KEY,
category VARCHAR(150),
name VARCHAR(255) NOT NULL,
mrp DECIMAL(10,2),
discountPercent DECIMAL(5,2),
availableQuantity INT,
discountedSellingPrice DECIMAL(10,2),
weightInGms INT,
outOfStock BOOLEAN,
quantity INT
);

-- Wizard import failed, therefore importing the data using local infile
LOAD DATA LOCAL INFILE '/Users/bhavyabansal/Desktop/zepto_v2(in).csv'
INTO TABLE zepto
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(category, name, mrp, discountPercent, availableQuantity, discountedSellingPrice, weightInGms, @outOfStock_var, quantity)
SET outOfStock = IF(UPPER(TRIM(@outOfStock_var)) = 'TRUE', 1, 0);

-- Viewing data
SELECT * FROM zepto LIMIT 100;

-- Data cleaning(NULL value items removal)
SELECT *FROM zepto 
WHERE category is NULL
OR name is NULL
OR mrp is NULL
OR discountPercent is NULL
OR availableQuantity is NULL
OR discountedSellingPrice is NULL
OR weightInGms is NULL
OR outOfStock is NULL
OR quantity is NULL;
-- data is already cleaned

-- viewing the distinct categories
SELECT DISTINCT category FROM zepto ORDER BY category;

-- viewing the products in stock
SELECT outOfStock, COUNT(sku_id) FROM zepto GROUP BY outOfStock;

-- Duplicate product names in the list
SELECT name,COUNT(sku_id) as "Number of SKUs" 
FROM zepto
GROUP BY name
HAVING COUNT(sku_id)>1
ORDER BY COUNT(sku_id) DESC;
-- insight: Items with same name have been counted as a different SKU, maybe due to varying packet design, weight etc.

-- Data cleaning
-- removing products with price=0
SELECT *FROM zepto WHERE 
mrp=0 OR discountedSellingPrice=0;

DELETE FROM zepto WHERE mrp=0;
DELETE FROM zepto WHERE discountedSellingPrice=0;

-- converting the mrp currently in paise to rupees
UPDATE zepto 
SET mrp=mrp/100.0,
discountedSellingPrice=discountedSellingPrice/100.0;

-- INSIGHTS AND QUESTIONS
-- Q1)Find the top 10 best-value products based on the discount percentage.
SELECT DISTINCT name,mrp,discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

-- Q2)What are the Products with High MRP but Out of Stock
SELECT DISTINCT name,mrp
FROM zepto
WHERE outOfStock=1
ORDER BY mrp DESC
LIMIT 20;

-- Q3)Calculate Estimated Revenue for each category
SELECT category,
SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto 
GROUP BY category
ORDER BY total_revenue DESC;

-- Q4) Find all products where MRP is greater than ₹500 and discount is less than 10%.
SELECT DISTINCT name,mrp,discountPercent
FROM zepto
WHERE mrp>500 AND discountPercent<10;

-- Q5) Identify the top 5 categories offering the highest average discount percentage.
SELECT category,
ROUND(AVG(discountPercent),2) AS avg_discount
FROM zepto 
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- Q6) Find the price per gram for products above 100g and sort by best value.
SELECT DISTINCT name,weightInGms,discountedSellingPrice,
ROUND(discountedSellingPrice/weightInGms ,2) as price_per_gm
FROM zepto 
WHERE weightInGms>100
ORDER BY price_per_gm ;

-- Q7) Group the products into categories like Low, Medium, Bulk.
SELECT name,weightInGms,
CASE WHEN weightInGms<1000 THEN 'LOW'
     WHEN weightInGms<5000 THEN 'MEDIUM'
     ELSE 'BULK'
     END AS weight_category
FROM zepto;

-- Q8)What is the Total Inventory Weight Per Category 
SELECT category,
SUM(weightInGms * availableQuantity) as total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight;



 