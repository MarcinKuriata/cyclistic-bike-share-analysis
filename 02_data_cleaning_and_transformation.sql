/*
===============================================================================
CYCLISTIC BIKE-SHARE 2019: DATA CLEANING & TRANSFORMATION PIPELINE
===============================================================================
Author: Marcin Kuriata
Environment: Google BigQuery
Source: Divvy Trips 2019 (Q1–Q4 consolidated)
===============================================================================
*/

-- ============================================================================
-- STEP 1: MATERIALIZE STAGING LAYER
-- Materialize external Google Drive table into native BigQuery storage for fast querying
-- ============================================================================
CREATE OR REPLACE TABLE `cyclisticcapstone-506211.cyclistic_data.cyclistic_2019_stage1` AS
SELECT * 
FROM `cyclisticcapstone-506211.cyclistic_data.cyclistic_2019_raw`;


-- ============================================================================
-- STEP 2: DATA PROFILING & ANOMALY DETECTION (ON STAGING TABLE)
-- Inspecting baseline metrics, extreme outliers, and missing values
-- ============================================================================

-- Step 2.1: Initial audit of raw trip durations (calculating minutes & days on the fly)
SELECT 
    COUNT(*) AS total_raw_records,
    ROUND(AVG(tripduration) / 60.0, 2) AS avg_duration_minutes,
    ROUND(MIN(tripduration) / 60.0, 2) AS min_duration_minutes,
    ROUND(MAX(tripduration) / 60.0, 2) AS max_duration_minutes,
    ROUND(MAX(tripduration) / 86400.0, 2) AS max_duration_days
FROM 
    `cyclisticcapstone-506211.cyclistic_data.cyclistic_2019_stage1`;
  
/*
Query Output:
+-------------------+----------------------+----------------------+----------------------+-------------------+
| total_raw_records | avg_duration_minutes | min_duration_minutes | max_duration_minutes | max_duration_days |
+-------------------+----------------------+----------------------+----------------------+-------------------+
| 3,818,004         | 24.17                | 1.02                 | 177,140.00           | 123.01            |
+-------------------+----------------------+----------------------+----------------------+-------------------+
Observation:
- The minimum duration is 1.02 minutes (> 60 seconds), confirming sub-minute rides were pre-filtered in source CSVs.
- The maximum duration is 177,140 minutes (~123 days), which is an extreme anomaly (stolen/lost bike or dock failure).
- This extreme outlier distorts the overall average duration (24.17 mins).
*/

-- Step 2.2: Quantify outlier trips exceeding 24 hours (86,400 seconds) by user type
SELECT 
    usertype,
    COUNT(*) AS rides_over_24h,
    ROUND(MIN(tripduration) / 3600.0, 2) AS min_duration_hours,
    ROUND(AVG(tripduration) / 3600.0, 2) AS avg_duration_hours,
    ROUND(MAX(tripduration) / 86400.0, 2) AS max_duration_days
FROM 
    `cyclisticcapstone-506211.cyclistic_data.cyclistic_2019_stage1`;
WHERE 
    tripduration > 86400;
GROUP BY 
    usertype;

/*
Query Output:
+------------+------------------+--------------------+--------------------+-------------------+
| usertype   | rides_over_24h   | min_duration_hours | avg_duration_hours | max_duration_days |
+------------+------------------+--------------------+--------------------+-------------------+
| Subscriber | 501              | 24.16              | 136.61             | 104.82            |
| Customer   | 1,347            | 24.01              | 192.31             | 123.01            |
+------------+------------------+--------------------+--------------------+-------------------+
Observation:
- Total anomalies > 24 hours: 1,848 rides (~0.048% of total volume).
- Casual Customers account for ~73% of extreme outliers.
- Decision: Exclude rides > 86,400s (24h) in Step 3 to ensure data integrity and unbiased averages.
*/

-- ============================================================================
-- STEP 3: PRODUCTION DATA CLEANING & FEATURE ENGINEERING
-- Applying business cleaning rules based on profiling results:
--   1. Filter out trips < 60s (false starts / dock testing)
--   2. Filter out trips > 24 hours (stolen / lost bikes)
--   3. Extract calendar & time dimensions for behavioral analysis
-- ============================================================================
CREATE OR REPLACE TABLE `cyclisticcapstone-506211.cyclistic_data.cyclistic_2019_cleaned` AS
SELECT 
    trip_id,
    start_time,
    end_time,
    bikeid,
    tripduration AS trip_duration_seconds,
    ROUND(tripduration / 60.0, 2) AS trip_duration_minutes,
    from_station_id,
    from_station_name,
    to_station_id,
    to_station_name,
    usertype,
    gender,
    birthyear,
    -- Time dimensions for behavioral analysis
    EXTRACT(DAYOFWEEK FROM start_time) AS day_of_week,
    FORMAT_DATE('%A', DATE(start_time)) AS day_name,
    EXTRACT(MONTH FROM start_time) AS month_num,
    FORMAT_DATE('%B', DATE(start_time)) AS month_name,
    EXTRACT(HOUR FROM start_time) AS start_hour
FROM 
    `cyclisticcapstone-506211.cyclistic_data.cyclistic_2019_stage1`;
WHERE 
    tripduration >= 60                   -- Exclude trips < 1 min (false starts / dock tests)
    AND tripduration <= 86400            -- Exclude trips > 24h (1848 outlier records)
    AND start_time IS NOT NULL 
    AND end_time IS NOT NULL;


-- ============================================================================
-- STEP 4: POST-TRANSFORMATION QUALITY ASSURANCE
-- Verify that cleaned dataset conforms to data quality standards
-- ============================================================================
SELECT 
    COUNT(*) AS total_cleaned_records,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_duration_min,
    MIN(trip_duration_minutes) AS min_duration_min,
    MAX(trip_duration_minutes) AS max_duration_min
FROM 
    `cyclisticcapstone-506211.cyclistic_data.cyclistic_2019_cleaned`;

/*
Query Output:
+-----------------------+------------------+------------------+------------------+
| total_cleaned_records | avg_duration_min | min_duration_min | max_duration_min |
+-----------------------+------------------+------------------+------------------+
| 3,816,156             | 19.03            | 1.02             | 1440.00          |
+-----------------------+------------------+------------------+------------------+
Observation:
- Total records retained: 3,816,156 (filtered out 1,848 extreme outliers > 24h).
- Average trip duration decreased from 24.17 mins to a realistic 19.03 mins.
- Max duration capped at 1,440 minutes (24 hours).
*/
