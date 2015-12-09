/* Paul Clifford */

use    a_books;
GO
/*  TASK 00 */
Select getdate(), @@servername as ServerName,  @@version as VersionNumber;
GO -- git is pretty cool

/*  TASK 01 */

/*Create the view you will use in the rest of the assignment. 
You will need to use the SQL Server syntax for dropping and then creating 
the view-that is discussed in the notes for this unit. Use the view name: bkorders.BkOrdersPriorYear */

if  exists (
    select *    
    from sys.views 
    where object_id = object_id('bkorders.BkOrdersPriorYear'))
drop view bkorders.BkOrdersPriorYear;
GO

Create view  bkorders.BkOrdersPriorYear as (
    select distinct C.cust_id as c_id
    , coalesce(C.cust_name_first, 'N/A') as cust_name_first
    , coalesce(C.cust_name_last, 'N/A') as cust_name_last
    , datepart(mm, OH.order_date) as 'Order_Month'
    from bkorders.customers as C
    INNER JOIN bkorders.order_headers as OH ON OH.cust_id = C.cust_id
    where datepart(yy, OH.order_date) = datepart(yy, dateadd(yy, -1, getdate()))
    );
GO

/*  TASK 02 */

/*Display customer id and name for all customers who have at least one order in March 
and at least one order in June and at least one order in September. */

-- I should have done the concatination in the view query given the output format doesn't change. 


    select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
    where Order_Month = 3
INTERSECT 
    select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
    where Order_Month = 6
INTERSECT
    select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
    where Order_Month = 9
GO

/*  TASK 03 */

/*Display customer id and name for all customers who have at least one order in at least one of the months:
 April, June, August. */

    select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
    where Order_Month = 4
UNION
    select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
    where Order_Month = 6
UNION
    select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
    where Order_Month = 8
GO

/*  TASK 04 */

/* Display customer id and name for all customers who have at least one order in 
April and at least one order in May but no orders in June. */
    
	select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
    where Order_Month = 4
INTERSECT 
    select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
    where Order_Month = 5
EXCEPT
    select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
    where Order_Month = 6
GO

/*  TASK 05 */

/* Display customer id and name for all customers who have at least one order in either 
March or June but have no orders in September. */

    select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
	where Order_Month = 3
UNION 
    select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
	where Order_Month = 6
EXCEPT
    select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
	where Order_Month = 9
GO

/*  TASK 06 */

/* Display customer id and name for all customers who have no orders in March or June or September.  
Since you are using the view as the data source these customers will have some orders 
in the prior year but not in any of those three months */

    select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
EXCEPT (
    select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
	where Order_Month = 3
UNION
    select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
	where Order_Month = 6
UNION
    select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
	where Order_Month = 9
	)
GO

/*  TASK 07 */

/* Display customer id and name for all customers who have at least one order in 
January but no orders in February and no orders in March. */

    select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
	where Order_Month = 1
EXCEPT (
	select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
	where Order_Month = 2
UNION
	select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
	where Order_Month = 3
	)
GO

/*  TASK 08 */

/* Display customer id and name for all customers who have at least one order in 
March or June but not in both March and June. */

	select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
	where Order_Month = 3
UNION
	select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
	where Order_Month = 6
EXCEPT 
	select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
	where Order_Month = 3
INTERSECT
	select c_id
    , cust_name_last + ', ' + cust_name_first as c_name
    from bkorders.BkOrdersPriorYear
	where Order_Month = 6
GO


/* The rule for T-SQL (and for standard SQL ) is that the order of precedence is that 
Intersect is done first followed by (Except and Union) left to right */

-- CTE or a View is the good for these set operations because we need table to be same size. 
-- CTE can only be used with one select statement, but set operations count as one. 

/*
T-SQL does not use the word Distinct in the query; it is the default for all of these operators. 
UNION ALL- returns all of the rows from each of the queries. 
UNION- returns all of the rows but removes any duplicates.
INTERSECT- returns rows that are part of both of the return sets for the component queries.
EXCEPT- returns rows that were returned by the first Select and not by the second.
T-SQL does not implement Intersect All and Except All; we will see a workaround for this after we cover the analytical queries.

a non-correlated subquery can stand by itself. 
a correlated subquery has a where clause like a join. 

if subquery retuns multiple rows then use IN rather than =. Can also use NOT IN.

*/
