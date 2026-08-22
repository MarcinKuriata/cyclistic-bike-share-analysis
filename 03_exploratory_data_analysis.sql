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
- Subscribers use bikes mainly for daily commutes to work — short trips (~13 mins).
*/


-- ============================================================================
-- ANALYSIS 2: DAY OF WEEK BEHAVIORAL PATTERNS 
-- Purpose: Compare ride volume and average duration across days of the week.
-- ============================================================================
SELECT 
    day_of_week,
    day_name,
    -- Ride Counts
    COUNTIF(usertype = 'Customer') AS customer_rides,
    COUNTIF(usertype = 'Subscriber') AS subscriber_rides,
    -- Average Durations (minutes)
    ROUND(AVG(CASE WHEN usertype = 'Customer' THEN trip_duration_minutes END), 2) AS customer_avg_duration,
    ROUND(AVG(CASE WHEN usertype = 'Subscriber' THEN trip_duration_minutes END), 2) AS subscriber_avg_duration
FROM 
    `cyclisticcapstone-506211.cyclistic_data.cyclistic_2019_cleaned`
GROUP BY 
    day_of_week, 
    day_name
ORDER BY 
    day_of_week;

/*
Query Output:
+-------------+-----------+----------------+------------------+-----------------------+-------------------------+
| day_of_week | day_name  | customer_rides | subscriber_rides | customer_avg_duration | subscriber_avg_duration |
+-------------+-----------+----------------+------------------+-----------------------+-------------------------+
| 1           | Sunday    | 169,941        | 256,191          | 41.33                 | 14.22                   |
| 2           | Monday    | 101,356        | 458,714          | 39.30                 | 12.64                   |
| 3           | Tuesday   | 88,415         | 496,951          | 37.57                 | 12.58                   |
| 4           | Wednesday | 89,601         | 494,205          | 36.68                 | 12.62                   |
| 5           | Thursday  | 101,203        | 486,837          | 37.39                 | 12.64                   |
| 6           | Friday    | 120,934        | 456,890          | 38.31                 | 12.54                   |
| 7           | Saturday  | 207,760        | 287,078          | 41.55                 | 14.46                   |
+-------------+-----------+----------------+------------------+-----------------------+-------------------------+
Insights:
- Customer rides peak sharply on weekends (Saturday & Sunday account for ~43% of all casual trips).
- Subscriber rides peak during workdays (Tuesday through Thursday at nearly 500k rides/day) and decline on weekends.
- Customer ride durations stay around 37-41 minutes across all days, while Subscribers maintain short 12-14 minute rides.
*/


-- ============================================================================
-- ANALYSIS 3: HOURLY USAGE & COMMUTE PEAKS 
-- Purpose: Compare hourly ride volume and average duration for both user types.
-- ============================================================================
SELECT 
    start_hour,
    -- Ride Counts
    COUNTIF(usertype = 'Customer') AS customer_rides,
    COUNTIF(usertype = 'Subscriber') AS subscriber_rides,
    -- Average Durations (minutes)
    ROUND(AVG(CASE WHEN usertype = 'Customer' THEN trip_duration_minutes END), 2) AS customer_avg_duration,
    ROUND(AVG(CASE WHEN usertype = 'Subscriber' THEN trip_duration_minutes END), 2) AS subscriber_avg_duration
FROM 
    `cyclisticcapstone-506211.cyclistic_data.cyclistic_2019_cleaned`
GROUP BY 
    start_hour
ORDER BY 
    start_hour;

/*
Query Output:
+------------+----------------+------------------+-----------------------+-------------------------+
| start_hour | customer_rides | subscriber_rides | customer_avg_duration | subscriber_avg_duration |
+------------+----------------+------------------+-----------------------+-------------------------+
| 0          | 8,179          | 15,867           | 39.21                 | 13.80                   |
| 1          | 5,355          | 9,029            | 40.20                 | 13.59                   |
| 2          | 3,313          | 5,326            | 40.07                 | 13.49                   |
| 3          | 1,908          | 3,680            | 41.93                 | 12.85                   |
| 4          | 1,167          | 6,614            | 38.87                 | 11.06                   |
| 5          | 2,606          | 33,151           | 32.63                 | 10.85                   |
| 6          | 6,077          | 102,130          | 28.77                 | 11.50                   |
| 7          | 12,853         | 224,826          | 27.92                 | 11.76                   |
| 8          | 21,770         | 283,941          | 32.68                 | 11.96                   |
| 9          | 28,655         | 135,109          | 43.00                 | 12.00                   |
| 10         | 44,712         | 100,686          | 46.29                 | 12.70                   |
| 11         | 59,969         | 119,915          | 45.72                 | 12.79                   |
| 12         | 69,517         | 136,645          | 43.43                 | 12.73                   |
| 13         | 75,084         | 131,920          | 42.99                 | 12.91                   |
| 14         | 78,358         | 127,892          | 42.37                 | 13.35                   |
| 15         | 80,001         | 163,317          | 40.73                 | 13.25                   |
| 16         | 82,751         | 292,860          | 37.85                 | 13.13                   |
| 17         | 84,343         | 390,619          | 35.24                 | 13.75                   |
| 18         | 67,928         | 247,176          | 35.61                 | 13.63                   |
| 19         | 50,295         | 158,353          | 35.82                 | 13.65                   |
| 20         | 34,331         | 99,735           | 35.40                 | 13.61                   |
| 21         | 24,876         | 71,245           | 35.12                 | 13.66                   |
| 22         | 21,120         | 48,522           | 35.36                 | 13.32                   |
| 23         | 14,122         | 28,308           | 36.32                 | 13.67                   |
+------------+----------------+------------------+-----------------------+-------------------------+
Insights:
- Subscribers show two clear rush hour spikes:
  * Morning peak: 8:00 AM (283k rides)
  * Afternoon peak: 5:00 PM (390k rides)
  This clearly confirms they use the bikes to commute to and from work.
- Customers build up activity gradually throughout the day:
  * Rides start picking up around 11:00 AM and peak late afternoon (3:00 PM - 5:00 PM).
  * Trip duration remains high (35-46 mins) all day, pointing to casual daytime leisure.
*/


-- ============================================================================
-- ANALYSIS 4: MONTHLY & SEASONAL DISTRIBUTION 
-- Purpose: Track ride volume and average duration across months (Jan-Dec).
-- ============================================================================
SELECT 
    month_num,
    month_name,
    -- Ride Counts
    COUNTIF(usertype = 'Customer') AS customer_rides,
    COUNTIF(usertype = 'Subscriber') AS subscriber_rides,
    -- Average Durations (minutes)
    ROUND(AVG(CASE WHEN usertype = 'Customer' THEN trip_duration_minutes END), 2) AS customer_avg_duration,
    ROUND(AVG(CASE WHEN usertype = 'Subscriber' THEN trip_duration_minutes END), 2) AS subscriber_avg_duration
FROM 
    `cyclisticcapstone-506211.cyclistic_data.cyclistic_2019_cleaned`
GROUP BY 
    month_num, 
    month_name
ORDER BY 
    month_num;

/*
Query Output:
+-----------+------------+----------------+------------------+-----------------------+-------------------------+
| month_num | month_name | customer_rides | subscriber_rides | customer_avg_duration | subscriber_avg_duration |
+-----------+------------+----------------+------------------+-----------------------+-------------------------+
| 1         | January    | 4,591          | 98,601           | 33.62                 | 11.46                   |
| 2         | February   | 2,627          | 93,522           | 29.35                 | 11.23                   |
| 3         | March      | 15,877         | 149,659          | 36.74                 | 11.26                   |
| 4         | April      | 47,669         | 217,531          | 40.86                 | 12.47                   |
| 5         | May        | 81,507         | 285,793          | 41.58                 | 13.24                   |
| 6         | June       | 130,066        | 345,135          | 40.42                 | 14.04                   |
| 7         | July       | 175,433        | 381,615          | 40.61                 | 14.35                   |
| 8         | August     | 186,625        | 403,241          | 40.14                 | 13.86                   |
| 9         | September  | 128,988        | 364,034          | 37.81                 | 13.18                   |
| 10        | October    | 70,889         | 300,717          | 35.48                 | 11.99                   |
| 11        | November   | 18,653         | 158,401          | 34.31                 | 11.09                   |
| 12        | December   | 16,365         | 138,647          | 37.17                 | 11.04                   |
+-----------+------------+----------------+------------------+-----------------------+-------------------------+
Insights:
- Both groups peak in the summer (June–August), with August being the busiest month overall.
- Customer demand is heavily weather-dependent: it drops drastically in winter (under 5k rides in Jan/Feb) and surges in summer (over 186k in August).
- Subscribers maintain consistent activity year-round, recording ~90k-100k rides even during the coldest winter months.
*/


-- ============================================================================
-- ANALYSIS 5: TOP 10 START STATIONS BY USER TYPE
-- Purpose: Identify primary geographic hotspots for targeted marketing campaigns.
-- ============================================================================

-- Use a CTE (subquery) to calculate total rides and assign rank positions before filtering the top 5
WITH RankedStations AS (
    SELECT 
        usertype,
        from_station_name,
        COUNT(*) AS total_rides,
        ROUND(AVG(trip_duration_minutes), 2) AS avg_duration_minutes,
        -- Rank stations from most to least popular separately for each user type (resets count for each group)
        RANK() OVER (PARTITION BY usertype ORDER BY COUNT(*) DESC) AS station_rank
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
    station_rank <= 5
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
- Top Customer stations are located near parks, attractions, and the waterfront (e.g., Streeter Dr, Millennium Park, Shedd Aquarium).
- Top Subscriber stations are concentrated around major train stations and busy downtown street intersections (e.g., Canal St, Clinton St).
*/
