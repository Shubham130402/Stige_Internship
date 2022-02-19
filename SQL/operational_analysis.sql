<!-- create database -->
Create database operational_analysis;
<!-- create table job_data -->
create table job_data
(ds date, job_id int unique , actor_id int, event varchar(30),language varchar(30), time_spent int, org varchar(2));

desc job_data;

insert into job_data values
('2020-11-30',	21,	1001,	'skip',	'English'	,15,	'A'),
('2020-11-30'	,22,	1006,	'transfer',	'Arabic',	25,	'B'),
('2020-11-29'	,23,	1003,	'decision',	'Persian',	20,	'C'),
('2020-11-28'	,23	,1005	,'transfer',	'Persian',	22,	'D'),
('2020-11-28'	,25	,1002	,'decision',	'Hindi',11,	'B'),
('2020-11-27'	,11	,1007	,'decision',	'French',	104,'D'),
('2020-11-26'	,23	,1004	,'skip'	,'Persian',56	,'A'),
('2020-11-25'	,20	,1003	,'transfer',	'Italian',	45,	'C')
;

<!-- QA : Calculate the number of jobs reviewed per hour per day for November 2020? -->
select count(*) as no_of_jobs,ds as dates
from job_data
group by ds
order by no_of_jobs desc;

select
ds,
round(1.0*count(job_id)*3600/sum(time_spent),2) as throughout
from
job_data
where
event in ('transfer','decision')
and ds between '2020-11-01' and '2020-11-30'
group by
ds
ORDER BY
DS;


-- select
-- lan, count(lan) as total,
-- 100*count(*)/sum(count(*)) as perc_lan
-- from job_data
-- where event in ('transfer','decision')
-- group by perc_lan
-- order by total desc;

-- QB : Let’s say the above metric is called throughput. Calculate 7 day rolling average of throughput? For throughput, do you prefer daily metric or 7-day rolling and why?



-- QC : Calculate the percentage share of each language in the last 30 days?


with cte as(
  select lan,
  count(job_id) as num_jobs
  from jowith cte as(
select
ds,
count(job_id) as num_jobs,
sum(time_spent) as total_time
from
job_data
where
event in ('transfer','decision')
and ds between '2020-11-01' and '2020-11-30'
group by
ds
)
SELECT
ds,
round(1.0*sum(num_jobs) over (ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)/ SUM(total_time) over (ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) AS throughput_7d
from
cte
order by ds;b_data
  where
  event in ('transfer','decision')
  and ds between '2020-11-01' and '2020-11-30'
 group by lan
),
total AS (
  select
  count(job_id) as total_jobs
  from job_data
  where
  event in ('transfer','decision')
  and ds between '2020-11-01' and '2020-11-30'
  group by lan
)

SELECT
LAN,
ROUND(100*(NUM_JOBS)/(TOTAL_JOBS)) AS PERC_JOBS
FROM
total
cross join
cte
group by lan
ORDER BY
PERC_JOBS DESC;

-- QD: Let’s say you see some duplicate rows in the data. How will you display duplicates from the table?
with cte as(
select * ,
row_number () over(partition by ds,job_id,actor_id) as row_num
from
job_data
)
delete from cte where row_num>1;
select * from cte;
