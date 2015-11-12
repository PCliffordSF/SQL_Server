/* Paul Clifford */

use    a_books;
GO
/*  TASK 00 */
Select getdate(), @@servername as ServerName,  @@version as VersionNumber;

GO
/*  TASK 01 */
/*For each customer in the customers table who lives in New Jersey (NJ) or in Massachusetts (MA), 
display their id, their last name and the number of orders they have. 
Sort by the customer id.
Cust_ID Cust_Name_Last        Number Of Orders 
------- -------------------- ---------------- 
300124  Adams                              21 
300150  Jobs                                1 
300153  Jones                              12*/


select cust_id
, cust_name_last
, ISNULL(
   (
   select cast(count(distinct order_id) as varchar)
   from bkorders.order_headers as BKOH
   group by cust_id 
   having BKOH.cust_id = BKC.cust_id
   ), 'No Orders') as 'Number of Orders'
from bkorders.customers as BKC
where cust_state in ('NJ', 'MA')
order by cust_id
GO

/*  TASK 02 */
/*Use an Exists query to display the customer id and last name for any customer who ordered a book 
in each (every one) of the first three months of the current year. Sort by the customer id. 
(The first three months of any year are always Jan, Feb, Mar- so you can hard code the months.) */

select cust_id
, cust_name_last
from bkorders.customers as BKC
where exists (
    select 'X'
	from bkorders.order_headers as BKOH
	where BKOH.cust_id = BKC.cust_id and
		  datepart(yyyy,order_date) = datepart(yyyy, getdate()) and 
		  datepart(m, order_date) = 1		  
    )
and exists (
    select 'X'
	from bkorders.order_headers as BKOH
	where BKOH.cust_id = BKC.cust_id and
		  datepart(yyyy,order_date) = datepart(yyyy, getdate()) and 
		  datepart(m, order_date) = 2		  
    )
and exists (
    select 'X'
	from bkorders.order_headers as BKOH
	where BKOH.cust_id = BKC.cust_id and
		  datepart(yyyy,order_date) = datepart(yyyy, getdate()) and 
		  datepart(m, order_date) = 3		  
    )
order by cust_id
GO


/*  TASK 03 */
/*Use an Exists query to display the author information for authors who have more than one book
 but for whom we have no book sales.  Sort by the author id.  
 Author_Name_First    Author_Name_Last     Author_ID
  -------------------- -------------------- --------- 
  Mark                 Gersten              G1234 
  Sue                  Haldeson             H9876     */

select author_name_first, author_name_last, author_id
from bkinfo.authors as BKA
where exists (
    select 'X'
    from bkinfo.book_authors BKBA
	group by BKBA.author_id
	having BKA.author_id = BKBA.author_id
and 
	count(book_id) > 1
	)
and BKA.author_id not in (
	select author_id
    from bkinfo.book_authors
    where book_id in (
	    select book_id
		from bkorders.order_details
		)
	)
order by author_id
GO

/*  TASK 04 */
/*We want to find any books which cover exactly two of the different sql systems using the topic ids
 'SSRV', 'ORA', 'MySQL'  For example, the book could have a topic of SSRV and a topic of ORA, but not MySQL.
  Any two of these topics is sufficient to pass our filter.
  Display the id and title of the book(s) that are meet this test. */

select book_id
, title
from bkinfo.books
where book_id in ( 
        select book_id
        from bkinfo.book_topics
        where topic_id in ('SSRV', 'ORA', 'MySQL')
        group by book_id
        having count(topic_id) = 2
	    )
GO


/*  TASK 05 */
/*For each order placed in the first three months of the previous year, display the following pieces of data: 
order date
order id 
customer id
customer last name - use an alias of customer 
total number of books purchased ( quantity) on that order- use an alias of NumberBooks total amount due for that order
 - use an alias of OrderCost.  Sort the result  by the order date.
 (Suggestion- use the order headers table in the From clause of the main query.)
  Remember you are not allowed to use joins other than that required for a correlated subquery. */ 


select order_date
, order_id
, cust_id
, (
    select cust_name_last
    from bkorders.customers as BKC
	where BKC.cust_id = BKOH.cust_id
  ) as customer
  from bkorders.order_headers as BKOH
  where  datepart(yyyy, order_date) = datepart(yyyy, dateadd(yyyy,-1,getdate()))
         and 
		 datepart(m, order_date) in (1, 2, 3)
order by order_date
GO

/*  TASK 06 */
/*Display the customer id and last name for customers with at least three and no more than five
 orders last year. Sort by the customer id.*/
select cust_id
, cust_name_last
from bkorders.customers as BKC
where exists (
        select 'X'
        from bkorders.order_headers as BKOH
        where datepart(yyyy, order_date) = datepart(yyyy, dateadd(yyyy, -1, getdate()))
and 
        BKOH.cust_id = BKC.cust_id
        group by cust_id
        having count(order_id) between 3 and 5
        )
GO



/*  TASK 07 */
/*Display the cust id and last name of customers who had the same or more orders in the first quarter 
of last year than they had in the first quarter of the current year.
 Count the order id values for this comparison.
  This will include only customers who have any orders in those two time periods. Sort by the customer id.*/

select cust_id
, cust_name_last
from bkorders.customers as BKC
where (
    select count(order_id)
    from bkorders.order_headers as BKOH
    where datepart(yyyy, order_date) = datepart(yyyy, dateadd(yyyy, -1, getdate()))
and 
    datepart(m, order_date) in (1, 2, 3)
and 
    BKOH.cust_id = BKC.cust_id
    group by cust_id
	) >= (
    select count(order_id)
    from bkorders.order_headers as BKOH
    where datepart(yyyy, order_date) = datepart(yyyy, getdate())
and 
    datepart(m, order_date) in (1, 2, 3)
and
	BKOH.cust_id = BKC.cust_id
    group by cust_id
    )
order by cust_id
GO


--- tester queries below. 
 ------------------------------------------------------------------------------------------------



 	select count(order_id) 
	from bkorders.order_headers
	group by cust_id







select cust_id
, (
   select cust_name_last
   from bkorders.customers as BKC
   where BKC.cust_id = BKOH.cust_id
   ) as 'Customer'
from bkorders.order_headers as BKOH
    where (
	select count(order_id) 
	from bkorders.order_headers as BKOH 
	where 	datepart(yyyy, order_date) = datepart(yyyy, dateadd(yyyy, -1, getdate()))
and 
            datepart(m, order_date) in (1, 2, 3)
	group by cust_id
    ) > (
	select count(order_id) 
	from bkorders.order_headers as BKOH 
	where 	datepart(yyyy, order_date) = datepart(yyyy, dateadd(yyyy, -1, getdate()))
and 
            datepart(m, order_date) in (1, 2, 3)
	group by cust_id
	)
GO








select count(order_id) as 'last years orders'
,(
select count(order_id)
from bkorders.order_headers as BKOH
where datepart(yyyy, order_date) = datepart(yyyy, getdate())
and 
datepart(m, order_date) in (1, 2, 3)
and BKOH.cust_id = bkorders.order_headers.cust_id
group by cust_id
) as 'this years orders'
, cust_id
from bkorders.order_headers
where datepart(yyyy, order_date) = datepart(yyyy, dateadd(yyyy, -1, getdate()))
and 
datepart(m, order_date) in (1, 2, 3)
group by cust_id
GO


select 
case when count(order_id)
 >= (
select count(order_id)
from bkorders.order_headers as BKOH
where datepart(yyyy, order_date) = datepart(yyyy, getdate())
and 
datepart(m, order_date) in (1, 2, 3)
and BKOH.cust_id = bkorders.order_headers.cust_id
group by cust_id
) then 'fuck yea' end
, cust_id
from bkorders.order_headers
where datepart(yyyy, order_date) = datepart(yyyy, dateadd(yyyy, -1, getdate()))
and 
datepart(m, order_date) in (1, 2, 3)
group by cust_id
GO

        select count(order_id) as 'order total', cust_id
        from bkorders.order_headers as BKOH
        where datepart(yyyy, order_date) = datepart(yyyy, dateadd(yyyy, -1, getdate()))
        group by cust_id
        having count(order_id) between 3 and 5