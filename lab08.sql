/*
Name:	Rayon Pinnock
Date:	1/29/2017
Coures:	Querying with Transact-SQL
	
Lab 8 – Grouping Sets and Pivoting Data
Overview
In this lab, you will use grouping sets and the PIVOT operator to summarize data in the AdventureWorksLT database.

Challenge 1: Retrieve Regional Sales Totals

Adventure Works sells products to customers in multiple country/regions around the world.
1. Retrieve totals for country/region and state/province Tip: Review the documentation for GROUP BY in the Transact-SQL Language Reference.
An existing report uses the following query to return total sales revenue grouped by country/region and state/province.

SELECT a.CountryRegion, a.StateProvince, SUM(soh.TotalDue) AS Revenue
FROM SalesLT.Address AS a
JOIN SalesLT.CustomerAddress AS ca ON a.AddressID = ca.AddressID
JOIN SalesLT.Customer AS c ON ca.CustomerID = c.CustomerID
JOIN SalesLT.SalesOrderHeader as soh ON c.CustomerID = soh.CustomerID
GROUP BY a.CountryRegion, a.StateProvince
ORDER BY a.CountryRegion, a.StateProvince;

You have been asked to modify this query so that the results include a grand total for all sales revenue and a subtotal for each country/region
in addition to the state/province subtotals that are already returned.
*/
SELECT a.CountryRegion, a.StateProvince, SUM(soh.TotalDue) AS Revenue
FROM SalesLT.Address AS a
JOIN SalesLT.CustomerAddress AS ca ON a.AddressID = ca.AddressID
JOIN SalesLT.Customer AS c ON ca.CustomerID = c.CustomerID
JOIN SalesLT.SalesOrderHeader as soh ON c.CustomerID = soh.CustomerID
GROUP BY ROLLUP(a.CountryRegion, a.StateProvince)
ORDER BY a.CountryRegion, a.StateProvince;
GO

/*
2. Indicate the grouping level in the results 
Modify your query to include a column named Level that indicates at which level in the total, country/region, and state/province hierarchy the 
revenue figure in the row is aggregated. For example, the grand total row should contain the value ‘Total’, the row showing the subtotal for
United States should contain the value ‘United States Subtotal’, and the row showing the subtotal for California should contain the value
‘California Subtotal’.
*/
SELECT  CASE GROUPING_ID(a.CountryRegion) + GROUPING_ID(a.StateProvince) 
			WHEN 2 THEN 'Total'
			WHEN 1 THEN a.CountryRegion + ' Subtotal'
			ELSE a.StateProvince + ' Subtotal'
		END AS [Level], a.CountryRegion, a.StateProvince, SUM(soh.TotalDue) AS Revenue
FROM SalesLT.Address AS a
JOIN SalesLT.CustomerAddress AS ca ON a.AddressID = ca.AddressID
JOIN SalesLT.Customer AS c ON ca.CustomerID = c.CustomerID
JOIN SalesLT.SalesOrderHeader as soh ON c.CustomerID = soh.CustomerID
GROUP BY ROLLUP(a.CountryRegion, a.StateProvince)
ORDER BY a.CountryRegion, a.StateProvince;
GO

/*
3. Add a grouping level for cities
Extend your query to include a grouping for individual cities.
*/
SELECT	CASE t.[Level]
			WHEN 0 THEN t.City + ' Subtotal'
			WHEN 1 THEN t.StateProvince + ' Subtotal'
			WHEN 2 THEN t.CountryRegion + ' Subtotal'
			WHEN 3 THEN 'Total'
		END AS [Level],
		t.CountryRegion, t.StateProvince, t.City, t.Revenue
FROM (
	SELECT  GROUPING_ID(a.CountryRegion) + GROUPING_ID(a.StateProvince) + GROUPING_ID(A.City)  AS [Level], 
			a.CountryRegion, 
			a.StateProvince, 
			a.City,
			SUM(soh.TotalDue) AS Revenue
	FROM SalesLT.Address AS a
	JOIN SalesLT.CustomerAddress AS ca ON a.AddressID = ca.AddressID
	JOIN SalesLT.Customer AS c ON ca.CustomerID = c.CustomerID
	JOIN SalesLT.SalesOrderHeader as soh ON c.CustomerID = soh.CustomerID
	GROUP BY ROLLUP(a.CountryRegion, a.StateProvince, a.City)
	) AS t
ORDER BY t.CountryRegion, t.StateProvince, t.City;
GO

/*
Challenge 2: Retrieve Customer Sales Revenue by Category

Adventure Works products are grouped into categories, which in turn have parent categories 
(defined in the SalesLT.vGetAllCategories view). Adventure Works customers are retail companies,
and they may place orders for products of any category. The revenue for each product in an order 
is recorded as the LineTotal value in the SalesLT.SalesOrderDetail table.

1. Retrieve customer sales revenue for each parent category 
Retrieve a list of customer company names together with their total revenue for each parent 
category in Accessories, Bikes, Clothing, and Components.
*/
SELECT pvt.CompanyName, pvt.Accessories, pvt.Bikes, pvt.Clothing, pvt.Components
FROM (
	SELECT cu.CompanyName, cat.ParentProductCategoryName, sod.LineTotal
	FROM SalesLT.SalesOrderDetail sod
	INNER JOIN SalesLT.SalesOrderHeader soh on sod.SalesOrderID = soh.SalesOrderID
	INNER JOIN SalesLT.Product p on sod.ProductID = p.ProductID
	INNER JOIN SalesLT.vGetAllCategories cat on p.ProductCategoryID = cat.ProductCategoryID
	INNER JOIN SalesLT.Customer cu on soh.CustomerID = cu.CustomerID
) AS t
PIVOT (
	SUM (t.LineTotal)
	FOR t.ParentProductCategoryName IN ([Accessories], [Bikes], [Clothing], [Components])
) AS pvt
