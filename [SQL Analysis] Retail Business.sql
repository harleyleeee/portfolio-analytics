SELECT DB_NAME();

SELECT TOP 100 customer_key, gender, name, city
FROM retails.customers
WHERE gender IS NOT NULL
ORDER BY customer_key;

SELECT TOP 200 product_key, product_name, brand, color, subcategory, subcategory_key, category_key, category  
FROM retails.products
WHERE product_name IS NOT NULL 
ORDER BY product_key;


SELECT TOP 100 order_number, line_item, order_date, delivery_date 
FROM retails.sales
ORDER BY order_number; 


SELECT TOP 100 store_key, country, state 
FROM retails.stores
WHERE country IS NOT NULL
ORDER BY store_key; 

-- Q1: How many orders did we sell across the whole chain in 2020? 
SELECT 
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'retails'
  AND TABLE_NAME = 'sales'
  AND COLUMN_NAME = 'order_date';

SELECT COUNT(DISTINCT(order_number)) AS total_orders_2020 
FROM retails.sales AS s 
WHERE s.order_date >= '2020-01-01'
AND s.order_date <= '2021-01-01';

-- Q2:  Can you list out for me all the product categories we're currently selling, along with the number of SKUs in each category. I need it for a product mix overview on the marketing slide. Sort alphabetically.
SELECT 
	p.category, 
	COUNT(*) AS sku_count 
FROM retails.products AS p 
GROUP BY p.category 
ORDER BY p.category; 

-- Q3: I need the top 10 cities with the most customers so the CRM team can pick a location for the appreciation event. Send me: city name, state, country, and the number of customers.
SELECT TOP 10 c.city, c.state, c.country, 
		COUNT(*) AS customer_count
FROM retails.customers as c
GROUP BY c.city, c.state,c.country
ORDER BY customer_count DESC, c.city; 

-- Q4: I need the total revenue for December 2020 across all stores - that's the amount customers actually paid (selling price × quantity), not profit.
SELECT SUM(s.quantity * p.unit_price_usd) AS total_revenue 
	FROM retails.sales AS s
	JOIN retails.products AS p
	ON p.product_key = s.product_key 
	WHERE s.order_date  BETWEEN '2020-12-01' AND '2020-12-31';  


-- Q5: How many stores do we currently have in each country? Give me a simple table: country + number of stores. Sort by store count descending
SELECT st.country, 
	COUNT(DISTINCT(st.store_key)) AS num_store 
FROM retails.stores AS st
GROUP BY st.country
ORDER BY num_store DESC, st.country; 

-- Q6: I need to know the top 5 best-selling products in each category to decide what to order
WITH product_sales AS 
  SELECT
    p.category,
    p.product_name,
    SUM(s.quantity) AS totalquantity_sold 
  FROM retails.sales AS s
  JOIN retails.products AS p
    ON p.product_key = s.product_key
  GROUP BY p.category, p.product_name
),
ranked AS ( 
	SELECT 
	category,
	product_name, 
	totalquantity_sold, 
	ROW_NUMBER() OVER (  
		PARTITION BY category 
		ORDER BY totalquantity_sold DESC, product_name) 
	AS rank_in_category 
	FROM product_sales) 
SELECT category, product_name, totalquantity_sold, rank_in_category
FROM ranked 
WHERE rank_in_category <= 5 
ORDER BY category, rank_in_category; 

-- Q7:  I need to know the average gross margin of each subcategory to evaluate our pricing strategy. Margin % = (selling price − cost) / selling price.
SELECT
  p.subcategory,
  COUNT(*) AS product_count,
  CAST(
    AVG((p.unit_price_usd - p.unit_cost_usd) / NULLIF(p.unit_price_usd, 0)) * 100
    AS DECIMAL(6, 2) -- cái CAST AS DECIMAL này là tối đa 6 chữ số tổng trước và sau dấu phẩy, và chỉ giữ 2 chữ số thập phân, tức sau dấu phẩy 
  ) AS avg_margin_pct
FROM retails.products AS p
GROUP BY p.subcategory
HAVING COUNT(*) >= 10
ORDER BY avg_margin_pct DESC; 

-- Q8: Check delivery SLA. Note: only orders that actually involve a delivery to the customer have a delivery date - in-store purchases don't. For that group of delivered orders, on average how many days from when the customer places the order to when they receive it, broken down by the customer's country? 
WITH delivered AS (
SELECT DISTINCT
    s.order_number,
    s.customer_key,
    s.order_date,
    s.delivery_date
  FROM retails.sales AS s
  WHERE s.delivery_date IS NOT NULL 
)  
 SELECT 
 c.country, 
 COUNT(*) AS delivered_orders, 
 CAST(
 AVG(CAST(DATEDIFF(DAY, d.order_date, d.delivery_date) AS DECIMAL(10, 2)))
 AS DECIMAL(10, 2)
 ) AS avg_delivery_days 
 FROM delivered AS d
 JOIN retails.customers AS c 
 ON c.customer_key = d.customer_key
GROUP BY c.country
ORDER BY avg_delivery_days DESC;

-- Q9: I need to prepare a list of VIP customers by country so the CRM team can run a year-end appreciation campaign. For each country, give me the single customer who spent the most in 2020. 
WITH customer_spend AS (
SELECT c.country, c.customer_key, c.name,
SUM(s.quantity * p.unit_price_usd) AS total_expense
FROM retails.sales AS s  
JOIN retails.products AS p 
ON s.product_key = p.product_key
JOIN retails.customers AS c 
ON s.customer_key = c.customer_key
WHERE s.order_date BETWEEN '2020-01-01' AND '2020-12-31'
GROUP BY c.country, c.customer_key, c.name),  
ranked AS (
SELECT 
	country, 
	name, 
	total_expense, 
	ROW_NUMBER() OVER (
		PARTITION BY country
		ORDER BY total_expense DESC, name)
	AS rn 
	FROM customer_spend)  
	SELECT 
	country,
	name, 
	CAST(total_expense AS DECIMAL (14,2)) AS total_expense 
	FROM ranked 
	WHERE rn = 1
	ORDER BY total_expense DESC; 
	

	WITH customer_spend AS (
    SELECT
        c.country,
        c.customer_key,
        c.name,
        SUM(s.quantity * p.unit_price_usd) AS total_expense
    FROM retails.sales AS s
    JOIN retails.products AS p
        ON s.product_key = p.product_key
    JOIN retails.customers AS c
        ON s.customer_key = c.customer_key
    WHERE s.order_date BETWEEN '2020-01-01' AND '2020-12-31'
    GROUP BY
        c.country,
        c.customer_key,
        c.name
)
SELECT
    co.country,
    ca.name,
    CAST(ca.total_expense AS DECIMAL(14,2)) AS total_expense
FROM (
    SELECT DISTINCT country
    FROM customer_spend -- đoạn này là xử lý theo từng country 
) AS co

CROSS APPLY (
    SELECT TOP (1)
        cs.name,
        cs.total_expense
    FROM customer_spend AS cs
    WHERE cs.country = co.country
    ORDER BY
        cs.total_expense DESC,
        cs.name
) AS ca  
ORDER BY ca.total_expense DESC;

	-- Q10: Merchandising suspects there are products in the catalog that have never sold a single unit - zombie inventory. Can you list out all those SKUs so the clearance team can deal with them.
SELECT 
p.product_key,
p.product_name,
p.brand,
p.category
FROM retails.products AS p 
WHERE NOT EXISTS (  
SELECT * 
FROM retails.sales AS s 
WHERE s.product_key = p.product_key)
ORDER BY p.category, p.product_name; 

-- Q11: monthly revenue + cumulative revenue from the start of the period for the last 24 months 
-- CTE 1: bounds 
WITH bounds AS (
  SELECT DATEFROMPARTS(YEAR(MAX(order_date)), MONTH(MAX(order_date)), 1) AS last_month
  FROM retails.sales
),
monthly AS ( -- CTE 2: monthly) 
  SELECT
    DATEFROMPARTS(YEAR(s.order_date), MONTH(s.order_date), 1) AS month_start,   
    SUM(s.quantity * p.unit_price_usd) AS revenue_usd
  FROM retails.sales AS s
  JOIN retails.products AS p
    ON p.product_key = s.product_key
  CROSS JOIN bounds AS b 
  WHERE s.order_date >= DATEADD(MONTH, -23, b.last_month) 
  GROUP BY DATEFROMPARTS(YEAR(s.order_date), MONTH(s.order_date), 1) 
)
SELECT (
  FORMAT(month_start, 'yyyy-MM') AS year_month, 
  CAST(revenue_usd AS DECIMAL(14, 2)) AS revenue_usd, 
  CAST( 
    SUM(revenue_usd) OVER (ORDER BY month_start ROWS UNBOUNDED PRECEDING) 
    AS DECIMAL(14, 2) 
  ) AS cumulative_revenue_usd  
FROM monthly 
ORDER BY month_start;  

-- Q12 List customers who first bought in year X, what % come back to buy in year X+1, X+2, X+3? Group customers by the year of their first purchase. Export a matrix: first-purchase year × years later (0, 1, 2, 3) × retention %
WITH cohort AS ( 
  SELECT
    s.customer_key,
    YEAR(MIN(s.order_date)) AS cohort_year
  FROM retails.sales AS s
  GROUP BY s.customer_key
),
cohort_size AS ( 
  SELECT cohort_year, COUNT(*) AS cohort_customers
  FROM cohort
  GROUP BY cohort_year
),
activity AS (  
  SELECT DISTINCT  
    c.cohort_year,
    s.customer_key,
    YEAR(s.order_date) - c.cohort_year AS year_offset (change in years) 
  FROM retails.sales AS s
  JOIN cohort AS c
    ON c.customer_key = s.customer_key
)
SELECT
  cs.cohort_year,
  cs.cohort_customers,
  a.year_offset,
  COUNT(DISTINCT a.customer_key) AS active_customers,  
  CAST(100.0 * COUNT(DISTINCT a.customer_key) / cs.cohort_customers AS DECIMAL(5, 2)) AS retention_pct  
FROM activity AS a 
JOIN cohort_size AS cs 
  ON cs.cohort_year = a.cohort_year
WHERE a.year_offset BETWEEN 0 AND 3
GROUP BY cs.cohort_year, cs.cohort_customers, a.year_offset
ORDER BY cs.cohort_year, a.year_offset;


-- Q13: Can you compute the revenue per square meter of each store (YTD 2020) so I can compare how efficiently they use floor space. Then rank them into 4 groups (quartiles) within the same country - which stores are in the top 25%, which are in the bottom 25%. 
WITH total_revenue AS (
SELECT st.store_key,
st.country, st.square_meters, 
	SUM(s.quantity * p.unit_price_usd) AS total_revenue_store 
FROM retails.sales AS s 
JOIN retails.products AS p 
	ON s.product_key = p.product_key 
JOIN retails.stores AS st
    ON st.store_key = s.store_key
WHERE s.order_date BETWEEN '2020-01-01' AND '2020-12-31'
 	AND st.square_meters > 0 
GROUP BY st.store_key, st.country, st.square_meters)
SELECT tr.store_key,
tr.country,
CAST(tr.total_revenue_store/tr.square_meters AS DECIMAL (15,2)) AS ratio_revenue_square, 
NTILE(4) OVER ( 
    PARTITION BY tr.country
    ORDER BY tr.total_revenue_store / tr.square_meters DESC 
  ) AS quartile_in_country
 FROM total_revenue AS tr 
ORDER BY tr.country, quartile_in_country, ratio_revenue_square DESC;

-- Q14:  Can you help me check this suspicion: every time we open another store in a country that already has one, do the existing stores there lose revenue? I suspect cannibalization but I have no data to prove it.
WITH store_pairs AS (  
  SELECT
    incumbent.store_key AS incumbent_store,
    newcomer.store_key AS new_store,
    incumbent.country,
    newcomer.open_date AS new_store_open_date
  FROM retails.stores AS incumbent  
  JOIN retails.stores AS newcomer
    ON newcomer.country = incumbent.country
   AND newcomer.open_date > incumbent.open_date
),
windowed AS ( 
  SELECT
    sp.incumbent_store,
    sp.new_store,
    sp.country,
    sp.new_store_open_date,
    SUM(CASE
      WHEN s.order_date >= DATEADD(MONTH, -6, sp.new_store_open_date)
       AND s.order_date < sp.new_store_open_date
      THEN s.quantity * p.unit_price_usd
    END) AS revenue_before,  
    SUM(CASE
      WHEN s.order_date >= sp.new_store_open_date
       AND s.order_date < DATEADD(MONTH, 6, sp.new_store_open_date)
      THEN s.quantity * p.unit_price_usd
    END) AS revenue_after  
  FROM store_pairs AS sp
  JOIN retails.sales AS s
    ON s.store_key = sp.incumbent_store  
  JOIN retails.products AS p 
    ON p.product_key = s.product_key
  GROUP BY sp.incumbent_store, sp.new_store, sp.country, sp.new_store_open_date
) 
SELECT
  incumbent_store,
  new_store,
  country,
  new_store_open_date,
  CAST(revenue_before AS DECIMAL(14, 2)) AS revenue_before,  
  CAST(ISNULL(revenue_after, 0) AS DECIMAL(14, 2)) AS revenue_after, 
  CAST(100.0 * (ISNULL(revenue_after, 0) - revenue_before) / revenue_before AS DECIMAL(7, 2)) AS change_pct
FROM windowed 
WHERE revenue_before > 0
  AND ISNULL(revenue_after, 0) < revenue_before * 0.85
ORDER BY change_pct, incumbent_store, new_store;


-- Q15: Which pairs of products are frequently bought together in the same order? Get me the top 20 pairs that appear together most often, only considering orders with at least 2 distinct products.

WITH order_products AS (
  SELECT DISTINCT s.order_number, s.product_key
  FROM retails.sales AS s  
),
total_orders AS ( 
  SELECT COUNT(DISTINCT order_number) AS order_count
  FROM retails.sales
),
pairs AS (
  SELECT
    a.product_key AS product_a_key,
    b.product_key AS product_b_key,
    COUNT(*) AS times_together 
  FROM order_products AS a
  JOIN order_products AS b
    ON b.order_number = a.order_number
   AND b.product_key > a.product_key 
  GROUP BY a.product_key, b.product_key   
)
SELECT TOP (20)
  pa.product_name AS product_a,
  pb.product_name AS product_b,
  pr.times_together,
  CAST(100.0 * pr.times_together / t.order_count AS DECIMAL(8, 4)) AS pct_of_orders
FROM pairs AS pr
JOIN retails.products AS pa 
  ON pa.product_key = pr.product_a_key   
JOIN retails.products AS pb
  ON pb.product_key = pr.product_b_key
CROSS JOIN total_orders AS t   
ORDER BY pr.times_together DESC, product_a, product_b;
 


