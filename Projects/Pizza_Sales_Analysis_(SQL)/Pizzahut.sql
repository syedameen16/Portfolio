create database pizzahut;
use  pizzahut;

create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key (order_id));

create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key (order_details_id));

drop table order_details;

-- 1. Retrieve the total number of orders placed.
select count(order_id) as Total_Orders from orders;

-- 2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_revenue
FROM
    order_details
JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;

    

-- 3. Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- 4. Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS Order_Count
FROM
    pizzas
JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY Order_Count DESC;


-- 5. List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, 
    SUM(order_details.quantity) AS Quantity
FROM
    pizza_types
JOIN 
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN 
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.name
ORDER BY 
    Quantity DESC
LIMIT 5;


-- 6.Join the necessary tables to find the total quantity of each pizza category ordered.

 SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM 
    pizza_types
JOIN 
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN 
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.category
ORDER BY 
    quantity DESC;
    
-- 7.Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour,
    COUNT(order_id) AS order_count
FROM 
    orders
GROUP BY 
    HOUR(order_time)
ORDER BY 
    hour;

-- 8.Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, 
    COUNT(name) AS pizza_count
FROM 
    pizza_types
GROUP BY 
    category;
    
-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(daily_orders.total_quantity), 0) AS avg_pizza_ordered_per_day
FROM (
    SELECT 
        orders.order_date, 
        SUM(order_details.quantity) AS total_quantity
    FROM 
        orders
    JOIN 
        order_details ON orders.order_id = order_details.order_id
    GROUP BY 
        orders.order_date
) AS daily_orders;
    
-- 10.Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM 
    pizza_types
JOIN 
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN 
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.name
ORDER BY 
    revenue DESC limit 3;
    
-- 11. Calculate the percentage contribution of each pizza type to total revenue. 

SELECT 
    pizza_types.category,
ROUND(
        SUM(order_details.quantity * pizzas.price) / 
        (
            SELECT 
                SUM(order_details.quantity * pizzas.price)
            FROM 
                order_details
            JOIN 
                pizzas ON pizzas.pizza_id = order_details.pizza_id
        ) * 100, 2
    ) AS revenue_percentage
FROM 
    pizza_types
JOIN 
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN 
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.category
ORDER BY 
    revenue_percentage DESC;

-- 12. Analyze the cumulative revenue generated over time.
SELECT 
    order_date,
    SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue
FROM (
    SELECT 
        orders.order_date,
        SUM(order_details.quantity * pizzas.price) AS revenue
    FROM 
        order_details
    JOIN 
        pizzas ON order_details.pizza_id = pizzas.pizza_id
    JOIN 
        orders ON orders.order_id = order_details.order_id
    GROUP BY 
        orders.order_date
) AS sales;


-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT 
name, 
    revenue
FROM (
    SELECT 
        pizza_types.category,
        pizza_types.name,
        SUM(order_details.quantity * pizzas.price) AS revenue,
        RANK() OVER (
            PARTITION BY pizza_types.category 
            ORDER BY SUM(order_details.quantity * pizzas.price) DESC
        ) AS rn
    FROM 
        pizza_types
    JOIN 
        pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN 
        order_details ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY 
        pizza_types.category, pizza_types.name
) AS ranked_pizzas
WHERE 
    rn <= 3;