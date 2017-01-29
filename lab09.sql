/*
Name:	Rayon Pinnock
Date:	1/29/2017
Course:	Querying with Transact-SQL

Lab 9 – Modifying Data

Overview
In this lab, you will insert, update, and delete data in the AdventureWorksLT database.

Challenge 1: Inserting Products
Each Adventure Works product is stored in the SalesLT.Product table, and each product has a unique ProductID identifier, 
which is implemented as an IDENTITY column in the SalesLT.Product table. Products are organized into categories, which 
are defined in the SalesLT.ProductCategory table. The products and product category records are related by a common 
ProductCategoryID identifier, which is an IDENTITY column in the SalesLT.ProductCategory table. 

1. Insert a product
Adventure Works has started selling the following new product. Insert it into the SalesLT.Product table, 
using default or NULL values for unspecified columns:
Name			ProductNumber	StandardCost	ListPrice	ProductCategoryID	SellStartDate
LED Lights		LT-L123			2.56			12.99		37					<Today>

After you have inserted the product, run a query to determine the ProductID that was generated. 
Then run a query to view the row for the product in the SalesLT.Product table.
*/

INSERT INTO SalesLT.Product(Name, ProductNumber,StandardCost, ListPrice, ProductCategoryID, SellStartDate)
VALUES ('LED Lights', 'LT-l123', 2.56, 12.99, 37, GETDATE());

SELECT SCOPE_IDENTITY() AS ProductID;

SELECT * FROM SalesLT.Product p WHERE p.ProductID = SCOPE_IDENTITY();
GO;

/*
2. Insert a new category with two products
Adventure Works is adding a product category for ‘Bells and Horns’ to its catalog. The parent category for
the new category is 4 (Accessories). This new category includes the following two new products:

Name			ProductNumber	StandardCost	ListPrice	ProductCategoryID					SellStartDate
Bicycle Bell	BB-RING			2.47			4.99		<The new ID for Bells and Horns>	<Today>
Bicycle Horn	BB-PARP			1.29			3.75		<The new ID forBells and Horns>		<Today>

Write a query to insert the new product category, and then insert the two new products with the appropriate ProductCategoryID value.
After you have inserted the products, query the SalesLT.Product and SalesLT.ProductCategory tables to verify that the data has been inserted.
*/
DECLARE @productCategoryID INT

INSERT INTO SalesLT.ProductCategory(Name, ParentProductCategoryID, ModifiedDate)
VALUES('Bells and Horns', 4, GETDATE());

SELECT @productCategoryID = SCOPE_IDENTITY();

INSERT INTO SalesLT.Product(Name, ProductNumber, StandardCost, ListPrice, ProductCategoryID, SellStartDate)
VALUES 
	('Bicycle Bell', 'BB-RING', 2.47, 4.99, @productCategoryID, GETDATE()),
	('Bicycle Horn', 'BB-PARP', 1.29, 3.75, @productCategoryID, GETDATE());

SELECT * FROM SalesLT.ProductCategory WHERE ProductCategoryID = @productCategoryID;
SELECT * FROM SalesLT.Product WHERE ProductCategoryID = @productCategoryID;
GO