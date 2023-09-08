-- =============================================
-- Author:      Eric Rohrer
-- Create date: 6/7/2023
-- Description: PMG interviewee SQL assessment
-- 
-- Table of Contents
--      0. Create and initialize db
--      1. SQL Assessment Queries
-- =============================================

-- =============================================
-- Section 0. CREATE AND INITIALIZE DB
--      I'm including some initialization code here to best show my development process.
--
--      I chose to use PostgreSQL to build my database. Steps I took to run code:
--          1. Postgres running, ProgrammingChallenges cloned on local machine:
--          2. Open a new terminal
--          3. Navigate to ./ProgrammingChallenges/sql-assessment/
--          4. run the command 'psql -d postgres -U <postgres username> -f answers.sql'
-- =============================================

-- I'm using PostgreSQL for this assessment, see above for details
\c postgres 

DROP DATABASE IF EXISTS sql_assessment;
CREATE DATABASE sql_assessment;

\c sql_assessment

CREATE TABLE marketing_data (
    date timestamp,
    campaign_id varchar(50),
    geo varchar(50),
    cost float,
    impressions float,
    clicks float,
    conversions float
);

CREATE TABLE website_revenue (
    date timestamp,
    campaign_id varchar(50),
    state varchar(2),
    revenue float
);

CREATE TABLE campaign_info (
    id serial not null primary key,
    name varchar(50),
    status varchar(50),
    last_updated_date timestamp
);

\copy marketing_data(date, campaign_id, geo, cost, impressions, clicks, conversions) from 'marketing_performance.csv' csv header

\copy website_revenue(date, campaign_id, state, revenue) from 'website_revenue.csv' csv header

\copy campaign_info(id, name, status, last_updated_date) from 'campaign_info.csv' csv header

-- =============================================
-- Section 1. SQL ASSESSMENT QUERIES
--
-- Table of Contents:
--      1. Sum of impressions by day
--      2. Top 3 revenue-generating states
--      3. Total cost, impressions, clicks, and revenue of each campaign
--      4. Number of conversions of Campaign5 by state
--      5. Opinion - Most efficient campaign
--      6. Bonus - Best day of week to run ads
-- =============================================

-----------------------------------------------
-- QUERY 1: Sum of impressions by day
\echo 'Query 1: Sum of impressions by day\n'
-----------------------------------------------
SELECT DATE(date), SUM(impressions) AS impressions
  FROM marketing_data
 GROUP BY date
 ORDER BY date;

-----------------------------------------------
-- QUERY 2: Top 3 revenue-generating states
\echo 'Query 2: Top 3 revenue-generating states\n'
--
-- ANSWER:
-- The 3rd best state generated $37,577 in revenue
-----------------------------------------------
SELECT state, SUM(revenue) AS revenue
  FROM website_revenue
 GROUP BY state
 ORDER BY revenue DESC
 LIMIT 3;

-----------------------------------------------
-- QUERY 3: Total cost, impressions, clicks, and revenue of each campaign
\echo 'Query 3: Total cost, impressions, clicks, and revenue of each campaign\n'
-----------------------------------------------
SELECT c.name, 
       ROUND(CAST(SUM(m.cost) AS numeric), 2) AS cost, 
       SUM(m.impressions) AS impressions, 
       SUM(m.clicks) AS clicks,
       SUM(w.revenue) AS revenue
  FROM campaign_info as c 
       JOIN marketing_data AS m ON c.id = CAST(m.campaign_id AS int)
       JOIN website_revenue AS w ON c.id = CAST(w.campaign_id AS int)
 GROUP BY c.name
 ORDER BY c.name;

-----------------------------------------------
-- QUERY 4: Number of conversions of Campaign5 by state
\echo 'Query 4: Number of conversions of Campaign5 by state\n'
--
-- ANSWER:
-- Georgia generated the most conversions for this campaign
-----------------------------------------------
SELECT m.geo AS state, SUM(m.conversions) AS conversions
  FROM campaign_info as c 
       JOIN marketing_data AS m ON c.id = CAST(m.campaign_id AS int)
 WHERE c.name = 'Campaign5'
 GROUP BY state
 ORDER BY conversions DESC;

-----------------------------------------------
-- Query 5: Opinion on most efficient campaign
\echo 'Query 5: Opinion on most efficient campaign\n'
--
-- ANSWER:
-- Campaign3 is the most efficient campaign in my opinion.
--      I selected 3 metrics to track efficiency:
--          Metric 1: click-through rate (clicks / impressions)
--          Metric 2: conversion rate (conversions / clicks)
--          Metric 3: profit (revenue - cost)
-- Campaign3 stood out to me because:
--      1. Campaign3 brought in the largest profit by far, of $535,862.96
--      2. Campaign3 was tied for the highest conversion rate at 31%
--      3. The clickthrough rate was on par with the other campaigns at 73%
--          We do note that the clickthrough rates were suspiciously high, in fact Campaign5 recieved more clicks than impressions.
--              this is an unlikely scenario which should lead us to investigate the data sources further.     
-----------------------------------------------
SELECT c.name, 
       ROUND(CAST(SUM(m.clicks) / SUM(m.impressions) AS numeric), 2) AS clickthrough_rate,
       ROUND(CAST(SUM(m.conversions) / SUM(m.clicks) AS numeric), 2) AS conversion_rate,
       ROUND(CAST(SUM(w.revenue) - SUM(m.cost) AS numeric), 2) AS profit
  FROM campaign_info as c 
       JOIN marketing_data AS m ON c.id = CAST(m.campaign_id AS int)
       JOIN website_revenue AS w ON c.id = CAST(w.campaign_id AS int)
 GROUP BY c.name
 ORDER BY c.name;

-----------------------------------------------
-- Query 6: Bonus - Best day of week to run ads
\echo 'Query 6: Bonus - Best day of week to run ads\n'
--
-- ANSWER:
-- Friday appears to be the best day of the week to run ads.
--      I used the same metrics as outlined in question 5, and observe:
--          Fridays, on average, have the highest profit out of all the days
--          Fridays, on average have the highest conversion rate out of all the days
--          And although Friday's clickthrough rate is lower than other days, 
--              we again observe anomalies with this metric as noted in query 5 that should prompt further investigation of the data.
-----------------------------------------------
SELECT TO_CHAR(m.date, 'DAY') AS day, 
       ROUND(CAST(SUM(m.clicks) / SUM(m.impressions) AS numeric), 2) AS clickthrough_rate,
       ROUND(CAST(SUM(m.conversions) / SUM(m.clicks) AS numeric), 2) AS conversion_rate,
       ROUND(CAST(SUM(w.revenue) - SUM(m.cost) AS numeric), 2) AS profit
  FROM campaign_info as c 
       JOIN marketing_data AS m ON c.id = CAST(m.campaign_id AS int)
       JOIN website_revenue AS w ON c.id = CAST(w.campaign_id AS int)
 GROUP BY day
 ORDER BY profit DESC;