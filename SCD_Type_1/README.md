# Slowly Changing Dimension Type 1

Slowly Changing Dimension (SCD) Type 1 identifies columns which can be updated with new data when data changes in source systems.
This method overwrites old data with new and so does not track historical data.

## SCD Type 1 implementation in SQL is done by using the MERGE command

* Sample schema for Source table
```sql
DECLARE @src_table TABLE 
  ( --  source table with customer attributes 
     customer_id INT, 
     title       NVARCHAR(10), 
     first_name  NVARCHAR(100), 
     last_name   NVARCHAR(100), 
     mobile      BIGINT, 
     record_date DATE 
  ) 
```

* Sample schema for Dimension table

```sql
DECLARE @dimension_table TABLE 
  ( --a sample dimension table with customer attributes 
     customer_id    INT,--  key column 
     title          NVARCHAR(10),-- type 1 dimension 
     first_name     NVARCHAR(100), 
     last_name      NVARCHAR(100),--  type 1 dimension 
     mobile         BIGINT, 
     from_date      DATE,--  date of load or update 
     to_date        DATE,--  record valid till date 
     current_record NVARCHAR(1)-- flag to identify latest record 
  ) 
```
* We identify `customer_id` as the key column between Source and Dimension tables. Do keep in mind the key column cannot have duplicates or the merge will fail.

* Populating test data in Source table
```sql
INSERT INTO @src_table
VALUES 
(1,'Ms','Jane','Smith',99020344,@record_date),
(2,'Mrs','Aparna','Mitra',89020345,@record_date),
(3,'Mr','Ramki','Bhat',89010345,@record_date)
```

* The `MERGE` command then takes care of updating the Destination table when keys match and insert records in case of a no match.

```sql
merge @dimension_table as dest using @src_table as src  --  Merging source table with dimension table
ON (dest.customer_id = src.customer_id)  -- matching the key columns
WHEN MATCHED
THEN UPDATE SET  -- updating dimension table with following values if the customer_id keys match
	    dest.title = src.title,
		  dest.first_name = src.first_name,
		  dest.last_name = src.last_name,
		  dest.mobile = src.mobile,
		  dest.from_date = src.record_date,
		  dest.to_date = '9999-12-31',  -- adding a value for expiry date 
		  dest.current_record = 'Y'  -- marks current record 
WHEN NOT MATCHED   -- if the keys do not match, inserting the following values
THEN INSERT (customer_id,title,first_name,last_name,mobile,from_date,to_date,current_record)
VALUES(src.customer_id,src.title,src.first_name,src.last_name,src.mobile,src.record_date,'9999-12-31','Y')
;
```

## Important Notes while implementing SCD Type1 data load using SQL Merge
* Key column in source cannot have duplicates
* Conditional checks after `WHEN MATCHED` can help checking column data before running the update
* Current Record column is not necessary if all columns in the table are SCD Type 1 but makes queries easier
* Merge command in SQL ends with a semi colon(;)
