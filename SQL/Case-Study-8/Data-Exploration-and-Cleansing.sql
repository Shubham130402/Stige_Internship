-- Solutions
-- Data Exploration and Cleansing
-- 1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month
ADD month_year2 DATE;

UPDATE fresh_segments.interest_metrics
set month_year2 = date_format(str_to_date(_month_year, '%m-%Y'),'%Y-%m-01') ;

-- 2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?
select month_year2, count(*) from fresh_segments.interest_metrics
group by month_year2
order by month_year2;

-- 3. What do you think we should do with these null values in the fresh_segments.interest_metrics
-- check the null_percentage of null values in interest_id in fresh_segments.interest_metrics table
SELECT
 (SUM(CASE WHEN interest_id IS NULL THEN 1 END)*100  /
    COUNT(*)) AS null_pct
FROM fresh_segments.interest_metrics;

-- DELETE all the null values in table
DELETE FROM fresh_segments.interest_metrics
WHERE interest_id IS NULL;

-- check if all the values of null are deleted or not
SELECT
 (SUM(CASE WHEN interest_id IS NULL THEN 1 END)*100  /
    COUNT(*)) AS null_pct
FROM fresh_segments.interest_metrics;


-- 4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?
with temp_cte as(
select a.*, b.*
from fresh_segments.interest_metrics a
full outer join fresh_segments.interest_map b
on a._interest_id = b.id);

select count(*) from temp_cte where id is NULL;

-- 5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table
select count(*) from fresh_segments.interest_map;

-- 6. What sort of table join should we perform for our analysis and why?
-- Check your logic by checking the rows where interest_id = 21246 in your joined output
-- and include all columns from fresh_segments.interest_metrics and all columns
-- from fresh_segments.interest_map except from the id column.

select a.*, b.* from fresh_segments.interest_metrics a
inner join fresh_segments.interest_map b
on a._interest_id = b.id 
where a._interest_id = 21246
and a.month_year2 is not null;
-- 7. Are there any records in your joined table where the month_year value is before
-- the created_at value from the fresh_segments.interest_map table? Do you think
-- these values are valid and why?

select a.*, b.* from fresh_segments.interest_metrics  a
inner join fresh_segments.interest_map b
on a._interest_id = b.id
where a.month_year2 < b.created_at
and a.month_year2 is not null;
--Yes since we started our date with 01 of every MONTH
