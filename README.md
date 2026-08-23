# Cyclistic Bike-Share Case Study
Google Data Analytics Capstone Case Study — Analyzing rider trends using SQL, BigQuery, Python, and Tableau to drive annual memberships.

## Table of Contents
* [1. Ask Phase (Business Task & Context)](#1-ask-phase-business-task--context)
* [2. Prepare Phase (Data Sourcing & Integrity)](#2-prepare-phase-data-sourcing--integrity)
* [3. Process Phase (Data Consolidation & Cleaning Architecture)](#3-process-phase-data-consolidation--cleaning-architecture)
* [4. Analyze Phase (Exploratory Data Analysis)](#4-analyze-phase-exploratory-data-analysis)
* [5. Share Phase (Data Visualizations & Dashboard)](#5-share-phase-data-visualizations--dashboard)
* [6. Act Phase (Business Recommendations)](#6-act-phase-business-recommendations)

## 1. Ask Phase (Business Task & Context)

### Business Background
Cyclistic is a bike-share program in Chicago operating a fleet of over 5,800 bicycles across nearly 700 stations. The company's marketing strategy has historically focused on broad consumer segments via flexible pricing plans: single-ride passes, full-day passes (Casual riders), and annual memberships (Cyclistic members).

Finance analysts have established that **annual members are significantly more profitable than casual riders**. Rather than targeting all-new prospects, the marketing director, Lily Moreno, aims to maximize future revenue by converting existing casual riders into annual members.

---

### Core Business Task
Analyze historical bike trip data to identify behavioral patterns and differences between **casual riders** and **annual members**. Deliver data-driven recommendations to design a targeted marketing strategy that effectively converts casual riders into annual members.

---

### Key Guiding Questions
1. **Primary Analysis Question:** How do annual members and casual riders use Cyclistic bikes differently?
2. **Business Implication:** Why would casual riders be incentivized to buy a Cyclistic annual membership?
3. **Marketing Strategy:** How can Cyclistic leverage digital media and behavioral data to influence casual riders into becoming members?

---

### Key Stakeholders
* **Lily Moreno (Director of Marketing):** Primary stakeholder responsible for campaign strategy and approval.
* **Cyclistic Executive Team:** Decision-makers requiring robust, data-backed insights before approving the marketing strategy.
* **Cyclistic Marketing Analytics Team:** Primary working group responsible for collecting, processing, and reporting data insights.

---

### Deliverables
* [ ] A clear statement of the business task
* [ ] Description of all data sources used and data integrity validation (Prepare)
* [ ] Documentation of data cleaning and transformation steps (Process)
* [ ] Exploratory analysis and statistical summary (Analyze)
* [ ] Supporting interactive visualizations and dashboards (Share)
* [ ] Top three actionable business recommendations (Act)

## 2. Prepare Phase (Data Sourcing & Integrity)

### Data Source & Storage
* **Source:** Historical trip data provided by Motivate International Inc. under an open data license.
* **Scope:** 12 months of historical trip records in `.csv` format.
* **Privacy:** Personally Identifiable Information (PII) is excluded to comply with data privacy regulations (no credit card or address tracking).
* **Storage:** datasets are stored in a private Google Drive. 

### ROCCC Data Quality Framework
* **Reliable:** High integrity, direct internal tracking logs from bike IoT sensors.
* **Original:** First-party system logs from Motivate International Inc.
* **Comprehensive:** Contains comprehensive trip metrics (start/end timestamp, station names, rideable type, user type).
* **Current:** Covers the latest available 12-month operating window (year 2019).
* **Cited:** Publicly accessible and licensed dataset.

## 3. Process Phase (Data Consolidation & Cleaning Architecture)

### Step 1: Initial Ingestion & Schema Alignment (Python / Pandas)
* **Exploratory Data Inspection:** Inspected all 4 quarterly datasets for 2019 to identify schema mismatches and data types.
* **Schema Standardization:** Remapped non-standard column headers in the `Q2` dataset to align seamlessly with `Q1`, `Q3`, and `Q4`.
* **Consolidation:** Concatenated the 4 datasets into a single master file containing **3,818,004 records** and exported it as `divvy_trips_2019_raw.csv`.
* **Jupyter Notebook:** Documented in [`01_cyclistic_exploratory_analysis.ipynb`](./01_cyclistic_exploratory_analysis.ipynb).

### Step 2: Data Cleaning & Transformation Pipeline (Google BigQuery / SQL)
After consolidating the raw quarterly files, the dataset was ingested into Google BigQuery using an **ELT (Extract, Load, Transform)** architecture:

1. **Staging Layer & Data Profiling:**
   * Materialized raw data into a native BigQuery staging table (`cyclistic_2019_stage1`) containing **3,818,004 records**.
   * Profiled trip duration metrics and identified extreme anomalies (e.g., maximum trip duration of **123.01 days / 177,140 minutes**).
   * Quantified extreme outliers exceeding 24 hours: **1,848 records** (1,347 Casual, 501 Subscriber) representing unreturned, lost, or stolen bikes.

2. **Production Cleaning & Feature Engineering (`cyclistic_2019_cleaned`):**
   * **Outlier Removal:** Filtered out trips $< 60$ seconds and $> 24$ hours, resulting in **3,816,156 clean records** (99.95% data retention).
   * **Unit Conversion:** Calculated `trip_duration_minutes` rounded to 2 decimal places, bringing the realistic average duration down to **19.03 minutes**.
   * **Time Dimensions Extracted:**
     * `day_of_week` & `day_name` (Monday–Sunday) for weekly commuting patterns.
     * `month_num` & `month_name` (January–December) for seasonal demand analysis.
     * `start_hour` (0–23) for peak-hour and diurnal usage trends.

* **Full Documented SQL Script:** [`02_data_cleaning_and_transformation.sql`](./02_data_cleaning_and_transformation.sql)

## 4. Analyze Phase: Exploratory Data Analysis (EDA)

I conducted an in-depth exploratory analysis in Google BigQuery to uncover behavioral differences between **Subscribers (Annual Members)** and **Customers (Casual Riders)** across volume, duration, seasonality, and geography.

### Summary Comparison Table
| Metric / Dimension | Casual Customers | Annual Subscribers | Key Behavioral Difference |
| :--- | :--- | :--- | :--- |
| **Total Rides** | 879,290 (23.0%) | 2,936,866 (77.0%) | Subscribers generate >3x more total trips |
| **Avg. Trip Duration** | **39.4 minutes** | **12.9 minutes** | Customers ride **3x longer** per trip |
| **Peak Days** | **Saturday & Sunday** (~43% of trips) | **Tuesday – Thursday** (~500k trips/day) | Leisure on weekends vs. weekday utility |
| **Peak Hours** | Afternoon peak (3:00 PM – 5:00 PM) | Commuting peaks (**8:00 AM & 5:00 PM**) | Daytime recreation vs. work commute |
| **Seasonality** | Extreme summer peak (Aug: 186k vs Jan: 4.5k) | High year-round baseline (Jan: 98k) | Weather-dependent vs. all-season transport |
| **Top Station Types** | Waterfront, parks & attractions | Transit hubs & downtown intersections | Tourism/leisure hubs vs. railway terminals |

---

### Core Business Insights

1. **User Purpose & Persona:**
   * **Subscribers:** Use Cyclistic as a daily functional transit method to commute to work. Rides are short (~13 min), frequent on weekdays, and peak precisely at standard office commute hours (8:00 AM and 5:00 PM).
   * **Casual Customers:** Use bikes for leisure, sightseeing, and exercise. Rides are substantially longer (~40 min), highly concentrated on weekends, and surge during the warm summer months (June–August).

2. **Geographic Distribution:**
   * Casual riders originate overwhelmingly near shoreline paths and park attractions (*Streeter Dr & Grand Ave*, *Lake Shore Dr*, *Millennium Park*).
   * Subscribers consistently start trips around major commuter train stations (*Canal St & Adams St*, *Clinton St & Madison St*).
  
## 5. Share Phase (Data Visualizations & Dashboard)
An interactive executive dashboard was designed in **Tableau Public** to summarize behavioral trends across trip volume, commute hours, day-of-week demand, and monthly seasonality.

[![Cyclistic Dashboard](./cyclisticdashboard.png)](https://public.tableau.com/app/profile/marcin.kuriata/viz/CyclisticAnalysisVisualisation/CyclicticDashboard?publish=yes)
* Click the image above to explore the live interactive dashboard on Tableau Public.*

* **Direct Link:** [View Dashboard on Tableau Public](https://public.tableau.com/app/profile/marcin.kuriata/viz/CyclisticAnalysisVisualisation/CyclicticDashboard?publish=yes)

---

## 6. Act Phase (Business Recommendations)

Based on the behavioral differences identified between casual riders and annual members, here are three targeted, data-backed recommendations for Lily Moreno (Director of Marketing):

### 1. Introduce a "Weekend Pass" with Conversion Credits
* **Insight:** Casual customers ride predominantly on weekends (~43% of trips) and take longer leisure rides (~40 mins). A full-price annual membership may feel too rigid or commuting-focused for them.
* **Action:** Launch a seasonal **Weekend Membership / Leisure Pass** that charges a lower recurring fee for weekend access. Include a feature where all weekend ride fees can be applied as a discount toward a full Annual Membership within 30 days.

### 2. High-Impact Geotargeted Campaigns at Waterfront & Park Stations
* **Insight:** Casual riders start trips overwhelmingly around recreation and tourist spots (*Streeter Dr & Grand Ave*, *Millennium Park*, *Lake Shore Dr*, *Shedd Aquarium*).
* **Action:** Run localized in-app promotions, QR code dock banners, and digital out-of-home (DOOH) ads specifically at the top 10 waterfront stations. The messaging should highlight the savings of an annual membership for recurring weekend trips.

### 3. Summer Launch & Early-Bird Seasonal Campaigns (May – August)
* **Insight:** Over 68% of all casual rider volume happens between May and September, peaking in August (186k rides vs. under 5k in winter).
* **Action:** Schedule primary digital marketing spend and promotional push between late spring and mid-summer. Run an "Early Bird Summer Membership" campaign in May, offering discounted first-month pricing or digital rewards before peak riding season begins.
* **Full EDA SQL Script with query outputs:** [`03_exploratory_data_analysis.sql`](./03_exploratory_data_analysis.sql)
