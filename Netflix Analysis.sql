SELECT  *
FROM PortfolioProject..netflix_userbase



-- Pre-Processing The Data

---- Standardizing column names
BEGIN TRANSACTION;

EXEC sp_rename 'PortfolioProject..netflix_userbase.User ID', 'User_ID', 'COLUMN';
EXEC sp_rename 'PortfolioProject..netflix_userbase.Subscription Type', 'Subscription_Type', 'COLUMN';
EXEC sp_rename 'PortfolioProject..netflix_userbase.Monthly Revenue', 'Monthly_Revenue', 'COLUMN';
EXEC sp_rename 'PortfolioProject..netflix_userbase.Join Date', 'Join_Date', 'COLUMN';
EXEC sp_rename 'PortfolioProject..netflix_userbase.Last Payment Date', 'Last_Payment_Date', 'COLUMN';
EXEC sp_rename 'PortfolioProject..netflix_userbase.Plan Duration', 'Plan_Duration', 'COLUMN';

COMMIT TRANSACTION;


-- Deleting Ambiguous Dates

DELETE FROM PortfolioProject..netflix_userbase
WHERE Join_Date > '2023-12-31'; -- remove dates after December 31, 2023

DELETE FROM PortfolioProject..netflix_userbase
WHERE Join_Date < '2013-01-01'; -- remove dates befor January 01, 2013

select min(Last_Payment_Date), max(Last_Payment_Date)
FROM PortfolioProject..netflix_userbase

DELETE FROM PortfolioProject..netflix_userbase
WHERE Last_Payment_Date > '2023-12-31'; -- remove dates after December 31, 2023

DELETE FROM PortfolioProject..netflix_userbase
WHERE Last_Payment_Date < '2013-01-01'; -- remove dates before January 01, 2013


-- Checking for incosistent date where Join date is greater than last payment date

SELECT  Join_Date, Last_Payment_Date
FROM PortfolioProject..Netflix_Userbase
WHERE Join_Date > Last_Payment_Date

-- Swapping incosistent dates where Join date is greater than last payment date

UPDATE PortfolioProject..Netflix_Userbase
SET
Join_Date = Last_Payment_Date,
Last_Payment_Date = Join_Date
WHERE
Join_Date > Last_Payment_Date


-- Exploring The Dataset
--- Distribution Of Subscription Types

SELECT Subscription_Type, COUNT(Subscription_Type) SubscriptionType_Distribution
FROM PortfolioProject..netflix_userbase
GROUP BY Subscription_Type
ORDER BY SubscriptionType_Distribution DESC


--Demographic Analysis (Country)

SELECT Country, Count(Country) Country_Count
FROM PortfolioProject..netflix_userbase
GROUP BY Country
ORDER BY Country_Count DESC

--Demographic Analysis (Age)

SELECT MIN(Age) Min_Age, Max(Age) Max_Age, 
ROUND(AVG(Age),2) Avg_Age
FROM PortfolioProject..netflix_userbase


-- Analyzing users usage based on Age

SELECT 
    CASE
	WHEN Age < 30 THEN 'Under 30'
	WHEN Age >=30 AND Age < 40 THEN '30-39'
	WHEN Age >=40 AND Age < 52 THEN '40-51'
	ELSE '52+'
	END AS Age_Group,
	COUNT(*) User_Count,
	SUM(Monthly_Revenue) AgeGroup_Revenue
FROM PortfolioProject..netflix_userbase
GROUP BY
     CASE
	WHEN Age < 30 THEN 'Under 30'
	WHEN Age >=30 AND Age < 40 THEN '30-39'
	WHEN Age >=40 AND Age < 52 THEN '40-51'
	ELSE '52+'
	END 
ORDER BY User_Count DESC


--Demographic Analysis (Gender)

SELECT Gender, COUNT(*) AS Gender_Count,
SUM(Monthly_Revenue) Total_Monthly_Revenue
FROM PortfolioProject..netflix_userbase
GROUP BY Gender
ORDER BY Total_Monthly_Revenue DESC


-- Analyzing time duration to understand user retention rates

WITH CTE (User_ID, Join_Date, Last_Payment_Date, Duration_In_Days,
	Duration_In_Months) AS
	(SELECT User_ID, Join_Date, Last_Payment_Date,
	DATEDIFF(DAY, Join_Date, Last_Payment_Date) AS Duration_In_Days,
	DATEDIFF(MONTH, Join_Date, Last_Payment_Date) AS Duration_In_Months
	FROM PortfolioProject..netflix_userbase)

	SELECT MAX(Duration_In_Days) Max_Days, MIN(Duration_In_Days) Min_Days,   
	MAX(Duration_In_Months) Max_Months, MIN(Duration_In_Months) Min_Months
FROM CTE


-- Analyzing time duration between Join_Date and Last_Payment_Date

SELECT 
    CASE 
        WHEN DATEDIFF(MONTH, Join_Date, Last_Payment_Date) < 3 THEN 'Short-term'
        WHEN DATEDIFF(MONTH, Join_Date, Last_Payment_Date) >= 3 AND 
		DATEDIFF(MONTH, Join_Date, Last_Payment_Date) < 6 THEN 'Mid-term'
        ELSE 'Long-term'
    END AS Subscription_Duration,
    COUNT(*) AS User_Count
FROM PortfolioProject..netflix_userbase
GROUP BY 
    CASE 
        WHEN DATEDIFF(MONTH, Join_Date, Last_Payment_Date) < 3 THEN 'Short-term'
        WHEN DATEDIFF(MONTH, Join_Date, Last_Payment_Date) >= 3 AND 
		DATEDIFF(MONTH, Join_Date, Last_Payment_Date) < 6 THEN 'Mid-term'
        ELSE 'Long-term'
    END
ORDER BY User_Count DESC


-- Device used mostly to watch Netflix contents

SELECT Device, COUNT(*) Device_Count
FROM PortfolioProject..netflix_userbase
GROUP BY Device
ORDER BY Device_Count DESC


-- Exploring possible correlation between number of users
---and monthly revenue by country

SELECT Country, COUNT(*) AS User_Count,
SUM(Monthly_Revenue) AS Total_Monthly_Revenue
FROM PortfolioProject..netflix_userbase
GROUP BY Country
ORDER BY Total_Monthly_Revenue DESC;































