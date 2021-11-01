use [WideWorldImporters];
go

--1.Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers

begin tran
declare @N_count_iteraciy int =1
declare @t_count int = 1
while @t_count <=5
begin
declare @randomString varchar(255)
--SELECT @randomString = CONVERT(varchar(255), NEWID())
SELECT @randomString = 'Slava'+convert(varchar(255),@N_count_iteraciy)

insert into [WideWorldImporters].[Sales].[Customers] ( 
      [CustomerName]
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy]
     
  )
  values
  (
  @randomString
,1
,3
,1
,1001
,1002
,3
,19586
,19586
,NULL
,'01.01.2013'
,0.000
,0
,0
,7
,'(308) 555-0100'
,'(308) 555-0101'
,''
,''
,'http://www.tailspintoys.com'
,'Shop 38'
,'1877 Mittal Road'
,90410
,0xE6100000010CE73F5A52A4BF444010638852B1A759C0
,'PO Box 8975'
,'Ribeiroville'
,90410
,1

)
 set @t_count=@t_count+1
  set @N_count_iteraciy=@N_count_iteraciy+1
 end

COMMIT TRAN
 --ROLLBACK tran


-- 2.Удалите одну запись из Customers, которая была вами добавлена

 begin tran
 delete from [Sales].[Customers]
 where [CustomerName] like 'Slava3'
COMMIT TRAN
--ROLLBACK tran

--3. Изменить одну запись, из добавленных через UPDATE

 begin tran
update scus set [CustomerName]='Slava_Erema'
from [Sales].[Customers] as scus
where [CustomerName]= 'Slava4'
COMMIT TRAN
--ROLLBACK tran

--4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет,
-- и изменит если она уже есть
 begin tran
 declare @CustomerName_old nvarchar(250)
 set @CustomerName_old = 'Slava'
 declare @CustomerName_new nvarchar(250)
  set @CustomerName_new = 'Slava_new'

MERGE [Sales].[Customers] AS T_Base --Целевая таблица
        USING 
		(select @CustomerName_old as [CustomerName]) AS T_Source 
	   --Таблица источник
        ON (T_Base.[CustomerName] = T_Source.[CustomerName])  --Условие объединения
        WHEN MATCHED and T_Base.[CustomerName] =@CustomerName_old
		THEN --Если истина (UPDATE)
                 UPDATE SET [CustomerName] = @CustomerName_new 
        WHEN NOT MATCHED /*BY TARGET */
		THEN --Если НЕ истина (INSERT)
                insert  (
					[CustomerID],
				 [CustomerName]
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy])
				values
(
  550505013,
  @CustomerName_old
,1
,3
,1
,1001
,1002
,3
,19586
,19586
,NULL
,'01.01.2013'
,0.000
,0
,0
,7
,'(308) 555-0100'
,'(308) 555-0101'
,''
,''
,'http://www.tailspintoys.com'
,'Shop 38'
,'1877 Mittal Road'
,90410
,0xE6100000010CE73F5A52A4BF444010638852B1A759C0
,'PO Box 8975'
,'Ribeiroville'
,90410
,1
)
OUTPUT $action, inserted.*, deleted.*;				     
  COMMIT TRAN
--ROLLBACK

--5.Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert

exec master..xp_cmdshell 'bcp "[WideWorldImporters].[Sales].[Customers]" out  "C:\Otus\Customers_01_11_2021.txt" -T -w -t"@eu&$1&" -S DESKTOP-4ABVVF5'

drop table if exists dbo.[Customers_bcp]

CREATE TABLE dbo.[Customers_bcp](
	[CustomerID] [int] NOT NULL,
	[CustomerName] [nvarchar](100) NOT NULL,
	[BillToCustomerID] [int] NOT NULL,
	[CustomerCategoryID] [int] NOT NULL,
	[BuyingGroupID] [int] NULL,
	[PrimaryContactPersonID] [int] NOT NULL,
	[AlternateContactPersonID] [int] NULL,
	[DeliveryMethodID] [int] NOT NULL,
	[DeliveryCityID] [int] NOT NULL,
	[PostalCityID] [int] NOT NULL,
	[CreditLimit] [decimal](18, 2) NULL,
	[AccountOpenedDate] [date] NOT NULL,
	[StandardDiscountPercentage] [decimal](18, 3) NOT NULL,
	[IsStatementSent] [bit] NOT NULL,
	[IsOnCreditHold] [bit] NOT NULL,
	[PaymentDays] [int] NOT NULL,
	[PhoneNumber] [nvarchar](20) NOT NULL,
	[FaxNumber] [nvarchar](20) NOT NULL,
	[DeliveryRun] [nvarchar](5) NULL,
	[RunPosition] [nvarchar](5) NULL,
	[WebsiteURL] [nvarchar](256) NOT NULL,
	[DeliveryAddressLine1] [nvarchar](60) NOT NULL,
	[DeliveryAddressLine2] [nvarchar](60) NULL,
	[DeliveryPostalCode] [nvarchar](10) NOT NULL,
	[DeliveryLocation] [geography] NULL,
	[PostalAddressLine1] [nvarchar](60) NOT NULL,
	[PostalAddressLine2] [nvarchar](60) NULL,
	[PostalPostalCode] [nvarchar](10) NOT NULL)


BULK INSERT WideWorldImporters.dbo.Customers_bcp
				   FROM "C:\Otus\Customers_bcp.txt"
				   WITH 
					 (
						BATCHSIZE = 1000, 
						DATAFILETYPE = 'widechar',
						FIELDTERMINATOR = '@eu&$1&',
						ROWTERMINATOR ='\n',
						KEEPNULLS,
						TABLOCK        
					  );



