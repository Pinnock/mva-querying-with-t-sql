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

/*
Challenge 2: Updating Products
You have inserted data for a product, but the pricing details are not correct. 
You must now update the records you have previously inserted to reflect the correct pricing. 

1. Update product prices
The sales manager at Adventure Works has mandated a 10% price increase for all products in 
the Bells and Horns category. Update the rows in the SalesLT.Product table for these 
products to increase their price by 10%.
*/
UPDATE SalesLT.Product
SET ListPrice = ListPrice * 1.1
WHERE ProductCategoryID = (
	SELECT pc.ProductCategoryID
	FROM SalesLT.ProductCategory pc 
	WHERE pc.Name = 'Bells and Horns'
);
GO

/*
2. Discontinue products
The new LED lights you inserted in the previous challenge are to replace all previous light products. 
Update the SalesLT.Product table to set the DiscontinuedDate to today’s date for all products in the 
Lights category (Product Category ID 37) other than the LED Lights product you inserted previously.
*/
UPDATE SalesLT.Product
SET DiscontinuedDate = GETDATE()
WHERE ProductCategoryID = 37;
GO

/*
Challenge 3: Deleting Products
The Bells and Horns category has not been successful, and it must be deleted from the database.

1. Delete a product category and its products
Delete the records for the Bells and Horns category and its products. 
You must ensure that you delete the records from the tables in the correct order to 
avoid a foreign-key constraint violation.
*/
DELETE FROM SalesLT.Product
WHERE ProductCategoryID = (
	SELECT ProductCategoryID
	FROM SalesLT.ProductCategory
	WHERE [Name] = 'Bells and Horns'
		AND ProductNumber <> 'LT-l123'
);

DELETE FROM SalesLT.ProductCategory 
WHERE [Name] = 'Bells and Horns'
GO