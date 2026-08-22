/*
===============================================================================
CYCLISTIC BIKE-SHARE 2019: EXPLORATORY DATA ANALYSIS (EDA)
===============================================================================
Author: Marcin Kuriata
Environment: Google BigQuery
Source Table: `cyclisticcapstone-506211.cyclistic_data.cyclistic_2019_cleaned`
===============================================================================
*/

-- ============================================================================
-- ANALYSIS 1: OVERALL USAGE & TRIP DURATION COMPARISON
-- Purpose: Compare total volume, proportion, and trip durations by user type.
-- ============================================================================
SELECT 
    usertype,
    COUNT(*) AS total_rides,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM `cyclisticcapstone-506211.cyclistic_data.cyclistic_2019_cleaned`), 2) AS ride_percentage,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_duration_minutes,
    ROUND(MIN(trip_duration_minutes), 2) AS min_duration_minutes,
    ROUND(MAX(trip_duration_minutes), 2) AS max_duration_minutes
FROM 
    `cyclisticcapstone-506211.cyclistic_data.cyclistic_2019_cleaned`
GROUP BY 
    usertype;

/*
Query Output:
+------------+-------------+-----------------+----------------------+----------------------+----------------------+
| usertype   | total_rides | ride_percentage | avg_duration_minutes | min_duration_minutes | max_duration_minutes |
+------------+-------------+-----------------+----------------------+----------------------+----------------------+
| Customer   | 879,290     | 23.04           | 39.43                | 1.02                 | 1,440.00             |
| Subscriber | 2,936,866   | 76.96           | 12.93                | 1.02                 | 1,439.75             |
+------------+-------------+-----------------+----------------------+----------------------+----------------------+
Insights:
- Subscribers make up ~77% of all trips (core user base).
- Casual Customers ride on average for 39.43 minutes — more than 3x longer than Subscribers (12.93 minutes).
- Subscribers use bikes for quick, utility/commuting trips, while Customers use them for leisure/extended rides.
*/


-- ============================================================================
-- ANALYSIS 2: DAY OF WEEK BEHAVIORAL PATTERNS
-- Purpose: Analyze ride volume and average duration per day of the week by user type.
-- ============================================================================
SELECT 
    usertype,
    day_name,
    day_of_week,
    COUNT(*) AS total_rides,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_duration_minutes
FROM 
    `cyclisticcapstone-506211.cyclistic_data.cyclistic_2019_cleaned`
GROUP BY 
    usertype, 
    day_name, 
    day_of_week
ORDER BY 
    usertype, 
    day_of_week;

/*
Query Output:
+------------+-----------+-------------+-------------+----------------------+
| usertype   | day_name  | day_of_week | total_rides | avg_duration_minutes |
+------------+-----------+-------------+-------------+----------------------+
| Customer   | Sunday    | 1           | 169,941     | 41.33                |
| Customer   | Monday    | 2           | 101,356     | 39.30                |
| Customer   | Tuesday   | 3           | 88,415      | 37.57                |
| Customer   | Wednesday | 4           | 89,601      | 36.68                |
| Customer   | Thursday  | 5           | 101,203     | 37.39                |
| Customer   | Friday    | 6           | 120,934     | 38.31                |
| Customer   | Saturday  | 7           | 207,760     | 41.55                |
| Subscriber | Sunday    | 1           | 256,191     | 14.22                |
| Subscriber | Monday    | 2           | 458,714     | 12.64                |
| Subscriber | Tuesday   | 3           | 496,951     | 12.58                |
| Subscriber | Wednesday | 4           | 494,205     | 12.62                |
| Subscriber | Thursday  | 5           | 486,837     | 12.64                |
| Subscriber | Friday    | 6           | 456,890     | 12.54                |
| Subscriber | Saturday  | 7           | 287,078     | 14.46                |
+------------+-----------+-------------+-------------+----------------------+
Insights:
- Customer demand peaks strongly on weekends (Saturday: 207k, Sunday: 170k).
- Subscriber demand is concentrated heavily on weekdays (Tuesday-Thursday peaks ~497k/day) and drops by ~45% on weekends.
*/


-- ============================================================================
-- ANALYSIS 3: HOURLY USAGE & COMMUTE PEAKS
-- Purpose: Identify hourly distribution and peak commuting windows (0-23h).
-- ============================================================================
SELECT 
    usertype,
    start_hour,
    COUNT(*) AS total_rides,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_duration_minutes
FROM 
    `cyclisticcapstone-506211.cyclistic_data.cyclistic_2019_cleaned`
GROUP BY 
    usertype, 
    start_hour
ORDER BY 
    usertype, 
    start_hour;

/*
Key Summary of Hourly Trends:
- Subscribers show a distinct bimodal commuting pattern:
  * Morning peak: 08:00 (283,941 rides)
  * Evening peak: 17:00 (390,619 rides)
- Customers exhibit a unimodal afternoon curve:
  * Steady climb from 10:00 to 17:00 (peaking at 17:00 with 84,343 rides).
*/


-- ============================================================================
-- ANALYSIS 4: MONTHLY & SEASONAL DISTRIBUTION
-- Purpose: Track ride volume throughout the year (Jan-Dec) to identify seasonal shifts.
-- ============================================================================
SELECT 
    usertype,
    month_num,
    month_name,
    COUNT(*) AS total_rides,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_duration_minutes
FROM 
    `cyclisticcapstone-506211.cyclistic_data.cyclistic_2019_cleaned`
GROUP BY 
    usertype, 
    month_num, 
    month_name
ORDER BY 
    usertype, 
    month_num;

/*
Key Summary of Seasonality:
- Both segments peak during summer (June-August).
- Customers are highly weather-dependent: August has 186k rides vs January with only 4.5k rides (~40x difference).
- Subscribers maintain a much higher baseline even in winter (January: 98.6k, February: 93.5k).
*/


-- ============================================================================
-- ANALYSIS 5: TOP 10 START STATIONS BY USER TYPE
-- Purpose: Identify primary geographic hotspots for targeted marketing campaigns.
-- ============================================================================
WITH RankedStations AS (
    SELECT 
        usertype,
        from_station_name,
        COUNT(*) AS total_rides,
        ROUND(AVG(trip_duration_minutes), 2) AS avg_duration_minutes,
        DENSE_RANK() OVER (PARTITION BY usertype ORDER BY COUNT(*) DESC) AS station_rank
    FROM 
        `cyclisticcapstone-506211.cyclistic_data.cyclistic_2019_cleaned`
    WHERE 
        from_station_name IS NOT NULL
    GROUP BY 
        usertype, 
        from_station_name
)
SELECT 
    usertype,
    station_rank,
    from_station_name,
    total_rides,
    avg_duration_minutes
FROM 
    RankedStations
WHERE 
    station_rank <= 10
ORDER BY 
    usertype, 
    station_rank;

/*
Query Output (Top 5 comparison):
+------------+--------------+------------------------------------+-------------+----------------------+
| usertype   | station_rank | from_station_name                  | total_rides | avg_duration_minutes |
+------------+--------------+------------------------------------+-------------+----------------------+
| Customer   | 1            | Streeter Dr & Grand Ave            | 53,071      | 42.51                |
| Customer   | 2            | Lake Shore Dr & Monroe St          | 39,209      | 42.22                |
| Customer   | 3            | Millennium Park                    | 21,728      | 47.88                |
| Customer   | 4            | Michigan Ave & Oak St              | 21,370      | 47.62                |
| Customer   | 5            | Shedd Aquarium                     | 20,609      | 35.52                |
+------------+--------------+------------------------------------+-------------+----------------------+
| Subscriber | 1            | Canal St & Adams St                | 50,569      | 11.97                |
| Subscriber | 2            | Clinton St & Madison St            | 45,986      | 11.25                |
| Subscriber | 3            | Clinton St & Washington Blvd       | 45,375      | 11.54                |
| Subscriber | 4            | Columbus Dr & Randolph St          | 31,369      | 12.08                |
| Subscriber | 5            | Franklin St & Monroe St            | 30,828      | 13.32                |
+------------+--------------+------------------------------------+-------------+----------------------+
Insights:
- Customers congregate at tourist/waterfront hotspots (Navy Pier / Streeter Dr, Lake Shore Dr, Millennium Park, Shedd Aquarium).
- Subscribers start trips at major transit hubs and commercial office corridors (Union Station / Canal & Adams, Ogilvie Transportation Center / Clinton & Madison).
*/
