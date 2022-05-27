--Q1
--Finds the best performing country
SELECT 

Sales.Salesterritory.CountryRegionCode as Country,
Person.CountryRegion.Name, 
ROUND(SUM(salesYTD),2) as Total_Sales
from Sales.Salesterritory
inner join Person.CountryRegion 
ON Person.CountryRegion.CountryRegionCode = Sales.Salesterritory.CountryRegionCode
GROUP BY Sales.Salesterritory.CountryRegionCode, Person.CountryRegion.Name
ORDER BY Total_Sales desc;

--US Regional Sales
SELECT 
NAME as Region,
--round(sum(salesYTD),2) as Total_Sales,
Sales.SalesTerritory.SalesYTD,
Sales.SalesTerritory.SalesLastYear
FROM Sales.Salesterritory
WHERE CountryRegionCode = 'US'



--Q2 Identify the three most important cities. Show the breakdown of top-level product categories against city.
SELECT TOP(3) FIN.City,DER.Name AS ProductCatergory,FIN.Sales 
FROM 
	(SELECT G.City, MAX(G.VALUE) AS Sales 
FROM 
	(SELECT f.City,D.Name,SUM(LineTotal) VALUE 
FROM Sales.SalesOrderDetail AS A 
JOIN Production.Product AS B ON(A.ProductID=B.ProductID) 
JOIN Production.ProductSubcategory AS D ON (D.ProductSubcategoryID=B.ProductSubcategoryID) 
JOIN Production.ProductCategory AS E ON (D.ProductCategoryID=E.ProductCategoryID) 
JOIN Sales.SalesOrderHeader AS C ON (A.SalesOrderID=C.SalesOrderID) 
JOIN Person.Address AS F ON (F.AddressID=C.ShipToAddressID) GROUP BY F.City ,D.Name)AS G GROUP BY G.City ) AS FIN 
INNER JOIN 
	(SELECT f.City,D.Name,SUM(LineTotal) VALUE FROM Sales.SalesOrderDetail AS A 
JOIN Production.Product AS B ON(A.ProductID=B.ProductID) 
JOIN Production.ProductSubcategory AS D ON (D.ProductSubcategoryID=B.ProductSubcategoryID) 
JOIN Production.ProductCategory AS E ON (D.ProductCategoryID=E.ProductCategoryID) 
JOIN Sales.SalesOrderHeader AS C ON (A.SalesOrderID=C.SalesOrderID) 
JOIN Person.Address AS F ON (F.AddressID=C.ShipToAddressID) 
GROUP BY F.City ,D.Name) AS DER 
ON (FIN.City=DER.City AND FIN.Sales=DER.VALUE ) 
ORDER BY VALUE DESC

--Q3
--What is the Relationship between Country and Revenue?
 SELECT Person.CountryRegion.CountryRegionCode as Country , CONCAT('$',round(sum(SalesYTD),2)) as  CurrentYearRevenue, CONCAT('$',round(sum(SalesLastYear),2)) as LastYearRevenue
 FROM  Sales.SalesTerritory
 join Person.CountryRegion
 ON Sales.SalesTerritory.CountryRegionCode=Person.CountryRegion.CountryRegionCode
 GROUP BY Person.CountryRegion.CountryRegionCode
 ORDER BY CurrentYearRevenue desc

--Q4
-- 4. What is the relationship between sick leave and Job Title?

-- Focuses on Production Technician Job Title
SELECT JobTitle,
SickLeaveHours,
HireDate, 
OrganizationLevel
FROM HumanResources.Employee
WHERE JobTitle LIKE 'Production Technician%'
ORDER BY JobTitle desc;

--Summarizes by GroupName
SELECT  AVG(SickLeaveHours)as SickLeaveHours_Available ,HumanResources.vEmployeeDepartment.GroupName
FROM HumanResources.Employee
join HumanResources.vEmployeeDepartment
ON HumanResources.Employee.BusinessEntityID=HumanResources.vEmployeeDepartment.BusinessEntityID
GROUP BY HumanResources.vEmployeeDepartment.GroupName




--Q5
-- 5. What is the relationship between store trading duration and revenue?

 SELECT YearOpened,avg(AnnualRevenue) as AnnualRevenue,
 datepart(year,(select current_timestamp))- (YearOpened)-21 as YearsTrading
 FROM Sales.vStoreWithDemographics
 GROUP BY YearOpened
 ORDER BY YearOpened

 -- Includes count of companies by year
 SELECT COUNT(YearOpened), YearOpened,avg(AnnualRevenue) as AnnualRevenue,
 datepart(year,(select current_timestamp))- (YearOpened)-21 as YearsTrading
 FROM Sales.vStoreWithDemographics
 GROUP BY YearOpened
 ORDER BY YearOpened
  
  --or
  --Uses XML link to parse information
;WITH XMLNAMESPACES(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey')
SELECT 
BusinessEntityID,
Name,
Demographics.value('(/StoreSurvey/AnnualRevenue)[1]', 'bigint') as AnnualRevenue,
Demographics.value('(/StoreSurvey/YearOpened)[1]', 'bigint') as YearOpened,
--2022- Demographics.value('(/StoreSurvey/YearOpened)[1]', 'bigint') as YearsTrading,
datepart(year,(select current_timestamp))- Demographics.value('(/StoreSurvey/YearOpened)[1]', 'bigint') as YearsTrading
FROM 
Sales.Store
ORDER BY YearsTrading desc;

--Q6 
--6. What is the relationship between the size of the stores, number of employees and revenue?

SELECT NumberEmployees as Employees ,SquareFeet,AnnualRevenue, (AnnualRevenue/NumberEmployees ) as RevenuePerEmployee
FROM Sales.vStoreWithDemographics
ORDER BY SquareFeet

  --or
  --Uses XML link to parse information

;WITH XMLNAMESPACES(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey')
SELECT 
BusinessEntityID,
Name,
Demographics.value('(/StoreSurvey/AnnualRevenue)[1]', 'bigint') as AnnualRevenue,
Demographics.value('(/StoreSurvey/SquareFeet)[1]', 'bigint') as SquareFeet,
Demographics.value('(/StoreSurvey/NumberEmployees)[1]', 'bigint') as NumberOfEmployees
FROM Sales.Store
ORDER BY SquareFeet desc;

