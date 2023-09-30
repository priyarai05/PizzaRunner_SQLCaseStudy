CREATE database pizza_runner;
use pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  



-- EDA & Data Cleaning
select * from customer_orders;
select * from runner_orders;
select * from runners;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;

describe customer_orders;
set sql_safe_updates = 0;

update customer_orders
set exclusions = null
where exclusions = 'null' or exclusions = '';

update customer_orders
set extras = null
where extras = 'null' or extras = '';

-- -----------------------------------------------------------------------------------------------------------------
describe runner_orders;

update runner_orders
set duration = replace(duration, 'minutes','');

update runner_orders
set duration = replace(duration, 'minute','');

update runner_orders
set duration = replace(duration, 'mins','');

update runner_orders
set distance = replace(distance, 'km','');

update runner_orders
set cancellation = null
where cancellation = 'null' or  cancellation = '';

-- update runner_orders
-- set cancellation = 'No'
-- where cancellation is null or cancellation = 'null' or  cancellation = '';

update runner_orders
set duration = trim(duration);

update runner_orders
set cancellation = 'Yes'
where cancellation <> 'No';

select * from runner_orders
where cancellation <> 'No';
  
-- -----------------------------------------------------------------------------------------------------------------
  -- PIZZA METRICS
--  1.How many pizzas were ordered?
select count(*) as total_pizzas_ordered 
from customer_orders;

-- 2. How many unique customer orders were made?
select count(distinct customer_id) as unique_customers 
from customer_orders;

-- 3. How many successful orders were delivered by each runner?
select runner_id, count(order_id) as successful_orders
from runner_orders where cancellation is null group by runner_id;

-- 4. How many of each type of pizza was delivered?
select pn.pizza_name, count(ro.order_id) as no_of_orders 
from runner_orders ro right join customer_orders co on ro.order_id = co.order_id
left join pizza_names pn on pn.pizza_id = co.pizza_id where ro.cancellation is null 
group by pn.pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
select co.customer_id, pn.pizza_name, count(co.pizza_id) as pizza_ordered
from runner_orders ro right join customer_orders co on ro.order_id = co.order_id
left join pizza_names pn on pn.pizza_id = co.pizza_id where ro.cancellation is null
group by 1,2;

-- 6. What was the maximum number of pizzas delivered in a single order?
select max(no_of_pizza) as max_pizza_delivered from (select co.order_id, count(co.pizza_id) as no_of_pizza
from customer_orders co join runner_orders ro on ro.order_id = co.order_id
where cancellation is null
group by order_id) t;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select customer_id,
sum(if(co.exclusions is null and co.extras is null, 1, 0)) as no_changes, 
sum(if(co.exclusions is null and co.extras is null, 0, 1)) as atleast_one_change
from customer_orders co join runner_orders ro on ro.order_id = co.order_id
where cancellation is null
group by customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
select
sum(if(exclusions is not null and extras is not null, 1, 0)) as pizza_delivered
from customer_orders co join runner_orders ro on ro.order_id = co.order_id
where cancellation is null;

-- 9. What was the total volume of pizzas ordered for each hour of the day?

select hour(order_time) as hour_of_day, count(*) as no_of_pizza
from customer_orders
group by 1 order by 1;

-- 10. What was the volume of orders for each day of the week?
  
select dayofweek(order_time) as day_num, dayname(order_time) as day_of_week,
count(*) as no_of_pizza
from customer_orders
group by 1,2 order by 1;
-- -----------------------------------------------------------------------------------------------------------------
-- Runner and Customer Experience
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

select weekofyear(registration_date + interval 1 week) as week_num, count(*) as runners_signed
from runners group by 1;

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

select runner_id, round(avg(time_diff)) as avg_time from (
	select distinct co.order_id, runner_id, 
    timestampdiff(minute, co.order_time, ro.pickup_time) as time_diff
	from customer_orders co inner join runner_orders ro on ro.order_id = co.order_id
	where cancellation is null
)t group by 1;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

select pizza_count, round(avg(time_diff)) as avg_time from (
	select distinct co.order_id, runner_id, 
    timestampdiff(minute, co.order_time, ro.pickup_time) as time_diff,
    count(co.order_id) over(partition by co.order_id) as pizza_count
	from customer_orders co inner join runner_orders ro on ro.order_id = co.order_id
	where cancellation is null
)t group by 1;

-- 4. What was the average distance travelled for each customer?

select customer_id, round(avg(distance),1) as Avg_distance
from customer_orders co inner join runner_orders ro on ro.order_id = co.order_id
where cancellation is null group by 1;
 
-- 5. What was the difference between the longest and shortest delivery times for all orders?

select max(duration) as longest_delivery_time, min(duration) as shortest_delivery_time, 
max(duration)-min(duration) as difference
from runner_orders where cancellation is null;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

with speed as(
select order_id, runner_id, round(distance/(duration/60),2) as speed_kmph
from runner_orders where cancellation is null)
select *, round(avg(speed_kmph) over(partition by runner_id),2) as avg_speed 
from speed;

-- 7. What is the successful delivery percentage for each runner?
  
with percentage_delivery as(
select runner_id,
sum(case when cancellation is null then 1 else 0 end) as successful_delivery,
count(*) as total_orders from runner_orders group by 1)
select runner_id, concat(round(successful_delivery * 100 / total_orders),' %') as success_prcnt
from percentage_delivery;

-- C. Ingredient Optimisation
-- Trasforming Tables to make them virtual tables(creating view)

create view pizza_recipes_new as(
select t.pizza_id, trim(j.toppings) as topping
from pizza_recipes t
join json_table(
  replace(json_array(t.toppings), ',', '","'),
  '$[*]' columns (toppings varchar(50) path '$')
) j);

select * from pizza_recipes_new;
-- ---------------------------------------------------------------------------------------------------------------------
-- Transforming customer order table

create view customer_order_new as(
select t.order_id, t.customer_id, t.pizza_id, trim(j.exclusions) as exclusion, 
trim(k.extras) as extra, t.order_time
from customer_orders t
join json_table(
  replace(json_array(t.exclusions), ',', '","'),
  '$[*]' columns (exclusions varchar(50) path '$')
) j
join json_table(
  replace(json_array(t.extras), ',', '","'),
  '$[*]' columns (extras varchar(50) path '$')
) k);

select * from customer_order_new;
-- What are the standard ingredients for each pizza?

select pr.pizza_id, group_concat(pt.topping_name) as ingredients
from pizza_recipes_new pr join pizza_toppings pt
on pr.topping = pt.topping_id group by 1;

-- What was the most commonly added extra?

select topping_name as most_common_extra from (
select pt.topping_name, count(*) 
from customer_order_new con join pizza_toppings pt
on con.extra = pt.topping_id
where extra is not null group by 1 order by 2 desc limit 1) t;

-- What was the most common exclusion?
select topping_name as most_common_exclusion from pizza_toppings
where topping_id = ( select exclusion from (
select exclusion, count(*) from customer_order_new 
where exclusion is not null group by exclusion order by 2 desc limit 1)t);

-- Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

with exclusion_extras as (
select con.order_id, con.customer_id, con.pizza_id, pn.pizza_name, 
group_concat(distinct pt.topping_name) as exclusions, group_concat(distinct pt2.topping_name) as extras
from customer_order_new con join pizza_names pn
on con.pizza_id=pn.pizza_id left join pizza_toppings pt
on con.exclusion = pt.topping_id left join pizza_toppings pt2 on con.extra = pt2.topping_id 
group by 1,2,3,4)
select order_id, customer_id,
concat(pizza_name, ifnull(concat(' -excludes ',exclusions),""), ifnull(concat(' -extras ',extras),'')) as order_item
from exclusion_extras;

-- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and 
-- add a 2x in front of any relevant ingredients For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
with PZ_Ingredients as(
with pizza_ingredients as (
select pr.pizza_id, group_concat(pt.topping_name) as ingredients
from pizza_recipes_new pr join pizza_toppings pt
on pr.topping = pt.topping_id group by 1)

select co.order_id, co.customer_id, co.pizza_id, pi.ingredients 
from customer_orders co left join pizza_ingredients pi
on co.pizza_id=pi.pizza_id)




-- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

select *,count(toppings) over(partition by toppings) as frequency from (
select order_id, pizza_id, (ingredients_count-ifnull(total_exclusion,0)+ifnull(total_extras,0)) as toppings from (
select c.order_id, duration, c.pizza_id,
length(exclusions) - length(replace(exclusions,',','')) +1 as total_exclusion,
length(extras) - length(replace(extras,',','')) + 1 as total_extras,
ingredients_count
from runner_orders r join customer_orders c on r.order_id = c.order_id
join 
(select pizza_id,count(*) as ingredients_count from pizza_recipes_new group by pizza_id) t on t.pizza_id=c.pizza_id
where cancellation is null) t2) t3
order by frequency desc;

--  D. Pricing and Ratings
-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - 
-- how much money has Pizza Runner made so far if there are no delivery fees?

select sum(costs) as TotalRevenue from(
select c.order_id, c.pizza_id, p.pizza_name,
case
	when pizza_name='Meatlovers' then 12
    else 10
end as costs
from customer_orders c 
join runner_orders r on c.order_id = r.order_id
join  pizza_names p on c.pizza_id = p.pizza_id
where cancellation is null) t;

-- 2. What if there was an additional $1 charge for any pizza extras? - Add cheese is $1 extra

select sum(total_cost) as Total_Revenue from(
select *, ifnull(total_extras,'')+costs as total_cost from(
select c.order_id, c.pizza_id, length(extras) - length(replace(extras,',','')) + 1 as total_extras,
if(pizza_id=1, 12, 10) as costs
from customer_orders c 
join runner_orders r on c.order_id = r.order_id
where cancellation is null) t
)t2;

-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner,
-- how would you design an additional table for this new dataset - 
-- generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

DROP TABLE IF EXISTS runner_ratings;
CREATE TABLE runner_ratings (
  order_id INTEGER,
  ratings INTEGER
);
INSERT INTO runner_ratings(order_id, ratings)
VALUES
  ('1', '3'),
  ('2', '5'),
  ('3', '3'),
  ('4', '2'),
  ('5', '3'),
  ('7', '2'),
  ('8', '4'),
  ('10', '4');
select * from runner_ratings;

-- 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
-- customer_id
-- order_id
-- runner_id
-- rating
-- order_time
-- pickup_time
-- Time between order and pickup
-- Delivery duration
-- Average speed
-- Total number of pizzas

select  distinct r.order_id, c.customer_id, r.runner_id, rr.ratings, c.order_time, r.pickup_time,
timestampdiff(minute, c.order_time, r.pickup_time) as time_btw_ordr_pikup, r.duration,
Round(Avg((distance * 60)/duration),1) as avg_speed, count(pizza_id) as pizza_count
from customer_orders c 
right join runner_orders r on r.order_id = c.order_id 
join runner_ratings rr on r.order_id = rr.order_id
group by 1,2,3,4,5,6,7,8;

-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - 
-- how much money does Pizza Runner have left over after these deliveries?

select sum(total_amount-delivery_fee) as Total_Revenue from (
select r.order_id, distance, round(distance* 0.30) as delivery_fee, sum(costs) as total_amount from(
select c.order_id, c.pizza_id,
case
	when c.pizza_id='1' then 12
    else 10
end as costs
from customer_orders c 
join runner_orders r on c.order_id = r.order_id
where cancellation is null) t join runner_orders r on t.order_id = r.order_id
group by 1,2,3) t2;

-- E. Bonus Questions
-- If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate 
-- what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

  
  
  
  
  
  
  