use emart_project;

-- looking at all tables
select * from customers;
select * from sales;
select * from products;

-- checking whether files count is correct or not
select count(*) from customers;
select count(*) from products;
select count(*) from sales;

-- Total customers per country
SELECT 
    country,
    COUNT(*) AS total_customers
FROM customers
GROUP BY country
ORDER BY total_customers DESC;

-- Gender split of customer base
SELECT 
    gender,
    COUNT(*) AS total_customers,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers), 1) AS percentage
FROM customers
GROUP BY gender;

-- Total orders and revenue per year
SELECT 
    s.order_year,
    COUNT(DISTINCT s.order_id) AS total_orders,
    ROUND(SUM(s.quantity * p.unit_price_usd), 0) AS total_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id 
WHERE s.order_year IS NOT NULL                  
GROUP BY s.order_year
ORDER BY s.order_year;

-- Revenue by product category
SELECT 
    p.category,
    ROUND(SUM(s.quantity * p.unit_price_usd), 0) AS total_revenue,
    ROUND(SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)), 0) AS total_profit
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Revenue by country
SELECT 
    c.country,
    COUNT(DISTINCT s.order_id) AS total_orders,
    ROUND(SUM(s.quantity * p.unit_price_usd), 0) AS total_revenue
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN products p ON s.product_id = p.product_id
GROUP BY c.country
ORDER BY total_revenue DESC;

-- Online vs physical store order count
SELECT 
    order_type,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM sales), 1) AS percentage
FROM sales
GROUP BY order_type;

-- Customers who registered but never purchased
SELECT 
    c.country,
    COUNT(*) AS never_purchased
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id 
WHERE s.customer_id IS NULL                        
GROUP BY c.country
ORDER BY never_purchased DESC;

-- Top 10 customers by lifetime value
SELECT 
    c.customer_id,
    c.customer_name,
    c.country,
    COUNT(DISTINCT s.order_id) AS total_orders,
    ROUND(SUM(s.quantity * p.unit_price_usd), 0) AS lifetime_value,
    ROUND(SUM(s.quantity * p.unit_price_usd) /
          COUNT(DISTINCT s.order_id), 0) AS avg_order_value 
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN products p ON s.product_id = p.product_id
GROUP BY c.customer_id, c.customer_name, c.country
ORDER BY lifetime_value DESC
LIMIT 10;

-- Categories with more than 1000 orders (HAVING)
SELECT 
    p.category,
    COUNT(DISTINCT s.order_id) AS total_orders,
    ROUND(SUM(s.quantity * p.unit_price_usd), 0) AS total_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.category
HAVING total_orders > 1000    
ORDER BY total_orders DESC;

-- Dead products — never sold once
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.brand
FROM products p
LEFT JOIN sales s ON p.product_id = s.product_id 
WHERE s.product_id IS NULL;  

-- Month over month revenue change using LAG()
WITH monthly_revenue AS (
    SELECT 
        s.order_year,
        s.order_month,
        MIN(s.order_date) AS month_start,
        ROUND(SUM(s.quantity * p.unit_price_usd), 0) AS revenue
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    WHERE s.order_year IS NOT NULL
    GROUP BY s.order_year, s.order_month
)
SELECT 
    order_year,
    order_month,
    revenue,
    LAG(revenue) OVER (ORDER BY month_start) AS prev_month_revenue,
    revenue - LAG(revenue) OVER (ORDER BY month_start) AS changes
FROM monthly_revenue
ORDER BY month_start;

-- Rank categories by revenue within each year using RANK() + PARTITION BY
WITH category_year AS (
    -- Step 1: revenue per category per year
    SELECT 
        s.order_year,
        p.category,
        ROUND(SUM(s.quantity * p.unit_price_usd), 0) AS revenue
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    WHERE s.order_year IS NOT NULL
    GROUP BY s.order_year, p.category
)
-- Step 2: rank categories within each year
SELECT 
    order_year,
    category,
    revenue,
    RANK() OVER (PARTITION BY order_year ORDER BY revenue DESC) AS rank_in_year
FROM category_year
ORDER BY order_year, rank_in_year;

-- Repeat vs new buyer revenue split using CTE + CASE WHEN
WITH buyer_classification AS (
    -- Step 1: classify each customer as repeat or new
    SELECT 
        customer_id,
        CASE 
            WHEN COUNT(DISTINCT order_id) > 1 THEN 'Repeat Buyer'
            ELSE 'New Buyer'
        END AS buyer_type
    FROM sales
    GROUP BY customer_id
)
-- Step 2: calculate revenue per buyer type
SELECT 
    b.buyer_type,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    COUNT(DISTINCT s.order_id) AS total_orders,
    ROUND(SUM(s.quantity * p.unit_price_usd), 0) AS total_revenue,
    ROUND(SUM(s.quantity * p.unit_price_usd) * 100.0 /
          SUM(SUM(s.quantity * p.unit_price_usd)) OVER(), 1) AS revenue_pct
FROM sales s
JOIN products p ON s.product_id = p.product_id
JOIN buyer_classification b ON s.customer_id = b.customer_id
GROUP BY b.buyer_type;