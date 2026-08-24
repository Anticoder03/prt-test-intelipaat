WITH restaurant_revenue AS (
    SELECT
        c.city_name,
        r.restaurant_id,
        r.restaurant_name,
        SUM(o.final_order_amount) AS total_revenue
    FROM restaurants r
    JOIN orders o
        ON r.restaurant_id = o.restaurant_id
    JOIN cities c
        ON r.city_id = c.city_id
    GROUP BY
        c.city_name,
        r.restaurant_id,
        r.restaurant_name
),
ranked_restaurants AS (
    SELECT
        city_name,
        restaurant_id,
        restaurant_name,
        total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY city_name
            ORDER BY total_revenue DESC
        ) AS rank_no
    FROM restaurant_revenue
)
SELECT *
FROM ranked_restaurants
WHERE rank_no <= 3
ORDER BY city_name, rank_no;


-- second query
WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(o.final_order_amount) AS total_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_id,
        c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_spending
FROM customer_spending
WHERE total_spending > (
    SELECT AVG(total_spending)
    FROM customer_spending
)
ORDER BY total_spending DESC;


-- third query

DELIMITER $$

CREATE PROCEDURE GetCuisinePerformance(IN p_city_name VARCHAR(100))
BEGIN

    SELECT
        c.city_name,
        r.cuisine,
        SUM(o.final_order_amount) AS total_revenue,
        DENSE_RANK() OVER (
            ORDER BY SUM(o.final_order_amount) DESC
        ) AS cuisine_rank
    FROM cities c
    JOIN restaurants r
        ON c.city_id = r.city_id
    JOIN orders o
        ON r.restaurant_id = o.restaurant_id
    WHERE c.city_name = p_city_name
    GROUP BY
        c.city_name,
        r.cuisine
    ORDER BY cuisine_rank;

END $$

DELIMITER ;

-- for Bengaluru 
CALL GetCuisinePerformance('Bengaluru');

-- for Hyderabad
CALL GetCuisinePerformance('Hyderabad');