/******************************
** File: SCD_Type_1_Using_Merge.sql 
** Name: SCD_Type_1_Using_Merge
** Desc: Sample implementation of SCD Type 1 using SQL Merge
** Auth: Unnati Palan
** Date: 11/04/2020
**************************
** Change History
**************************
** PR   Date        Author  Description 
** --   --------   -------   ------------------------------------

*******************************/

declare @record_date date = getdate()-10 --this variable marks a date 10 days ago 

declare @dimension_table table ( --a sample dimension table with customer attributes
customer_id int, --  key column
title nvarchar(10), -- type 1 dimension
first_name nvarchar(100),  
last_name nvarchar(100), --  type 1 dimension
mobile bigint,
from_date date, --  date of load or update
to_date date, --  record valid till date
current_record nvarchar(1)  -- flag to identify latest record
)

declare @src_table table ( --  source table with customer attributes
customer_id int,
title nvarchar(10),
first_name nvarchar(100),
last_name nvarchar(100),
mobile bigint,
record_date date
)

insert into @src_table
values 
(1,'Ms','Jane','Smith',99020344,@record_date),
(2,'Mrs','Aparna','Mitra',89020345,@record_date),
(3,'Mr','Ramki','Bhat',89010345,@record_date)


select *,'source' tablename ,'Initializing Data in Source' status from @src_table

select case when count(*) = 0 then 'Dimension Table is empty' END status from @dimension_table

/*
We have initialized the source table with sample data. We have also checked to see if the dimension table has any values.
*/

merge @dimension_table as dest using @src_table as src  --  Merging source table with dimension table
ON (dest.customer_id = src.customer_id)  -- matching the key columns
WHEN MATCHED
	THEN UPDATE SET  -- updating dimension table with following values if the customer_id keys match
	      dest.title = src.title,
		  dest.first_name = src.first_name,
		  dest.last_name = src.last_name,
		  dest.mobile = src.mobile,
		  dest.from_date = src.record_date,
		  dest.to_date = '9999-12-31',  -- adding a value for expiry date (usually a date very far in the future)
		  dest.current_record = 'Y'  -- marks current record (not necessary for a table with only SCD Type 1 Columns)
WHEN NOT MATCHED   -- if the keys do not match, inserting the following values
	THEN INSERT (customer_id,title,first_name,last_name,mobile,from_date,to_date,current_record)
		 VALUES(src.customer_id,src.title,src.first_name,src.last_name,src.mobile,src.record_date,'9999-12-31','Y')
;		

select *,'dimension' tablename,'Dimesion in sync with Source' status from @dimension_table -- checking dimension table after merging with source table

update @src_table  -- updating source table with values for title, last_name and record_date
set 
title = 'Ms',
last_name = 'Sen',record_date = getdate()
where customer_id = 1

insert into @src_table  -- inserting a new record in the source table
values (4,'Mr','Aditya','Sen',99020323,@record_date)

select *,'source' tablename,'Updated & Added Record in Source' status from @src_table --displaying the updated source table

merge @dimension_table as dest using @src_table as src  -- rerunning the merge to check if latest changes are merged in dimension table
ON (dest.customer_id = src.customer_id)
WHEN MATCHED 
	THEN UPDATE SET
	      dest.title = src.title,
		  dest.first_name = src.first_name,
		  dest.last_name = src.last_name,
		  dest.mobile = src.mobile,
		  dest.from_date = src.record_date,
		  dest.to_date = '9999-12-31',
		  dest.current_record = 'Y'
WHEN NOT MATCHED 
	THEN INSERT (customer_id,title,first_name,last_name,mobile,from_date,to_date,current_record)
		 VALUES(src.customer_id,src.title,src.first_name,src.last_name,src.mobile,src.record_date,'9999-12-31','Y')
;		

select *,'dimension' tablename,'Dimension in sync with Source again' status from @dimension_table  -- checking if the dimension and source table are in sync

