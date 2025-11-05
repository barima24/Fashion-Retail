select * from retail_sales;

-- Process 1 --> Data Cleaning and Preprocessing 
---- Step 1 --> Check Data Quality
select count(*) as total_rows from retail_sales
where year(transaction_date) = 2024; --- Total rows in a table 
--- Checking Null Values present or not in Unique Column ID 
 
select count(*) from retail_sales where transaction_id is null; --- for a single row

select SUM(case when store_id is null then 1 else 0 end) as null_store,
SUM(case when product_id is null then 1 else 0 end) as null_product,SUM(case when [transaction_id] is null then 1 else 0 end) as null_transactions,
SUM(case when quantity is null then 1 else 0 end) as null_units_sold ,SUM(case when channel is null then 1 else 0 end) as null_channel, 
SUM(case when [discount_percent] is null then 1 else 0 end) as null_dis,
SUM(case when [payment_method] is null then 1 else 0 end) as null_paymode
from retail_sales;  ---- for multiple rows

select * from targets
where store_id  is null 
and [target_id] is null ;

-- result - no null values found 

--- Step 2 -- Check Duplicates

select store_id,product_id,transaction_id from retail_sales
group by store_id,product_id,transaction_id
having count(*)>1; 

select product_name,product_id from products
group by product_name,product_id
having count(*)>1; 

---- if duplicates found then Remove Duplicate 
--WITH ranked AS (
--  SELECT *, ROW_NUMBER() OVER(PARTITION BY column1, column2 ORDER BY id) AS rn
--  FROM table
--)
--DELETE FROM ranked WHERE rn > 1;
 
 -- Result - No duplicates found 

--- Step 3 --> Standardize Data Formats

select distinct launch_date
from Products;
--- Launch year was in float data type
ALTER TABLE Products ALTER COLUMN Launch_date date;

--Alter table customers alter column age int;
--Alter table customers alter column registration_Date date;

Alter table retail_sales alter column transaction_date date;
Alter table retail_sales alter column quantity int;
alter table retail_sales drop column total_revenue;
    
Alter table stores alter column opening_date date;

Alter table Targets alter column Year int;
Alter table targets alter column units_target int;
Alter table targets alter column month int;
Alter table targets alter column traffic_target int;

--- result - some specific data types were changed 

--- Step 4 --> check inconsistent categorical data 


select distinct category from products;
select distinct Sub_Category from products; select distinct Brand from Products;
select distinct season from products; select distinct Payment_method from retail_sales;  
select distinct channel from retail_sales;
select distinct Store_Type from Stores; SELECT DISTINCT city FROM stores;
select distinct state from stores;

update stores
set state = case
when state = 'CA' then 'California'
when state = 'CO' then 'Colorado'
when state = 'MN' then 'Minnesota'
when state = 'OR' then 'Oregon'
when state = 'TX' then 'Texas'
when state = 'WA' then 'Washington'
when state = 'WI' then 'Wisconsin'
else state 
end;

select distinct store_name from stores;

--- result - there were some inconsistent categrical data which I cleaned it

--- if we would have found inconsistent data then we would have fixed it like this 
--UPDATE customers
--SET gender = CASE 
 --   WHEN gender IN ('M', 'male', 'Male') THEN 'Male'
--    WHEN gender IN ('F', 'female', 'Female') THEN 'Female'
 --   ELSE 'Other'
--END;

----Step 5 --> Check outliers 
-- select * from customers where Age < 10 and Age > 120;
select * from retail_sales where Year(transaction_date) > 2025 and Year(transaction_date) < 2020;
select * from targets where Year > 2025 and Year < 2020;
select * from targets where units_target < 1000 and units_target > 5000;
select * from targets where month < 1 and month > 12;

---- Result - No outliers 

-- Step 6 --> Check unecessary columns 

alter table stores drop column size_sqft;
alter table retail_sales drop column total_revenue;

-- result -- no unecessary columns found 

--Process 2 --> Data Transformation 

-- If I want to added revenue,total_cost and profit column but I wont as it will take more load in my power bi dashbaord there i can create measures 
--create view sales_data as 
--select *,units_sold * unit_price as Revenue, units_sold * cost_price as Total_Cost,
--(units_sold * unit_price) - (units_sold * cost_price) as profit
--from sales;
--go