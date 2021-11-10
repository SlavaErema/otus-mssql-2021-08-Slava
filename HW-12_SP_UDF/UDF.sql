-- ================================================

-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<������ ��������>
-- Create date: <20211102>
-- Description:	<12�������� ���������, �������, ��������, �������. ��>
-- =============================================

--1.�������� ������� ������������ ������� � ���������� ������ �������.
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
--2.�������� �������� ��������� � �������� ���������� �ustomerID, ��������� ����� ������� �� ����� �������.
--������������ ������� : Sales.Customers Sales.Invoices Sales.InvoiceLines

IF OBJECT_ID ( 'Sum_Customer', 'P' ) IS NOT NULL   
    DROP PROCEDURE Sum_Customer;  
GO  
create PROCEDURE Sum_Customer   
    @�ustomerID int 
AS   
select sum([TaxAmount])
		from [Sales].[InvoiceLines] as sil 
		inner join Sales.Invoices as sic on sic.InvoiceID=sil.InvoiceID
		inner join Sales.Customers as scs on scs.CustomerID=sic.CustomerID
		where scs.CustomerID =@�ustomerID
		group by scs.CustomerName, scs.CustomerID
go

DECLARE @�ustomerID int;  
SET @�ustomerID = 834;     
exec Sum_Customer @�ustomerID;



--3.������� ���������� ������� � �������� ���������, ���������� � ��� ������� � ������������������ � ������.

IF OBJECT_ID ( 'Pr_CustomerName', 'P' ) IS NOT NULL   
    DROP PROCEDURE Pr_CustomerName;  
GO  
create PROCEDURE Pr_CustomerName   
    @�ustomerID sql_variant
AS   
    select CustomerName
	from Sales.Customers as scs 
		where scs.CustomerID =@�ustomerID
go

SET STATISTICS IO ON 
SET STATISTICS TIME ON 
		exec Pr_CustomerName 834
--����� ��������������� ������� � ���������� SQL Server: 
-- ����� �� = 0 ��, �������� ����� = 0 ��.
-- ����� ������ SQL Server:
--   ����� �� = 0 ��, ����������� ����� = 0 ��.
-- ����� ������ SQL Server:
--   ����� �� = 0 ��, ����������� ����� = 0 ��.
--����� ��������������� ������� � ���������� SQL Server: 
-- ����� �� = 0 ��, �������� ����� = 0 ��.
-- ����� ������ SQL Server:
--   ����� �� = 0 ��, ����������� ����� = 0 ��.
-- ����� ������ SQL Server:
--   ����� �� = 0 ��, ����������� ����� = 0 ��.
--����� ��������������� ������� � ���������� SQL Server: 
-- ����� �� = 15 ��, �������� ����� = 20 ��.
--(��������� ���� ������)
--������� "Worktable". ������������ 0, ���������� �������� ������ 0, ���������� �������� ������ 0, �������� ������ ����������� ������� 0, �������� ������, ����������� � ����������� 0, �������� ������ ����������� �������, ����������� � ����������� 0, ���������� �������� ������ LOB 0, ���������� �������� ������ LOB 0, �������� ������ LOB ����������� ������� 0, �������� ������ LOB, ����������� � ����������� 0, �������� ������ LOB ����������� �������, ����������� � ����������� 0.
--������� "Customers". ������������ 0, ���������� �������� ������ 2, ���������� �������� ������ 0, �������� ������ ����������� ������� 0, �������� ������, ����������� � ����������� 0, �������� ������ ����������� �������, ����������� � ����������� 0, ���������� �������� ������ LOB 0, ���������� �������� ������ LOB 0, �������� ������ LOB ����������� ������� 0, �������� ������ LOB, ����������� � ����������� 0, �������� ������ LOB ����������� �������, ����������� � ����������� 0.
--(��������� �����: 19)
--(��������� ���� ������)
-- ����� ������ SQL Server:
--   ����� �� = 16 ��, ����������� ����� = 27 ��.
-- ����� ������ SQL Server:
--   ����� �� = 31 ��, ����������� ����� = 48 ��.
--����� ��������������� ������� � ���������� SQL Server: 
-- ����� �� = 0 ��, �������� ����� = 0 ��.
-- ����� ������ SQL Server:
--   ����� �� = 0 ��, ����������� ����� = 0 ��.
-- ����� ������ SQL Server:
--   ����� �� = 0 ��, ����������� ����� = 0 ��.

go

create FUNCTION dbo.F_CustomerName  (@�ustomerID int)
RETURNS nvarchar(50)
WITH EXECUTE AS CALLER  
AS  
BEGIN  
declare @CustomerName nvarchar(50)

   select @CustomerName=CustomerName
	from Sales.Customers as scs 
	where scs.CustomerID =@�ustomerID

	 RETURN(@CustomerName);  
END;  

SET STATISTICS IO ON 
SET STATISTICS TIME ON 

select [dbo].[F_CustomerName](834)

--����� ��������������� ������� � ���������� SQL Server: 
-- ����� �� = 0 ��, �������� ����� = 0 ��.
-- ����� ������ SQL Server:
--   ����� �� = 0 ��, ����������� ����� = 0 ��.
-- ����� ������ SQL Server:
--   ����� �� = 0 ��, ����������� ����� = 0 ��.
--����� ��������������� ������� � ���������� SQL Server: 
-- ����� �� = 7 ��, �������� ����� = 7 ��.
-- ����� ������ SQL Server:
--   ����� �� = 0 ��, ����������� ����� = 0 ��.
-- ����� ������ SQL Server:
--   ����� �� = 0 ��, ����������� ����� = 0 ��.
--(��������� ���� ������)
--(��������� �����: 3)
--(��������� ���� ������)
-- ����� ������ SQL Server:
--   ����� �� = 0 ��, ����������� ����� = 8 ��.
--����� ��������������� ������� � ���������� SQL Server: 
--����� �� = 0 ��, �������� ����� = 0 ��.
-- ����� ������ SQL Server:
--   ����� �� = 0 ��, ����������� ����� = 0 ��.
-- ����� ������ SQL Server:
--   ����� �� = 0 ��, ����������� ����� = 0 ��.

--�����: ������� ���������� ������� �������, ��� ���������, � ������� ����� ��������� ������� �������������� ����� � ��������� ������� ������ �� ������� �����


--4.�������� ��������� ������� �������� ��� �� ����� ������� ��� ������ ������ result set'�
--��� ������������� �����.
--���� ��������� �����,������,� �������������� ������ ����� ���������� �������� �� ������� � ���������� �������� �������� ������� 
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
--1. ������(2,3) - ��������� ���� � ������ ������� �� ����� ����� ������ � �� ������� ���������� ����������-���������, ������� ��� ������� ��� 
--, ��� ����� ������������ READ COMMITTED SNAPSHOT, �� ������ ���� ��������� �������� �� tempdb.





