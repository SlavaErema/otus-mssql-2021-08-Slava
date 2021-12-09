use master;
go

/*Создаю БД с двумя файловыми группами, предпологаю в одной проводить оперативную обработку
, в другой накапливать(использовать как хранилище)
	Логическую файловую группу выношу на другой физический диск, думаю так будет быстрее. 
	Хотя после бэкап, лог файлы как я понимаю очищаются*/
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

/*****************входящая таблица ******************************/
--входящая таблица около 50,000 записей еженедельно

CREATE TABLE [dbo].[stat](
	[Item_Number] nvarchar(50) NOT NULL,
	[Item_number_list] [int] NOT NULL,
	[Описание] [nvarchar](max) NOT NULL,
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

alter table dbo.stat add constraint Item_Number_list unique([Item_Number],[Item_number_list]);--ограничение так как номер накладной и позиция должны давать уникальность,
																							  --естественный составной ключ

/*Проверка названий полей*/
--мне в этой проверке не нравится, что если одно поле слетает, все следующие за ним также выводятся
    select q1.t1, q.t
   from
 (  
   SELECT /*COUNT(COLUMN_NAME) */ COLUMN_NAME as t, ORDINAL_POSITION as w
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE 
    TABLE_CATALOG = 'P_Stat'
    AND TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = 'stat_full' --накопительная таблица
  ) as q
 right join
  ( 
   SELECT /*COUNT(COLUMN_NAME) */ COLUMN_NAME as t1,ORDINAL_POSITION as w1
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE 
    TABLE_CATALOG = 'P_Stat'
    AND TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = 'stat' -- входящая таблица
) as q1
on q.t=q1.t1 and q.w=q1.w1
where q.t is null

/*Проверка дублей с основной базой и удаление*/

begin tran
IF OBJECT_ID('dbo.Double_stat', 'U') IS NOT NULL
  DROP TABLE dbo.Double_stat
GO
--[Item_Number],[Item_number_list] -- естественный составной ключ
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
print ('совпадающих номеров нет')
end;
commit tran;

/*******удаление задвоений****************/
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

--сливаем в таблицу
--truncate table [dbo].[stat_full];
go
CREATE TABLE [dbo].[stat_full](
	[Item_Number] nvarchar(50) NOT NULL,
	[Item_number_list] [int] NOT NULL,
	[Описание] [nvarchar](max) NOT NULL,
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

alter table dbo.stat_full add constraint Item_Number_list_full unique([Item_Number],[Item_number_list]);--ограничение так как номер накладной и позиция должны давать уникальность,
																							  --естественный составной ключ

/*********таблицы и справочники************/

create TABLE [Номер_накладной] (
	Item_Number varchar(50) NOT NULL, --номер накладной
	Item_number_list integer NOT NULL,--номер позиции в накладной --два поля Item_Number и Item_number_list естественный уникальный ключ 
	id integer identity (1,1) NOT NULL, --ключ суррогатный
	date_sender datetime2,--дата поставки
  CONSTRAINT [PK_НОМЕР_НАКЛАДНОЙ] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)
GO

			
/*****таблица описание***********/
--в поле описание попадает все текстовое заполнение накладных от руки. В основном это каша из фактов и творчества заполнявшего.
CREATE TABLE [Описание] (
	id integer identity (1,1) NOT NULL, --ключ суррогатный
	Описание nvarchar(max) NOT NULL,--поле описания (самая объемная часть)
	Item_Number integer NOT NULL, --связь с таблицей содержащей номера накладных
  CONSTRAINT [PK_ОПИСАНИЕ] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)
ALTER TABLE [Описание] WITH CHECK ADD CONSTRAINT [Описание_fk0] FOREIGN KEY ([Item_Number]) REFERENCES [Номер_накладной]([id])

GO

/*******таблица [Вес_брутто] *************/
--вес с упаковкой
CREATE TABLE [Вес_брутто] (
	Gross_weight decimal NOT NULL, --вес брутто
	id integer identity (1,1) NOT NULL,
	Item_Number integer NOT NULL, --связь с таблицей содержащей номера накладных
  CONSTRAINT [PK_ВЕС_БРУТТО] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)


ALTER TABLE [Вес_брутто] WITH CHECK 
ADD CONSTRAINT [Вес_брутто_fk0] FOREIGN KEY ([Item_Number]) REFERENCES [Номер_накладной]([id])
ALTER TABLE [Вес_брутто]
ADD CONSTRAINT CHK_Gross_weight CHECK (Gross_weight>=0); --поставил ограничение на вес, не должно быть отрицательных значений



GO

/*******таблица [Вес_нетто] *************/
--вес без упаковки
CREATE TABLE [Вес_нетто] (
	Net_weight decimal NOT NULL,
	id integer identity (1,1) NOT NULL,
	Item_Number integer NOT NULL, --связь с таблицей содержащей номера накладных
  CONSTRAINT [PK_ВЕС_НЕТТО] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
ALTER TABLE [Вес_нетто] WITH CHECK ADD CONSTRAINT [Вес_нетто_fk0] FOREIGN KEY ([Item_Number]) REFERENCES [Номер_накладной]([id])
ALTER TABLE [Вес_нетто]
ADD CONSTRAINT CHK_Net_weight CHECK (Net_weight>=0);

GO

/***********[Стоимость_товара]*************/
--Стоимость_товара
CREATE TABLE [Стоимость_товара] (
	id integer identity (1,1) NOT NULL,
	price_product decimal NOT NULL,
	Item_Number integer NOT NULL, --связь с таблицей содержащей номера накладных
  CONSTRAINT [PK_СТОИМОСТЬ_ТОВАРА] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)
ALTER TABLE [Стоимость_товара] WITH CHECK ADD CONSTRAINT [Стоимость_товара_fk0] FOREIGN KEY ([Item_Number]) REFERENCES [Номер_накладной]([id])
ALTER TABLE [Стоимость_товара]
ADD CONSTRAINT CHK_price_product CHECK (price_product>=0);


GO

/*********[Направление]**************/
--продаем или покупаем
CREATE TABLE [Направление] (
	direction varchar(10) NOT NULL,
	id integer identity (1,1) NOT NULL,
	Item_Number integer NOT NULL,--связь с таблицей содержащей номера накладных
  CONSTRAINT [PK_НАПРАВЛЕНИЕ] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)


ALTER TABLE [Направление] WITH CHECK ADD CONSTRAINT [Направление_fk0] FOREIGN KEY ([Item_Number]) 
REFERENCES [Номер_накладной]([id])

GO

/********[Отправитель]*****************/
--Отправитель
CREATE TABLE [Отправитель] (
	id integer identity (1,1) NOT NULL,
	sender_inn integer NOT NULL,
	Item_Number integer NOT NULL,--связь с таблицей содержащей номера накладных
	sender_name varchar(255) NOT NULL,
  CONSTRAINT [PK_ОТПРАВИТЕЛЬ] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)

ALTER TABLE [Отправитель] WITH CHECK ADD CONSTRAINT [Отправитель_fk0] FOREIGN KEY ([Item_Number]) 
REFERENCES [Номер_накладной]([id])

GO


CREATE TABLE [Отправитель_адрес] (
	sender_address varchar(255) NOT NULL,
	id integer identity (1,1) NOT NULL,
  CONSTRAINT [PK_ОТПРАВИТЕЛЬ_АДРЕС] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)



--у отправителя может быть несколько адресов юр и тд
CREATE TABLE [Отправитель_связь] (
	id integer identity (1,1) NOT NULL,
	sender_id integer NOT NULL,
	sender_address_id integer NOT NULL,
  CONSTRAINT [PK_ОТПРАВИТЕЛЬ_СВЯЗЬ] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)

ALTER TABLE [Отправитель_связь] WITH CHECK ADD CONSTRAINT [Отправитель_связь_fk0] FOREIGN KEY ([sender_id]) REFERENCES [Отправитель]([id])

GO

ALTER TABLE [Отправитель_связь] WITH CHECK ADD CONSTRAINT [Отправитель_связь_fk1] FOREIGN KEY ([sender_address_id]) REFERENCES [Отправитель_адрес](id)
go

/**********[Получатель]*************/

CREATE TABLE [Получатель] (
	id integer identity (1,1) NOT NULL,
	recipient_inn integer NOT NULL,
	Item_Number integer NOT NULL,--связь с таблицей содержащей номера накладных
	recipient_name varchar(255) NOT NULL,
  CONSTRAINT [PK_ПОЛУЧАТЕЛЬ] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)

ALTER TABLE [Получатель] WITH CHECK ADD CONSTRAINT [Получатель_fk0] FOREIGN KEY ([Item_Number]) REFERENCES [Номер_накладной]([id])

GO
CREATE TABLE [Получатель_адрес] (
	recipient_address varchar(255) NOT NULL,
	id integer identity (1,1) NOT NULL,
  CONSTRAINT [PK_ПОЛУЧАТЕЛЬ_АДРЕС] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
--у получателя может быть несколько адресов
CREATE TABLE [Получатель_связь] (
	id integer NOT NULL,
	recipient_id integer NOT NULL,
	recipient_address_id integer NOT NULL,
  CONSTRAINT [PK_ПОЛУЧАТЕЛЬ_СВЯЗЬ] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)

ALTER TABLE [Получатель_связь] WITH CHECK ADD CONSTRAINT [Получатель_связь_fk0] FOREIGN KEY ([recipient_id]) REFERENCES [Получатель]([id])

GO

ALTER TABLE [Получатель_связь] WITH CHECK ADD CONSTRAINT [Получатель_связь_fk1] FOREIGN KEY ([recipient_address_id]) REFERENCES [Получатель_адрес](id)

GO


/*********[Страна_отправления]***********/

CREATE TABLE [Страна_отправления] (
	id integer identity (1,1) NOT NULL,
	country_departure varchar(255) NOT NULL,
	country_departure_cod varchar(50) NOT NULL,
	country_departure_cod_int integer NOT NULL,
	Item_Number integer NOT NULL,--связь с таблицей содержащей номера накладных
  CONSTRAINT [PK_СТРАНА_ОТПРАВЛЕНИЯ] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)

ALTER TABLE [Страна_отправления] WITH CHECK ADD CONSTRAINT [Страна_отправления_fk0] FOREIGN KEY ([Item_Number]) REFERENCES [Номер_накладной]([id])

GO

/*********[Cтрана_назначения]***************/
--куда отправили
CREATE TABLE [Cтрана_назначения] (
	country_destination varchar(255) NOT NULL,
	country_destination_cod varchar(50) NOT NULL,
	country_destination_cod_int integer NOT NULL,
	Item_Number integer NOT NULL--связь с таблицей содержащей номера накладных
)

ALTER TABLE [Cтрана_назначения] WITH CHECK ADD CONSTRAINT [Cтрана_назначения_fk0] FOREIGN KEY ([Item_Number]) REFERENCES [Номер_накладной]([id])

GO

/******[Условие_поставки]********/

CREATE TABLE [Условие_поставки] (
	id integer identity (1,1) NOT NULL,
	Item_Number integer NOT NULL,--связь с таблицей содержащей номера накладных
	delivery_condition varchar(10) NOT NULL,
  CONSTRAINT [PK_УСЛОВИЕ_ПОСТАВКИ] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)

ALTER TABLE [Условие_поставки] WITH CHECK ADD CONSTRAINT [Условие_поставки_fk0]FOREIGN KEY ([Item_Number]) REFERENCES [Номер_накладной]([id])

GO

/********[Код_продукта]**********/
--внутренний код продукта

CREATE TABLE [Код_продукта] (
	id integer identity (1,1) NOT NULL,
	product_code integer NOT NULL,
	Item_Number integer NOT NULL,--связь с таблицей содержащей номера накладных
  CONSTRAINT [PK_Код_продукта] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)
)

ALTER TABLE [dbo].[Код_продукта]  WITH CHECK ADD CONSTRAINT [Код_продукта_fk1] FOREIGN KEY([Item_Number])
REFERENCES [dbo].[Номер_накладной] ([id])

/***********Справочники********************/
--создал схему dir для понимания, где справочники
--справочник марки содержит в себе маски для поиска марок в поле описания
--create SCHEMA dir;
CREATE TABLE dir.[Марки] (
	id integer identity (1,1) NOT NULL,
	Mark varchar(50) NOT NULL,
	Company_id integer NOT NULL,
	purpose_id integer NOT NULL,
	Product_id integer NOT NULL,
	Mask1 varchar(50) NOT NULL,
	Mask2 varchar(50),
	Mask3 varchar(50),
  CONSTRAINT [PK_МАРКИ] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE dir.[Компании] (
	id integer identity (1,1) NOT NULL,
	Company varchar(255) NOT NULL,
  CONSTRAINT [PK_КОМПАНИИ] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE dir.[Продукт] (
	id integer identity (1,1) NOT NULL,
	Product varchar(50) NOT NULL,
  CONSTRAINT [PK_ПРОДУКТ] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE dir.[Назначение] (
	id integer identity (1,1) NOT NULL,
	purpose varchar(255) NOT NULL,
  CONSTRAINT [PK_НАЗНАЧЕНИЕ] PRIMARY KEY CLUSTERED
  (
  [id] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
ALTER TABLE [dir].[Марки] WITH CHECK ADD CONSTRAINT [Марки_fk0] FOREIGN KEY ([Company_id]) REFERENCES [dir].[Компании]([id])


ALTER TABLE [dir].[Марки] WITH CHECK ADD CONSTRAINT [Марки_fk1] FOREIGN KEY ([purpose_id]) REFERENCES [dir].[Назначение]([id])


ALTER TABLE [dir].[Марки] WITH CHECK ADD CONSTRAINT [Марки_fk2] FOREIGN KEY ([Product_id]) REFERENCES [dir].[Продукт]([id])

go

