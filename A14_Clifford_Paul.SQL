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
, datax.value('(//bk_subject)[1]', 'varchar(18)') as Subject
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
where datax.value('(//bk_price)[1]', 'decimal(8,2)') > 55;
GO


/*  TASK 04 */

/* Use the value function to query for all books where the first subject area is Fiction 
and the book costs more than $30.50. Display the book id, title of the book, 
and the price. Use the exist function and xml predicates in the filter. 
Do not use the value function in the filter. */

select  datax.value('(//bk_id)[1]', 'varchar(18)')  as BookID
, datax.value('(//bk_title)[1]', 'varchar(18)') as Title
, datax.value('(//bk_price)[1]', 'decimal(8,2)') as Price
, datax.value('(//bk_subject)[1]', 'varchar(18)') + ' ' +
 ISNULL(datax.value('(//bk_subject)[2]', 'varchar(18)'), ' ') +
 ISNULL(datax.value('(//bk_subject)[3]', 'varchar(18)'), '') as AllSubject
from xml_A14_books
where datax.exist('(/book)[bk_price[1] gt 30.5]') = 1;
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

/*  TASK 10 */

GO

