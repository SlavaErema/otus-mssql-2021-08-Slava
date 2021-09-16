/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

select app.PersonID
	  ,app.FullName
from [Application].[People] as app
where app.IsSalesperson = 1
		and PersonID not in 
		   (
			select sins.SalespersonPersonID
			from Sales.Invoices as sins
			where sins.InvoiceDate = '20150704'
		   );
go

;with cte_IsSalesperson
as
(
		select app.PersonID
			  ,app.FullName
		from [Application].[People] as app
		where app.IsSalesperson = 1
)
,
 cte_InvoiceDate
as
(
			select sins.SalespersonPersonID
			from Sales.Invoices as sins
			where sins.InvoiceDate = '20150704'

)
select   cte_IsSalesperson.PersonID
		,cte_IsSalesperson.FullName
from cte_IsSalesperson  left join cte_InvoiceDate
on cte_IsSalesperson.PersonID=cte_InvoiceDate.SalespersonPersonID
where cte_InvoiceDate.SalespersonPersonID is null
go


/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/


	SELECT 
	 StockItemID
	,wsi.StockItemName 
	,UnitPrice 
FROM Warehouse.StockItems as wsi 
inner join 
 (SELECT StockItemName
		,Min(UnitPrice) as Min_UnitPrice
	FROM Warehouse.StockItems
	group by StockItemName
  )  as sim_min
  on wsi.StockItemName=sim_min.StockItemName 
  and wsi.UnitPrice=sim_min.Min_UnitPrice
  order by StockItemID
  go

  ;WITH allProducts AS
(
SELECT
	  StockItemID
	 ,StockItemName 
	 ,UnitPrice 
     ,ROW_NUMBER() OVER (PARTITION BY StockItemName ORDER BY UnitPrice asc) ROW_NUM
FROM test.[Warehouse].[StockItems]
)
SELECT StockItemID,StockItemName,UnitPrice
FROM allProducts
WHERE ROW_NUM = 1
  order by StockItemID
go


/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

select top 5 scs.*
from[Sales].[Customers] as scs
inner join 
(
select 
		max(sct.TransactionAmount) as max_
		,sct.CustomerID
from [Sales].[CustomerTransactions] as sct
group by sct.CustomerID
) as t_sct
on 
scs.CustomerID=t_sct.CustomerID
order by t_sct.max_ desc
go

;with top_5 as
(
select scs.*
from[Sales].[Customers] as scs
)
, max_ as
(
select 
		max(sct.TransactionAmount) as max_
		,sct.CustomerID
from [Sales].[CustomerTransactions] as sct
group by sct.CustomerID
)
select top 5  *
from top_5 inner join max_ on top_5.CustomerID=max_.CustomerID
order by max_.max_ desc


/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

SELECT ac.CityID, ac.CityName, app.FullName
FROM Sales.OrderLines as sol
     INNER JOIN Sales.Orders as sor ON  sor.OrderID=sol.OrderID
     INNER JOIN Sales.Invoices as sic ON  sic.OrderID=sor.OrderID
     INNER JOIN Sales.Customers as scm ON scm.CustomerID=sor.CustomerID 
     INNER JOIN Application.Cities as ac ON  scm.DeliveryCityID=ac.CityID
     INNER JOIN Application.People as app ON sic.PackedByPersonID=app.PersonID
WHERE sol.StockItemID IN
(
    SELECT TOP 3 wsi.StockItemID
    FROM Warehouse.StockItems as wsi
    ORDER BY wsi.UnitPrice DESC
);


WITH max_price AS (
	SELECT TOP 3 wsi.StockItemID
    FROM Warehouse.StockItems as wsi
    ORDER BY wsi.UnitPrice DESC
)
SELECT ac.CityID, ac.CityName, app.FullName
FROM Sales.OrderLines as sol
     INNER JOIN Sales.Orders as sor ON  sor.OrderID=sol.OrderID
     INNER JOIN Sales.Invoices as sic ON  sic.OrderID=sor.OrderID
     INNER JOIN Sales.Customers as scm ON scm.CustomerID=sor.CustomerID 
     INNER JOIN Application.Cities as ac ON  scm.DeliveryCityID=ac.CityID
     INNER JOIN Application.People as app ON sic.PackedByPersonID=app.PersonID
WHERE sol.StockItemID IN (SELECT _max.StockItemID FROM max_price as _max)

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос
--Как я понял это сверка выставленных счетов и проданных на сумму более 27000 разбитая по дате и продавцам
--не убрал запросы, просто хотел показать как крутил, мне не все еще понятно как оптимизировать

SET STATISTICS IO on;
--SET STATISTICS TIME ON;
SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC


---1

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	People.FullName AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SUM(OrderLines1.PickedQuantity*OrderLines1.UnitPrice)) AS TotalSummForPickedItems	
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
	join (	select FullName, PersonID from 
		 Application.People) as People  on
		People.PersonID = Invoices.SalespersonPersonID
join
(
SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL) as t 
			on Invoices.OrderID=t.OrderId 
join (SELECT OrderLines.PickedQuantity,OrderLines.UnitPrice,OrderId
		FROM Sales.OrderLines	
	) AS OrderLines1 on  OrderLines1.OrderId = t.OrderID
	group by Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	People.FullName ,
	SalesTotals.TotalSumm 
ORDER BY TotalSumm DESC

---- 2

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	People.FullName AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SUM(OrderLines1.PickedQuantity*OrderLines1.UnitPrice)) AS TotalSummForPickedItems	
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
	join 	
		 Application.People  on
		People.PersonID = Invoices.SalespersonPersonID
join
(
SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL) as t 
			on Invoices.OrderID=t.OrderId 
join (SELECT OrderLines.PickedQuantity,OrderLines.UnitPrice,OrderId
		FROM Sales.OrderLines	
	) AS OrderLines1 on  OrderLines1.OrderId = t.OrderID
	group by Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	People.FullName ,
	SalesTotals.TotalSumm 
ORDER BY TotalSumm DESC

--------------------------

---3


SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	People.FullName AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = t.OrderID	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
	join 	
		 Application.People  on
		People.PersonID = Invoices.SalespersonPersonID
	
join
(
SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL) as t 
			on Invoices.OrderID=t.OrderId 
ORDER BY TotalSumm DESC
go
--
;with SalesTotals as 
(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000)
,TotalSumm as
(SELECT Orders.OrderID, 
                SUM(OrderLines.PickedQuantity * OrderLines.UnitPrice) AS [TotalSummForPickedItems]
         FROM Sales.Orders
              INNER JOIN Sales.OrderLines ON Orders.OrderID = OrderLines.OrderID
         WHERE Orders.PickingCompletedWhen IS NOT NULL
         GROUP BY Orders.OrderID)
select *
from Sales.Invoices as sic
inner join [Application].[People] as ap on ap.PersonID=sic.SalespersonPersonID
inner join SalesTotals on SalesTotals.InvoiceID=sic.InvoiceID
left join TotalSumm on TotalSumm.OrderID=sic.OrderID
 ORDER BY TotalSumm DESC;







