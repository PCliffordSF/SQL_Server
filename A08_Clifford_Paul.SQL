/* Paul Clifford */

-- MIN, MAX, SUM, COUNT, AVG

/*
select . . .
from . . . 
where . . . filters table construction. 
group by . . . Partitions the table. includes nulls as a group. Use coalesce to display message. 
having . . . filters groups. 
order by . . . 

This is how the DMBS processes
1.	The FROM clause is evaluated first
2.	The WHERE clause
3.	The GROUP BY clause
4.	The HAVING clause
5.	The SELECT clause
6.	The ORDER BY clause is done last
*/

use    a_vets;
GO
/*  TASK 00 */
Select getdate(), @@servername as ServerName,  @@version as VersionNumber;

GO
/*  TASK 01 */

/*
Display the number of exams and the total fees charged for all exams for animal id 16003. 
Then repeat this query for animal 21205. 
NumberOfExams  TotalFees 
------------- ----------            
12     678.25 */

with feesummary as (
    select EH.an_id
	, ED.ex_fee
	, ED.ex_id
	from vt_exam_headers as EH
	INNER JOIN vt_exam_details as ED ON ED.ex_id = EH.ex_id
	)
select count(distinct ex_id) as NumberOfExams
, sum(ex_fee) as TotalFees
from feesummary
group by an_id 
having an_id in (16003);

with feesummary as (
    select EH.an_id
	, ED.ex_fee
	, ED.ex_id
	from vt_exam_headers as EH
	INNER JOIN vt_exam_details as ED ON ED.ex_id = EH.ex_id
	)
select count(distinct ex_id) as NumberOfExams
, sum(ex_fee) as TotalFees
from feesummary
group by an_id 
having an_id in (21205);

/*  TASK 02 */

/* Display the number of exams for all rodents that were done in the previous year. 
NumberOfExams 
-------------            
30 */

select count(A.an_id) as NumberOfExams
from vt_animals as A
INNER JOIN vt_exam_headers as EH ON EH.an_id = A.an_id
where an_type in ('hamster', 'capybara', 'porcupine', 'dormouse') AND 
      year(EH.ex_date) = year(dateadd(yyyy,-1,getdate()))	
GO


/*  TASK 03 */

/* For every client in the clients table, display the client ID, last name, the number of animals 
they have and the number of rodents they have. Sort by the client id.   
Client ID Client Name    Number of Animals Number of Rodents 
----------- -------------- ----------------- -----------------         
411 Carter                           5                 0       
1825 Harris                          3                 3       
1852 Dalrymple                       8                 0       
1967 Dixon                           0                 0 */

with clientsummary as (
    select C.cl_id
	, C.cl_name_last
	, A.an_id
	, A.an_type
	from vt_clients as C
	LEFT JOIN vt_animals as A ON A.cl_id = C.cl_id
	)
select cl_id as 'Client ID'
, cl_name_last as 'Client Name'
, count(an_id) as NumberOfAnimals
, count(CASE when an_type in ('hamster', 'capybara', 'porcupine', 'dormouse') then an_type end) as 'Number of Rodents'
from clientsummary
group by cl_id, cl_name_last
order by cl_id;
GO

/*  TASK 04 */

/* Display the number of exams that were performed in the previous quarter 
and the number of animal with an exam in the previous quarter. An animal that had more than one exam 
in that time period counts as a single animal. This query produces a single row with two columns. 
The term "previous quarter " means any date in the quarter before the current quarter. 
If you run the query in Aug 2015, that is the third quarter of 2015. 
The query will return data for the second quarter of 2015. If you run the query in Feb 2016, 
that is the first quarter of 2016, the query will return data for the fourth quarter of 2015. 
A quarter is a three month span starting with Jan. Jan, Feb, Mar are the first quarter; 
Apr, May, Jun are the second quarter; Jul, Aug, Sep are the third quarter; Oct, Nov, Dec are the fourth quarter. 
Number of Exams Number of Animals with Exams 
--------------- ----------------------------              
78                          6 */

select count(ex_id) as'Number of Exams'
, count(distinct an_id) as 'Number of Animals'
from vt_exam_headers
where datepart(year,dateadd(month, -3 ,getdate())) =  datepart(year, ex_date) 
AND datepart(quarter,dateadd(month, -3 ,getdate())) =  datepart(quarter, ex_date) ;
GO



/*  TASK 05 */

/* Display the client id and last name of the clients who has the highest total  
exam fees for all of their animals. Consider there might be ties for first place-  
in that case, all tied clients should be returned.       
cl_id		cl_name_last 
----------- -------------------------        
1234		Coltrane */

with feeTotal as (
    select C.cl_id
	, C.cl_name_last
	, ED.ex_fee
    from  vt_clients as C
	INNER JOIN vt_animals as A ON A.cl_id = C.cl_id
	INNER JOIN vt_exam_headers as EH on EH.an_id = A.an_id
	INNER JOIN vt_exam_details as ED on ED.ex_id = EH.ex_id
    )
select cl_id
, cl_name_last
from feeTotal
group by cl_id, cl_name_last
having sum(ex_fee) = (
	select top(1) sum(ex_fee)
	from feeTotal
	group by cl_id
	order by sum(ex_fee) desc
	)

/*  TASK 06 */

/* Use the cross tab techniques described in the notes for this task. 
We want to know how many animals we have in the animals  table in each of the indicated categories. 
We also want a count for all animals. This query has a single output row.       
Cats		   Dogs    Rodents	 Reptiles All Animals
 ---------- ---------- ---------- ---------- -----------
  22         98         24          45        312 */

select count(case when an_type = 'cat' then an_type end) as 'Kitty Cats'
, count(case when an_type = 'dog' then an_type end) as 'Doggies'
, count(case when an_type in ('hamster', 'capybara', 'porcupine', 'dormouse') then an_type end) as 'Rodents'
, count(an_type) as 'All Animals'
from vt_animals;
GO

/*  TASK 07 */

/*  Display the client' s id and last name for all clients who have only one animal.       
cl_id		cl_name_last 
----------- -------------------------        
1234		Coltrane */

select C.cl_id
, C.cl_name_last
from vt_clients as C
INNER JOIN vt_animals as A on A.cl_id = C.cl_id
group by C.cl_id, C.cl_name_last
having count(an_id) = 1
GO

/* tast 8 */

/* For each animal that we have in the animals table, list the animal id, type, and 
name and the date of the most recent exam for that animal.  If the animal has no exams, 
then display "No Exams'  in the column for the exam date. Order by the animal id    
AnimalID an_type                   an_name                   MostRecentExam 
----------- ------------------------- ------------------------- ---------------       
10002 cat                       Gutsy                     No Exams       
11025 bird                      no name                   No Exams       
12035 bird                      Mr Peanut                 01/09/2015            
15001 chelonian                 Big Mike                  01/31/2015            
15002 chelonian                 George                    08/10/2015            
15165 dog                       Burgess                   No Exams       
15401 lizard                    Pinkie                    11/06/2014 */

select A.an_id
, an_type
, coalesce(an_name, 'no name') 
, coalesce((cast(datepart(mm , max(ex_date)) as varchar) + '/' + cast(datepart(dd , max(ex_date)) as varchar) + 
'/' + cast(datepart(yyyy , max(ex_date)) as varchar)), 'No Exam') as MostRecentExam
from vt_animals as A
LEFT JOIN vt_exam_headers as EH ON EH.an_id = A.an_id
group by A.an_id, an_type, an_name

/*  TASK 09 */

/* The vets needs to make more money this year. Find all the animals with a total fees of 
more than $150 but the animal has no exam this year. Display the animal id, type and 
name and the cl_id and phone number.       
an_id an_type               an_name                   cl_id cl_phone 
----------- --------------------- ------------------- ----------- ------------       
17002 porcupine             Fritzchen                  5699 415.239.6875       
21005 dormouse              Koshka                     1825 NULL */

select A.an_id
, an_type
, an_name
, C.cl_id
, C.cl_phone
from vt_animals as A
INNER JOIN vt_clients as C on C.cl_id = A.cl_id
INNER JOIN vt_exam_headers as EH ON EH.an_id = A.an_id
INNER JOIN vt_exam_details as ED ON ED.ex_id = EH.ex_id
group by A.an_id, an_type, an_name, C.cl_id, C.cl_phone
having sum(ex_fee) > 150 and year(max(ex_date)) <> year(getdate());
GO

-- aggregate functions. IGNORE NULLS. return values they know. will return nulls if there is no value. 
-- max, min, sum, avg, 
-- count and count(distinct). Does not count nulls. 
declare @date date
set @date = '12-16-15'

-- shorter versions of datepart function. 
select year(@date) as year
select month(@date) as month
select day(@date) as day 

select datepart(quarter, @date) as Q
select datepart(day, @date) as D
select datepart(month, @date) as M
select datepart(year, @date) as Y GO