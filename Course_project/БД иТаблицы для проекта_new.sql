use master;
go

/*������ �� � ����� ��������� ��������, ����������� � ����� ��������� ����������� ���������
, � ������ �����������(������������ ��� ���������)
	���������� �������� ������ ������ �� ������ ���������� ����, ����� ��� ����� �������. 
	���� ����� �����, ��� ����� ��� � ������� ���������*/
CREATE DATABASE P_Stat
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = P_Stat, FILENAME = N'C:\P_Stat\P_Stat.mdf' , 
	SIZE = 8MB , 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 65536KB )
	, ( NAME = P_Stat2, FILENAME = N'C:\P_Stat\P_Stat_2.mdf' , 
	SIZE = 8MB , 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 65536KB )
 LOG ON 
( NAME = P_Stat_log, FILENAME = N'D:\P_Stat\P_Stat_log.ldf' , 
	SIZE = 8MB , 
	MAXSIZE = 100GB , 
	FILEGROWTH = 65536KB )
	COLLATE Cyrillic_General_CI_AS
GO

--SELECT *
--FROM ::fn_helpcollations()

--select @@SERVERNAME


/***************************************************************/
use P_Stat;
go

/*****************�������� ������� ******************************/
--�������� ������� ����� 50,000 ������� �����������

CREATE TABLE [dbo].[stat](
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
go
CREATE TABLE [dbo].[stat_full](
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
	Mark nvarchar(50) NULL,
	[Company] nvarchar(255)  NULL,
	[purpose] nvarchar(255) NULL,
	[Product] nvarchar(50) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

alter table dbo.stat_full add constraint Item_Number_list_full unique([Item_Number],[Item_number_list]);--����������� ��� ��� ����� ��������� � ������� ������ ������ ������������,
																							  --������������ ��������� ����

/*********������� � �����������************/

create TABLE [�����_���������] (
	Item_Number varchar(50) NOT NULL, --����� ���������
	Item_number_list integer NOT NULL,--����� ������� � ��������� --��� ���� Item_Number � Item_number_list ������������ ���������� ���� 
	id integer identity (1,1) NOT NULL, --���� �����������
	date_sender datetime2,--���� ��������
  CONSTRAINT [PK_�����_���������] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)
GO

			
/*****������� ��������***********/
--� ���� �������� �������� ��� ��������� ���������� ��������� �� ����. � �������� ��� ���� �� ������ � ���������� ������������.
CREATE TABLE [��������] (
	id integer identity (1,1) NOT NULL, --���� �����������
	�������� nvarchar(max) NOT NULL,--���� �������� (����� �������� �����)
	Item_Number integer NOT NULL, --����� � �������� ���������� ������ ���������
  CONSTRAINT [PK_��������] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)
ALTER TABLE [��������] WITH CHECK ADD CONSTRAINT [��������_fk0] FOREIGN KEY ([Item_Number]) REFERENCES [�����_���������]([id])

GO

/*******������� [���_������] *************/
--��� � ���������
CREATE TABLE [���_������] (
	Gross_weight decimal NOT NULL, --��� ������
	id integer identity (1,1) NOT NULL,
	Item_Number integer NOT NULL, --����� � �������� ���������� ������ ���������
  CONSTRAINT [PK_���_������] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)


ALTER TABLE [���_������] WITH CHECK 
ADD CONSTRAINT [���_������_fk0] FOREIGN KEY ([Item_Number]) REFERENCES [�����_���������]([id])
ALTER TABLE [���_������]
ADD CONSTRAINT CHK_Gross_weight CHECK (Gross_weight>=0); --�������� ����������� �� ���, �� ������ ���� ������������� ��������



GO

/*******������� [���_�����] *************/
--��� ��� ��������
CREATE TABLE [���_�����] (
	Net_weight decimal NOT NULL,
	id integer identity (1,1) NOT NULL,
	Item_Number integer NOT NULL, --����� � �������� ���������� ������ ���������
  CONSTRAINT [PK_���_�����] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
ALTER TABLE [���_�����] WITH CHECK ADD CONSTRAINT [���_�����_fk0] FOREIGN KEY ([Item_Number]) REFERENCES [�����_���������]([id])
ALTER TABLE [���_�����]
ADD CONSTRAINT CHK_Net_weight CHECK (Net_weight>=0);

GO

/***********[���������_������]*************/
--���������_������
CREATE TABLE [���������_������] (
	id integer identity (1,1) NOT NULL,
	price_product decimal NOT NULL,
	Item_Number integer NOT NULL, --����� � �������� ���������� ������ ���������
  CONSTRAINT [PK_���������_������] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)
ALTER TABLE [���������_������] WITH CHECK ADD CONSTRAINT [���������_������_fk0] FOREIGN KEY ([Item_Number]) REFERENCES [�����_���������]([id])
ALTER TABLE [���������_������]
ADD CONSTRAINT CHK_price_product CHECK (price_product>=0);


GO

/*********[�����������]**************/
--������� ��� ��������
CREATE TABLE [�����������] (
	direction varchar(10) NOT NULL,
	id integer identity (1,1) NOT NULL,
	Item_Number integer NOT NULL,--����� � �������� ���������� ������ ���������
  CONSTRAINT [PK_�����������] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)


ALTER TABLE [�����������] WITH CHECK ADD CONSTRAINT [�����������_fk0] FOREIGN KEY ([Item_Number]) 
REFERENCES [�����_���������]([id])

GO

/********[�����������]*****************/
--�����������
CREATE TABLE [�����������] (
	id integer identity (1,1) NOT NULL,
	sender_inn integer NOT NULL,
	Item_Number integer NOT NULL,--����� � �������� ���������� ������ ���������
	sender_name varchar(255) NOT NULL,
  CONSTRAINT [PK_�����������] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)

ALTER TABLE [�����������] WITH CHECK ADD CONSTRAINT [�����������_fk0] FOREIGN KEY ([Item_Number]) 
REFERENCES [�����_���������]([id])

GO


CREATE TABLE [�����������_�����] (
	sender_address varchar(255) NOT NULL,
	id integer identity (1,1) NOT NULL,
  CONSTRAINT [PK_�����������_�����] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)



--� ����������� ����� ���� ��������� ������� �� � ��
CREATE TABLE [�����������_�����] (
	id integer identity (1,1) NOT NULL,
	sender_id integer NOT NULL,
	sender_address_id integer NOT NULL,
  CONSTRAINT [PK_�����������_�����] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)

ALTER TABLE [�����������_�����] WITH CHECK ADD CONSTRAINT [�����������_�����_fk0] FOREIGN KEY ([sender_id]) REFERENCES [�����������]([id])

GO

ALTER TABLE [�����������_�����] WITH CHECK ADD CONSTRAINT [�����������_�����_fk1] FOREIGN KEY ([sender_address_id]) REFERENCES [�����������_�����](id)
go

/**********[����������]*************/

CREATE TABLE [����������] (
	id integer identity (1,1) NOT NULL,
	recipient_inn integer NOT NULL,
	Item_Number integer NOT NULL,--����� � �������� ���������� ������ ���������
	recipient_name varchar(255) NOT NULL,
  CONSTRAINT [PK_����������] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)

ALTER TABLE [����������] WITH CHECK ADD CONSTRAINT [����������_fk0] FOREIGN KEY ([Item_Number]) REFERENCES [�����_���������]([id])

GO
CREATE TABLE [����������_�����] (
	recipient_address varchar(255) NOT NULL,
	id integer identity (1,1) NOT NULL,
  CONSTRAINT [PK_����������_�����] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
--� ���������� ����� ���� ��������� �������
CREATE TABLE [����������_�����] (
	id integer NOT NULL,
	recipient_id integer NOT NULL,
	recipient_address_id integer NOT NULL,
  CONSTRAINT [PK_����������_�����] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)

ALTER TABLE [����������_�����] WITH CHECK ADD CONSTRAINT [����������_�����_fk0] FOREIGN KEY ([recipient_id]) REFERENCES [����������]([id])

GO

ALTER TABLE [����������_�����] WITH CHECK ADD CONSTRAINT [����������_�����_fk1] FOREIGN KEY ([recipient_address_id]) REFERENCES [����������_�����](id)

GO


/*********[������_�����������]***********/

CREATE TABLE [������_�����������] (
	id integer identity (1,1) NOT NULL,
	country_departure varchar(255) NOT NULL,
	country_departure_cod varchar(50) NOT NULL,
	country_departure_cod_int integer NOT NULL,
	Item_Number integer NOT NULL,--����� � �������� ���������� ������ ���������
  CONSTRAINT [PK_������_�����������] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)

ALTER TABLE [������_�����������] WITH CHECK ADD CONSTRAINT [������_�����������_fk0] FOREIGN KEY ([Item_Number]) REFERENCES [�����_���������]([id])

GO

/*********[C�����_����������]***************/
--���� ���������
CREATE TABLE [C�����_����������] (
	country_destination varchar(255) NOT NULL,
	country_destination_cod varchar(50) NOT NULL,
	country_destination_cod_int integer NOT NULL,
	Item_Number integer NOT NULL--����� � �������� ���������� ������ ���������
)

ALTER TABLE [C�����_����������] WITH CHECK ADD CONSTRAINT [C�����_����������_fk0] FOREIGN KEY ([Item_Number]) REFERENCES [�����_���������]([id])

GO

/******[�������_��������]********/

CREATE TABLE [�������_��������] (
	id integer identity (1,1) NOT NULL,
	Item_Number integer NOT NULL,--����� � �������� ���������� ������ ���������
	delivery_condition varchar(10) NOT NULL,
  CONSTRAINT [PK_�������_��������] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)

ALTER TABLE [�������_��������] WITH CHECK ADD CONSTRAINT [�������_��������_fk0]FOREIGN KEY ([Item_Number]) REFERENCES [�����_���������]([id])

GO

/********[���_��������]**********/
--���������� ��� ��������

CREATE TABLE [���_��������] (
	id integer identity (1,1) NOT NULL,
	product_code integer NOT NULL,
	Item_Number integer NOT NULL,--����� � �������� ���������� ������ ���������
  CONSTRAINT [PK_���_��������] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)

ALTER TABLE [dbo].[���_��������]  WITH CHECK ADD CONSTRAINT [���_��������_fk1] FOREIGN KEY([Item_Number])
REFERENCES [dbo].[�����_���������] ([id])

/***********�����������********************/
--������ ����� dir ��� ���������, ��� �����������
--���������� ����� �������� � ���� ����� ��� ������ ����� � ���� ��������
--create SCHEMA dir;
CREATE TABLE dir.[�����] (
	id integer identity (1,1) NOT NULL,
	Mark varchar(50) NOT NULL,
	Company_id integer NOT NULL,
	purpose_id integer NOT NULL,
	Product_id integer NOT NULL,
	Mask1 varchar(50) NOT NULL,
	Mask2 varchar(50),
	Mask3 varchar(50),
  CONSTRAINT [PK_�����] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE dir.[��������] (
	id integer identity (1,1) NOT NULL,
	Company varchar(255) NOT NULL,
  CONSTRAINT [PK_��������] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE dir.[�������] (
	id integer identity (1,1) NOT NULL,
	Product varchar(50) NOT NULL,
  CONSTRAINT [PK_�������] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE dir.[����������] (
	id integer identity (1,1) NOT NULL,
	purpose varchar(255) NOT NULL,
  CONSTRAINT [PK_����������] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
ALTER TABLE [dir].[�����] WITH CHECK ADD CONSTRAINT [�����_fk0] FOREIGN KEY ([Company_id]) REFERENCES [dir].[��������]([id])


ALTER TABLE [dir].[�����] WITH CHECK ADD CONSTRAINT [�����_fk1] FOREIGN KEY ([purpose_id]) REFERENCES [dir].[����������]([id])


ALTER TABLE [dir].[�����] WITH CHECK ADD CONSTRAINT [�����_fk2] FOREIGN KEY ([Product_id]) REFERENCES [dir].[�������]([id])

go

