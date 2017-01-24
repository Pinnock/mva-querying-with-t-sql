/*
Name:		Rayon Pinnock
Course:		Querying with Transact-SQL
Lab 7:		Using Table Expressions

Overview
In this lab, you will use views, temporary tables, variables, table-valued functions, 
derived tables, and common table expressions to retrieve data from the 
AdventureWorksLT database.

Challenge 1: Retrieve Product Information
Adventure Works sells many products that are variants of the same product model. 
You must write queries that retrieve information about these products

1. Retrieve product model descriptions
Retrieve the product ID, product name, product model name, and product model 
summary for each product from the SalesLT.Product table and the 
SalesLT.vProductModelCatalogDescription view.
*/
SELECT	p.ProductID, p.[Name], pm.[Name] AS ProductModelName, pm.Summary AS ProductModelSummary
FROM SalesLT.Product AS p
INNER JOIN	SalesLT.vProductModelCatalogDescription pm ON p.ProductModelID = pm.ProductModelID
ORDER BY p.ProductID;
GO

/*
2. Create a table of distinct colors
Create a table variable and populate it with a list of distinct colors from the
SalesLT.Product table. Then use the table variable to filter a query that 
returns the product ID, name, and color from the SalesLT.Product table so that 
only products with a color listed in the table variable are returned.
*/
DECLARE @tbColors TABLE(Color NVARCHAR(15));

INSERT INTO @tbColors(Color)
SELECT DISTINCT p.Color
FROM SalesLT.Product p;

SELECT	p.ProductID, p.[Name], p.Color
FROM	SalesLT.Product p
WHERE	p.Color IN (SELECT c.Color FROM @tbColors AS c)
ORDER BY P.ProductID;
GO

/*
3. Retrieve product parent categories
The AdventureWorksLT database includes a table-valued function named 
dbo.ufnGetAllCategories, which returns a table of product categories 
(for example ‘Road Bikes’) and parent categories (for example ‘Bikes’). 
Write a query that uses this function to return a list of all products 
including their parent category and category
*/
SELECT p.ProductID, P.ProductNumber, c.ProductCategoryName, c.ParentProductCategoryName
FROM SalesLT.Product p
INNER JOIN dbo.ufnGetAllCategories() AS c ON p.ProductCategoryID = c.ProductCategoryID
ORDER BY p.ProductID;
GO

/*
Challenge 2: Retrieve Customer Sales Revenue
Each Adventure Works customer is a retail company with a named contact. 
You must create queries that return the total revenue for each customer, 
including the company and customer contact names.

1. Retrieve sales revenue by customer and contact
Retrieve a list of customers in the format Company (Contact Name) together 
with the total revenue for that customer. Use a derived table or a common 
table expression to retrieve the details for each sales order, and then 
query the derived table or CTE to aggregate and group the data.
*/

WITH cteSalesOrderTotal (Customer, TotalDue) AS (
	SELECT c.CompanyName + ' (' + c.FirstName + ' ' + c.LastName + ')' AS Customer, soh.TotalDue
	FROM SalesLT.SalesOrderHeader soh
	INNER JOIN SalesLT.Customer AS c ON  soh.CustomerID = c.CustomerID	
)

SELECT sot.Customer, SUM(sot.TotalDue) AS TotalRevenue
FROM cteSalesOrderTotal AS sot
GROUP BY sot.Customer
ORDER BY sot.Customer;
GO
