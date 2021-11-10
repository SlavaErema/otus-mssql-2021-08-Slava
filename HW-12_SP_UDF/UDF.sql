-- ================================================

-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Еремин Вячеслав>
-- Create date: <20211102>
-- Description:	<12Хранимые процедуры, функции, триггеры, курсоры. ДЗ>
-- =============================================

--1.Написать функцию возвращающую Клиента с наибольшей суммой покупки.
--Sales.Customers
--Sales.Invoices
--Sales.InvoiceLines

create FUNCTION dbo.max_Amount ()
RETURNS nvarchar(50)
WITH EXECUTE AS CALLER  
AS  
BEGIN  
     DECLARE @max_Amount nvarchar(50)
	 set @max_Amount = null
	 DECLARE @InvoiceID int  = null

select @InvoiceID=[InvoiceID]
	from [Sales].[InvoiceLines]
	group by [InvoiceID]
	having sum([TaxAmount]) =
(
select max(summa)
	from (
select [InvoiceID], sum([TaxAmount]) as summa
	from [Sales].[InvoiceLines]
	group by [InvoiceID]) as t
)
select @max_Amount=scs.CustomerName
		from [Sales].[InvoiceLines] as sil 
		inner join Sales.Invoices as sic on sic.InvoiceID=@InvoiceID
		inner join Sales.Customers as scs on scs.CustomerID=sic.CustomerID
	
 RETURN (@max_Amount);  
END;  
go

select dbo.max_Amount ();
go
--2.Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
--Использовать таблицы : Sales.Customers Sales.Invoices Sales.InvoiceLines

IF OBJECT_ID ( 'Sum_Customer', 'P' ) IS NOT NULL   
    DROP PROCEDURE Sum_Customer;  
GO  
create PROCEDURE Sum_Customer   
    @СustomerID int 
AS   
select sum([TaxAmount])
		from [Sales].[InvoiceLines] as sil 
		inner join Sales.Invoices as sic on sic.InvoiceID=sil.InvoiceID
		inner join Sales.Customers as scs on scs.CustomerID=sic.CustomerID
		where scs.CustomerID =@СustomerID
		group by scs.CustomerName, scs.CustomerID
go

DECLARE @СustomerID int;  
SET @СustomerID = 834;     
exec Sum_Customer @СustomerID;



--3.Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.

IF OBJECT_ID ( 'Pr_CustomerName', 'P' ) IS NOT NULL   
    DROP PROCEDURE Pr_CustomerName;  
GO  
create PROCEDURE Pr_CustomerName   
    @СustomerID sql_variant
AS   
    select CustomerName
	from Sales.Customers as scs 
		where scs.CustomerID =@СustomerID
go

SET STATISTICS IO ON 
SET STATISTICS TIME ON 
		exec Pr_CustomerName 834
--Время синтаксического анализа и компиляции SQL Server: 
-- время ЦП = 0 мс, истекшее время = 0 мс.
-- Время работы SQL Server:
--   Время ЦП = 0 мс, затраченное время = 0 мс.
-- Время работы SQL Server:
--   Время ЦП = 0 мс, затраченное время = 0 мс.
--Время синтаксического анализа и компиляции SQL Server: 
-- время ЦП = 0 мс, истекшее время = 0 мс.
-- Время работы SQL Server:
--   Время ЦП = 0 мс, затраченное время = 0 мс.
-- Время работы SQL Server:
--   Время ЦП = 0 мс, затраченное время = 0 мс.
--Время синтаксического анализа и компиляции SQL Server: 
-- время ЦП = 15 мс, истекшее время = 20 мс.
--(затронута одна строка)
--Таблица "Worktable". Сканирований 0, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
--Таблица "Customers". Сканирований 0, логических операций чтения 2, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
--(затронуто строк: 19)
--(затронута одна строка)
-- Время работы SQL Server:
--   Время ЦП = 16 мс, затраченное время = 27 мс.
-- Время работы SQL Server:
--   Время ЦП = 31 мс, затраченное время = 48 мс.
--Время синтаксического анализа и компиляции SQL Server: 
-- время ЦП = 0 мс, истекшее время = 0 мс.
-- Время работы SQL Server:
--   Время ЦП = 0 мс, затраченное время = 0 мс.
-- Время работы SQL Server:
--   Время ЦП = 0 мс, затраченное время = 0 мс.

go

create FUNCTION dbo.F_CustomerName  (@СustomerID int)
RETURNS nvarchar(50)
WITH EXECUTE AS CALLER  
AS  
BEGIN  
declare @CustomerName nvarchar(50)

   select @CustomerName=CustomerName
	from Sales.Customers as scs 
	where scs.CustomerID =@СustomerID

	 RETURN(@CustomerName);  
END;  

SET STATISTICS IO ON 
SET STATISTICS TIME ON 

select [dbo].[F_CustomerName](834)

--Время синтаксического анализа и компиляции SQL Server: 
-- время ЦП = 0 мс, истекшее время = 0 мс.
-- Время работы SQL Server:
--   Время ЦП = 0 мс, затраченное время = 0 мс.
-- Время работы SQL Server:
--   Время ЦП = 0 мс, затраченное время = 0 мс.
--Время синтаксического анализа и компиляции SQL Server: 
-- время ЦП = 7 мс, истекшее время = 7 мс.
-- Время работы SQL Server:
--   Время ЦП = 0 мс, затраченное время = 0 мс.
-- Время работы SQL Server:
--   Время ЦП = 0 мс, затраченное время = 0 мс.
--(затронута одна строка)
--(затронуто строк: 3)
--(затронута одна строка)
-- Время работы SQL Server:
--   Время ЦП = 0 мс, затраченное время = 8 мс.
--Время синтаксического анализа и компиляции SQL Server: 
--время ЦП = 0 мс, истекшее время = 0 мс.
-- Время работы SQL Server:
--   Время ЦП = 0 мс, затраченное время = 0 мс.
-- Время работы SQL Server:
--   Время ЦП = 0 мс, затраченное время = 0 мс.

--Вывод: Функция отработала намного дешевле, чем процедура, в которой также произошло неявное преобразование типов и затронута таблица видимо не хватило места


--4.Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а
--без использования цикла.
--если правильно понял,сделал,в результирующем наборе можно посмотреть клиентов по городам и определить наиболее активные регионы 
go
create function dbo.Cities( @CityID int )
returns table
as
return
(
select [CustomerID]
	  ,[CustomerName]
from [Sales].[Customers]
where [DeliveryCityID] = @CityID
)
go

;with [AC/DC] as 
(
select ac.CityName
	  ,ap.CustomerName
from [Application].[Cities] ac 
  cross apply dbo.Cities ( ac.CityID ) ap
)
select CityName
	  ,count(*) as count_CustomerName
from [AC/DC]
group by CityName
having count(CityName)>1


--5.
--1. Задача(2,3) - обращение идет к данным которые не нужны прямо онлайн и не валятся постоянные обновления-изменения, поэтому мне видится так 
--, что можно использовать READ COMMITTED SNAPSHOT, не должно быть серьезной нагрузки на tempdb.





