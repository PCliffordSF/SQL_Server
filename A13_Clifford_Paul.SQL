/* Paul Clifford */

use a_books;  

GO


exec sp_helpText booksize

exec sp_helpText prevmonth  


/*  TASK 00 */ 

Select getdate(), @@version; 
GO  

/*  TASK 01 */ 
IF OBJECT_ID (N'dbo.booksize') IS NOT NULL
   DROP FUNCTION dbo.booksize
GO


CREATE  FUNCTION dbo.booksize (
   @page_count int  )
   RETURNS varchar(25) 
AS
BEGIN

   DECLARE @bksize varchar(25);
   IF (@page_count is null)
   BEGIN
		SET @bksize = 'Input value is missing'
   END
   IF (@page_count <= 200)
   BEGIN
		SET    @bksize = 'Short'
   END
   ELSE IF (@page_count > 200 and @page_count <= 500)
   BEGIN
		SET @bksize = 'Medium'
   END
   ELSE IF (@page_count > 500 and @page_count <= 1200)
   BEGIN
		SET @bksize = 'Long'
   END
   ELSE IF (@page_count > 1200 and @page_count <= 4000)
   BEGIN
		SET @bksize = 'ExtraLong'
   END
   ELSE IF (@page_count > 4000 and @page_count <= 10000)
   BEGIN
		SET @bksize = 'SuperLong'
   END
   ELSE IF (@page_count > 10000)
   BEGIN
		SET @bksize = 'SuperDUPERLong'
   END
   RETURN @bksize;
END;
GO

/* BookSize function test using a virtual table:  Demonstrate your function by running a query using 
a virtual test table to supply arguments. Include enough rows to fully demonstrate that your function is correct. 
The result of running this query should follow this sample run- I have shown only some of the rows. 
Sample rows only     
testrun   PageCount actual                    expected 
----------- ----------- ------------------------- ------------           
4				199		Short                     Short           
5				 200	 Short                     Short           
7			    325		Medium                    Medium          
11				999		 Long                      Long          
13				1250	ExtraLong                 ExtraLong */

-- set up testing data for scalar function above. 

select tstRun, pageCount as pageCount, dbo.booksize(pageCount) calculatedResult, expectedResult
from (
   select 1 as tstRun,  199 as pageCount, 'Short' as expectedResult  union all 
   select 2,    200,     'Short'     union all 
   select 3,    201,     'Medium'     union all 
   select 5,    499,     'Medium'     union all 
   select 6,    500,     'Medium'     union all 
   select 7,    501,     'Long'     union all 
   select 8,    1200,     'Long'     union all 
   select 9,    1201,     'ExtraLong'     union all 
   select 10,    3999,     'ExtraLong'     union all 
   select 11,    4000,     'ExtraLong'     union all 
   select 12,    4001,     'SuperLong'     union all 
   select 13,    9999,     'SuperLong'     union all 
   select 13,    null,     'Input value is missing'     union all 
   select 14,    400000000,'SuperDUPERLong'
) as tstTbl;  

-- turn this into a CTE. I like those better. 

with myTestData as (
   select 1 as tstRun,  199 as pageCount, 'Short' as expectedResult  union all 
   select 2,    200,     'Short'     union all 
   select 3,    201,     'Medium'     union all 
   select 5,    499,     'Medium'     union all 
   select 6,    500,     'Medium'     union all 
   select 7,    501,     'Long'     union all 
   select 8,    1200,     'Long'     union all 
   select 9,    1201,     'ExtraLong'     union all 
   select 10,    3999,     'ExtraLong'     union all 
   select 11,    4000,     'ExtraLong'     union all 
   select 12,    4001,     'SuperLong'     union all 
   select 13,    9999,     'SuperLong'     union all 
   select 13,    null,     'Input value is missing'     union all 
   select 14,    400000000,'SuperDUPERLong'
) 
select tstRun
, pageCount as pageCount
, dbo.booksize(pageCount) calculatedResult
, expectedResult
from myTestData


/*  TASK 02 */ 

/*PrevMonth:  function test using a virtual table:  
Demonstrate your function by running a query using a virtual test table to supply arguments. 
Include enough rows to fully demonstrate that your function is correct, 
include tests for nulls and negative values in the virtual table approach. 
Use the report model shown below. For the Status column, use a case statement to deal with the expected value being null.
The sample run shows some rows getting a ***Fail **** message because my function is not yet complete.
Your output should not show fail if your function is correct.  
testrun date_in       month_in		actual  expected status 
----------- ---------- ----------- ------- -------- ----------           
1			NULL                 0 NULL    2015-11  ***FAIL***           
5			2012-04-01           0 2015-04 2012-04  ***FAIL***           
6			2012-04-01           1 2012-03 2012-03  pass           
7			2012-04-30           6 2011-10 2011-10  pass          
10			2012-04-19        NULL NULL    NULL     pass          
11			2012-04-19         -25 NULL    NULL     pass */

IF OBJECT_ID (N'dbo.prevmonth') IS NOT NULL
   DROP FUNCTION dbo.prevmonth
GO
CREATE  FUNCTION dbo.prevmonth (
	@in_date date
	,@in_mn_adjust int
    )
   RETURNS date 
AS
BEGIN
   IF @in_mn_adjust is null or @in_mn_adjust < 0
   BEGIN 
   Return null
   END
   DECLARE   @adjusted date;
   set @adjusted = dateadd(mm, -@in_mn_adjust, @in_date)

   RETURN @adjusted;
END;
GO


-- set up testing data for scalar function above. 


With  myTestData as(
	select 1 as tstRun,  '2014-04-10' as tstDate , 2 as monthAdjustment, '2014-02' as expectedResult   union all 
    select 2,    '2014-04-10',    6, '2013-10'     union all 
    select 3,    '2012-04-10',    18 , '2010-10'  union all
    select 4,    '2012-04-30' ,   6,  '2011-10'    union all
	select 5,    '2012-04-01',    1,  '2012-03' union all
	select 6,    '2012-04-19',   NULL,  NULL union all
	select 7,    '2012-04-19',   -25,  NULL union all 
	select 8,    '2012-04-01',     0, '2012-04' union all
	select 9,     null,            0,   null 
	),
calcData as  (
    select tstRun
	, tstDate
	, cast(SUBSTRING ( cast(dbo.prevmonth(tstDate, monthAdjustment) as varchar(18)),1 , 7 ) as varchar(18)) as calculatedResult
    , monthAdjustment
	, cast(expectedResult as varchar(18)) as expectedResult
    from myTestData
    )
select tstRun as testRun
, tstDate as date_in
, monthAdjustment as month_in
, calculatedResult as actual
, expectedResult as expected
, case when calculatedResult = expectedResult then 'pass' 
  when calculatedResult is null and expectedResult is null then 'pass'
else '***FAIL*** ' end as status
from calcData
GO


/*  TASK 03 */ 

/*Use the BookSize function to produce a display as shown here. Use the books table as the data source for this query. 
The order of the rows must match the order shown here.  
Do not include any books with a null or negative page count. 
It is possible that the books table might not have any books of one of these size categories; 
in that case your result set would not have a row for that size category.
 Sample rows only 
 BookSize NumBooks 
 -------- ----------- 
 Short            29 
 Medium          183 
 ExtraLong        11 
 SuperLong         2*/

with myTestData as (
	select dbo.booksize(page_count) as BookSize
	, page_count
	, case when dbo.booksize(page_count) = 'Short' then 1 
	when dbo.booksize(page_count) = 'Medium' then 2 
	when dbo.booksize(page_count) = 'Long' then 3
	when dbo.booksize(page_count) = 'ExtraLong' then 4
	when dbo.booksize(page_count) = 'SuperLong' then 5 
	when dbo.booksize(page_count) = 'SuperDuperLong' then 6 end as 'orderRank'
	from bkinfo.books
	group by page_count, dbo.booksize(page_count)
	having page_count is not null
	)
select BookSize
, count(BookSize) as NumBooks
from myTestData
group by BookSize, orderRank
order by orderRank

/*  TASK 04 */

/*Use the BookSize function to produce a display as shown here. 
Use the books table as the data source for this query. The order of the rows must match the order shown here. 
 Do not include any books with a null or negative page count. 
 Display a row for each of the size categories, even if we have no books with a page count for that category; 
 display a count of 0 for that row. (Hint: consider a virtual table of size categories similar to the calender task 
 in a previous query .) 
 Sample rows only 
 BookSize    NumBooks 
 -------- ----------- 
 Short            29 
 Medium          323 
 Long              0 
 ExtraLong        11 
 SuperLong         5 */


with myTestData as (
	select dbo.booksize(page_count) as BookSize
	, count(dbo.booksize(page_count)) as NumberBooks
	, page_count
	from bkinfo.books
	group by page_count, dbo.booksize(page_count)
	having page_count is not null
	),
myVirtualTable as (
	select 'Short' as BookSize union all
	select 'Medium' union all
	select  'Long' union all
	select  'ExtraLong' union all
	select  'SuperLong' union all
	select   'SuperDuperLong'
	),
myDataTable as (
	select 
	B.BookSize
	, page_count
	, NumberBooks
	, case when B.BookSize = 'Short' then 1 
	when B.BookSize = 'Medium' then 2 
	when B.BookSize = 'Long' then 3
	when B.BookSize = 'ExtraLong' then 4
	when B.BookSize = 'SuperLong' then 5 
	when B.BookSize = 'SuperDuperLong' then 6 end as 'orderRank'
	from myTestData A
	RIGHT JOIN myVirtualTable as B ON B.BookSize = A.BookSize
	)
select BookSize
, count(NumberBooks) as NumBooks
from myDataTable
group by BookSize, orderRank
order by orderRank




/*  TASK 05 */ 
/*Use the PrevMonth function to display the number of orders we had in the previous two months 
and the number of customers we have who have at least one order in the previous two months. 
The term "previous two months" means any date in the two month before the current month. 
So if you run the query in April 2015, the query will return data for Feb 2015 and March 2015. 
You need to derive the months based on the system date. 
Use the tables in the a_books database as the data source for this query. 
Do not redo the calculations for a previous month in the task- 
use the function for this calculation. Do not use any variables in the task.  
NumberOrders NumberCustWithOrders
 ------------ --------------------          
 234                   98 */
 

with myTestData as (
select order_id
, cust_id
, order_date
from bkorders.order_headers
group by order_id, cust_id, order_date
having (month(order_date) = month(dbo.prevmonth(getdate(), 2))  

OR 
       month(order_date) = month(dbo.prevmonth(getdate(), 1)) 
	   )
AND
	   year(order_date) = year(getdate())
),
myCustTotal as (
select count(distinct cust_id) as NumberCustWithOrders
, 'join_link' as join_link
from myTestData
),
myOrderTotal as (
select count(order_id) as NumberOrders
, 'join_link' as join_link
from myTestData
)
select NumberOrders, NumberCustWithOrders
from myOrderTotal as OT
JOIN myCustTotal as CT ON CT.join_link = OT.join_link





-------------------------- scratch

-- trying different methods for number 5. 

with myTestData as (
select order_id
, cust_id
, order_date
from bkorders.order_headers
group by order_id, cust_id, order_date
having (month(order_date) = month(dbo.prevmonth(getdate(), 2))  

OR 
       month(order_date) = month(dbo.prevmonth(getdate(), 1)) 
	   )
AND
	   year(order_date) = year(getdate())
),
myCustTotal as (
select count(distinct cust_id) as NumberCustWithOrders
from myTestData
),
myOrderTotal as (
select count(order_id) as NumberOrders
from myTestData
)
	select NumberOrders
	from myOrderTotal
UNION ALL
	select NumberCustWithOrders
	from myCustTotal 













 
with myTestData as (
	select dbo.booksize(page_count) as BookSize
	, count(dbo.booksize(page_count)) as NumberBooks
	, page_count
	from bkinfo.books
	group by page_count, dbo.booksize(page_count)
	having page_count is not null
	),
myVirtualTable as (
	select 'Short' as BookSize union all
	select 'Medium' union all
	select  'Long' union all
	select  'ExtraLong' union all
	select  'SuperLong' union all
	select   'SuperDuperLong'
),
myDataTable as (
select 
	B.BookSize
	, page_count
	, NumberBooks
	, case when B.BookSize = 'Short' then 1 
	when B.BookSize = 'Medium' then 2 
	when B.BookSize = 'Long' then 3
	when B.BookSize = 'ExtraLong' then 4
	when B.BookSize = 'SuperLong' then 5 
	when B.BookSize = 'SuperDuperLong' then 6 end as 'orderRank'
	from myTestData A
	RIGHT JOIN myVirtualTable as B ON B.BookSize = A.BookSize
)
select BookSize
, count(NumberBooks) as NumBooks
from myDataTable
group by BookSize, orderRank
order by orderRank


select BookSize
, count(BookSize) as numBooks
from myDataTable
group by BookSize, orderRank
order by orderRank

