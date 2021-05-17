--  1.	Как называется самый дорогой товар из товарной категории №1?

SELECT ProductName FROM dbo.Products
WHERE UnitPrice = (SELECT MAX(UnitPrice) FROM dbo.Products
WHERE CategoryID=1)

-- 2.	В какие города заказы комплектовались более десяти дней?
SELECT ShipCity
FROM dbo.Orders
GROUP BY OrderDate, ShippedDate, ShipCity
HAVING DATEDIFF(DAY,OrderDate,ShippedDate) > 10

-- 3.	Какие покупатели до сих пор ждут отгрузки своих заказов?
SELECT ContactName
FROM dbo.Customers INNER JOIN dbo.Orders ON Customers.CustomerID=Orders.CustomerID
WHERE ShippedDate IS NULL;

-- 4.	Скольких покупателей обслужил продавец, лидирующий по общему количеству заказов?
SELECT MAX(EmployeesServices.[Num of customers]) as ServedCustomers
FROM(
	SELECT	
		EmployeeID, 
		COUNT(CustomerID) 'Num of customers'	
	FROM dbo.Orders	
	GROUP BY EmployeeID) EmployeesServices

-- 5.	Сколько французских городов обслужил продавец №1 в 1997-м?
SELECT COUNT(ShipCity) as num_of_French_cities
FROM dbo.Orders
WHERE EmployeeID = 1 AND YEAR(ShippedDate) = 1997 AND ShipCountry LIKE 'France' 
GROUP BY ShipCountry;

-- 6.	В каких странах есть города, в которые было отправлено больше двух заказов?
SELECT DISTINCT Country FROM dbo.Customers
INNER JOIN dbo.Orders ON dbo.Customers.CustomerID =dbo.Orders.CustomerID
GROUP BY ShipCountry,ShipCity,Country
HAVING Count(OrderID) > 2

-- 7.	Перечислите названия товаров, которые были проданы в количестве менее 1000 штук (quantity)?

SELECT ProductName
FROM dbo.Products INNER JOIN 
dbo.[Order Details] ON dbo.Products.ProductID = dbo.[Order Details].ProductID
GROUP BY ProductName
HAVING SUM(Quantity)<1000

-- 8.	Как зовут покупателей, которые делали заказы с доставкой в другой город (не в тот, в котором они прописаны)?

SELECT DISTINCT 
	ContactName
FROM dbo.Customers INNER JOIN dbo.Orders ON dbo.Customers.CustomerID = dbo.Orders.CustomerID
WHERE City <> ShipCity

-- 9.	Товарами из какой категории в 1997-м году заинтересовалось больше всего компаний, имеющих факс?
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


-- 10.	Сколько всего единиц товаров (то есть, штук – Quantity) продал каждый продавец (имя, фамилия) осенью 1996 года?

SELECT FirstName,LastName,SUM(dbo.[Order Details].Quantity) as quantity FROM dbo.Employees
INNER JOIN dbo.Orders ON dbo.Employees.EmployeeID=dbo.Orders.EmployeeID
INNER JOIN dbo.[Order Details] ON dbo.[Order Details].OrderID=dbo.Orders.OrderID
WHERE YEAR(dbo.Orders.ShippedDate)=1996 AND MONTH(dbo.Orders.ShippedDate) BETWEEN 9 AND 11
GROUP BY Employees.FirstName,Employees.LastName
