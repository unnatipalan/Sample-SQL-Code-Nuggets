/******************************
** File: Output_Clause_with_Merge.sql
** Name: Output_Clause_with_Merge
** Desc: Implementation of the Output Clause in Merge 
** Auth: Unnati Palan
** Date: 13/04/2020
**************************
** Change History
**************************
** PR   Date        Author  Description 
** --   --------   -------   ------------------------------------

*******************************/
/*
The Output Clause returns information from, or expressions based on, each row affected by an INSERT, UPDATE, DELETE, or MERGE statement. 
Using the Output Clause helps us keep track of what we are inserting/deleting/updating since default SQL insert/delete/updage only returns the number of rows affected.

In OLAP systems, the Output clause can be used with Merge command to get back the affected records with a special $action option.

The $action option captures the operation performed on the affected records, either INSERT,UPDATE or DELETE. This option, particularly the UPDATE $action status, will be very useful while performing SCD Type2 updates.

*/

declare @dim_customer table (id int IDENTITY(1,1), customer_name varchar(50), email varchar(50))

declare @src_customer table (id int IDENTITY(1,1), customer_name varchar(50), email varchar(50))
insert into @src_customer
values ('John', 'john@email.com'), 
('Lena', 'lena@email.com'), 
('Andrew', 'andrew@email.com'), 
('David', 'david@email.com'), 
('Jane', 'jane@email.com'), 
('Helen','helen@email.com')


MERGE @dim_customer AS TARGET
USING @src_customer AS SOURCE
ON (TARGET.id = SOURCE.id)
WHEN MATCHED AND TARGET.customer_name <> SOURCE.customer_name 
THEN
    UPDATE SET TARGET.customer_name = SOURCE.customer_name
	,TARGET.email = SOURCE.email
WHEN NOT MATCHED BY TARGET 
THEN
    INSERT (customer_name,email) VALUES (customer_name,email)
/* 
   Notice how the $action clause helps us determine the type of 'action' being performed on the records -
   INSERT in this case as the Destination table is empty 
*/
OUTPUT $action,INSERTED.*; 

select *,'dim_customer' tablename from @dim_customer


-- We add a new record to source table

insert into @src_customer
values
('Tony', 'tony@email.com')

MERGE @dim_customer AS TARGET
USING @src_customer AS SOURCE
ON (TARGET.id = SOURCE.id)
WHEN MATCHED AND TARGET.customer_name <> SOURCE.customer_name 
THEN
    UPDATE SET TARGET.customer_name = SOURCE.customer_name, TARGET.email = SOURCE.email
WHEN NOT MATCHED BY TARGET 
THEN
    INSERT (customer_name,email) VALUES (customer_name,email)
OUTPUT $action,INSERTED.*; -- At this step, the $action clause correctly identifies the UPDATED and INSERTED records separately.


