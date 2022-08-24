-- 1.Which interests have been present in all month_year dates in our dataset?
with cte as( select _interest_id, count(distinct _month_year) as total_months
  from fresh_segments.interest_metrics
  where month_year2 is not null
  group by _interest_id )
  select _interest_id, total_months
from cte
where total_months = 14;

-- 2. Using this same total_months measure - calculate the cumulative percentage of all
-- records starting at 14 months - which total_months value passes the 90% cumulative
-- percentage value?

with cte as( select _interest_id, count(distinct _month_year) as total_months
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

-- 3. If we were to remove all interest_id values which are lower than the total_months value
-- we found in the previous question - how many total data points would we be removing?
with temp_Cte as(
    select _interest_id, count(distinct _month_year) as total_months
    from fresh_segments.interest_metrics
    where month_year2 is not Null
    group by _interest_id
)
select count(distinct _interest_id) as total_interests
from temp_cte where total_months<14;

-- 4. Does this decision make sense to remove these data points from a business perspective?
-- Use an example where there are all 14 months present to a removed interest example for your
-- arguments - think about what it means to have less months present from a segment perspective.
with temp_Cte as(
    select _interest_id, count(distinct _month_year) as total_months
    from fresh_segments.interest_metrics
    where month_year2 is not Null
    group by _interest_id
),
temp_cte2 as(
select _interest_id from temp_cte where total_months<6)
delete from fresh_segments.interest_metrics where _interest_id in (select _interest_id from temp_cte2);

-- I think this decision of removing the data from the database is not valid untill your manager dont tell
-- you the exact details of why we are deleting and how many data points we can delete so that it is not
-- dangerous for our private space.

-- 5. After removing these interests - how many unique interests are there for each month?
select _month_year, count(distinct _interest_id) as interest_id
from fresh_segments.interest_metrics
where _month_year is not null
group by _month_year
order by _month_year ;
