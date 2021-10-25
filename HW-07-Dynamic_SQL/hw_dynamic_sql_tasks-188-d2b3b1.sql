/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/


	DECLARE @dml AS NVARCHAR(MAX)
DECLARE @ColumnName AS NVARCHAR(MAX)
create table #tt (CustomerName NVARCHAR(50),CustomerID int)
insert into #tt (CustomerName,CustomerID) 
		select distinct SUBSTRING(LEFT([CustomerName],NULLIF(PATINDEX('%)%',[CustomerName]),0)-1),(CHARINDEX ('(', [CustomerName])+1),20)	as 	Customer_Name3
			           ,sic.CustomerID
				FROM [WideWorldImporters].[Sales].[Invoices] as sic
					 inner join [WideWorldImporters].[Sales].[Customers] as wis
							 on sic.CustomerID=wis.CustomerID
				where sic.CustomerID between 2 and 6

--select * from #tt
--drop table #tt

SELECT @ColumnName= ISNULL(@ColumnName + ',','') 
       + QUOTENAME(CustomerName)
FROM (select CustomerName from #tt
) AS Customer_Name

--SELECT @ColumnName as ColumnName

SET @dml = 
  N'select dateInvoices,'+@ColumnName+' from (
	select 
		 convert(nvarchar,(DATEFROMPARTS(YEAR(InvoiceDate),MONTH(InvoiceDate),1)),104) as dateInvoices
		 ,w.CustomerName
  , count([OrderID]) as cou
	 FROM [WideWorldImporters].[Sales].[Invoices] as sic
	 inner join #tt as w on w.CustomerID=sic.CustomerID
	 where sic.CustomerID between 2 and 6
	 group by sic.CustomerID,w.CustomerName
	 ,convert(nvarchar,(DATEFROMPARTS(YEAR(InvoiceDate),MONTH(InvoiceDate),1)),104)) as t
	 PIVOT (sum(cou)
FOR CustomerName IN ('+@ColumnName+'))
as PVT_my
order by year(convert(date,dateInvoices)), month(convert(date,dateInvoices))'

exec(@dml)

