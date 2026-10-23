-- SQL課題1〜3 提出用
-- 氏名：小野澤眞紀
-- 課題1：
 
-- ========================================
-- SQL課題1
課題1-1: 月別の売上合計を取得する
課題1-2: カテゴリ別の売上ランキングを作成する
課題1-3: 売上トップ10の商品を取得する
課題1-4: 前月比での売上成長率を計算する
-- ========================================


-- 課題1-1：月別の売上合計
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
    SUM(total_amount) AS total_sales
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY sales_month;



-- 課題1-2：カテゴリ別の売上ランキング
SELECT
    p.category,
    SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN products p
    ON od.product_id = p.product_id
GROUP BY p.category
ORDER BY total_quantity DESC;



-- 課題1-3：売上トップ10の商品
SELECT
    p.product_name,
    SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN products p
    ON od.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity DESC
LIMIT 10;



-- 課題1-4：前月比での売上成長率
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        SUM(total_amount) AS total_sales
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    sales_month,
    total_sales,
    LAG(total_sales) OVER (
        ORDER BY sales_month
    ) AS previous_month_sales,
    ROUND(
        (
            total_sales - LAG(total_sales) OVER (
                ORDER BY sales_month
            )
        ) / LAG(total_sales) OVER (
            ORDER BY sales_month
        ) * 100,
        2
    ) AS growth_rate_percent
FROM monthly_sales
ORDER BY sales_month;


-- =========================================
-- SQL課題2
課題2- 1：ロイヤリティ分析（顧客ランク別の行動比較）
課題2-2：商品分析（人気商品とカテゴリの特定）
-- =========================================


-- 課題2-1：会員ランク別の分析
SELECT
    c.membership_rank,
    SUM(o.total_amount) AS total_sales,
    ROUND(AVG(o.total_amount), 2) AS average_order_value,
    ROUND(COUNT(o.order_id) / COUNT(DISTINCT c.customer_id), 2)
        AS average_purchase_count
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.membership_rank
ORDER BY total_sales DESC;



-- 課題2-2：販売数量トップ3の商品
SELECT
    p.product_name,
    SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN products p
    ON od.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity DESC
LIMIT 3;



-- 課題2-2（後半）：カテゴリ別の販売数量
-- 注意：productsテーブルに単価がないため、総売上は算出できない
SELECT
    p.category,
    SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN products p
    ON od.product_id = p.product_id
GROUP BY p.category
ORDER BY total_quantity DESC;



-- =========================================
-- SQL課題3：在庫管理（PostgreSQL）
SQL課題3：在庫管理（PostgreSQL）
課題3-1：在庫数が50未満の商品と倉庫を取得
課題3-2：商品ごとの全倉庫の在庫合計
課題3-3：東京都の倉庫にのみ在庫がある商品
-- =========================================


-- 課題3-1：在庫数が50未満の商品と倉庫を取得
SELECT
    w.warehouse_name,
    p.product_name,
    i.quantity
FROM inventory i
JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id
JOIN products p
    ON i.product_id = p.product_id
WHERE i.quantity < 50
ORDER BY i.quantity ASC;



-- 課題3-2：商品ごとの全倉庫の在庫合計
SELECT
    p.product_name,
    COALESCE(SUM(i.quantity), 0) AS total_stock
FROM products p
LEFT JOIN inventory i
    ON p.product_id = i.product_id
GROUP BY p.product_id, p.product_name
ORDER BY p.product_id;



-- 課題3-3：東京都の倉庫にのみ在庫がある商品
SELECT
    p.product_name
FROM products p
JOIN inventory i
    ON p.product_id = i.product_id
JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id
GROUP BY p.product_id, p.product_name
HAVING
    SUM(CASE WHEN w.location LIKE '東京都%' THEN 1 ELSE 0 END) > 0
    AND
    SUM(CASE WHEN w.location NOT LIKE '東京都%' THEN 1 ELSE 0 END) = 0
ORDER BY p.product_name;
