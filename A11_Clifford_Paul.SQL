/* Paul Clifford */

use    -- db.name;
GO
/*  TASK 00 */
Select getdate(), @@servername as ServerName,  @@version as VersionNumber;

GO
/*  TASK 01 */
/*For each customer in the customers table who lives in New Jersey (NJ) or in Massachusetts (MA), 
display their id, their last name and the number of orders they have. 
Sort by the customer id.
Cust_ID Cust_Name_Last Number Of Orders 
------- -------------------- ---------------- 
300124  Adams                              21 
300150  Jobs                                1 
300153  Jones                              12*/

GO

/*  TASK 02 */
/*Use an Exists query to display the customer id and last name for any customer who ordered a book 
in each (every one) of the first three months of the current year. Sort by the customer id. 
(The first three months of any year are always Jan, Feb, Mar- so you can hard code the months.) */

GO

/*  TASK 03 */
/*Use an Exists query to display the author information for authors who have more than one book
 but for whom we have no book sales.  Sort by the author id.  
 Author_Name_First    Author_Name_Last     Author_ID
  -------------------- -------------------- --------- 
  Mark                 Gersten              G1234 
  Sue                  Haldeson             H9876     */

GO

/*  TASK 04 */
/*We want to find any books which cover exactly two of the different sql systems using the topic ids
 'SSRV', 'ORA', 'MySQL'  For example, the book could have a topic of SSRV and a topic of ORA, but not MySQL.
  Any two of these topics is sufficient to pass our filter.
  Display the id and title of the book(s) that are meet this test. */


GO

/*  TASK 05 */
/*For each order placed in the first three months of the previous year, display the following pieces of data: 
order date order 
id customer 
id customer 
last name - use an alias of customer 
total number of books purchased ( quantity) on that order- use an alias of NumberBooks total amount due for that order
 - use an alias of OrderCost.  Sort the result  by the order date.
 (Suggestion- use the order headers table in the From clause of the main query.)
  Remember you are not allowed to use joins other than that required for a correlated subquery. */ 


GO

/*  TASK 06 */
/*Display the customer id and last name for customers with at least three and no more than five
 orders last year. Sort by the customer id.*/

GO

/*  TASK 07 */
/*Display the cust id and last name of customers who had the same or more orders in the first quarter 
of last year than they had in the first quarter of the current year.
 Count the order id values for this comparison.
  This will include only customers who have any orders in those two time periods. Sort by the customer id.*/

GO
