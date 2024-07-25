USE youtube_db;

-- After importing the Flat File, check entire table was successfully imported 
SELECT TOP(100) *
FROM top_uk_youtubers_2024;

/* 1. Remove Unecessary Columns (only select necessary columns for analysis) 
   2. Extract YouTube Channel Names from First Column
   3. Rename Column Headers where necessary
*/

-- Only require 'NOMBRE', 'total_subscribers', 'total_views', 'total_videos'
SELECT NOMBRE, total_subscribers, total_views, total_videos
FROM top_uk_youtubers_2024;

--Extracting YouTube Channel Name from 'NOMBRE' using SUBSTRING with CHARINDEX to locate '@'
SELECT NOMBRE, 
       --extract substring from 'start' to '1 character BEFORE @' (hence '-1') 
       CAST(
	        SUBSTRING(NOMBRE, 1, CHARINDEX('@',NOMBRE) - 1) 
			AS VARCHAR(100)
			) AS 'Channel_Name',
		total_subscribers,
		total_views,
		total_videos
FROM top_uk_youtubers_2024;

--Create a VIEW for the above query (only show users necessary data)
CREATE VIEW view_uk_youtubers_2024 AS
SELECT --extract substring from 'start' to '1 character BEFORE @' (hence '-1') 
       CAST(
	        SUBSTRING(NOMBRE, 1, CHARINDEX('@',NOMBRE) - 1) 
			AS VARCHAR(100)
			) AS 'Channel_Name',
		total_subscribers,
		total_views,
		total_videos
FROM top_uk_youtubers_2024


              /* Data Quality Checks */

--must be confident that data is complete and accurate (no errors in data)

/*
1. Data must have 100 Records of Youtube Channels (row count test)
2. Data needs 4 Fields (column count test)
3. Channel Name Column must have VARCHAR Data Type, Other Columns must be INTEGER Data Types (data type check)
4. Each Row must be Unique (duplicate count check)
*/

SELECT COUNT(DISTINCT Channel_Name) AS 'Count_of_YouTubers'
FROM view_uk_youtubers_2024;
-- 100 Records = 100 YouTubers - Passed!

SELECT COUNT(*) AS column_count
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'view_uk_youtubers_2024';
--using INFORMATION_SCHEMA table, can count how many ROWS of 'TABLE_NAME = view_uk_youtubers_2024' there are (=number of columns in the view table)
--Count 4 Columns - Passed!

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'view_uk_youtubers_2024';
--using INFORMATION_SCHEMA table, can also see the data types of each Column in 'view_uk_youtubers_2024'
--all data types are suitable - Passed!

SELECT Channel_Name,
       COUNT(*) AS Duplicate_Count
FROM view_uk_youtubers_2024
GROUP BY Channel_Name
HAVING COUNT(*) > 1;
--Duplicate Check returns EMPTY Table - No Duplicate Records in the View Table! All 100 Channel Names are Unique.

--Now, have verified that this data is suitable for the next stage - Visualization in Power BI!


                 /* Validating Excel Analysis in SQL */
/*
1. Define Variables
2. Create a CTE to round average views per video
3. Select columns required for analysis
4. Filter Results by YouTube Channels with Highest Subscriber Bases
5. Order net_profit from highest to lowest
*/

--Define our Variables needed for Analysis using 'DECLARE @' Statements:
DECLARE @conversionRate FLOAT = 0.02;
DECLARE @productCost MONEY = 5.0;
DECLARE @campaignCost MONEY = 50000.0;

WITH ChannelData AS (
SELECT 
      Channel_Name,
      total_subscribers,
	  total_views,
	  total_videos,
	  ROUND((CAST(total_views AS FLOAT) / total_videos), -4) AS rounded_avg_views_per_video
	  -- '-4' rounds to nearest 10,000 (cleaner-looking)
FROM view_uk_youtubers_2024
)
--Use Variables defined above to calcluate required values
SELECT TOP(3) 
       Channel_Name, 
	   rounded_avg_views_per_video,
	   (rounded_avg_views_per_video * @conversionRate) AS potential_units_sold_per_video,
	   (rounded_avg_views_per_video * @conversionRate * @productCost) AS potential_revenue_per_video,
	   (rounded_avg_views_per_video * @conversionRate * @productCost) - @campaignCost AS net_profit 
FROM ChannelData
ORDER BY total_subscribers DESC;









