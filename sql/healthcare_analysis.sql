USE healthcare_analytics;
SELECT count(*) from medicalappointment;

SELECT * FROM medicalappointment;


-- DATA CLEANING --
ALTER TABLE medicalappointment
	CHANGE COLUMN Handcap disability_count INT;

    
SELECT 
	disability_count, 
    COUNT(*)
FROM medicalappointment
GROUP BY disability_count;



ALTER TABLE medicalappointment
	MODIFY COLUMN ScheduledDay DATETIME;

ALTER TABLE medicalappointment
	ADD COLUMN ScheduledDay_clean DATETIME;
    
-- Disable safe mode --
SET SQL_SAFE_UPDATES = 0;
SELECT * FROM medicalappointment;

UPDATE medicalappointment
SET ScheduledDay_clean = STR_TO_DATE(REPLACE(REPLACE(ScheduledDay, 'T', ' '), 'Z', ''), '%Y-%m-%d %H:%i:%s');


ALTER TABLE medicalappointment
	DROP COLUMN ScheduledDay;
 
ALTER TABLE medicalappointment
	CHANGE COLUMN ScheduledDay_clean ScheduledDay DATETIME;

SELECT 
	ScheduledDay 
FROM medicalappointment
LIMIT 10;
 
SELECT
	MIN(AGE), 
    MAX(AGE)
FROM medicalappointment; 

DELETE FROM medicalappointment 
WHERE AGE = -1;


ALTER TABLE medicalappointment ADD COLUMN lead_time_days INT; 

UPDATE medicalappointment
SET lead_time_days = DATEDIFF(AppointmentDay, DATE(ScheduledDay));

SELECT
	MIN(lead_time_days), 
    MAX(lead_time_days)
FROM medicalappointment;

SELECT count(*) FROM medicalappointment
WHERE lead_time_days < 0;

DELETE FROM medicalappointment
WHERE lead_time_days < 0;

-- Data Exploration
-- 1: What's our overall no-show rate?
 SELECT * FROM medicalappointment;
SELECT
	no_show, 
    COUNT(*) as total_appointments, 
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM medicalappointment), 2) as pct_of_total
FROM medicalappointment
GROUP BY no_show;

-- 2: Does the day of the week matter

SELECT
	DAYNAME(AppointmentDay) as appointment_day, 
    COUNT(*) as total_appointments, 
    SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) as no_shows,
	ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) as rate_of_no_shows
FROM medicalappointment
GROUP BY DAYNAME(AppointmentDay)
ORDER BY rate_of_no_shows DESC;

-- 3: Does lead time matter

-- same day
-- 1-3 days
-- within a week (4-7 days)
-- long lead (8+ days)

SELECT
	CASE
		WHEN lead_time_days = 0 THEN 'Same Day'
        WHEN lead_time_days BETWEEN 1 AND 3 THEN 'Short (1-3 Days)'
		WHEN lead_time_days BETWEEN 4 AND 7 THEN 'Within a week'
        ELSE 'Long Lead (8+ days)'
	END AS lead_time_bucket, 
	COUNT(*) as total_appointments, 
	ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) as no_show_rate
FROM medicalappointment
GROUP BY lead_time_bucket
ORDER BY no_show_rate DESC;

-- 4: Age groups

-- child 0-12
-- teen (13-19)
-- young adult (20-39)
-- adult (40-59)

SELECT
	CASE
		WHEN Age BETWEEN 0 AND 12 THEN 'Child'
		WHEN Age BETWEEN 13 AND 19 THEN 'Teen'
        WHEN Age BETWEEN 20 AND 39 THEN 'Young Adult'
        WHEN Age BETWEEN 40 AND 59 THEN 'Adult'
		ELSE 'Senior'
	END AS age_group, 
    COUNT(*) as total_appointments,
	ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) as no_show_rate
FROM medicalappointment
GROUP BY age_group
ORDER BY no_show_rate DESC;

-- 5: Do SMS reminders help
SELECT
	CASE WHEN sms_received = 1 THEN 'Received SMS' ELSE 'No SMS' 
    END AS sms_status,
    COUNT(*) as total_appointments,
	ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) as no_show_rate
FROM medicalappointment
GROUP BY sms_status;

-- 6: Which neighborhoods have the highest risk? 

 SELECT
	Neighbourhood, 
    COUNT(*) as total_appointments, 
    ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) as no_show_rate, 
    RANK() OVER (ORDER BY ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) DESC) as risk_rank
	FROM medicalappointment
    GROUP BY Neighbourhood
    HAVING COUNT(*) >= 50
    ORDER BY no_show_rate DESC
    LIMIT 15;


-- Patient-level risk scoring

SELECT
	patientid, 
    appointmentid, 
    appointmentday, 
    no_show, 
    COUNT(*) OVER (
		PARTITION BY PatientID
        ORDER BY AppointmentDay
        ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) as prior_appointments,
	SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) OVER 
		(PARTITION BY PatientID
        ORDER BY AppointmentDay
        ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) as prior_no_shows
	FROM medicalappointment
    ORDER BY patientid, appointmentday;


-- 
SELECT * FROM medicalappointment;

CREATE VIEW v_appointment_risk AS
WITH patient_history AS (
    SELECT
        PatientId,
        AppointmentID,
        AppointmentDay,
        Neighbourhood,
        lead_time_days,
        sms_received,
        Scholarship,
        no_show,
        COUNT(*) OVER (
            PARTITION BY PatientId 
            ORDER BY AppointmentDay 
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prior_appointments,
        SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) OVER (
            PARTITION BY PatientId 
            ORDER BY AppointmentDay 
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prior_no_shows
    FROM medicalappointment
)
SELECT
    PatientId,
    AppointmentID,
    AppointmentDay,
    Neighbourhood,
    lead_time_days,
    prior_appointments,
    prior_no_shows,
    ROUND(prior_no_shows / NULLIF(prior_appointments, 0), 2) AS prior_no_show_rate,
    CASE
        WHEN prior_appointments = 0 THEN 'New Patient - Monitor'
        WHEN (prior_no_shows / NULLIF(prior_appointments, 0)) >= 0.5 
             OR lead_time_days >= 8 THEN 'High Risk'
        WHEN (prior_no_shows / NULLIF(prior_appointments, 0)) >= 0.2 
             OR lead_time_days BETWEEN 4 AND 7 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_tier
FROM patient_history;

SELECT
* 
FROM v_appointment_risk
WHERE risk_tier = 'High Risk'
ORDER BY AppointmentDay;

SELECT * FROM medicalappointment;
SELECT * FROM v_appointment_risk;
--
















