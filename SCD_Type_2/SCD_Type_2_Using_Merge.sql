/******************************
** File: SCD_Type_2_Using_Merge.sql 
** Name: SCD_Type_2_Using_Merge
** Desc: Sample implementation of SCD Type 2 using SQL Merge
** Auth: Unnati Palan
** Date: 14/04/2020
**************************
** Change History
**************************
** PR   Date        Author  Description 
** --   --------   -------   ------------------------------------

*******************************/
/*
Questions and points to note while attempting an SCD Type 2 Merge-

1. Which columns in the Destination Table are SCD Type 2?
2. What should be the from_date of the latest record - getdate() or a system date from source?
3. The to_date column for a historic record should be updated using the record_date - 1 
4. It is possible to have more than one key column between source and destination. Configure the ON clause of the MERGE match accordingly

*/

declare @record_date date = getdate()-10 --this variable marks a date 10 days ago 

declare @dimension_table table ( --a sample dimension table with customer attributes
customer_id int, --  key column
title nvarchar(10), -- type 2 dimension
first_name nvarchar(100),  --  type 2 dimension
last_name nvarchar(100), --  type 2 dimension
mobile bigint, --  type 2 dimension
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

insert into @dimension_table (
			customer_id
	       ,title
		   ,first_name
		   ,last_name,
		    mobile
		   ,from_date
		   ,to_date
		   ,current_record
		   )

select customer_id
	       ,title
		   ,first_name
		   ,last_name,
		    mobile
		   ,from_date
		   ,to_date
		   ,current_record from
(
merge @dimension_table as dest using @src_table as src  -- rerunning the merge to check if latest changes are merged in dimension table
ON (dest.customer_id = src.customer_id)
WHEN MATCHED 

AND (dest.title <> src.title or dest.last_name <>src.last_name or dest.first_name <> src.first_name or dest.mobile <>src.mobile)
--Question 1 determines what columns are added in the AND clause
	THEN UPDATE SET 
		  dest.to_date = dateadd(DAY,-1,src.record_date),
		  dest.current_record = 'N'
    
WHEN NOT MATCHED 
	THEN INSERT (customer_id,title,first_name,last_name,mobile,from_date,to_date,current_record)
		 VALUES(src.customer_id,src.title,src.first_name,src.last_name,src.mobile,src.record_date,'9999-12-31','Y')
OUTPUT $action as [status], src.customer_id,
				src.title, 
                src.last_name, 
                src.first_name, 
				src.mobile, 
				src.record_date as from_date,
				'9999-12-31' as to_date,
				'Y' as current_record
) as changed_rows where [status] = 'UPDATE';
select *,'dimension' tablename, 'Inserting dimension records for the first time' [status] from @dimension_table


update @src_table  -- updating source table with values for title, last_name and record_date
set 
title = 'Mrs',
last_name = 'Sen',record_date = getdate()
where customer_id = 1

select *,'source' tablename,'Updated & Added Record in Source' status from @src_table --displaying the updated source table


insert into @dimension_table (
			customer_id
	       ,title
		   ,first_name
		   ,last_name,
		    mobile
		   ,from_date
		   ,to_date
		   ,current_record
		   )

select customer_id
	       ,title
		   ,first_name
		   ,last_name,
		    mobile
		   ,from_date
		   ,to_date
		   ,current_record from
(
merge @dimension_table as dest using @src_table as src  -- rerunning the merge to check if latest changes are merged in dimension table
ON (dest.customer_id = src.customer_id) 
WHEN MATCHED 

AND (dest.title <> src.title or dest.last_name <>src.last_name or dest.first_name <> src.first_name or dest.mobile <>src.mobile)
--Question 1 determines what columns are added in the AND clause
	THEN UPDATE SET 
		  dest.to_date = dateadd(DAY,-1,src.record_date),
		  dest.current_record = 'N'
    
WHEN NOT MATCHED 
	THEN INSERT (customer_id,title,first_name,last_name,mobile,from_date,to_date,current_record)
		 VALUES(src.customer_id,src.title,src.first_name,src.last_name,src.mobile,src.record_date,'9999-12-31','Y')
OUTPUT $action as [status], -- The $action column marks the type of action performed on the destination table
				src.customer_id,
				src.title, 
                src.last_name, 
                src.first_name, 
				src.mobile, 
				src.record_date as from_date,
				'9999-12-31' as to_date,
				'Y' as current_record
) as changed_rows where [status] = 'UPDATE'; -- The where clause filters only the rows that were updated

select *,'dimension' tablename, 'SCD Type 2 Merge successful' [status] from @dimension_table