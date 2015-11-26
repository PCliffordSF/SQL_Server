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


with rankings as (
	select  DENSE_RANK() over (order by round(sum(quantity*order_price),0) desc) as SalesRanking
	, BKB.book_id
	, BKB.title
	, round(sum(quantity*order_price),0) as OrderTotal
from bkinfo.books as BKB
INNER JOIN bkorders.order_details as BKOD ON BKOD.book_id = BKB.book_id
group by BKB.book_id, BKB.title
)
select SalesRanking as 'Sales-Ranking'
, cast(book_id as varchar) + ' ' + title as Book
, OrderTotal as 'Total-Sales'
from rankings
where SalesRanking <= 10

/*  TASK 04 */
/*

Display the following style of report.  
For each book we want to know what percentage of total sale this book is for its 
publisher and its percentage of all sales. Use a partition by expression.
Do not include books where we do not have publisher information.  Do not include books with no sales. 
The first column is the publisher id and the second is the book id and title. 
For example, book 1627 accounts for 45.5% of the total sales of the books published by publisher 
9022 and book 1629 accounts for 54.5% of the total sales of the books published by that publisher. 
After you get the query to work, then format the last two columns as shown; the % sign is 
concatenated to the column expression. The sort order is by publisher id and book id. 
       Publ			Book                          Book_Sales Publ_Sales % All_Sales % 
	   ----------- ------------------------- -------------- ------------ ----------- 
. . .        
			9022	1627 The Ants                     199.95       45.5 %       0.1 %        
			9022	1629 The Leafcutter Ants:         239.40       54.5 %       0.1 %        
			9030	2002 SQL Server 2005 A Be         955.00        4.2 %       0.4 %        
			9030	2004 SQL Server 2005 Stor          49.95        0.2 %       0.0 %        
			9030	2018 Oracle Database 11g           99.98        0.4 %       0.0 %        
			9030	2025 Oracle SQL Fundament       21840.00       95.2 %       9.5 %        
			9102	1104 Sibley Guide to Bird        5715.00      100.0 %       2.5 %
. . .
*/

declare @total decimal(10,2)

set @total = (
	select sum(quantity*order_price)
	from bkorders.order_details
);

with publisher as (
	select RANK() over (partition by BKB.publ_id order by BKB.book_id) as publisher_rank 
	,BKB.publ_id
	, round(sum(quantity*order_price),0) as Book_Sales
	, BKB.book_id 
	, cast(BKB.book_id as varchar) + ' ' + title as Book
	from bkinfo.books as BKB
	INNER JOIN bkorders.order_details as BKOD ON BKOD.book_id = BKB.book_id
	INNER JOIN bkinfo.publishers as BKP ON BKP.publ_id = BKB.publ_id
	group by BKB.book_id, BKB.publ_id, title
)
select publ_id as publ
, Book
, Book_Sales
, concat(cast(cast(round(Book_Sales*1.0 / (sum(Book_Sales) over (partition by publ_id))*100,1) as decimal(10,1)) as varchar), + ' %') as 'Publ_Sales %'
, concat(cast(cast((Book_Sales*100)/@total as decimal(10,1)) as varchar), ' %') as 'All_Sales %'
from publisher
group by book_id, publ_id, Book, Book_Sales
order by publ_id, book_id
GO


/*  TASK 05 */
/*
Rollup total sales for each book by author.  
The third column is the total quantity of books sold and the fourth is the total sales.  
Include rows if an author or book title has no sales but do not include authors with no books.  
Only use the sales data for the first author of a book- use the sequence attribute in the book_author
 table. For this task you may assume that there will always be an author with sequence 1 for each 
 book. This means that if a book has three authors, we include the sales data only under the first author 
 and not with all three authors. 
 Note that there is a grand total line at the bottom.  
 To keep the output shorter limit this to authors with an ID that is less than 'J'. 
 You can do that filter in the CTE. 
 The following is typical output; format your output to match this display.   
Author ID  Book ID Total-Quantity   Total-Sales  
---------- ------- -------------- -------------- 
ABCDE      1948                 6         125.64 
ABCDE        Total              6         125.64 
B3456      1142                19         506.80 
B3456        Total             19         506.80 
B8018      1102                 2         100.00 
B8018      1670                60        1200.00 
B8018      1689                13         700.45 
B8018        Total             75        2000.45 
C5820      1899                 0       No sales 
C5820        Total              0       No sales 
F6654      1526                 5         379.95 
F6654      1527                 0       No sales 
F6654        Total              5         379.95 
. . . . 
GrandTotal   Total           3083       89372.42 

*/

with group_roll_up as (
	select BKBA.author_id
	, BKB.book_id
	, quantity
	, order_price
	, order_id
	, BKOD.quantity*order_price as Extended_Price
	from bkinfo.book_authors as BKBA
	INNER JOIN bkinfo.books as BKB ON BKB.book_id = BKBA.book_id
	LEFT JOIN bkorders.order_details as BKOD ON BKOD.book_id = BKB.book_id
	where author_id < 'J'
	group by BKB.book_id, BKBA.author_id, quantity, order_price, order_id
)
select coalesce(author_id, 'Grand Total') as 'Author ID'

, case when author_id is null and book_id is null then ''
when book_id is null then 'Total' 
else cast(book_id as varchar) end as 'Book ID'

, ISNULL(sum(quantity),0) as 'Total - Quantity'
, ISNULL(cast(sum(Extended_Price) as varchar), 'No sales') as 'Total - Sales'
from group_roll_up
group by rollup(author_id, book_id)
order by author_id, book_id desc


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

--------\


with sales_rank as (
select DENSE_RANK() over (order by round(sum(quantity*order_price),0) desc) as 'Sales-Ranking'	 
, round(sum(quantity*order_price),0) as 'Total-Sales'
from bkorders.order_details as BKOD
group by book_id
)
select [Sales-Ranking]
,concat ( 
	(
	select cast(book_id as varchar)
    from bkinfo.books as BKB
	group by book_id, title
	having BKB.book_id = sales_rank.book_id
	)
	 , ' ', 
	 ( 
	 select title
	 from bkinfo.books as BKB
     group by book_id, title
	having BKB.book_id = sales_rank.book_id
	 )
	 ) as Book

, [Total-Sales]
from sales_rank as SR
GO

, concat ( 
	(
	select cast(book_id as varchar)
    from bkinfo.books as BKB
	group by book_id, title
	having BKB.book_id = BKOD.book_id
	)
	 , ' ', 
	 ( 
	 select title
	 from bkinfo.books as BKB
     group by book_id, title
	having BKB.book_id = BKOD.book_id
	 )
	 ) as Book