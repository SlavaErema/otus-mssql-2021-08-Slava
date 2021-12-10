--use master;
--go

/*������ �� � ����� ��������� ��������, ����������� � ����� ��������� ����������� ���������
, � ������ �����������(������������ ��� ���������)
	���������� �������� ������ ������ �� ������ ���������� ����, ����� ��� ����� �������. 
	���� ����� �����, ��� ����� ��� � ������� ���������*/
--CREATE DATABASE P_Stat
-- CONTAINMENT = NONE
-- ON  PRIMARY 
--( NAME = P_Stat, FILENAME = N'C:\P_Stat\P_Stat.mdf' , 
--	SIZE = 8MB , 
--	MAXSIZE = UNLIMITED, 
--	FILEGROWTH = 65536KB )
--	, ( NAME = P_Stat2, FILENAME = N'C:\P_Stat\P_Stat_2.mdf' , 
--	SIZE = 8MB , 
--	MAXSIZE = UNLIMITED, 
--	FILEGROWTH = 65536KB )
-- LOG ON 
--( NAME = P_Stat_log, FILENAME = N'D:\P_Stat\P_Stat_log.ldf' , 
--	SIZE = 8MB , 
--	MAXSIZE = 100GB , 
--	FILEGROWTH = 65536KB )
--	COLLATE Cyrillic_General_CI_AS
--GO

--SELECT *
--FROM ::fn_helpcollations()

--select @@SERVERNAME


/***************************************************************/
use P_Stat;
go

/*****************�������� ������� ******************************/
--�������� ������� ����� 50,000 ������� �����������

CREATE TABLE [dbo].[Stat](
	[Item_Number] nvarchar(50) NOT NULL,
	[Item_number_list] [int] NOT NULL,
	[��������] [nvarchar](max) NOT NULL,
	[Gross_weight] [decimal](18, 0) NOT NULL,
	[Net_weight] [decimal](18, 0) NOT NULL,
	[price_product] [decimal](18, 0) NOT NULL,
	[direction] nvarchar(10) NOT NULL,
	[sender_inn] [int] NOT NULL,
	[sender_name] nvarchar(255) NOT NULL,
	[sender_address] nvarchar(255) NOT NULL,
	[recipient_inn] [int] NOT NULL,
	[recipient_name] nvarchar(255) NOT NULL,
	[recipient_address] nvarchar(255) NOT NULL,
	[country_departure] nvarchar(255) NOT NULL,
	[country_departure_cod] nvarchar(50) NOT NULL,
	[country_departure_cod_int] [int] NOT NULL,
	[country_destination] nvarchar(255) NOT NULL,
	[country_destination_cod] nvarchar(50) NOT NULL,
	[recipient_id] [int] NOT NULL,
	[sender_id] [int] NOT NULL,
	[sender_address_id] [int] NOT NULL,
	[delivery_condition] nvarchar(10) NOT NULL,
	[product_code] [int] NOT NULL,
	date_sender datetime2,
	[id] [int] IDENTITY(1,1) NOT NULL,


) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

alter table dbo.stat add constraint Item_Number_list unique([Item_Number],[Item_number_list]);--����������� ��� ��� ����� ��������� � ������� ������ ������ ������������,
																							  --������������ ��������� ����

/*�������� �������� �����*/
--��� � ���� �������� �� ��������, ��� ���� ���� ���� �������, ��� ��������� �� ��� ����� ���������
    select q1.t1, q.t
   from
 (  
   SELECT /*COUNT(COLUMN_NAME) */ COLUMN_NAME as t, ORDINAL_POSITION as w
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE 
    TABLE_CATALOG = 'P_Stat'
    AND TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = 'stat_full' --������������� �������
  ) as q
 right join
  ( 
   SELECT /*COUNT(COLUMN_NAME) */ COLUMN_NAME as t1,ORDINAL_POSITION as w1
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE 
    TABLE_CATALOG = 'P_Stat'
    AND TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = 'stat' -- �������� �������
) as q1
on q.t=q1.t1 and q.w=q1.w1
where q.t is null

/*�������� ������ � �������� ����� � ��������*/

begin tran
IF OBJECT_ID('dbo.Double_stat', 'U') IS NOT NULL
  DROP TABLE dbo.Double_stat
GO
--[Item_Number],[Item_number_list] -- ������������ ��������� ����
select t.Item_Number,t.Item_number_list
into Double_stat
from [P_Stat]..stat_full as t inner join [P_Stat]..stat as t1
on t.Item_Number=t1.Item_Number and t.Item_number_list=t1.Item_number_list

declare @count int 
set @count= (select count(*) from [P_Stat]..stat)
if @count>1
begin
delete t from [P_Stat]..stat as t inner join dbo.Double_stat as t1 
on t.Item_Number=t1.Item_Number and t.Item_number_list=t1.Item_number_list
end;
else 
begin
print ('����������� ������� ���')
end;
commit tran;

/*******�������� ���������****************/
begin tran
;with Q as
(
SELECT [Item_Number],[Item_number_list],
  ROW_NUMBER() OVER(PARTITION BY [Item_Number]
								,[Item_number_list]
                    ORDER BY (SELECT NULL)) AS n
FROM [P_Stat]..stat
)
delete
from q
WHERE n > 1;
commit tran;

--������� � �������
--truncate table [dbo].[stat_full];
GO

CREATE TABLE [dbo].[Stat_Full](
	[Item_Number] nvarchar(50) NOT NULL,
	[Item_Number_list] [int] NOT NULL,
	[Description] [nvarchar](max) NOT NULL,
	[Gross_Weight] [decimal](18, 0) NOT NULL,
	[Net_Weight] [decimal](18, 0) NOT NULL,
	[Price_Product] [decimal](18, 0) NOT NULL,
	[Direction] nvarchar(10) NOT NULL,
	[Sender_INN] [int] NOT NULL,
	[Sender_Name] nvarchar(255) NOT NULL,
	[Sender_Address] nvarchar(255) NOT NULL,
	[Recipient_INN] [int] NOT NULL,
	[Recipient_Name] nvarchar(255) NOT NULL,
	[Recipient_Address] nvarchar(255) NOT NULL,
	[Country_Departure] nvarchar(255) NOT NULL,
	[Country_Departure_Cod] nvarchar(50) NOT NULL,
	[Country_Departure_cod_int] [int] NOT NULL,
	[Country_Destination] nvarchar(255) NOT NULL,
	[Country_Destination_cod] nvarchar(50) NOT NULL,
	[Recipient_ID] [int] NOT NULL,
	[Sender_ID] [int] NOT NULL,
	[Sender_Address_ID] [int] NOT NULL,
	[Delivery_Condition] nvarchar(10) NOT NULL,
	[Product_Code] [int] NOT NULL,
	Date_Sender datetime2,
	Mark nvarchar(50) NULL,
	[Company] nvarchar(255)  NULL,
	[Purpose] nvarchar(255) NULL,
	[Product] nvarchar(50) NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

alter table dbo.Stat_Full add constraint Item_Number_list_full unique([Item_Number],[Item_number_list]);--����������� ��� ��� ����� ��������� � ������� ������ ������ ������������,
																							  --������������ ��������� ����

/*********������� � �����������************/

create TABLE Invoice_Number (
	ID_Invoice_Number integer identity (1,1) NOT NULL, --���� �����������
	Item_Number varchar(50) NOT NULL, --����� ���������
	Item_Number_list integer NOT NULL,--����� ������� � ��������� --��� ���� Item_Number � Item_number_list ������������ ���������� ���� 
	Date_Sender datetime2,--���� ��������
  CONSTRAINT [PK_�����_���������] PRIMARY KEY CLUSTERED
  (
  [ID_Invoice_Number] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)
GO

			
/*****������� ��������***********/
--� ���� �������� �������� ��� ��������� ���������� ��������� �� ����. � �������� ��� ���� �� ������ � ���������� ������������.
CREATE TABLE [Description] (
	ID_Description integer identity (1,1) NOT NULL, --���� �����������
	[Description] nvarchar(max) NOT NULL,--���� �������� (����� �������� �����)
	Item_Number integer NOT NULL, --����� � �������� ���������� ������ ���������
  CONSTRAINT [PK_Description] PRIMARY KEY CLUSTERED
  (
  [ID_Description] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)
ALTER TABLE [Description] WITH CHECK ADD CONSTRAINT [Description_fk0] 
FOREIGN KEY ([Item_Number]) REFERENCES Invoice_Number([ID_Invoice_Number])

GO

/*******������� [���_������] *************/
--��� � ���������
CREATE TABLE [Gross_Weight] (
	ID_Gross_Weight integer identity (1,1) NOT NULL,
	Gross_Weight decimal NOT NULL, --��� ������
	Item_Number integer NOT NULL, --����� � �������� ���������� ������ ���������
  CONSTRAINT [PK_Gross_Weight] PRIMARY KEY CLUSTERED
  (
  ID_Gross_Weight ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)


ALTER TABLE [Gross_Weight] WITH CHECK 
ADD CONSTRAINT [Gross_Weight_fk0] FOREIGN KEY ([Item_Number]) REFERENCES Invoice_Number([ID_Invoice_Number])
ALTER TABLE Gross_Weight
ADD CONSTRAINT CHK_Gross_Weight CHECK (Gross_Weight>=0); --�������� ����������� �� ���, �� ������ ���� ������������� ��������


GO

/*******������� [���_�����] *************/
--��� ��� ��������
CREATE TABLE Net_Weight (
	ID_Net_Weight integer identity (1,1) NOT NULL,
	Net_Weight decimal NOT NULL,
	Item_Number integer NOT NULL, --����� � �������� ���������� ������ ���������
  CONSTRAINT [PK_Net_Weight] PRIMARY KEY CLUSTERED
  (
  ID_Net_Weight ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
ALTER TABLE Net_Weight WITH CHECK ADD CONSTRAINT [Net_Weight_fk0] 
FOREIGN KEY ([Item_Number]) REFERENCES Invoice_Number([ID_Invoice_Number])
ALTER TABLE Net_Weight
ADD CONSTRAINT CHK_Net_Weight CHECK (Net_Weight>=0);

GO

/***********[���������_������]*************/
--���������_������
CREATE TABLE Price_Product (
	ID_Price_Product integer identity (1,1) NOT NULL,
	Price_Product decimal NOT NULL,
	Item_Number integer NOT NULL, --����� � �������� ���������� ������ ���������
  CONSTRAINT [PK_Price_Product] PRIMARY KEY CLUSTERED
  (
  ID_Price_Product ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)
ALTER TABLE Price_Product WITH CHECK ADD CONSTRAINT [Price_Product_fk0] 
FOREIGN KEY ([Item_Number]) REFERENCES Invoice_Number([ID_Invoice_Number])
ALTER TABLE Price_Product
ADD CONSTRAINT CHK_Price_Product CHECK (Price_Product>=0);


GO

/*********[�����������]**************/
--������� ��� ��������
CREATE TABLE Direction (
	ID_Direction integer identity (1,1) NOT NULL,
	Direction varchar(10) NOT NULL,
	Item_Number integer NOT NULL,--����� � �������� ���������� ������ ���������
  CONSTRAINT [PK_Direction] PRIMARY KEY CLUSTERED
  (
  ID_Direction ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)


ALTER TABLE Direction WITH CHECK ADD CONSTRAINT [Direction_fk0] 
FOREIGN KEY ([Item_Number]) REFERENCES Invoice_Number([ID_Invoice_Number])

GO

/********[�����������]*****************/
--�����������
CREATE TABLE Sender (
	ID_Sender integer identity (1,1) NOT NULL,
	Sender_INN integer NOT NULL,
	Item_Number integer NOT NULL,--����� � �������� ���������� ������ ���������
	Sender_Name varchar(255) NOT NULL,
  CONSTRAINT [PK_�����������] PRIMARY KEY CLUSTERED
  (
  ID_Sender ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)

ALTER TABLE Sender WITH CHECK ADD CONSTRAINT [Sender_fk0] 
FOREIGN KEY ([Item_Number]) REFERENCES Invoice_Number([ID_Invoice_Number])

GO


CREATE TABLE Sender_Address (
	ID_Sender_Address integer identity (1,1) NOT NULL,
	Sender_Address varchar(255) NOT NULL,
  CONSTRAINT [PK_�����������_�����] PRIMARY KEY CLUSTERED
  (
  ID_Sender_Address ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)


--� ����������� ����� ���� ��������� ������� �� � ��
CREATE TABLE Sender_Connection (
	ID_Sender_Connection integer identity (1,1) NOT NULL,
	Sender_ID integer NOT NULL,
	Sender_Address_ID integer NOT NULL,
  CONSTRAINT [PK_Sender_Connection] PRIMARY KEY CLUSTERED
  (
  ID_Sender_Connection ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)

ALTER TABLE Sender_Connection WITH CHECK ADD CONSTRAINT [Sender_Connection_fk0] 
FOREIGN KEY ([Sender_ID]) REFERENCES Sender(ID_Sender)

ALTER TABLE Sender_Connection WITH CHECK ADD CONSTRAINT [Sender_Connection_fk1] 
FOREIGN KEY ([Sender_Address_ID]) REFERENCES Sender_Address(ID_Sender_Address)
go

/**********[����������]*************/

CREATE TABLE Recipient (
	ID_Recipient integer identity (1,1) NOT NULL,
	Recipient_INN integer NOT NULL,
	Item_Number integer NOT NULL,--����� � �������� ���������� ������ ���������
	Recipient_Name varchar(255) NOT NULL,
  CONSTRAINT [PK_Recipient] PRIMARY KEY CLUSTERED
  (
  ID_Recipient ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)

ALTER TABLE Recipient WITH CHECK ADD CONSTRAINT [Recipient_fk0] 
FOREIGN KEY ([Item_Number]) REFERENCES Invoice_Number([ID_Invoice_Number])

GO

CREATE TABLE Recipient_Address (
	 ID_Recipient_Address integer identity (1,1) NOT NULL
	,Recipient_Address varchar(255) NOT NULL,
  CONSTRAINT [PK_Recipient_Address] PRIMARY KEY CLUSTERED
  (
  ID_Recipient_Address ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
--� ���������� ����� ���� ��������� �������
CREATE TABLE Recipient_Connection (
	ID_Recipient_Connection integer NOT NULL,
	Recipient_ID integer NOT NULL,
	Recipient_Address_ID integer NOT NULL,
  CONSTRAINT [PK_Recipient_Connection] PRIMARY KEY CLUSTERED
  (
  ID_Recipient_Connection ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)

ALTER TABLE Recipient_Connection WITH CHECK ADD CONSTRAINT [Recipient_Connection_fk0]
FOREIGN KEY ([Recipient_ID]) REFERENCES Recipient(ID_Recipient)

ALTER TABLE Recipient_Connection WITH CHECK ADD CONSTRAINT [Recipient_Connection_fk1] 
FOREIGN KEY (Recipient_Address_ID) REFERENCES Recipient_Address(ID_Recipient_Address)

GO


/*********[������_�����������]***********/

CREATE TABLE Country_Departure (
	ID_Country_Departure integer identity (1,1) NOT NULL,
	Country_Departure varchar(255) NOT NULL,
	Country_Departure_Cod varchar(50) NOT NULL,
	Country_Departure_Cod_Int integer NOT NULL,
	Item_Number integer NOT NULL,--����� � �������� ���������� ������ ���������
  CONSTRAINT [PK_Country_Departure] PRIMARY KEY CLUSTERED
  (
  ID_Country_Departure ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)

ALTER TABLE Country_Departure WITH CHECK ADD CONSTRAINT [Country_Departure_fk0] 
FOREIGN KEY ([Item_Number]) REFERENCES Invoice_Number([ID_Invoice_Number])

GO

/*********[C�����_����������]***************/
--���� ���������
CREATE TABLE Country_Destination (
	ID_Country_Destination  integer identity (1,1) NOT NULL,
	Country_Destination varchar(255) NOT NULL,
	Country_Destination_Cod varchar(50) NOT NULL,
	Country_Destination_Int integer NOT NULL,
	Item_Number integer NOT NULL--����� � �������� ���������� ������ ���������
	 ,CONSTRAINT [PK_ID_Country_Destination] PRIMARY KEY CLUSTERED
  (
  ID_Country_Destination ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)


ALTER TABLE Country_Destination WITH CHECK ADD CONSTRAINT [Country_Destination_fk0] 
FOREIGN KEY ([Item_Number]) REFERENCES Invoice_Number([ID_Invoice_Number])

GO

/******[�������_��������]********/

CREATE TABLE Delivery_Condition (
	ID_Delivery_Condition integer identity (1,1) NOT NULL,
	Item_Number integer NOT NULL,--����� � �������� ���������� ������ ���������
	Delivery_Condition varchar(10) NOT NULL,
  CONSTRAINT [PK_Delivery_Condition] PRIMARY KEY CLUSTERED
  (
  ID_Delivery_Condition ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)

ALTER TABLE Delivery_Condition WITH CHECK ADD CONSTRAINT [Delivery_Condition_fk0]
FOREIGN KEY ([Item_Number]) REFERENCES Invoice_Number([ID_Invoice_Number])

GO

/********[���_��������]**********/
--���������� ��� ��������

CREATE TABLE Product_Code (
	ID_Product_Code integer identity (1,1) NOT NULL,
	Product_Code integer NOT NULL,
	Item_Number integer NOT NULL,--����� � �������� ���������� ������ ���������
  CONSTRAINT [PK_Product_Code] PRIMARY KEY CLUSTERED
  (
  ID_Product_Code ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)

ALTER TABLE Product_Code  WITH CHECK ADD CONSTRAINT [���_��������_fk1] 
FOREIGN KEY ([Item_Number]) REFERENCES Invoice_Number([ID_Invoice_Number])


/***********�����������********************/
--������ ����� dir ��� ���������, ��� �����������
--���������� ����� �������� � ���� ����� ��� ������ ����� � ���� ��������
--create SCHEMA dir;
CREATE TABLE dir.Mark (
	ID_Mark integer identity (1,1) NOT NULL,
	Mark varchar(50) NOT NULL,
	Company_ID integer NOT NULL,
	Purpose_ID integer NOT NULL,
	Product_ID integer NOT NULL,
	Mask1 varchar(50) NOT NULL,
	Mask2 varchar(50),
	Mask3 varchar(50),
  CONSTRAINT [PK_Mark] PRIMARY KEY CLUSTERED
  (
  ID_Mark ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE dir.Company (
	ID_Company integer identity (1,1) NOT NULL,
	Company varchar(255) NOT NULL,
  CONSTRAINT [PK_Company] PRIMARY KEY CLUSTERED
  (
  ID_Company ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE dir.Product (
	ID_Product integer identity (1,1) NOT NULL,
	Product varchar(50) NOT NULL,
  CONSTRAINT [PK_Product] PRIMARY KEY CLUSTERED
  (
  ID_Product ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE dir.Purpose (
	ID_Purpose integer identity (1,1) NOT NULL,
	Purpose varchar(255) NOT NULL,
  CONSTRAINT [PK_Purpose] PRIMARY KEY CLUSTERED
  (
  ID_Purpose ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
ALTER TABLE [dir].Mark WITH CHECK ADD CONSTRAINT [Mark_fk0] 
FOREIGN KEY ([Company_ID]) REFERENCES [dir].Company(ID_Company)


ALTER TABLE [dir].Mark WITH CHECK ADD CONSTRAINT [Mark_fk1] 
FOREIGN KEY ([Purpose_id]) REFERENCES [dir].Purpose(ID_Purpose)


ALTER TABLE [dir].Mark WITH CHECK ADD CONSTRAINT [Mark_fk2] 
FOREIGN KEY ([Product_id]) REFERENCES [dir].Product(ID_Product)

GO

