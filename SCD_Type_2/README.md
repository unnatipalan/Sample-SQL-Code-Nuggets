# Slowly Changing Dimension Type 2

Slowly Changing Dimension (SCD) Type 2 tracks columns for historical updates. 
When we receive a new update on SCD Type 2 column, we update the valid_to_date of the current record and mark the current_record column as 'N'.
At the same time, we tweak the MERGE command with OUTPUT clause to insert the latest record from source as the current_record.


## Important Questions and Notes while implementing SCD Type 2 data load using SQL Merge

* Which columns in the Destination Table are SCD Type 2?
* What should be the from_date of the latest record - getdate() or a system date from source?
* The to_date column for a historic record should be updated using the record_date - 1 
* It is possible to have more than one key column between source and destination. Configure the ON clause of the MERGE match accordingly
* Key column in source cannot have duplicates
* Conditional checks after `WHEN MATCHED` can help checking column data before running the update
* Merge command in SQL ends with a semi colon(;)


