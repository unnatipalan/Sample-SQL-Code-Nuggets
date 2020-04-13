/******************************
** File: Output_Clause_in_SQL.sql 
** Name: Output Clause in SQL
** Desc: Sample implementation of Output Clause in SQL
** Auth: Unnati Palan
** Date: 12/04/2020
**************************
** Change History
**************************
** PR   Date        Author  Description 
** --   --------   -------   ------------------------------------

*******************************/
/*
The Output Clause returns information from, or expressions based on, each row affected by an INSERT, UPDATE, DELETE, or MERGE statement. 

More information at https://docs.microsoft.com/en-us/sql/t-sql/queries/output-clause-transact-sql?view=sql-server-ver15

Using the Output Clause helps us keep track of what we are inserting/deleting/updating since default SQL insert/delete/updage only returns the number of rows affected.
*/

DECLARE @dim_customer TABLE 
  ( 
     id            INT IDENTITY(1, 1), 
     customer_name VARCHAR(50), 
     email         VARCHAR(50) 
  ) 

INSERT INTO @dim_customer 
VALUES      ('John', 
             'john@email.com'), 
            ('Lena', 
             'lena@email.com'), 
            ('Andrew', 
             'andrew@email.com'), 
            ('David', 
             'david@email.com'), 
            ('Jane', 
             'jane@email.com'), 
            ('Helen', 
             'helen@email.com') 


--select * from @dim_customer 
DELETE FROM @dim_customer 
output deleted.*, -- The Output Clause returns the rows which are deleted from specified columns (* if you want to return all columns)
       'DELETED' status 

INSERT INTO @dim_customer 
output      inserted.*, -- The Output Clause here returns the newly inserted rows 
            'INSERTED' status 
VALUES      ('John', 
             'john@email.com'), 
            ('Lena', 
             'lena@email.com'), 
            ('Andrew', 
             'andrew@email.com'), 
            ('David', 
             'david@email.com'), 
            ('Jane', 
             'jane@email.com'), 
            ('Helen', 
             'helen@email.com') 



