/* Paul Clifford */

use    a_books;
GO
/*  TASK 00 */
Select getdate(), @@servername as ServerName,  @@version as VersionNumber;
GO -- git is pretty cool

/*  TASK 01 */

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
