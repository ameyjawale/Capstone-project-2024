-- for removing duplicate customers
WITH duplicate_customers AS (
    SELECT customer_code
    FROM customers
    GROUP BY customer_code
    HAVING COUNT(*) > 1
)
DELETE FROM customers
WHERE customer_code IN (SELECT customer_code FROM duplicate_customers);

-- removing transactions where sales quantity is less than 0
DELETE FROM transactions WHERE sales_qty < 0;

-- replacing unknown at the place of null in customers table
UPDATE customers SET custmer_name = 'Unknown' WHERE custmer_name IS NULL;
UPDATE customers SET customer_type = 'Unknown' WHERE customer_type IS NULL;

-- correcting date format if wrong
UPDATE date SET date = STR_TO_DATE(date, '%Y-%m-%d') WHERE date IS NOT NULL;

-- convertng USD into INR
UPDATE transactions
SET 
    currency = 'INR',
    sales_amount = sales_amount * 87,
    profit_margin = profit_margin * 87,
    cost_price = cost_price * 87
WHERE currency = 'USD';

-- Deleting rows with null /blank values in transactions table
DELETE FROM transactions
WHERE product_code IS NULL OR product_code = ''
OR customer_code IS NULL OR customer_code = ''
OR market_code IS NULL OR market_code = ''
OR order_date IS NULL
OR sales_qty IS NULL
OR sales_amount IS NULL
OR currency IS NULL OR currency = ''
OR profit_margin_percentage IS NULL
OR profit_margin IS NULL
OR cost_price IS NULL;

-- Deleting rows with null /blank values in products table
DELETE FROM products
WHERE product_code IS NULL OR product_code = ''
OR product_type IS NULL OR product_type = '';

-- Deleting rows with null /blank values in markets table
DELETE FROM markets
WHERE markets_code IS NULL OR markets_code = ''
OR markets_name IS NULL OR markets_name = ''
OR zone IS NULL OR zone = '';

-- Deleting rows with null /blank values in date table
DELETE FROM date
WHERE date IS NULL
OR cy_date IS NULL
OR year IS NULL
OR month_name IS NULL OR month_name = ''
OR date_yy_mmm IS NULL OR date_yy_mmm = '';

-- Deleting rows with null /blank values in customers table
DELETE FROM customers
WHERE customer_code IS NULL OR customer_code = ''
OR custmer_name IS NULL OR custmer_name = ''
OR customer_type IS NULL OR customer_type = '';
   
-- setting sales quantity as integer value
ALTER TABLE transactions 
MODIFY sales_qty INT;

-- making all customer codes in customerrs table unique
ALTER TABLE customers
ADD UNIQUE INDEX unique_customer_code (customer_code);

-- using foreign key to secure transaction tabel
ALTER TABLE transactions
ADD CONSTRAINT fk_customer_code
FOREIGN KEY (customer_code)
REFERENCES customers(customer_code);

-- to make all the product codes unique in products table
ALTER TABLE products
ADD UNIQUE INDEX unique_product_code (product_code);

-- usinf foreign keys to update transactions table
ALTER TABLE transactions
ADD CONSTRAINT fk_market_code
FOREIGN KEY (market_code)
REFERENCES markets(markets_code);


--- Following queries can be used to observe only specific trends from the tables by exporting them theough MySQL
/*
-- joining tables with transactions table
SELECT *
FROM transactions
LEFT JOIN customers ON transactions.customer_code = customers.customer_code

LEFT JOIN products ON transactions.product_code = products.product_code

LEFT JOIN date ON transactions.order_date = date.date

LEFT JOIN markets ON transactions.market_code = markets.markets_code;

-- markets sales and respective profits
SELECT 
    markets_name, 
    SUM(profit_margin) AS total_profit, 
    SUM(sales_qty) AS total_quantity,
    SUM(sales_amount) AS sales
FROM markets, transactions
GROUP BY markets_name
ORDER BY total_profit DESC;

-- products proft and sales quantity along with total sales
SELECT 
	product_code,
    SUM(profit_margin) AS total_profit, 
    SUM(sales_qty) AS total_quantity,
    SUM(sales_amount) AS sales
FROM transactions
GROUP BY product_code
ORDER BY total_profit DESC;

-- monthly sales
SELECT MONTH(order_date) AS month, SUM(sales_amount) AS total_sales
FROM transactions
GROUP BY MONTH(order_date)
ORDER BY month;

-- customer type and sales 
SELECT 
    customers.customer_code,
    customers.customer_type, 
    SUM(transactions.sales_amount) AS total_sales,
    AVG(sales_amount) AS avg_transaction_value
FROM transactions
JOIN customers ON transactions.customer_code = customers.customer_code
GROUP BY customers.customer_code
ORDER BY total_sales DESC;



-- customer type wise grouping and total sales and customer counts
SELECT 
    customers.customer_type, 
    COUNT(transactions.customer_code) AS total_customers, 
    SUM(transactions.sales_amount) AS total_sales
FROM transactions
JOIN customers ON transactions.customer_code = customers.customer_code
GROUP BY customers.customer_type
ORDER BY total_sales DESC;

-- finding customers with repeat purchases
SELECT 
    customer_code, 
    COUNT(customer_code) AS repeat_purchases, 
    SUM(sales_amount) AS total_spent
FROM transactions
GROUP BY customer_code
HAVING COUNT(customer_code) > 1
ORDER BY repeat_purchases DESC;

-- date wise profit and sales
SELECT 
    EXTRACT(YEAR FROM order_date) AS year, 
    EXTRACT(MONTH FROM order_date) AS month, 
    SUM(sales_amount) AS total_sales,
	SUM(profit_margin) AS total_profit
FROM transactions
GROUP BY year, month
ORDER BY year, month;


-- date wiese sales
SELECT 
    order_date, 
    SUM(sales_amount) AS total_sales
FROM transactions
GROUP BY order_date
ORDER BY total_sales DESC; 


-- moving average of sales
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    AVG(SUM(sales_amount)) OVER (ORDER BY MIN(order_date) ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_sales
FROM transactions
GROUP BY month
ORDER BY month;


-- churn
SELECT 
    customer_code, 
    MAX(order_date) AS last_purchase_date
FROM transactions
GROUP BY customer_code 
HAVING MAX(order_date) < CURRENT_DATE - INTERVAL 6 MONTH;


-- marketwise sales
SELECT 
    markets.markets_code, 
    SUM(transactions.sales_amount) AS total
FROM transactions
JOIN markets ON transactions.market_code = markets.markets_code
GROUP BY markets.markets_code
HAVING total < (SELECT AVG(sales_amount) FROM transactions);


-- total sales total quantity sold productwise
SELECT 
    products.product_type, 
    SUM(transactions.sales_amount) AS total_revenue, 
    SUM(transactions.sales_qty) AS total_quantity
FROM transactions
JOIN products ON transactions.product_code = products.product_code
GROUP BY products.product_type
ORDER BY total_revenue DESC;

-- productwise quantiy sold according to dates along with sales amount
SELECT
    p.product_code,
    EXTRACT(YEAR FROM s.order_date) AS year,
    EXTRACT(MONTH FROM s.order_date) AS month,
    SUM(s.sales_qty) AS total_quantity_sold,
    SUM(s.sales_amount) AS total_sales_value
FROM transactions s
JOIN products p ON s.product_code = p.product_code
GROUP BY p.product_code,
		EXTRACT(YEAR FROM s.order_date),
		EXTRACT(MONTH FROM s.order_date)
ORDER BY p.product_code ,year,month;

-- product name order date profit and sales of product
SELECT 
    p.product_type, 
    t.order_date, 
    SUM(t.sales_qty) AS total_quantity_sold, 
    SUM(t.profit_margin) AS total_profit,
    SUM(t.sales_amount) AS total_sales
FROM transactions t
JOIN products p ON t.product_code = p.product_code
GROUP BY p.product_type, t.order_date
ORDER BY t.order_date ASC, p.product_type;

*/
