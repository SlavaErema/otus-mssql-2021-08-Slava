/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

	 --;with CustomerName as (
	 --select CustomerID,SUBSTRING(LEFT([CustomerName],NULLIF(PATINDEX('%)%',[CustomerName]),0)-1)
		--				,(CHARINDEX ('(', [CustomerName])+1),20)	as 	Customer_Name	
	 --FROM [WideWorldImporters].[Sales].[Customers]
	 --where CustomerID between 2 and 6
	 --) 
	 --select *
	 --from CustomerName
--------------------------------
	  
	select * from 
	(
	 select /*sic.CustomerID*/
		 SUBSTRING(LEFT([CustomerName],NULLIF(PATINDEX('%)%',[CustomerName]),0)-1)
						,(CHARINDEX ('(', [CustomerName])+1),20)	as 	Customer_Name
		 ,convert(nvarchar,(DATEFROMPARTS(YEAR(InvoiceDate),MONTH(InvoiceDate),1)),104) as dateInvoices
  , count([OrderID]) as cou
	 FROM [WideWorldImporters].[Sales].[Invoices] as sic
	 inner join [WideWorldImporters].[Sales].[Customers] as wis
	 on sic.CustomerID=wis.CustomerID
	 where sic.CustomerID between 2 and 6
	 group by sic.CustomerID,SUBSTRING(LEFT([CustomerName],NULLIF(PATINDEX('%)%',[CustomerName]),0)-1)
						,(CHARINDEX ('(', [CustomerName])+1),20)
	 ,convert(nvarchar,(DATEFROMPARTS(YEAR(InvoiceDate),MONTH(InvoiceDate),1)),104)
	 --order by CustomerID
	 ) as t
	 PIVOT (sum(cou)
FOR Customer_Name IN ([Peeples Valley, AZ],[Medicine Lodge, KS],[Gasport, NY], [Sylvanite, MT],[Jessie, ND]))
as PVT_my
order by year(convert(date,dateInvoices)), month(convert(date,dateInvoices))
	 
 
/*где-то я не допонимаю, буду ждать занятия))*/
	 
	--declare  @CustomerName as NVARCHAR(MAX)	,
	-- @query  AS NVARCHAR(MAX)

	-- select  @CustomerName=SUBSTRING(LEFT([CustomerName],NULLIF(PATINDEX('%)%',[CustomerName]),0)-1)
	--					,(CHARINDEX ('(', [CustomerName])+1),20)
	-- FROM [WideWorldImporters].[Sales].[Customers]
	-- where CustomerID between 2 and 6

	-- select @CustomerName

	-- set @query='select * from (select
	-- sic.CustomerID
	--	 ,convert(nvarchar,(DATEFROMPARTS(YEAR(InvoiceDate),MONTH(InvoiceDate),1)),104) as dateInvoices
 -- , count([OrderID]) as cou
 -- ,[CustomerName]
	-- FROM [WideWorldImporters].[Sales].[Invoices] as sic
	-- inner join [WideWorldImporters].[Sales].[Customers] as scr
	-- on sic.CustomerID=scr.CustomerID
	-- group by sic.CustomerID
	-- ,convert(nvarchar,(DATEFROMPARTS(YEAR(InvoiceDate),MONTH(InvoiceDate),1)),104)
	-- ,CustomerName
	--  ) as src
	--  pivot
 --     (
 --       sum(cou)
 --       for CustomerName  in ('+@CustomerName+')
 --     ) piv'
	-- exec(@query)




/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/
;with TT as ( 
select *
from
(
select scus.CustomerName
, scus.DeliveryAddressLine1
,scus.DeliveryAddressLine2
,scus.PostalAddressLine1
,scus.PostalAddressLine2
FROM [WideWorldImporters].[Sales].[Customers] as scus
where scus.CustomerName like 'Tailspin Toys%'
) as Customer_Name
UNPIVOT (AddressLine for Delivery_Postal in (DeliveryAddressLine1
,DeliveryAddressLine2
,PostalAddressLine1
,PostalAddressLine2)) AS unpt
)

select CustomerName, AddressLine
from tt;


/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

;with Country_ as
(select CountryId
      ,CountryName
	  ,IsoAlpha3Code
	  ,cast(IsoNumericCode as nvarchar(3)) as IsoNumericCode
from Application.Countries
)
select *
from(
select CountryId
      ,CountryName
	  ,IsoAlpha3Code
	  ,IsoNumericCode
from Country_
) as Country
UNPIVOT (Country_Name for Code in (IsoAlpha3Code,IsoNumericCode)) as unpt


/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

select r.CustomerId
		,r.CustomerName
		,t.InvoiceID
		,t.TransactionAmount
		,t.TransactionDate
from [Sales].[Customers] as r
cross apply (
				SELECT top 2 *
				FROM [Sales].[CustomerTransactions] as o
				where o.CustomerID=r.CustomerID
				order by TransactionAmount DESC) as t
order by r.CustomerId,t.TransactionAmount
 
