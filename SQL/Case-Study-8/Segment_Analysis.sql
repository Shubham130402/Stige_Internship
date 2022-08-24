-- Segment analysis
-- 1. Using our filtered dataset by removing the interests with less than 6
-- months worth of data, which are the top 10 and bottom 10 interests which
-- have the largest composition values in any month_year? Only use the maximum
-- composition value for each interest but you must keep the corresponding month_year
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

  --2.Which 5 interests had the lowest average ranking value?
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
select * from temp_cte2;
select a._interest_id, a.max_rank,a.min_rank,b.month_year2 as max_month_year,
c.month_year2 as min_month_year
from temp_cte2 a
left join fresh_segments.interest_metrics b
on a._interest_id = b._interest_id and round(a.max_rank,2)= round(b.percentile_ranking,2)
left join fresh_segments.interest_metrics b
on a._interest_id = c._interest_id and round(a.max_rank,2)= round(c.percentile_ranking,2);
