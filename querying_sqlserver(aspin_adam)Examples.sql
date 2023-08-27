-- count the number of cars sold per country and(12.1)
--the total car sales for all vehicles
SELECT CO.CountryName, COUNT(SD.StockID) AS CarsSold,
(SELECT COUNT(SalesDetailsID) FROM Data.SalesDetails) AS SalesTotal
FROM Data.SalesDetails SD
INNER JOIN Data.Sales AS SA ON SA.SalesID = SD.SalesID
INNER JOIN DATA.Customer CU ON SA.CustomerID = CU.CustomerID
INNER JOIN Data.Country CO ON CU.Country = CO.CountryISO2
GROUP BY CO.CountryName

-----------------------------------------percentage of the total sales AND Sales Ratio(12.2)-----------------------------------------

SELECT MK.MakeName,
SUM(SD.SalePrice) AS SalePrice,
FORMAT(SUM(SD.SalePrice) / (SELECT SUM(SalePrice)
--Here we use 'FORMAT' to format the result as a percentage
FROM Data.SalesDetails), '#0.00%')  AS SalesRtio
FROM Data.Make AS MK
INNER JOIN Data.Model AS MD ON MK.MakeID=MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
GROUP BY MK.MakeName

--Note: It is vital to remember that the two queries are--completely independent of each other. This is why the--SalePrice field has an alias in the “main” query but does--not need an alias in the subquery

--------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------Using SubQuery to filter Data-----------------------------------------
--12.3)some colors of car sell better than others?

select ST.ModelID, ST.Color AS COLOR 
from Data.Stock as ST
INNER JOIN Data.SalesDetails AS SD
ON ST.StockCode = SD.StockID
WHERE SD.SalePrice = (SELECT MAX(SalePrice) FROM Data.SalesDetails)

--subquery:finds the sale price for the most expensive vehicles sold.
--main query: Uses The subquery AS filter criterion To return the car color.

--------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------Using SubQuery AS PART OF CALCULATIONS-----------------------------------------
--(12.4)see a list of all vehicles whose repair cost is more than three times the average repair cost

SELECT DMK.MakeName, MD.ModelName, ST.RepairsCost
FROM Data.Make AS DMK
INNER JOIN Data.Model AS MD 
ON DMK.MakeID=MD.MakeID
INNER JOIN Data.Stock AS ST
ON ST.ModelID=MD.ModelID
WHERE ST.RepairsCost > 3 * (SELECT AVG(RepairsCost) FROM Data.Stock)
--THE RECULT OF THE SUBQUERY THAT WILL SELECT THE AVERAGE REPAIRCOST WILL BE 1533.14 AFTER *3 = 4599.2
--THE MAIN QUERY WILL SELECT filter criterion To return the cars THAT MATCH THIS CONDITION 
--WHY WE CALL THE SAME TABLE TWICE IN THE MAIN AND SUBQUERY? 
--The reason is that you are looking at the data in two different ways:
--The outer query: Looks at the data at a detailed level, where each record is processed individually.
--The subquery: Looks at the whole table to calculate the average repair cost for all records in the table.


--------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------Filtering Using Multiple SubQueries-----------------------------------------
--(12.5)all sales in which repair costs are within 10 percent of the average repair cost for all stock.

SELECT DMK.MakeName, MD.ModelName, ST.Cost, ST.RepairsCost 
FROM Data.Make AS DMK
INNER JOIN Data.Model AS MD 
ON DMK.MakeID=MD.MakeID
INNER JOIN Data.Stock AS ST
ON ST.ModelID=MD.ModelID
WHERE ST.RepairsCost BETWEEN (SELECT AVG(RepairsCost) FROM Data.Stock) * 0.9 AND (SELECT AVG(RepairsCost) FROM Data.Stock) * 1.1

--Remember that when using the BETWEEN … AND--technique, you must always begin with the lower--threshold (90 percent in this example) and end with the--higher threshold (110 percent in this example).
--In cases like these, you have to repeat the subquery // WE CAN SOLVE THIS USING CTE WE'LL TALK ABOUT IT...

--12.6











































































































































































































































































































































