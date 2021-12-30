--Importing file
SELECT *
FROM MarketingCam..MarketCamp
ORDER BY Year_Birth DESC;


--Describe Table
--EXEC sp_help 'MarketingCampaign..MarketingCampaign';
SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'MarketCamp';


--Creating a new field(Column) called Age (ie Age of each Customer)
--Taking today as 2014
SELECT (2014-Year_Birth) AS Age, *
FROM MarketingCam..MarketCamp
ORDER BY Age;


--Classifying the Education into Undergradute and Graduate
UPDATE MarketingCam..MarketCamp
SET  Education = 'Graduate'
WHERE Education IN ('Graduation', 'PhD', 'Master');

UPDATE MarketingCam..MarketCamp
SET  Education = 'Undergraduate'
WHERE Education IN ('2n Cycle', 'Basic');


--Classifying the Marital_Status into Single and Married
UPDATE MarketingCam..MarketCamp
SET  Marital_Status = 'Single'
WHERE Marital_Status IN ('Divorced', 'Widow', 'Absurd', 'Alone', 'YOLO');

UPDATE MarketingCam..MarketCamp
SET  Marital_Status = 'Married'
WHERE Marital_Status = 'Together';


--Creating a field called Children (NOTE : Children is the sum of the kids and teenages)
SELECT Kidhome, Teenhome, (CAST(Kidhome AS INT) + CAST(Teenhome AS INT)) AS Children
FROM MarketingCam..MarketCamp;


--Creating a TEMP TABLE for the above result
--Getting Month Difference Between the EntryDate and Today's date (ASSUMING TODAY IS 2014-07-01)
--NOTE : 2014-07-01 is been used inplace of the current date simply because the max date is 06-2014 
DROP TABLE IF EXISTS MarketAnalysisTable
CREATE TABLE MarketAnalysisTable(
ID NUMERIC,
Age NUMERIC,
Education VARCHAR(255),
Marital_Status VARCHAR(255),
Income NUMERIC,
TotalMonths NUMERIC,
Children NUMERIC,
TotalSpent NUMERIC,
AcceptedCmp NUMERIC,
Web NUMERIC,
Catalogs NUMERIC,
Store NUMERIC
)
Insert into MarketAnalysisTable
	SELECT CAST(ID AS NUMERIC) AS ID,
(2021-Year_Birth) AS Age, Education, Marital_Status, CAST(Income AS INT) AS Income,
DATEDIFF(MONTH, CONVERT(date, Dt_Customer, 105), '2014-07-01') AS TotalMonths,
(CAST(Kidhome AS INT) + CAST(Teenhome AS INT)) AS Children,
(CAST(MntWines AS INT)+CAST(MntFruits AS INT)+CAST(MntMeatProducts AS INT)+
CAST(MntFishProducts AS INT)+CAST(MntSweetProducts AS INT)+CAST(MntGoldProds AS INT)) AS TotalSpent,
(CAST(AcceptedCmp1 AS INT) + CAST(AcceptedCmp2 AS INT) + CAST(AcceptedCmp3 AS INT) + CAST(AcceptedCmp4 AS INT) +
CAST(AcceptedCmp5 AS INT)) AS AcceptedCmp, CAST(NumWebPurchases AS INT) AS Web, 
CAST(NumCatalogPurchases AS INT) AS Catalogs, CAST(NumStorePurchases AS INT) AS Store
FROM MarketingCam..MarketCamp
WHERE Income <> 0 AND (2021-Year_Birth) < 80
ORDER BY Age, Income;

SELECT *
FROM MarketAnalysisTable
ORDER BY Age;


--Removing Duplicates
WITH RowNumberCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ID,
				 Age,
				 Education,
				 Marital_Status,
	             Income,
				 TotalMonths, 
				 Children,
				 TotalSpent,
				 AcceptedCmp
				 ORDER BY
					Income
					) RowNumber
FROM MarketAnalysisTable
)
DELETE
FROM RowNumberCTE
WHERE RowNumber > 1;


SELECT *
FROM MarketAnalysisTable
ORDER BY Age;


--Creating Viewws of Clusters by the segments of the customer. 
--Dividing into 4 segment

--Taking old customers as those who have spent over 6 months
--Taking high income customers as those who earn above the mean Income (ie 51,640 )
--Taking high spending as those who spent above the mean of the total amount spent (ie 607) 

--Stegment 1 (Alpha): Old customers with high income and high spending nature.
CREATE VIEW OHH AS
SELECT *
FROM MarketAnalysisTable
WHERE 
	TotalMonths > 6
	AND
	Income >= 51640
	AND
	TotalSpent >= 607;

--Segment 2 (Beta): Old customers with below-average income and a low spending nature
CREATE VIEW OLL AS
SELECT *
FROM MarketAnalysisTable
WHERE 
	TotalMonths > 6
	AND
	Income < 51640
	AND
	TotalSpent < 607;

--Stegment 3 (Gamma): New customers with below-average income and low spending nature.
CREATE VIEW NLL AS
SELECT *
FROM MarketAnalysisTable
WHERE  
	TotalMonths <= 6
	AND
	Income < 51640
	AND
	TotalSpent < 607;

--Segment 4 (Delta): New customers with high income and high spending nature.
CREATE VIEW NHH AS
SELECT *
FROM MarketAnalysisTable
WHERE   
	TotalMonths <= 6
	AND
	Income > 51640
	AND
	TotalSpent > 607;

















