/* Paul Clifford */

use    -- db.name;
GO
/*  TASK 00 */
Select getdate(), @@servername as ServerName,  @@version as VersionNumber;

GO
/*  TASK 01 */
/*
Display the following columns for each book in the books table
column 1:  the row_number using the list price as the order field. This uses the row_number function 
and a windowing clause. 
column 2:  book id and the title; limit the column to 25 characters 
column 3:  publisher id 
column 4:  list price.  
Sort the output by the list_price.     
List-Price-Order 	Book						Publ   Price 
-------------------- ------------------------- ------ --------                    
1 					100 Queries are Fun         8123     12.00                    
2 					560 Subqueries are Useful   8275     15.25  
*/

select ROW_NUMBER() over (order by list_price) as 'List-Price-Order'
,cast(book_id as varchar) + ' ' + title as Book
,publ_id as Publ
,list_price as Price
from bkinfo.books
order by list_price
GO

/*  TASK 02 */
/*
Display the following columns for books with a publication date more recent than 2005.
column 1:  a ranked ordering by the book's publisher and the list price with the more expensive books 
first within the publisher id.  The first column reports any tied rows with the same price as having the
same rank number. 
column 2:  publisher id  
column 3:  list price  
column 4:  book id and title; limit the column to 25 characters  
For example, all books from the same publisher that cost $35.00 will have the same number. But 
another book from a different publisher that costs $35.00 will have a different number. Do not skip 
any numbers in the first column.  
Sort the final output by publisher id and the list price desc.  
Publ-List-Price-Order        Publ    Price  Book
--------------------- ----------- -------- ------------------------- 
. . . MID WAY THROUGH THE OUTPUT                     
					16       8223    59.95 456 Wait for June                                  
					17       8223    35.00 789 Yet Another Subquery                                   
					17       8223    35.00 874 The Exam Cometh                                         
					17       8223    35.00 451 The SQL Booklet                         
					18       8223    25.00 652 The Big Book of SQL                    
					19       9358    59.95 800 Lichens                                  
					20       9358    35.00 900 Moss Gardening
*/
select DENSE_RANK() over (order by publ_id) as 'Publ-List-Price-Order'
, publ_id as Publ
, list_price as Price
, cast(book_id as varchar) + ' ' + title as Book
from bkinfo.books
where year_publd > 2005
order by publ_id, list_price desc
GO


/*  TASK 03 */
/*
Which are the top 10 selling books based on the total sales of the book? Round the total sales to the 
nearest hundred before ranking the sales.  
Display the SalesRanking number, book id & title, and total sales in sales ranking order. Please pay 
attention to the values in the first column for ties and follow that ranking pattern.
All books that are tied for the last place should be returned. The only place we are concerned about
ties is in the last slot.
As you develop this, display enough rows so that you find two or more rows that tie for a position and
check that your query would return the tied books if that were the last position. Then edit the query to
return the top 10. 
Sales-Ranking  Book                      Total-Sales 
-------------- ------------------------- -----------             
			1 1245 The Ants                 5100.00             
			1 1784 The Beatles of Bolivia   5100.00              
			3 9845 Mosses of Pennsylvania   1800.00              
			4 7638 Guide to Tree Bark       1700.00        
			5 9298 Why Ducks Matter         1500.00 
. . . rows omitted to save space here             
			10 8178 SQL Legends               500.00             
			10 8005 Logic Matters             500.00 
(11 row(s) affected)
*/

select
cast(book_id as varchar) + ' ' + title as Book
, (
    select round(sum(quantity*order_price),0)
    from bkorders.order_details BKOH
    group by book_id
    having BKOH.book_id = BKB.book_id
) as 'Total-Sales'
from bkinfo.books as BKB
GO

select
cast(book_id as varchar) + ' ' + title as Book
, RANK() over (order by 
from bkinfo.books as BKB
GO





/*  TASK 04 */


GO

/*  TASK 05 */


GO

/*  TASK 06 */


GO

/*  TASK 07 */

GO

/*  TASK 08 */

GO

/*  TASK 09 */

GO

select book_id   
,round(sum(quantity*order_price),0)
from bkorders.order_details
group by book_id
order by book_id

with X as (
select book_id   
,round(sum(quantity*order_price),0)
from bkorders.order_details
group by book_id
)
select 
