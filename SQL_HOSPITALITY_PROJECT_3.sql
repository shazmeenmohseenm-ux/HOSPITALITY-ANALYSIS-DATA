CREATE DATABASE HOSPITALITY_ANALYTICS;
USE HOSPITALITY_ANALYTICS;
SHOW TABLES;
SELECT COUNT(*) FROM fact_bookings;
select max(revenue_generated),min(revenue_generated) from fact_bookings;
select COUNT(*) AS TOTAL_ROWS FROM fact_bookings;
SELECT COUNT(*) AS NO_OF_ROWS FROM FACT_AGGREGATED_BOOKINGS;
SELECT TABLE_NAME,TABLE_ROWS FROM hospitality_analytics WHERE TABLE_SCHEMA = DATABASE();

SELECT * FROM fact_bookings;
/*Booking by Hotel*/
select property_name, sum(successful_bookings) as Total_booking from dim_hotels join fact_aggregated_bookings 
       on dim_hotels.property_id = fact_aggregated_bookings.property_id group by property_name;

/*Booking by City*/
select City, sum(successful_bookings) as Total_booking from dim_hotels join fact_aggregated_bookings 
on dim_hotels.property_id = fact_aggregated_bookings.property_id group by city;


/*Occupancy %*/
SELECT SUM(successful_bookings) / SUM(capacity) * 100 AS occupancy FROM fact_aggregated_bookings;

/*Week no Booking & Revenue */
select `week no`, count(booking_id)as total_booking, sum(revenue_realized)as total_revenue
 from dim_date join fact_bookings on dim_date.date = fact_bookings.check_in_date group by `week no`;


/*Revenue MoM changes in % */
with y as(with x as(select monthname(check_in_date)as month, sum(revenue_realized)as Total_Revenue from fact_bookings group by monthname(check_in_date))
    select *, lag(Total_Revenue,1,"Not Available") over(order by month) as Prev_Month from x)
select *, ifnull(concat(round(((Total_Revenue-Prev_Month)/prev_month)*100,2),"%"),"Not Available")as MoM_Changes from y;

-- to view hotels by city ---

SELECT 
    category,
    property_id,
    property_name,
    city
FROM dim_hotels
WHERE LOWER(city) = 'hyderabad' 
ORDER BY category, property_name;


---- to view Hotels by catagoery wise  ----

SELECT 
    category,
    COUNT(*) AS total_hotels
FROM dim_hotels
WHERE LOWER(city) = 'delhi'         -- hyderabads,Delhi,Mumbai,Bangalore ---
GROUP BY category
ORDER BY total_hotels DESC;


--- total bookings by  month and year -----

SELECT 
    YEAR(booking_date) AS booking_year,
    MONTHNAME(booking_date) AS booking_month,
    booking_status,
    COUNT(booking_id) AS total_bookings
FROM fact_bookings
WHERE booking_date IS NOT NULL
GROUP BY booking_year, booking_month, booking_status
ORDER BY booking_year, 
         STR_TO_DATE(booking_month, '%M'), 
         booking_status; 
 
 ----- Successful Room Bookings by Hotel, Room Type, and Date -----
 
SELECT 
    h.property_name,
    a.room_category,
    a.check_in_date,
    a.successful_bookings
FROM fact_aggregated_bookings a
JOIN dim_hotels h 
    ON a.property_id = h.property_id
ORDER BY h.property_name, a.check_in_date
LIMIT 100;
 
 --- total revneu of hotel by month 
 
SELECT 
    h.property_name AS hotel_name,
    YEAR(b.check_in_date) AS year,
    MONTHNAME(b.check_in_date) AS month_name,
    SUM(b.revenue_realized) AS total_revenue
FROM fact_bookings b
JOIN dim_hotels h 
    ON b.property_id = h.property_id
GROUP BY 
    h.property_name, 
    YEAR(b.check_in_date), 
    MONTHNAME(b.check_in_date), 
    MONTH(b.check_in_date)
ORDER BY 
    h.property_name, 
    year, 
    MONTH(b.check_in_date);



--- Revenue generated After Cancellations ----

SELECT 
    h.property_name,
    SUM(b.revenue_generated) AS total_revenue_generated
FROM factbooking b
JOIN dimhotels h 
    ON b.property_id = h.property_id
GROUP BY h.property_name
ORDER BY total_revenue_generated DESC;


       ---- Cancellation Percentage by City ---
       
SELECT 
    h.city,
    ROUND(
        (SUM(CASE WHEN b.booking_status = 'Cancelled' THEN 1 ELSE 0 END) 
        / COUNT(*)) * 100, 2
    ) AS cancellation_percentage                                  
FROM factbooking b
JOIN dimhotels h ON b.property_id = h.property_id
GROUP BY h.city
ORDER BY cancellation_percentage DESC;

------- overall cancellation percentage --- 

SELECT 
    ROUND(
        (SUM(CASE WHEN booking_status = 'Cancelled' THEN 1 ELSE 0 END) 
        / COUNT(*)) * 100, 2
    ) AS cancellation_percentage
FROM factbooking;

-- booking status by date --- 

SELECT booking_date, booking_id, booking_status
FROM factbooking
WHERE booking_date IS NOT NULL
LIMIT 100;

-- To know thw specific booking_id 

SELECT 
    booking_id,
    booking_status
FROM factbooking
WHERE booking_id = 'May012216558RT13';


---- Monthly Revenue by Hotel wise 

SELECT 
    h.property_name AS hotel_name,
    YEAR(b.check_in_date) AS year,
    MONTHNAME(b.check_in_date) AS month_name,
    SUM(b.revenue_realized) AS total_revenue
FROM factbooking b
JOIN dimhotels h ON b.property_id = h.property_id
GROUP BY 
    h.property_name, 
    YEAR(b.check_in_date), 
    MONTHNAME(b.check_in_date), 
    MONTH(b.check_in_date)
ORDER BY 
    h.property_name, 
    year, 
    MONTH(b.check_in_date);

