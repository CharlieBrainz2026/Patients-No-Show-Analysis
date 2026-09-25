# Patients-No-Show-Analysis

**Patient No-Show Analysis**

**Project Overview**

Healthcare patient no-shows create operational challenges for clinics by leaving appointment slots unused and reducing provider efficiency.
This project analyzes 4,999 medical appointments to identify patterns associated with patient no-shows and determine which factors may indicate a higher likelihood of missed appointments. The project takes the data from a raw CSV file through data cleaning and SQL analysis to an interactive Tableau dashboard.

**Business Problem**
Why are patients missing appointments, and what factors are associated with higher no-show rates?

The analysis focuses on:
1. No-show rates by day of the week
2. Time between booking and appointment
3. Patient demographics
4. Clinic/speciality patterns
5. Patient attendance history
6. Identification of higher-risk patients

**Key Objectives**
🔹Clean and prepare a messy healthcare dataset
🔹Identify and resolve data-quality issues
🔹Analyze appointment attendance patterns using SQL
🔹Calculate no-show rates and operational KPIs
🔹Use SQL window functions to analyze patient attendance history
🔹Develop a patient no-show risk scoring model
🔹Create a reusable SQL VIEW for analysis
🔹Build an interactive Tableau dashboard
🔹Generate insights that could help clinics reduce missed appointments

**Tools & Technologies**
MySQL / MySQL Workbench | SQL | Tableau Public | GitHub


**Skills Demonstrated**
**Data Cleaning**
Handling invalid records
Cleaning date fields
Identifying missing and inconsistent values
Preparing raw CSV data for analysis

**SQL Analysis**
CASE WHEN
GROUP BY
Aggregate functions
Filtering and data validation
Subqueries
SQL VIEWs

Advanced SQL
Window functions
PARTITION BY
ROWS BETWEEN
Rolling patient attendance history
Patient risk scoring
Avoiding data leakage when creating predictive-style features

Data Visualization
Created an interactive Tableau dashboard featuring:
No-show rate KPIs
Appointment volume
Attendance vs. no-show trends
Demographic analysis
Day-of-week analysis
Booking-to-appointment lead-time analysis
Patient risk indicators
Interactive filters

**Business Value**
The analysis demonstrates how healthcare appointment data can be used to identify operational patterns behind missed appointments.
Potential applications include:
Targeted appointment reminders
Identifying higher-risk appointments
Improving appointment scheduling
Supporting appropriate overbooking strategies
Reducing unused appointment capacity
Improving clinic resource utilization

**Project Workflow**
Raw CSV → Data Cleaning → MySQL → Exploratory SQL → Advanced SQL → Risk Scoring → SQL VIEW → Tableau → Interactive Dashboard

**Dashboard**


**Project Structure**
Patients-No-Show-Analysis/
│
├── data/
│   └── raw/
|       └──KaggleV2-May-2016.csv
|   └── Processed/
│       └──Cleaned Data
|
├── sql/
│    └──healthcare_analysis.sql
│    └──v_appointment_risk.csv
│    └──medicalappointment.csv
│    └──Which neighborhoods have the highest risk.csv
│    └──Patient-level risk scoring.csv
│    └──Do SMS reminders help.csv
│    └──Age groups.csv
│    └──Does lead time matter.csv
│    └──Does the day of the week matter.csv
│    └──What's our overall no-show rate.csv
│
├── Tableau/
│   └── tableau_dashboard.png
│   └── Appointment No-Show Dashboard.pdf
│   └── Patient_No_Show.twb
│
└── README.md


**Conclusion**
This project demonstrates an end-to-end data analytics workflow, from raw healthcare data preparation and SQL analysis to risk-based analysis and interactive dashboard development.
It showcases practical skills in SQL, data cleaning, analytical thinking, window functions, data visualization, and translating business problems into actionable insights.
