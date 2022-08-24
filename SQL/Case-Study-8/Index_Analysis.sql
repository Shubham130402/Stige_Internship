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
