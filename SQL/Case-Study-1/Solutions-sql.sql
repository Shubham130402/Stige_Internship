-- Case study questions and answers
-- 1. What is the total amount each customer spent at the restaurant?
-- select * from sales;
-- select * from menu;
-- select * from members;
select sales.customer_id, sum(menu.price) as total_spent
from dannys_dinner.sales 
join dannys_dinner.menu 
on 
sales.product_id = menu.product_id
group by customer_id
order by  customer_id;

-- 2. How many days has each customer visited the restaurant?
select sales.customer_id,count(distinct order_date) as days_spent
from dannys_dinner.sales
group by customer_id
order by  customer_id;

-- 3. What was the first item from the menu purchased by each customer?
with temp_cte as(select sales.customer_id, menu.product_name,
row_number() over(partition by sales.customer_id
order by sales.order_date,
sales.product_id) as item_order
 FROM dannys_dinner.sales
    JOIN dannys_dinner.menu
    ON sales.product_id = menu.product_id
)
select * from temp_cte
where item_order=1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select menu.product_id,product_name, count(sales.product_id) as order_count
from dannys_dinner.sales
join dannys_dinner.menu
on sales.product_id = menu.product_id
group by product_name
order by order_count desc
limit 1;

-- 5. Which item was the most popular for each customer?

select * from members;
drop table if exists membership_validation;
create temporary table membership_validation as
select 
sales.customer_id,
sales.order_date,
menu.product_name,
menu.price,
members.join_date,
case when sales.order_date>=members.join_date
then 'X'
else ' '
end as membership
from dannys_dinner.sales
Inner join dannys_dinner.menu
on sales.product_id = menu.product_id
left join dannys_dinner.members
on sales.customer_id  = members.customer_id
where join_date is not null
order by customer_id,
order_date;
select * from membership_validation;
-- 6. Which item was purchased first by the customer after they became a member?
-- Note: In this question, the orders made during the join date are counted within the first order as well
with cte_after_first_mem as(
select customer_id,product_name,
order_date, 
Rank() over(partition by customer_id order by order_Date) as purchase_order
from membership_validation
where membership='X'
)
select * from cte_after_first_mem
where purchase_order=1;

-- 7. Which item was purchased just before the customer became a member?
WITH cte_last_before_mem AS (
  SELECT 
    customer_id,
    product_name,
  	order_date,
    join_date,
    RANK() OVER(
    PARTITION BY customer_id
    ORDER BY order_date DESC) AS purchase_order
  FROM membership_validation
  WHERE membership = ' '
)
select * from cte_last_before_mem
where purchase_order=1;

-- 8. What is the total items and amount spent for each member before they became a member?
with cte_spent_before_mem as(
select customer_id,
    product_name,
    price
  FROM membership_validation
  WHERE membership = ' '
)
select customer_id, sum(price) as total_spent, 
count(*) as total_items
from cte_spent_before_mem
group by customer_id
order by customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select customer_id,
sum(
case when product_name="sushi"
then (price*20)
else (price*10) 
end
) as total_points
from membership_validation
group by customer_id
order by customer_id;


