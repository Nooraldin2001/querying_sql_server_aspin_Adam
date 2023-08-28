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

--Note: It is vital to remember that the two queries are
--completely independent of each other. This is why the
--SalePrice field has an alias in the “main” query but does
--not need an alias in the subquery

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

--Remember that when using the BETWEEN … AND
--technique, you must always begin with the lower
--threshold (90 percent in this example) and end with the
--higher threshold (110 percent in this example).
--In cases like these, you have to repeat the subquery // WE CAN SOLVE THIS USING CTE WE'LL TALK ABOUT IT...


--------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------Filtering On Aggregated output Using A second Aggeration-----------------------------------------
--(12.6) list of the average sale price of all makes whose average sale price is over twice the average sale price

SELECT MK.MakeName, AVG(SD.SalePrice) AS AverageUpperSalesPrice
FROM Data.Make as MK 
INNER JOIN Data.Model AS MD ON MK.MakeID = MD.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
GROUP BY MK.MakeName
HAVING AVG(SD.SalePrice) > 2 * (SELECT AVG(SalePrice) FROM Data.SalesDetails)

--NOTE: That the HAVING clause operates at the level of the aggregation NOT the level of individual records


--------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------USING MULTIPLE RESULTS FORM SUBQUERY TO FILTER DATA-----------------------------------------
--(12.7) find all the sales for the top five bestselling makes?

SELECT MK.MakeName AS NAME, SD.SalePrice AS Sales_Price
FROM Data.Make AS MK 
INNER JOIN Data.Model AS MD ON MD.MakeID = MK.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails AS SD ON SD.StockID = ST.StockCode 
WHERE MakeName IN (SELECT TOP(5) MK.MakeName AS NAME
					FROM Data.Make AS MK 
					INNER JOIN Data.Model AS MD ON MD.MakeID = MK.MakeID
					INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
					INNER JOIN Data.SalesDetails AS SD ON SD.StockID = ST.StockCode
					INNER JOIN Data.Sales SA ON SA.SalesID = SD.SalesID
					GROUP BY MK.MakeName
					ORDER BY SUM(SA.TotalSalePrice) DESC)
--Note: When a subquery returns more than one record you--must use the IN operator in the WHERE clause. If you do
--not, you will get an error message.
--When solving complex analytical problems like this one,--you may well find yourself beginning with the subquery--and then moving on to the outer query.


--------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------COMPLEX AGGREGATED SUBQUERIES-----------------------------------------
--(12.8) how many cars have been sold for the top three bestselling makes?

SELECT MK.MakeName AS Car_NAME, COUNT(MK.MakeName) AS Number_Of_Sold_Cars
FROM Data.Make AS MK 
INNER JOIN Data.Model AS MD ON MD.MakeID = MK.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN Data.SalesDetails AS SD ON SD.StockID = ST.StockCode 
WHERE MakeName IN (SELECT TOP(3) MK.MakeName AS NAME
					FROM Data.Make AS MK 
					INNER JOIN Data.Model AS MD ON MD.MakeID = MK.MakeID
					INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
					INNER JOIN Data.SalesDetails AS SD ON SD.StockID = ST.StockCode
					INNER JOIN Data.Sales SA ON SA.SalesID = SD.SalesID
					GROUP BY MK.MakeName
					ORDER BY COUNT(MK.MakeName) DESC)
GROUP BY MK.MakeName
ORDER BY COUNT(MK.MakeName) DESC


--------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------USING A SUBQUERY TO FILTER PERCENTAGE OF DATASET-----------------------------------------
--(12.9) find all colors for cars sold for the least profitable 5 percent of sales?

SELECT DISTINCT ST.Color AS Car_Color
FROM Data.Stock AS ST
INNER JOIN DATA.SalesDetails SD ON ST.StockCode = SD.StockID
WHERE SD.SalesID IN (
					SELECT TOP 5 PERCENT SalesID
					FROM Data.Stock AS ST
					INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
					--calculates the net profit per car sold
					ORDER BY (SD.SalePrice - (Cost + ISNULL(RepairsCost, 0) + PartsCost + TransportInCost)) ASC 
					)
--Adding the TOP 5PERCENT to the SELECT clause ensures that only the initial 5 percent of sales records are returned.


--------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------NESTED SUBQUERIES-----------------------------------------
--(12.9) find the top five vehicles sold by value in the color of the most expensive car sold?

SELECT TOP 5  MK.MakeName AS NAME,MD.ModelName AS MODEL_NAME, SD.SalePrice AS PRICE 
FROM Data.Make AS MK 
INNER JOIN DATA.Model AS MD ON MD.MakeID = MK.MakeID
INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
INNER JOIN DATA.SalesDetails AS SD ON ST.StockCode = SD.StockID
INNER JOIN Data.Sales AS DSS ON DSS.SalesID = SD.SalesID
WHERE Color IN (
					SELECT ST.Color
					FROM Data.Model MD 
					INNER JOIN Data.Stock AS ST ON ST.ModelID = MD.ModelID
					INNER JOIN Data.SalesDetails SD ON ST.StockCode = SD.StockID
					WHERE SD.SalePrice =
										(
										--Joins the Sales and SalesDetails tables and returns                                        --the highest sale price for a vehicle sold.
										SELECT MAX(SD.SalePrice)
										FROM Data.SalesDetails AS SD
										INNER JOIN Data.Sales AS DSS ON DSS.SalesID = SD.SalesID
										)
					)
ORDER BY SD.SalePrice DESC


--There is a theoretical limit of 32 levels of nested--subqueries in SQL Server. In practice, however, it is rare--when you need to use more than 3 or 4 levels, so it is--unlikely that you will hit the limit.


--12.11























































































































































































































































































































