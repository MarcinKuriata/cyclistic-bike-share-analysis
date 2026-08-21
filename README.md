# Cyclistic Bike-Share Case Study
Google Data Analytics Capstone Case Study — Analyzing rider trends using SQL, BigQuery, Python, and Tableau to drive annual memberships.

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

### Step 2: ELT Pipeline Decision (Google BigQuery / SQL)
To demonstrate production-grade data warehousing practices, full transformation and data hygiene were delegated to **Google BigQuery (SQL)**:
* **Data Type Casting:** Converting string timestamps (`start_time`, `end_time`) to `TIMESTAMP` and `tripduration` to numeric format.
* **Data Cleaning & Filtering:** Removing trip anomalies (negative durations, test/servicing trips, trips under 60 seconds).
* **Feature Engineering:** Calculating trip length in minutes, day of the week, and hour of the day for behavioral analysis.
