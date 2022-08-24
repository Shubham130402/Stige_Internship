/* ALTER TABLE fresh_segments.interest_metrics
ADD month_year2 DATE;

UPDATE fresh_segments.interest_metrics
set month_year2 = date_format(str_to_date(_month_year, '%m-%Y'),'%Y-%m-01') ;  */

-- 2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?
/* select month_year2, count(*) from fresh_segments.interest_metrics
group by month_year2 
order by month_year2;  */

-- 3. What do you think we should do with these null values in the fresh_segments.interest_metrics
-- use fresh_segments;
-- alter table fresh_segments_interest_metrics
-- drop column month_year; 
-- select * from fresh_segments.interest_metrics;

/* SELECT 
 (SUM(CASE WHEN _interest_id IS NULL THEN 1 END)*100  /
    COUNT(*)) AS null_pct
FROM fresh_segments.interest_metrics;  */

/* DELETE FROM fresh_segments.interest_metrics
WHERE _interest_id IS NULL;
*/
/* SELECT
 (SUM(CASE WHEN _interest_id IS NULL THEN 1 END)*100  /
    COUNT(*)) AS null_pct
FROM fresh_segments.interest_metrics;
*/


-- 4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?
-- select * from fresh_segments.interest_map;
-- select * from fresh_segments.interest_metrics;
/* with temp_cte as(
select a.*, b.*
from fresh_segments.interest_metrics a
FULL join fresh_segments.interest_map b
on (a._interest_id = b.id));
select count(*) from temp_cte where id is NULL;
*/
-- 5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table
-- select * from fresh_segments.interest_map;
-- select count(*) from fresh_segments.interest_map;
-- select count(*) from fresh_segments.interest_metrics;


-- 6. What sort of table join should we perform for our analysis and why? 
-- Check your logic by checking the rows where interest_id = 21246 in your joined output 
-- and include all columns from fresh_segments.interest_metrics and all columns 
-- from fresh_segments.interest_map except from the id column.

-- select * from fresh_segments.interest_map;
-- select * from fresh_segments.interest_metrics
/*
select a.*, b.* from fresh_segments.interest_metrics  a
inner join fresh_segments.interest_map b
on a._interest_id = b.id 
where a._interest_id = 21246
and a.month_year2 is not null;
*/
-- 7. Are there any records in your joined table where the month_year value is before 
-- the created_at value from the fresh_segments.interest_map table? Do you think 
-- these values are valid and why?

-- select * from fresh_segments.interest_map;
/* select a.*, b.* from fresh_segments.interest_metrics  a
inner join fresh_segments.interest_map b
on a._interest_id = b.id 
where a.month_year2 < b.created_at
and a.month_year2 is not null;
*/
-- Interest Analysis
-- 1. Which interests have been present in all month_year dates in our dataset?
-- select * from fresh_segments.interest_metrics;
 /* with cte as( select _interest_id, count(distinct _month_year) as total_months
  from fresh_segments.interest_metrics
  where month_year2 is not null 
  group by _interest_id )
  select _interest_id, total_months
from cte 
where total_months = 14;
*/

-- 2. Using this same total_months measure - calculate the cumulative percentage of all
-- records starting at 14 months - which total_months value passes the 90% cumulative 
-- percentage value?
/* with cte as( select _interest_id, count(distinct _month_year) as total_months
  from fresh_segments.interest_metrics
  where month_year2 is not null 
  group by _interest_id ),
  cte2 as ( select total_months, count(distinct _interest_id) as total_interests
  from cte
  group by total_months
  order by total_months desc)
select total_months,
total_interests,
sum(total_interests) over( order by total_months desc) / sum(total_interests) over() *100 cum_perc
from Cte2;
*/

-- 3. If we were to remove all interest_id values which are lower than the total_months value
-- we found in the previous question - how many total data points would we be removing?

/* with temp_Cte as(
    select _interest_id, count(distinct _month_year) as total_months
    from fresh_segments.interest_metrics
    where month_year2 is not Null
    group by _interest_id
)
select count(distinct _interest_id) as total_interests
from temp_cte where total_months<14;
*/
-- 4. Does this decision make sense to remove these data points from a business perspective? 
-- Use an example where there are all 14 months present to a removed interest example for your 
-- arguments - think about what it means to have less months present from a segment perspective.

/* with temp_Cte as(
    select _interest_id, count(distinct _month_year) as total_months
    from fresh_segments.interest_metrics
    where month_year2 is not Null
    group by _interest_id
),
temp_cte2 as(
select _interest_id from temp_cte where total_months<6)
delete from fresh_segments.interest_metrics where _interest_id in (select _interest_id from temp_cte2);
*/

-- 5. After removing these interests - how many unique interests are there for each month?
/* select _month_year, count(distinct _interest_id) as interest_id
from fresh_segments.interest_metrics
where _month_year is not null
group by _month_year
 order by _month_year ;
 */
 
 -- Segment Analysis
 -- select * from fresh_segments.interest_metrics;
 with temp_cte as(
 select _interest_id,_month_year, max(composition) as composition 
 from fresh_segments.interest_metrics
 group by _interest_id, _month_year 
 order by composition),
 temp_cte2 as(
 select * from temp_cte order by composition desc limit 10),
 temp_cte3 as (
 select * from temp_cte order by composition limit 10)
 select * from temp_cte2 
 union
  select * from temp_cte3;
  
-- 2. Which 5 interests had the lowest average ranking value?
select _interest_id, avg(ranking) as ranking  
from fresh_segments.interest_metrics
group by _interest_id
order by ranking
limit 5;

select _interest_id, std(percentile_ranking) as std_ranking  
from fresh_segments.interest_metrics
group by _interest_id
order by std_ranking desc
limit 5;

-- 3. Which 5 interests had the largest standard deviation in their percentile_ranking value?
select _interest_id, std(percentile_ranking) as std_ranking from 
fresh_segments.interest_metrics
group by _interest_id
order by std_ranking desc
limit 5;

-- 4. For the 5 interests found in the previous question - what was minimum and maximum 
-- percentile_ranking values for each interest and its corresponding year_month value? 
-- Can you describe what is happening for these 5 interests?
with temp_cte as (
select _interest_id, std(percentile_ranking) as std_ranking from 
fresh_segments.interest_metrics
group by _interest_id
order by std_ranking desc
limit 5) ,

temp_cte2 as (
  select _interest_id, 
  max(percentile_ranking) max_rank,
  min(percentile_ranking) min_rank
  from fresh_segments.interest_metrics
  where _interest_id in (select _interest_id from temp_cte ) 
  group by _interest_id
)
select a._interest_id, a.max_rank,a.min_rank,b.month_year2 as max_month_year,
c.month_year2 as min_month_year
from temp_cte2 a
left join fresh_segments.interest_metrics b
on a._interest_id = b._interest_id and round(a.max_rank,2)= round(b.percentile_ranking,2)
left join fresh_segments.interest_metrics c
on a._interest_id = c._interest_id and round(a.max_rank,2)= round(c.percentile_ranking,2);

-- Index Analysis
-- 1. What is the top 10 interests by the average composition for each month?
with temp_cte as(
  select month_year2,_interest_id,round(composition/index_value,2) as avg_composition
  from fresh_segments.interest_metrics
  where month_year2 is not null
),
temp_cte2 as(
  select month_year2,_interest_id, avg_composition,
  row_number() over(partition by month_year2 order by avg_composition desc) ranking
  from temp_cte
)
select * from temp_cte2 where ranking <=10;

-- 2. For all of these top 10 interests - which interest appears the most often?
with temp_cte as(
  select month_year2,_interest_id,round(composition/index_value,2) as avg_composition
  from fresh_segments.interest_metrics
  where month_year2 is not null
),
temp_cte2 as(
  select month_year2,_interest_id, avg_composition,
  row_number() over(partition by month_year2 order by avg_composition desc) ranking
  from temp_cte
)
select _interest_id, count(*) as total_interest
from temp_cte2 where ranking <=10
group by _interest_id 
order by total_interest desc limit 1;

-- 3.What is the average of the average composition for the top 10 interests for each month?
with temp_cte as(
  select month_year2,_interest_id,round(composition/index_value,2) as avg_composition
  from fresh_segments.interest_metrics
  where month_year2 is not null
),
temp_cte2 as(
  select month_year2,_interest_id, avg_composition,
  row_number() over(partition by month_year2 order by avg_composition desc) ranking
  from temp_cte
)
select month_year2,round(avg(avg_composition),2) as avg_composition
from temp_cte2 where ranking <= 10
group by month_year2;