# ✈️ Flight Delay Diagnostic & Cascade Analysis

An end-to-end data analytics project analyzing **December 2015 U.S. flight operations** to understand flight delays, their causes, temporal patterns, airline/airport variation, and potential delay propagation between consecutive flights.

The project combines **Python, SQL, and Power BI** to move from raw flight data to validated analysis and an interactive analytical dashboard.

---

## 📌 Project Overview

Flight delays can result from multiple interacting factors, including airline operations, weather, air-system constraints, security issues, and delays inherited from earlier flights.

This project investigates:

* How frequently flights were delayed
* How severe the delays were
* Which airlines and airports experienced different delay patterns
* How delay rates varied by departure time and day
* Which operational causes contributed the most delay minutes
* Whether delays in preceding flights were associated with delays in subsequent flights

The final outcome is an interactive **Power BI Flight Delay Diagnostic Dashboard** supported by Python-based data preparation and SQL analysis.

---

## 🎯 Objectives

The primary objectives of the project were to:

1. Clean and prepare the flight dataset for analysis.
2. Isolate **December 2015** flight operations.
3. Identify cancelled and diverted flights and handle them appropriately.
4. Calculate overall flight volume and delay metrics.
5. Analyze delay patterns across airlines, airports and time periods.
6. Quantify the contribution of different delay causes.
7. Investigate potential **cascade effects**, where a delayed preceding flight is followed by another delayed flight.
8. Present the findings through an interactive Power BI dashboard.

---

## 📊 Dataset

**Source:** U.S. Department of Transportation flight-delay dataset available through Kaggle.

The analysis focuses specifically on **December 2015**.

### Dataset after cleaning

| Metric                    |            Value |
| ------------------------- | ---------------: |
| Cleaned records           |      **479,230** |
| Operated flights          |      **469,717** |
| Delayed flights (≥15 min) |       **96,772** |
| Delay rate                |       **20.60%** |
| Average delay when delayed | **62.6 minutes** |
| Potential cascade flights |       **35,151** |

Cancelled and diverted flights were investigated separately because missing arrival-delay values were found to be associated with operational exceptions, particularly diverted flights.

---

## 🔍 Data Preparation

The raw dataset was processed using Python and Pandas.

### Main steps

```text
Raw Flight Dataset
        ↓
Filter December 2015
        ↓
Inspect missing values
        ↓
Investigate cancelled/diverted flights
        ↓
Clean operational records
        ↓
Validate delay-related fields
        ↓
Create analysis-ready dataset
```

During the cleaning process, missing `ARRIVAL_DELAY` values were investigated rather than automatically treating them as zero. The analysis identified diverted flights as an important reason for missing arrival-delay values among flights that were not simply cancelled.

---

## 🧮 Key Metrics

### Operated Flights

Flights that were neither cancelled nor diverted were considered operated flights for the main operational analysis.

**469,717 operated flights**

### Delayed Flights

Flights arriving **15 minutes or more** after schedule were treated as delayed, following the U.S. Department of Transportation definition. This also matches the dataset itself: delay-cause data is recorded for exactly these flights, including 3,459 flights that arrived exactly 15 minutes late.

**96,772 delayed flights**

### Delay Rate

The overall delay rate was calculated as:

```text
Delay Rate =
Delayed Flights / Operated Flights × 100
```

Result:

**20.60%**

### Arrival Delay: Average vs Typical

The average arrival delay across all operated flights was **6.09 minutes**, but this figure includes early arrivals as negative values: **59.7% of flights arrived early** and the median flight arrived **5 minutes early**.

For flights that were delayed, the picture is very different:

| Metric                              |       Value |
| ----------------------------------- | ----------: |
| Average delay when delayed          | **62.6 min** |
| Median delay when delayed           | **38 min**   |

---

# 📈 Exploratory Analysis

The project examines flight delays from several perspectives.

## ✈️ Airline Analysis

Airline-level analysis was performed to compare:

* Flight volume
* Delay rate
* Average delay
* Delay patterns

This allows differences in operational performance to be examined without relying only on the total number of delayed flights.

---

## 📍 Airport Analysis

Origin airports were analyzed using:

* Flight volume
* Delay rate
* Airport-level comparisons

A minimum-flight-volume threshold was used when identifying high-delay-rate airports to avoid overemphasizing airports with very small sample sizes.

---

## 🕐 Temporal Analysis

Delay patterns were examined across:

* Day of the month
* Departure hour
* Day of week

### Daily trend: the holiday peak

Delays were concentrated at the end of the month. The daily delay rate stayed between about **7% and 24%** until 21 December, then rose to **30–44% between 22 and 30 December** during the holiday travel peak. 28 December also had the month's highest cancellation rate (**13.4%**).

### Departure hour

The delay rate climbs steadily through the day, from about **10% for 5am departures to about 27% for 8–9pm departures**, consistent with delays building up as aircraft fly successive legs. Hours 1am–4am have very few flights (as few as 66), so they are excluded from the hourly chart.

### Day of week

December 2015 has five Tuesdays, Wednesdays and Thursdays but only four of each other weekday, so each weekday's delay rate rests on just 4–5 specific dates. The weekday ranking mostly reflects which weekdays fell inside the holiday peak, so the daily trend is the more reliable view.

---

# 🛫 Delay Cause Analysis

The dataset provides several delay-cause categories.

The project analyzes:

* **Airline Delay**
* **Weather Delay**
* **Air System / NAS Delay**
* **Security Delay**
* **Late Aircraft Delay**

The total delay minutes were compared across these causes.

One of the major observations was that **Late Aircraft Delay** accounted for the largest total delay contribution in the analyzed December dataset.

The analysis recorded approximately:

**2.54 million minutes of Late Aircraft Delay (about 42% of all delay minutes)**

This makes delay propagation and aircraft turnaround an important area for further investigation.

---

# 🔄 Cascade Delay Analysis

One of the main analytical components of this project was investigating whether a delay in a preceding flight was associated with a delay in the subsequent flight.

Under the project's cascade definition, the analysis identified:

**35,151 potential cascade flights**

The observed delay rates were approximately:

| Previous Flight Status      | Subsequent Flight Delay Rate |
| --------------------------- | ---------------------------: |
| Previous flight delayed     |                   **70.45%** |
| Previous flight not delayed |                   **11.43%** |

This represents a substantial difference in observed subsequent-flight delay rates under the defined analysis criteria.

### Important interpretation

This analysis identifies an **association**, not proof of direct causation.

A subsequent delay can depend on multiple factors, including:

* Aircraft rotation
* Airport congestion
* Air-system constraints
* Weather
* Airline operations
* Scheduling and turnaround time

Therefore, the cascade analysis is presented as an investigation of **potential delay propagation**, rather than a causal model.

---

# 📊 Power BI Dashboard

The final Power BI dashboard brings the analysis together into a single executive page.

### Dashboard sections include:

* KPI cards: operated flights, delayed flights, delay rate, average delay when delayed, potential cascade flights
* Airline delay rate and average delay when delayed
* Top 15 origin airports by delay rate (airports with at least 500 flights)
* Delay rate by departure hour (5am–11pm)
* Delay rate by day of week
* Delay minutes by cause
* Cascade analysis: delay rate after a delayed vs. an on-time previous flight

Clicking any chart element cross-filters the other visuals.

### Opening the dashboard

The dashboard is saved as a **Power BI Project** (`.pbip`), so its measures (DAX), tables and visuals are stored as readable text files in the repository.

1. Run `notebooks/flight_delay_analysis.ipynb` to create `data/flights_dec2015_clean.csv` (the data files are not stored in the repository because of their size).
2. Open `dashboard/Flight_Delay_Diagnostic.pbip` in Power BI Desktop.
3. If the project is in a different folder, update the CSV path under **Transform data → Data source settings**.
4. Click **Refresh**.

---

## 🛠️ Tech Stack

| Technology           | Purpose                                |
| -------------------- | -------------------------------------- |
| **Python**           | Data cleaning and exploratory analysis |
| **Pandas**           | Data manipulation and transformation   |
| **Matplotlib**       | Data visualization                     |
| **SQL**              | Analytical queries and validation      |
| **Power BI**         | Interactive dashboard                  |
| **DAX**              | Power BI measures and calculations     |
| **Jupyter Notebook** | Analysis workflow                      |

---

## 📁 Project Structure

```text
flight-delay-diagnostic/
│
├── data/
│   ├── airlines.csv
│   ├── airports.csv
│   └── flights_dec2015_clean.csv          (generated by the notebook)
│
├── notebooks/
│   └── flight_delay_analysis.ipynb
│
├── sql/
│   └── flight_delay_analysis.sql
│
├── dashboard/
│   ├── Flight_Delay_Diagnostic.pbip       (open this in Power BI Desktop)
│   ├── Flight_Delay_Diagnostic.Report/    (pages and visuals)
│   └── Flight_Delay_Diagnostic.SemanticModel/  (tables and DAX measures)
│
└── README.md
```

---

# 🔬 Analytical Workflow

The complete project workflow was:

```text
                 RAW DATA
                    │
                    ▼
          Data Cleaning & Validation
                    │
                    ▼
          December 2015 Extraction
                    │
                    ▼
        Operational Flight Filtering
                    │
                    ▼
        Exploratory Data Analysis
                    │
          ┌─────────┴─────────┐
          ▼                   ▼
        Python                SQL
          │                   │
          └─────────┬─────────┘
                    ▼
             Validated Metrics
                    │
                    ▼
           Cascade Analysis
                    │
                    ▼
              Power BI
                    │
                    ▼
          Interactive Dashboard
```

---

# 💡 Key Takeaways

The analysis highlights several important characteristics of the December 2015 flight network:

* Nearly **470K operated flights** were analyzed after cleaning.
* Approximately **97K flights** were delayed by 15 minutes or more.
* The overall delay rate was approximately **20.6%**; delayed flights averaged **62.6 minutes** late.
* **Late aircraft operations** represented the largest contributor to total delay minutes (about 42%).
* Delays peaked during the **22–30 December holiday period**, when daily delay rates reached 30–44%.
* The delay rate rose steadily through the day, from about 10% at 5am to about 27% at 8–9pm.
* Delay patterns varied across airlines and airports.
* Flights following a delayed preceding flight showed a substantially higher observed delay rate under the project's cascade definition.
* The relationship between preceding-flight delays and subsequent delays provides a useful starting point for deeper operational and predictive analysis.

---

# 🚀 Future Improvements

The current project focuses on descriptive and diagnostic analytics. Possible extensions include:

### 1. Predictive Delay Modeling

Build machine-learning models to predict whether a flight will be delayed using:

* Scheduled departure time
* Airline
* Origin airport
* Destination airport
* Previous-flight delay
* Weather information
* Historical airport delay patterns

### 2. Delay Severity Prediction

Instead of predicting only delayed/not delayed, develop a regression model to predict **arrival-delay minutes**.

### 3. Advanced Cascade Modeling

Construct aircraft-level or flight-rotation features to distinguish genuine aircraft-turnaround propagation from other correlated operational factors.

### 4. Real-Time Analytics

Extend the dashboard to incorporate live or periodically updated flight information.

### 5. Network Analysis

Model airports and flight connections as a network to investigate how congestion and delays propagate through the wider flight network.

---

# 📌 Project Outcome

This project demonstrates an end-to-end analytics workflow:

**Data Cleaning → Exploratory Analysis → SQL Validation → Diagnostic Analysis → Dashboard Development**

Rather than treating the Power BI dashboard as the entire project, the dashboard serves as the final interface for communicating analysis performed using **Python and SQL**.

---

## 👩‍💻 Author

**Sumouli Pramanik**

Civil Engineering | Data Science & Analytics

### Skills demonstrated

`Python` · `Pandas` · `SQL` · `Power BI` · `DAX` · `Data Cleaning` · `EDA` · `Data Visualization` · `Analytical Reasoning`

---
