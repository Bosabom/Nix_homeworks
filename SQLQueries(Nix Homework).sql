-- 1 

SELECT ProductName FROM dbo.Products
WHERE UnitPrice = (SELECT MAX(UnitPrice) FROM dbo.Products
WHERE CategoryID=1)

-- 2
SELECT ShipCity
FROM dbo.Orders
GROUP BY OrderDate, ShippedDate, ShipCity
HAVING DATEDIFF(DAY,OrderDate,ShippedDate) > 10

-- 3
SELECT ContactName
FROM dbo.Customers INNER JOIN dbo.Orders ON Customers.CustomerID=Orders.CustomerID
WHERE ShippedDate IS NULL;

-- 4
SELECT MAX(EmployeesServices.[Num of customers]) as ServedCustomers
FROM(
	SELECT	
		EmployeeID, 
		COUNT(CustomerID) 'Num of customers'	
	FROM dbo.Orders	
	GROUP BY EmployeeID) EmployeesServices

-- 5
SELECT COUNT(ShipCity) as num_of_French_cities
FROM dbo.Orders
WHERE EmployeeID = 1 AND YEAR(ShippedDate) = 1997 AND ShipCountry LIKE 'France' 
GROUP BY ShipCountry;

-- 6
SELECT DISTINCT Country FROM dbo.Customers
INNER JOIN dbo.Orders ON dbo.Customers.CustomerID =dbo.Orders.CustomerID
GROUP BY ShipCountry,ShipCity,Country
HAVING Count(OrderID) > 2

-- 7

SELECT ProductName
FROM dbo.Products INNER JOIN 
dbo.[Order Details] ON dbo.Products.ProductID = dbo.[Order Details].ProductID
GROUP BY ProductName
HAVING SUM(Quantity)<1000

-- 8

SELECT DISTINCT 
	ContactName
FROM dbo.Customers INNER JOIN dbo.Orders ON dbo.Customers.CustomerID = dbo.Orders.CustomerID
WHERE City <> ShipCity

-- 9
--#ÑustomersWithFaxAndOrdersByYear
SELECT 
OrderID,dbo.Customers.CustomerID 
INTO #ÑustomersWithFaxAndOrdersByYear
FROM dbo.Orders INNER JOIN dbo.Customers ON Customers.CustomerID=Orders.CustomerID
WHERE YEAR(OrderDate)=1997 AND Fax IS NOT NULL


--#OrdersDetailProductsCategories

SELECT
	[Order Details].OrderID,
	Products.ProductID,
	Products.CategoryID,
	Categories.CategoryName
INTO #OrdersDetailProductsCategories
FROM Products
INNER JOIN Categories
	ON Products.CategoryID = Categories.CategoryID
INNER JOIN [Order Details]
	ON [Order Details].ProductID = Products.ProductID

--
DECLARE @TheHiestNumOfOrdersQuantity int;

SET @TheHiestNumOfOrdersQuantity = (SELECT
	MAX(res.count)
FROM(
	SELECT
	#OrdersDetailProductsCategories.CategoryID,
	COUNT(#OrdersDetailProductsCategories.CategoryID) 'count'
	FROM #ÑustomersWithFaxAndOrdersByYear INNER JOIN #OrdersDetailProductsCategories ON #ÑustomersWithFaxAndOrdersByYear.OrderID = #OrdersDetailProductsCategories.OrderID

GROUP BY CategoryID, CategoryName) res)

--
SELECT
	CategoryName
FROM #ÑustomersWithFaxAndOrdersByYear INNER JOIN #OrdersDetailProductsCategories 
ON #ÑustomersWithFaxAndOrdersByYear.OrderID = #OrdersDetailProductsCategories.OrderID
GROUP BY CategoryID, CategoryName
HAVING COUNT(CategoryID) = @TheHiestNumOfOrdersQuantity


-- 10

SELECT FirstName,LastName,SUM(dbo.[Order Details].Quantity) as quantity FROM dbo.Employees
INNER JOIN dbo.Orders ON dbo.Employees.EmployeeID=dbo.Orders.EmployeeID
INNER JOIN dbo.[Order Details] ON dbo.[Order Details].OrderID=dbo.Orders.OrderID
WHERE YEAR(dbo.Orders.ShippedDate)=1996 AND MONTH(dbo.Orders.ShippedDate) BETWEEN 9 AND 11
GROUP BY Employees.FirstName,Employees.LastName
