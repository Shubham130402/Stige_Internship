-- A. Customer Nodes Exploration
select * from data_bank.regions;
select * from data_bank.customer_nodes;

-- 1. How many unique nodes are there on the Data Bank system?
with temp as(select distinct node_id, region_id from data_bank.customer_nodes
order by node_id, region_id)
select count(*) as node_count from temp;

-- 2. What is the number of nodes per region?
select region_id, count(distinct node_id) as total_node
from data_bank.customer_nodes
group by region_id
order by region_id;

-- 3. How many customers are allocated to each region?
select region_id, count(distinct customer_id) as total_cnt
from data_bank.customer_nodes
group by region_id
order by region_id;

-- 4. How many days on average are customers reallocated to a different node?
select substr(end_date,5,6) from data_bank.customer_nodes;
with temp_cte as(
    select customer_id,
    region_id, node_id,
    start_date,
