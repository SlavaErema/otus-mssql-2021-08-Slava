/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/
select ws.StockItemID
		,ws.StockItemName
from [Warehouse].[StockItems] as ws
where ws.StockItemName like '%urgent%' or ws.StockItemName like 'Animal%'
order by ws.StockItemID



/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

select ps.SupplierID
	  ,ps.SupplierName
from Purchasing.Suppliers as ps
left join
	 Purchasing.PurchaseOrders as ppo
			on ps.SupplierID=ppo.SupplierID
		where ppo.PurchaseOrderID is null
			order by ps.SupplierID,ps.SupplierName


/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

select   
		 sol.OrderID
		,convert(nvarchar,sor.OrderDate, 104) as OrderDate
		,datename(m,sor.OrderDate) as [Month_name]
		,datename(QUARTER,sor.OrderDate) as [Quarter]
			,case 
				when month(sor.OrderDate) BETWEEN 1 AND 4 THEN 1
				when month(sor.OrderDate) BETWEEN 5 AND 8 THEN 2
				when month(sor.OrderDate) BETWEEN 9 AND 12 THEN 3
		    end as Third_part
	   ,CustomerName
from 
	Sales.Orders as sor
	inner join 
	Sales.OrderLines as sol on sor.OrderID=sol.OrderID	
	inner join 
	Sales.Customers as scust on  sor.CustomerID=scust.CustomerID
where (sol.UnitPrice>100 or sol.Quantity >20) and sol.PickingCompletedWhen is not null
order by [Quarter], Third_part, OrderDate



/*************************************************/

select   
		 sol.OrderID
		,convert(nvarchar,sor.OrderDate, 104) as OrderDate
		,datename(m,sor.OrderDate) as [Month_name]
		,datename(QUARTER,sor.OrderDate) as [Quarter]
			,case 
				when month(sor.OrderDate) BETWEEN 1 AND 4 THEN 1
				when month(sor.OrderDate) BETWEEN 5 AND 8 THEN 2
				when month(sor.OrderDate) BETWEEN 9 AND 12 THEN 3
		    end as Third_part
	   ,CustomerName
from 
	Sales.Orders as sor
	inner join 
	Sales.OrderLines as sol on sor.OrderID=sol.OrderID	
	inner join 
	Sales.Customers as scust on  sor.CustomerID=scust.CustomerID
where (sol.UnitPrice>100 or sol.Quantity >20) and sol.PickingCompletedWhen is not null
order by [Quarter], Third_part, OrderDate
				,sor.OrderID OFFSET 1000 ROWS FETCH FIRST 100 ROWS ONLY
		
/*********************/



/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

declare @Year int = 2013
declare @Month int = 1
select 
		adm.DeliveryMethodName
		,ppo.ExpectedDeliveryDate
		,ps.SupplierName
		,ap.PreferredName		
from
Purchasing.Suppliers as ps
inner join
Purchasing.PurchaseOrders as ppo on ps.SupplierID=ppo.SupplierID
inner join 
Application.DeliveryMethods as adm on ps.DeliveryMethodID=adm.DeliveryMethodID
inner join 
Application.People as ap on ps.PrimaryContactPersonID=ap.PersonID
	where (year(ppo.ExpectedDeliveryDate) = @Year and month(ppo.ExpectedDeliveryDate) =@Month)
			and (adm.DeliveryMethodName ='Air Freight' or adm.DeliveryMethodName='Refrigerated Air Freight')
				and ppo.IsOrderFinalized = 1
order by ppo.ExpectedDeliveryDate,ps.SupplierName 




/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

select top 10 sor.OrderDate
			,appl.PreferredName
			,scust.CustomerName
from  [Sales].[Orders] as sor
inner join [Application].[People] as appl on sor.SalespersonPersonID=appl.PersonID
inner join [Sales].[Customers] as scust on sor.CustomerID=scust.CustomerID
group by sor.OrderDate, appl.PreferredName, scust.CustomerName
order by sor.OrderDate desc


/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

select scust.CustomerID
	  ,scust.CustomerName
	  ,scust.PhoneNumber
from [Sales].[Customers] as scust
inner join [Sales].[Orders] as sor on scust.CustomerID=sor.CustomerID
inner join [Sales].[OrderLines] as sol on sol.OrderID=sor.OrderID
inner join Warehouse.StockItems as wsi on sol.StockItemID=wsi.StockItemID
group by 
	   scust.CustomerID
	  ,scust.CustomerName
	  ,scust.PhoneNumber
	  ,wsi.StockItemName
having wsi.StockItemName = 'Chocolate frogs 250g'
order by scust.CustomerID


/*
7. Посчитать среднюю цену товара, общую сумму продажи по месяцам
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select year(si.InvoiceDate) as Y
	  ,month(si.InvoiceDate) as M
	  ,avg(UnitPrice) as AVG_UnitPrice
	  ,sum([UnitPrice]) as SUM_UnitPrice
from [Sales].[Invoices] as si
inner join [Sales].[OrderLines] as sol on si.OrderID=sol.OrderID
inner join [Sales].[Orders] as so on si.OrderID=so.OrderID
group by   year(si.InvoiceDate) 
		  ,month(si.InvoiceDate) 
having year(si.InvoiceDate) = 2015 
		and month(si.InvoiceDate) = 4
		 

/*
8. Отобразить все месяцы, где общая сумма продаж превысила 10 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select year(si.InvoiceDate) as Y
	  ,month(si.InvoiceDate) as M
	  ,sum([UnitPrice]) as SUM_UnitPrice
from [Sales].[Invoices] as si
inner join [Sales].[OrderLines] as sol on si.OrderID=sol.OrderID
inner join [Sales].[Orders] as so on si.OrderID=so.OrderID
group by   year(si.InvoiceDate) 
		  ,month(si.InvoiceDate) 
having (year(si.InvoiceDate) = 2015 
		and month(si.InvoiceDate) = 4)
		and sum([UnitPrice]) >10000


/*
9. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/


select year(sor.OrderDate) as Y
	  ,month(sor.OrderDate) as M
	  ,sol.Description as [Description]
	  ,sum(sol.UnitPrice) as SUM_UnitPrice
	  ,min(sor.OrderDate) as min_OrderDate
	  ,count(sol.Quantity) as [Quantity]
from [Sales].[Orders] as sor
 inner join   [Sales].[OrderLines] as sol on sol.OrderID=sor.OrderID
group by   year(sor.OrderDate) 
		  ,month(sor.OrderDate) 
		  ,sol.Description
having count(sol.Quantity) <50
order by Y, M



-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 8-9 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
