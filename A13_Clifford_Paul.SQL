/* Paul Clifford */

use a_books;  

GO


exec sp_helpText booksize GO  


/* function source code */ 


exec sp_helpText PrevMonth GO  


/*  TASK 00 */ Select getdate(), @@version; GO  

/*  TASK 01 */ 
IF OBJECT_ID (N'dbo.booksize') IS NOT NULL
   DROP FUNCTION dbo.booksize
GO


CREATE  FUNCTION dbo.booksize (
   @page_count int  )
   RETURNS varchar(25) 
AS
BEGIN
/* local variable declaration */

   DECLARE   @Short varchar(25);
   IF (@page_count is null)
   BEGIN
		SET @Short = 'Input value is missing'
   END
   IF (@page_count <= 200)
   BEGIN
		SET    @Short = 'Short'
   END
   ELSE
   IF (@page_count > 200 and @page_count <= 500)
   BEGIN
		SET @Short = 'Medium'
   END
   ELSE
   IF (@page_count > 500 and @page_count <= 1200)
   BEGIN
		SET @Short = 'Long'
   END
   ELSE
   IF (@page_count > 1200 and @page_count <= 4000)
   BEGIN
		SET @Short = 'ExtraLong'
   END
   ELSE
   IF (@page_count > 4000 and @page_count <= 10000)
   BEGIN
		SET @Short = 'SuperLong'
   END
   ELSE
   IF (@page_count > 10000)
   BEGIN
		SET @Short = 'SuperDUPERLong'
   END
   RETURN @Short;
END;
GO

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
   select 14,    400000000,'SuperDDUPERLong'
) as tstTbl;  -- turn this into a CTE. I like those better. 


/*  TASK 02 */ 

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

) 
,
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



/*  TASK 03 */ replace this line with your SQL for task 03 GO  

/*  TASK 04 */ replace this line with your SQL for task 04 GO 

/*  TASK 05 */ replace this line with your SQL for task 05 GO 



