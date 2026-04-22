CREATE DATABASE zomato_ops;

USE zomato_ops;

CREATE TABLE zomato_delivery (
    delivery_person_id VARCHAR(50),
    delivery_person_age FLOAT,
    delivery_person_ratings FLOAT,
    restaurant_latitude FLOAT,
    restaurant_longitude FLOAT,
    delivery_location_latitude FLOAT,
    delivery_longitude FLOAT,
    order_date DATE,
    order_time TIME,
    order_picked_time TIME,
    weather VARCHAR(50),
    traffic_density VARCHAR(50),
    vehicle_condition INT,
    order_type VARCHAR(50),
    vehicle_type VARCHAR(50),
    multiple_deliveries FLOAT,
    festival VARCHAR(10),
    city VARCHAR(50),
    delivery_time_min INT,
    order_hour FLOAT,
    time_slot VARCHAR(20)
);

select * from zomato_delivery;

# How big is the operation we are analyzing?

SELECT COUNT(*) AS total_orders
FROM zomato_delivery;

## What is the baseline delivery performance?
SELECT 
    ROUND(AVG(delivery_time_min), 2) AS avg_delivery_time
FROM zomato_delivery;

## How often are we missing SLA?
SELECT 
    COUNT(*) AS delayed_orders,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM zomato_delivery),
        2
    ) AS delay_percentage
FROM zomato_delivery
WHERE delivery_time_min > 45;

# How much does traffic slow us down?
SELECT 
    traffic_density,
    ROUND(AVG(delivery_time_min), 2) AS avg_delivery_time
FROM zomato_delivery
GROUP BY traffic_density
ORDER BY avg_delivery_time DESC;


# Are peak hours operationally stressed?
SELECT 
    time_slot,
    ROUND(AVG(delivery_time_min), 2) AS avg_delivery_time
FROM zomato_delivery
GROUP BY time_slot;

# Top 10 cities with worst delivery time
# Where are we consistently slow?
SELECT 
    city,
    ROUND(AVG(delivery_time_min), 2) AS avg_delivery_time
FROM zomato_delivery
GROUP BY city
ORDER BY avg_delivery_time DESC
LIMIT 10;

#Rank cities by delivery time
#How do cities rank relative to each other?
SELECT 
    city,
    ROUND(AVG(delivery_time_min), 2) AS avg_delivery_time,
    RANK() OVER (ORDER BY AVG(delivery_time_min) DESC) AS city_rank
FROM zomato_delivery
GROUP BY city;

##############################################################################
# “Does traffic impact deliveries equally during peak and off-peak hours?”
SELECT
    traffic_density,
    time_slot,
    ROUND(AVG(delivery_time_min), 2) AS avg_delivery_time
FROM zomato_delivery
GROUP BY traffic_density, time_slot
ORDER BY traffic_density, time_slot;

# “Under which conditions does SLA failure risk spike?”
SELECT
    traffic_density,
    weather,
    ROUND(
        SUM(CASE WHEN delivery_time_min > 45 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS delay_percentage
FROM zomato_delivery
GROUP BY traffic_density, weather
ORDER BY delay_percentage DESC;

#“Do experienced delivery partners perform better under stress?”
SELECT
    CASE
        WHEN delivery_person_age < 25 THEN 'Young'
        WHEN delivery_person_age BETWEEN 25 AND 35 THEN 'Mid'
        ELSE 'Senior'
    END AS age_group,
    ROUND(AVG(delivery_time_min), 2) AS avg_delivery_time
FROM zomato_delivery
GROUP BY age_group
ORDER BY avg_delivery_time;


# Which cities are not just slow, but inconsistent?”
SELECT
    city,
    ROUND(AVG(delivery_time_min), 2) AS avg_delivery_time,
    ROUND(STDDEV(delivery_time_min), 2) AS delivery_time_variability
FROM zomato_delivery
GROUP BY city
ORDER BY delivery_time_variability DESC
LIMIT 10;



