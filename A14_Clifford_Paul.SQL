/* Paul Clifford */

use a_books;
Go
set  QUOTED_IDENTIFIER on
GO
/*  TASK 00 */
Select getdate(), @@servername as ServerName,  @@version as VersionNumber;

GO
/*  TASK 01 */
/*Use the value function to show the book id, title, the price and the first two subjects of each book. 
Follow the format shown below. 
BookID     Title                     Price        Subject_1    Subject_2 
---------- ------------------------- ------------ ------------ ------------  
402        Birdland                         12.34 ornithology  NULL 
415        Adventures in XML                33.34 XML          Fiction 
485        Schema Refactoring               76.50 Database     XML 
497        Test-driven Programming          28.00 Logic        NULL */


select  datax.value('(//bk_id)[1]', 'varchar(18)')  as BookID
, datax.value('(//bk_title)[1]', 'varchar(18)') as Title
, datax.value('(//bk_price)[1]', 'decimal(8,2)') as Price
, datax.value('(//bk_subject)[1]', 'varchar(18)') as Subject_1
, datax.value('(//bk_subject)[2]', 'varchar(18)') as Subject_2
from xml_A14_books;
GO

/*  TASK 02 */

/* Use the value function to show the book id, title, and the price of each book 
where the first subject area is Fiction. Use the value function in the filter on the bk_subject.  */

select  datax.value('(//bk_id)[1]', 'varchar(18)')  as BookID
, datax.value('(//bk_title)[1]', 'varchar(18)') as Title
, datax.value('(//bk_price)[1]', 'decimal(8,2)') as Price
from xml_A14_books
where datax.value('(//bk_subject)[1]', 'varchar(18)') = 'Fiction';
GO

/*  TASK 03 */

/* Use the value function to query for all books where the first subject area is Fiction 
and the book costs more than $55.00. Display the book id, title of the book, 
the price and a list of all topics for the book in a single column . Use the value function in the filter.  
BookID     Title                            Price        AllSubjects 
---------- -------------------------------- ------------ -------------------------------------- 
109        Birds of a Feather                69.99			Fiction   
9214       SQL and More                     100.00			Fiction SQL  
9845       SQL and its role in the Universe 275.00			Fiction SQL DB */

select  datax.value('(//bk_id)[1]', 'varchar(18)')  as BookID
, datax.value('(//bk_title)[1]', 'varchar(18)') as Title
, datax.value('(//bk_price)[1]', 'decimal(8,2)') as Price
, datax.value('(//bk_subject)[1]', 'varchar(18)') + ' ' +
 ISNULL(datax.value('(//bk_subject)[2]', 'varchar(18)'), ' ') +
 ISNULL(datax.value('(//bk_subject)[3]', 'varchar(18)'), '') as AllSubject
from xml_A14_books
where datax.value('(//bk_subject)[1]', 'varchar(18)') = 'Fiction'
AND 
	  datax.value('(//bk_price)[1]', 'decimal(8,2)') > 55;
GO


/*  TASK 04 */

/* Use the value function to query for all books where the first subject area is Fiction 
and the book costs more than $30.50. Display the book id, title of the book, 
and the price. Use the exist function and xml predicates in the filter. 
Do not use the value function in the filter. */


select  datax.value('(//bk_id)[1]', 'varchar(18)')  as BookID
, datax.value('(//bk_title)[1]', 'varchar(18)') as Title
, datax.value('(//bk_price)[1]', 'decimal(8,2)') as Price
from xml_A14_books
where datax.exist('/book[bk_price[1] gt 30.5]') = 1
AND
datax.exist('/book[bk_subject[1] eq "Fiction"]') =1



/*  TASK 05 */
/* Display the book id as the first column, the title of the book as the second column 
and the author list as an xml fragment as the third column. 
(The third column is shown line wrapped here due to the limitations of a Word document; 
this does not happen in the database.) Limit this to books where the first or second author is named Martin.  
Sample display  
BookID     Title                     authors 
---------- --------------------- ------------------------------------------------------ 
254        XQuery is Too Easy    <bk_authors><author>Martin</author></bk_authors> 
258        Alice knows XML       <bk_authors><author>Albertson</author><author>Martin </author>< author>Dawson</author></bk_authors> */

select  datax.value('(//bk_id)[1]', 'varchar(18)')  as BookID
, datax.value('(//bk_title)[1]', 'varchar(18)') as Title
, datax.query('(//bk_authors)[1]') as authors
from xml_A14_books
where datax.value('(//author)[1]', 'varchar(18)') = 'Martin'
or  datax.value('(//author)[2]', 'varchar(18)') = 'Martin'      
GO


/*  TASK 06 */

/* Display the book id as the first column, the title of the book as the second column and the author 
list as an xml fragment as the third column.   Limit this to books where any of the authors is named Martin. 
The display follows the format of Task 05 */

select  datax.value('(//bk_id)[1]', 'varchar(18)')  as BookID
, datax.value('(//bk_title)[1]', 'varchar(18)') as Title
, datax.query('(//bk_authors)[1]') as authors
from xml_A14_books
where datax.exist('//book/bk_authors[author = "Martin"]') = 1
GO

/*  TASK 07 */
/* Display the book id as the first column, the title of the book as the second column and the author 
list as an xml fragment as the third column.   
Limit this to books where none of the authors is named Martin. The display follows the format of Task 05. */

select  datax.value('(//bk_id)[1]', 'varchar(18)')  as BookID
, datax.value('(//bk_title)[1]', 'varchar(18)') as Title
, datax.query('(//bk_authors)[1]') as authors
from xml_A14_books
where datax.exist('//book/bk_authors[author = "Martin"]') = 0
GO


/*  TASK 08 */

/* Display the average price of the books which are classified as SQL books; 
SQL can be any of the bk_subject values. 
Sample display  
AvgPrice 
------------        
34.99 */

with priceData as (
select datax.value('(//bk_price)[1]', 'decimal(8,2)') as Price
, datax.value('(//bk_subject)[1]', 'varchar(18)') as subject
, datax.value('(//bk_title)[1]', 'varchar(18)') as title
from xml_A14_books
where datax.exist('//book[bk_subject = "SQL"]') = 1
)
select cast(avg(Price) as decimal(8,2)) as AvgPrice
from priceData
GO

/*  TASK 09 */

/* For this task, a book is considered an SQL book if any of its subjects is SQL. 
Display one row with four columns  (1) the average price and (2) the count of the books 
which are classified as SQL books and (3) the  average price and (4) the count of books which are not SQL books. 
Suggestion: If you use two inline views ( or CTEs) that each return a single row; 
then you can cross join these to get a single result set. 
Sample display 
AvgPrice_SQL   Count_SQL AvgPrice_Other Count_Other
------------ ----------- -------------- -----------        
45.50          12          89.56           7 */




with SQLPriceData as (
select cast(avg(datax.value('(//bk_price)[1]', 'decimal(8,2)')) as decimal(8,2)) as AvgPrice_SQL
, count(*) as Count_SQL
from xml_A14_books
where datax.exist('//book[bk_subject = "SQL"]') = 1
),
NotSQLPricedata as (
select cast(avg(datax.value('(//bk_price)[1]', 'decimal(8,2)')) as decimal(8,2)) as AvgPrice_Other
, count(*) as Count_Other
from xml_A14_books
where datax.exist('//book[bk_subject = "SQL"]') = 0
)
select *
from SQLPriceData
CROSS JOIN NotSQLPricedata 
GO

/*  TASK 10 */

/* Produce a display as shown here. We are displaying the average price of the books for each subject, 
using the first subject of each book. The last row is the average price of all books.  
(Suggestion: use a CTE and  use rollup in the main query.
Do not list the subject areas as literals in your query The query should use whatever subject values 
are in the data as the first subject of the book. 
Subject         AvgPrice 
---------- ------------- 
Database           39.99 
Fiction           142.19 
SQL                54.99 
XML                16.75 
All Subjects       77.36 */

with averagePriceData as (
select datax.value('(//bk_price)[1]', 'decimal(8,2)') as 'Price'
, datax.value('(//bk_subject)[1]', 'varchar(18)') as 'Subject'
from xml_A14_books
)
select ISNULL(subject, 'All Subjects') as 'Subject'
, cast(avg(Price) as decimal(8,2)) as AvgPrice
from averagePriceData
group by rollup (Subject)
GO

