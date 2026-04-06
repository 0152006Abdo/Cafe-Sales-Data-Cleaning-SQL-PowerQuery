create database Cafe_Sales_Db
use Cafe_Sales_Db

CREATE TABLE cafe_sales_dirty (
    order_id INT,
    customer_name VARCHAR(120),
    customer_email VARCHAR(120),
    product_name VARCHAR(60),
    product_category VARCHAR(60),
    price VARCHAR(20),
    quantity INT,
    total_amount VARCHAR(20),
    payment_method VARCHAR(50),
    city VARCHAR(50),
    order_date VARCHAR(50)
);
-- Check datatypes 
EXEC sp_help cafe_sales_dirty ;

-- Check Duplicates
select Order_id , Count(*) 
from cafe_sales_dirty
group by order_id 
having Count(*) > 1  


CREATE TABLE cafe_sales_Clean (
    order_id INT primary key ,
    customer_name VARCHAR(60),
    customer_email VARCHAR(60),
    product_name VARCHAR(60),
    product_category VARCHAR(60),
    price decimal(10,2),
    quantity INT,
    total_amount decimal(10,2),
    payment_method VARCHAR(50),
    city VARCHAR(50),
    order_date Date 
);




insert into cafe_sales_Clean ( order_id , customer_name , customer_email , product_name 
                               ,product_category ,price ,quantity ,total_amount ,
                               payment_method , city , order_date)
select 
order_id ,
upper(NULLIF(TRIM(customer_name), '')) as customer_name,
lower(NULLIF(TRIM(customer_email), '')) as customer_email ,
upper(NULLIF(TRIM(product_name), '')) as product_name,
upper(NULLIF(TRIM(product_category), ''))as product_category ,
TRY_CAST(price as decimal(10,2)) as Price ,
TRY_CAST(quantity as int ) as quantity ,
TRY_CAST(total_amount as decimal(10,2) ) as total_amount,
upper(NULLIF(TRIM(payment_method), '')) as payment_method ,
upper(NULLIF(TRIM(city), '')) as city ,
Coalesce(
          Try_convert( date , trim(order_date) , 103) , --  ÇáÊäÓíÞ ÇáÈÑíØÇäí/ÇáãÕÑí (íæã/ÔåÑ/ÓäÉ
          Try_convert( date , trim(order_date) , 101) , -- ÊÌÑÈÉ ÇáÊäÓíÞ ÇáÃãÑíßí (ÔåÑ/íæã/ÓäÉ 
          Try_convert( date , trim(order_date) , 111)   -- ÊÌÑÈÉ ÇáÊäÓíÞ ÇáÚÇáãí (ÓäÉ/ÔåÑ/íæã
         ) as Order_Date 

from cafe_sales_dirty

TRUNCATE TABLE cafe_sales_Clean;

select * from cafe_sales_dirty
select * from cafe_sales_Clean

-- Check nulls at all table
SELECT 
    sum(case when order_date is null  then 1 else 0 end) as Order_date_nulls,
    sum(case when city is null or trim(city) = '' then 1 else 0 end) as city_empty_Nulls,
    sum(case when price is null  then 1 else 0 end) as price_Nulls,
    sum(case when quantity is null  then 1 else 0 end) as quantity_Nulls,
    sum(case when total_amount is null  then 1 else 0 end) as totalAmount_Nulls
FROM cafe_sales_Clean;

-- city_empty_Nulls ==> 1099 
-- price_Nulls ==>      1248
-- quantity nulls ==>   863
-- totalAmount_Nulls==> 1298

-- Dealing With Negative Prices 
update cafe_sales_Clean
set price = ABS(price)

-- Dealing with 0s Prices 
update cafe_sales_Clean
set price = null
where price = 0

-- Dealing with null Values
-- Cities
update cafe_sales_Clean
set city = 'Unknown'
where city is null

-- Dealing with Total Amount Nulls
Update cafe_sales_Clean
set total_amount = quantity * price 
where price is not null
and quantity is not null
-- TotalAmount_Nulls Became ==> 1001

-- Dealing with Price_Nulls
Update cafe_sales_Clean
set  Price = total_amount / nullif(quantity , 0)
where total_amount is not null
and quantity is not null
-- Price_Nulls Became ==> 387

--  Dealing with QTY_Nulls
Update cafe_sales_Clean
set  quantity = total_amount / nullif(price , 0)
where total_amount is not null
and price is not null
 --  QTY_Nulls is still 863

 -- Deleting Unuseful Nulls
 Delete cafe_sales_Clean
 where price is null 
  or   quantity is null 
  or   total_amount is null 

-- Check Mathematical Mistakes
select *
from cafe_sales_Clean
where (quantity * price) - total_amount   not between 0 and 0.99 
-- 117 Rows ==> (quantity * price) - total_amount   not between 0 and 0.99 

--Dealing with Mathematical Mistakes
Update cafe_sales_Clean
set total_amount = quantity * price 
where (quantity * price) - total_amount   not between 0 and 0.99 

select * from cafe_sales_Clean
-- Checking Fuzzy Names 
select product_name , count(*) As "No Of Orders" 
from cafe_sales_Clean
group by product_name  -- There isn't fuzzy names at Product name

select product_category , count(*) As "No Of Orders" 
from cafe_sales_Clean
group by product_category  -- There isn't fuzzy names at Product Category

select payment_method , count(*) As "No Of Orders" 
from cafe_sales_Clean
group by payment_method    -- There isn't fuzzy names at payment_method

select city , count(*) As "No Of Orders" 
from cafe_sales_Clean
group by city              -- There is Alexandria & Alex 

-- Dealing with Fuzzy Name ==> Alexandria & Alex  at cities
update cafe_sales_Clean
set city = 'ALEXANDRIA'
where city = 'ALEX'

-- Fixing Product Category  -- Because we have 5 products 4 drinks and 1 dessert 
update cafe_sales_Clean
set product_category = 'DRINK'
where product_name = 'ESPRESSO'
or    product_name = 'COFFEE'
or    product_name = 'TEA'
or    product_name = 'LATTE'

update cafe_sales_Clean
set product_category = 'DESSERT'
where product_name = 'CAKE'

-- Check Outliers 
select *
from cafe_sales_Clean
where price > (select avg(Price) + (3 * STDEV(Price)) from cafe_sales_Clean)
or quantity > 15

-- check Mistakes at order_date
select * from cafe_sales_Clean
where order_date > GETDATE() -- Done

SELECT customer_email 
FROM cafe_sales_Clean
WHERE customer_email  not LIKE '%_@__%.__%';  -- ==> 197 row

-- Dealing with Wrong Emails
Update cafe_sales_Clean
set customer_email = 'Unknown'
where customer_email  not LIKE '%_@__%.__%'; 

-- ===========================================================================
