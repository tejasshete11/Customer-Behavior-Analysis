CREATE DATABASE customer_behavior;
USE customer_behavior;

SELECT * FROM customer limit 20;

-- 1. What is the total revenue generated my male vs female customers --
 SELECT gender, SUM(purchase_amount) as revenue
 FROM customer
 GROUP BY gender;
 
 -- 2. which customer used a discount but still spent more than the average purchase amount? --  
 
 select customer_id, purchase_amount
 from customer
 where discount_applied = "Yes" and purchase_amount >= (select AVG(purchase_amount) from customer);
 
 -- 3. which are the top 5 product with the highest average review rating? -- 
 
 select item_purchased, ROUND(AVG(review_rating),2) as "Average Product Rating"
 from customer
 group by item_purchased
 order by avg(review_rating) desc
 limit 5;
 
 -- 4. compare the average purchase amounts between standard and express shipping.
 
 select shipping_type,
 ROUND(AVG(purchase_amount),2) AS 'Avg Purchase Amt'
 from customer
 where shipping_type in ('Standard', 'Express')
 group by shipping_type;
 
 -- 5. Do subscribed customers spend more? Compare average spend and total revenue bet subscribers and non-subscribers.--
 
 select subscription_status,
 COUNT(customer_id) AS total_customers,
 ROUND(AVG(purchase_amount),2) AS 'Avg_spend',
 ROUND(SUM(purchase_amount),2) AS 'total_revenue'
 from customer
 group by subscription_status
 order by total_revenue, Avg_spend desc;
 
 -- 6. which 5 products have higest percentage of purchases with discount applied? -- 
 
 select item_purchased,
 ROUND(100 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) as discount_rate
 from customer
 group by item_purchased
 order by discount_rate desc
 limit 5;
 
 -- 7. segment customer into New, Returning, and loyal based on thier 
 -- total number of previous purchases, and show the count of each segment
 
 with customer_type as(
 select customer_id, previous_purchases,
 CASE
	WHEN previous_purchases = 1 THEN 'New'
    WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
    ELSE 'Loyal'
    END AS customer_segment
from customer
)

select customer_segment, COUNT(*) AS 'Number of Customers'
from customer_type
group by customer_segment;

-- 8. what are top 3 most purchased products within each category-- 

with item_counts as(
select category,
item_purchased,
COUNT(customer_id) as total_orders,
ROW_NUMBER() over (partition by category order by count(customer_id) DESC) AS item_rank
from customer
group by category, item_purchased
)

select item_rank, category, item_purchased, total_orders
from item_counts
where item_rank <= 3;

-- 9. Are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe? -- 

select subscription_status,
count(customer_id) as repeat_buyers
from customer
where previous_purchases > 5
group by subscription_status;

-- 10 what is the revenue contribution of each age group? -- 
select age_group,
SUM(purchase_amount) as total_revenue
from customer
group by age_group
order by total_revenue desc;