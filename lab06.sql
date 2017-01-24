/*
Name:		Rayon Pinnock
Course:		Querying with Transact-SQL
Lab 6:		Using Subqueries and APPLY

Challenge 1: Retrieve Product Price Information
Adventure Works products each have a standard cost price that indicates the cost of manufacturing the
product, and a list price that indicates the recommended selling price for the product. This data is
stored in the SalesLT.Product table. Whenever a product is ordered, the actual unit price at which it
was sold is also recorded in the SalesLT.SalesOrderDetail table. You must use subqueries to compare
the cost and list prices for each product with the unit prices charged in each sale.


1. Retrieve products whose list price is higher than the average unit price
Retrieve the product ID, name, and list price for each product where the list price is higher than
the average unit price for all products that have been sold.
*/
SELECT	p.ProductID, p.[Name], p.ListPrice
FROM	SalesLT.Product AS p
WHERE	p.ListPrice > (	SELECT	AVG(sod.UnitPrice) AS AvgUnitPrice
						FROM	SalesLT.SalesOrderDetail AS sod);
GO

/*
2. Retrieve Products with a list price of $100 or more that have been sold for less than $100
Retrieve the product ID, name, and list price for each product where the list price is $100 or more,
and the product has been sold for less than $100.
*/
SELECT	p.ProductID, p.[Name], p.ListPrice
FROM	SalesLT.Product AS p 
WHERE	p.ListPrice >= 100
	AND EXISTS(	SELECT 1 FROM SalesLT.SalesOrderDetail AS sod 
				WHERE sod.ProductID = p.ProductID
					AND sod.UnitPrice < 100);
GO

/*
3. Retrieve the cost, list price, and average selling price for each product
Retrieve the product ID, name, cost, and list price for each product along with
the average unit price for which that product has been sold.
*/
SELECT		p.ProductID, p.[Name], p.StandardCost, p.ListPrice, AVG(sod.UnitPrice) AS AvgUnitPrice
FROM		SalesLT.Product AS p
INNER JOIN	SalesLT.SalesOrderDetail AS sod on sod.ProductID = p.ProductID
GROUP BY	p.ProductID, p.[Name], p.StandardCost, p.ListPrice;
GO

/*
4. Retrieve products that have an average selling price that is lower than the cost
Filter your previous query to include only products where the cost price is higher than the average selling price.
*/
SELECT		p.ProductID, p.[Name], p.StandardCost, AVG(sod.UnitPrice)  AS AvgUnitPrice
FROM		SalesLT.Product AS p
INNER JOIN	SalesLT.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
GROUP BY	p.ProductID, p.[Name], p.StandardCost
HAVING		p.StandardCost > AVG(sod.UnitPrice);
GO

/*
Challenge 2: Retrieve Customer Information
The AdventureWorksLT database includes a table-valued user-defined function named dbo.ufnGetCustomerInformation.
You must use this function to retrieve details of customers based on customer ID values retrieved from tables in
the database. 

1. Retrieve customer information for all sales orders
Retrieve the sales order ID, customer ID, first name, last name, and total due for all sales orders from the
SalesLT.SalesOrderHeader table and the dbo.ufnGetCustomerInformation function.
*/
SELECT		soh.SalesOrderID, soh.CustomerID, c.FirstName, c.LastName, soh.TotalDue
FROM		SalesLT.SalesOrderHeader AS soh
CROSS APPLY	dbo.ufnGetCustomerInformation(soh.CustomerID) AS c;
GO

/*
2. Retrieve customer address information
Retrieve the customer ID, first name, last name, address line 1 and city for all customers from the
SalesLT.Address and SalesLT.CustomerAddress tables, and the dbo.ufnGetCustomerInformation function.
*/
SELECT		ca.CustomerID, c.FirstName, c.LastName, a.AddressLine1, a.City
FROM		SalesLT.CustomerAddress AS ca
INNER JOIN	SalesLT.Address AS a on ca.AddressID = a.AddressID
CROSS APPLY	dbo.ufnGetCustomerInformation(ca.CustomerID) AS c;
GO
