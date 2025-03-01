use piazza_sql_project;

-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id)
FROM
    orders;  -- unique orders
SELECT 
    COUNT(order_id)
FROM
    or_detail;  -- total orders

-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(quantity * price), 2)
FROM
    or_detail
        JOIN
    pizzas ON or_detail.pizza_id = pizzas.pizza_id;

-- Identify the highest-priced pizza.

SELECT 
    *
FROM
    pizzas
ORDER BY price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.

SELECT 
    size, SUM(quantity) AS x
FROM
    or_detail
        JOIN
    pizzas ON or_detail.pizza_id = pizzas.pizza_id
GROUP BY size
ORDER BY x DESC;

-- List the top 5 most ordered pizza types along with their quantities

SELECT 
    pizza_type_id, SUM(quantity) AS x
FROM
    or_detail
        JOIN
    pizzas ON or_detail.pizza_id = pizzas.pizza_id
GROUP BY pizza_type_id
ORDER BY x DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    category, SUM(quantity)
FROM
    pizza_types AS A
        JOIN
    (SELECT 
        pizza_type_id, quantity
    FROM
        or_detail
    JOIN pizzas ON or_detail.pizza_id = pizzas.pizza_id) AS B ON A.pizza_type_id = B.pizza_type_id
GROUP BY category;

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(pizza_type_id)
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(A), 2)
FROM
    (SELECT 
        order_date, SUM(quantity) AS A
    FROM
        orders
    JOIN or_detail ON orders.order_id = or_detail.order_id
    GROUP BY order_date) AS B;

-- Determine the top 3 most ordered pizza types based on revenue

SELECT 
    pizza_type_id, SUM(quantity * price) AS A
FROM
    pizzas
        JOIN
    or_detail ON pizzas.pizza_id = or_detail.pizza_id
GROUP BY pizza_type_id
ORDER BY A DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    category, SUM(contribution)
FROM
    pizza_types
        JOIN
    (SELECT 
        pizza_type_id,
            (SUM(quantity * price) * 100) / (SELECT 
                    ROUND(SUM(quantity * price), 2)
                FROM
                    or_detail
                JOIN pizzas ON or_detail.pizza_id = pizzas.pizza_id) AS contribution
    FROM
        pizzas
    JOIN or_detail ON pizzas.pizza_id = or_detail.pizza_id
    GROUP BY pizza_type_id) AS A ON pizza_types.pizza_type_id = A.pizza_type_id
GROUP BY category;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select * from 
(select pizza_type_id,category,revenue,rank() over(partition by category order by revenue desc)  as RN
from (select pizza_types.pizza_type_id,category,revenue from pizza_types join
(select pizza_type_id,sum(quantity*price) as revenue from pizzas
join or_detail
on pizzas.pizza_id=or_detail.pizza_id
group by pizza_type_id) as X
on pizza_types.pizza_type_id=X.pizza_type_id) as B) as C
where RN<=3;

-- Analyze the cumulative revenue generated over time.

select order_date,round(sum(revenue) over(order by order_date),2) as cum_revenue from
(select orders.order_date, sum(or_detail.quantity*pizzas.price) as revenue from or_detail 
join pizzas
on or_detail.pizza_id=pizzas.pizza_id
join orders
on orders.order_id=or_detail.order_id
group by orders.order_date) as X;




