/* Paul Clifford */

use    a_books;
GO
/*  TASK 00 */
Select getdate(), @@servername as ServerName,  @@version as VersionNumber;

GO

/*  TASK 01 */

/*Display the book id and title for any books which someone has ordered and the book is categorized
as either an SQL book and a database book or possibly both topics. 
Use the topic_id  to filter for DB and SQL. Sort by the book_id. */

select book_id
, title
from bkinfo.books
where book_id in (
    select book_id
	from bkinfo.book_topics
	where topic_id IN ('DB', 'SQL')
	)
order by book_id
GO

/*  TASK 02 */

/*Display the book id and title for any books which someone has ordered and the book is categorized
as both an SQL book and a database book.  Use the topic_id  to filter for DB and SQL. Sort by the book_id.*/

select book_id
, title
from bkinfo.books
where book_id in (
    select book_id
	from bkinfo.book_topics
	where topic_id IN ('DB')
	) and book_id in (
	select book_id
	from bkinfo.book_topics
	where topic_id IN ('SQL')
	)
order by book_id
GO

/*  TASK 03 */

/*Display the book id and title for any books which someone has ordered and the same book is categorized as an SQL book  
but it is not categorized as a database book  Use the topic_id  to filter for DB and SQL. Sort by the book_id.*/

select book_id
, title
from bkinfo.books
where book_id in (
    select book_id
	from bkinfo.book_topics
	where topic_id IN ('SQL')
	) and book_id not in (
	select book_id
	from bkinfo.book_topics
	where topic_id IN ('DB')
	)
order by book_id
GO

/*  TASK 04 */
/*Display the ID, title of the books and the publication year for the book with the largest sales amount; 
include ties. For this query, use the total extended cost when determining the sales of a book. Sort by the book_id.*/

select book_id
, title
, year_publd
from bkinfo.books
where book_id in (
    select book_id
    from bkorders.order_details
    group by book_id
    having sum(quantity*order_price) >= ALL (
	    select sum(quantity*order_price)
		from bkorders.order_details
		group by book_id
		)
    )
order by book_id
GO

/*  TASK 05 */

/* Display the ID and last name of the customers who have bought any ART books in the current year. 
Use the topic id to filter for ART books. Sort by the cust_id. 
Copy the query and use it to filter for history (HIST) books.*/

select cust_id
, cust_name_last
from bkorders.customers
where cust_id in (
    select cust_id
	from bkorders.order_headers 
	where datepart(yyyy, order_date) = datepart(yyyy, getdate()) and order_id in (
	    select order_id
		from bkorders.order_details
		where book_id in (
		    select book_id
	        from bkinfo.book_topics
	        where topic_id IN ('ART')
		    )
        )
    ) 
order by cust_id
GO

select cust_id
, cust_name_last
from bkorders.customers
where cust_id in (
    select cust_id
	from bkorders.order_headers 
	where datepart(yyyy, order_date) = datepart(yyyy, getdate()) and order_id in (  
	    select order_id
		from bkorders.order_details
		where book_id in (
		    select book_id
	        from bkinfo.book_topics
	        where topic_id IN ('HIST')
		    )
        )
    )
order by cust_id         		      
GO

/*  TASK 06 */

/*Display the book id and title for any books where we have orders for more than 500 copies of the book. 
Use the quantity attribute. Sort by the book_id.*/

select book_id
, title
from bkinfo.books
where book_id in (
    select book_id
	from bkorders.order_details
	group by book_id
	having sum(quantity) > 500
	)
order by book_id
GO

/*  TASK 07 */

/*Display the year and month which has the fewest orders. 
This analysis only considers year/month where we have any orders. 
You can display the result as two columns (year, month) or as a single column in a format such as  '2014.11'  or '2014 Nov'. 
You may not use the literal 1 in your query.*/

select concat(datepart(yyyy, order_date), ' ', datename(m, order_date)) as 'Year and Month'
from bkorders.order_headers
group by datepart(yyyy, order_date), datename(m, order_date)
having count(order_id) <= ALL (
    select count(order_id) as total
    from bkorders.order_headers
	group by datepart(yyyy, order_date), datename(m, order_date)
	)
GO


/*  TASK 08 */

/* Display the year and month which has the most orders. 
This analysis only considers year/month where we have any orders. 
You can display the result as two columns (year, month) or as a single column in a format such as  '2014.11'  or '2014 Nov'.*/

select concat(datepart(yyyy, order_date), ' ', datename(m, order_date)) as 'Year and Month'
from bkorders.order_headers
group by datepart(yyyy, order_date), datename(m, order_date)
having count(order_id) >= ALL (
    select count(order_id) as total
    from bkorders.order_headers
	group by datepart(yyyy, order_date), datename(m, order_date)
	)
GO



-- subqueries
-- scalar subqueries. They can be used anywhere in place of a single value. 
-- where  something BETWEEN scalar1 AND scalar2 can use scalar subqueries for the between. 
-- correlated subquery compares each time. there is a "join" so to speak of the subquery and the main query. 
-- REPLICATE ( string_expression ,integer_expression ) 

-- this is pretty cool for a crude chart. 
select replicate ('=>', 
(select 5) );

-- exist with a correlated subquery is a way to put a conditional on a query. 
-- exists just checks for a bionary outcome of true of false. 
-- select item
-- from table as T
-- where exists (
--          select "x"
--          from otherTable as OT
--          where T.id = OT.id
--          )


-- ANY and ALL are checked against a list which is generated by a subquery. 
-- subquery generates list, and then compares to ANY and ALL using relational operators. 
-- pivot using selected data and pivots line excell. 
