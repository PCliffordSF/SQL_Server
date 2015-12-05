/* Paul Clifford */

use    a_vets;
GO
/*  TASK 00 */
Select getdate(), @@servername as ServerName,  @@version as VersionNumber;

GO
/*  TASK 01 */

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

select count(A.an_id) as NumberOfExams
from vt_animals as A
INNER JOIN vt_exam_headers as EH ON EH.an_id = A.an_id
where an_type in ('hamster', 'capybara', 'porcupine', 'dormouse') AND 
      EH.ex_date > dateadd(year,-1,getdate());	
GO

/*  TASK 03 */

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

select count(ex_id) as'Number of Exams'
, count(distinct an_id) as 'Number of Animals'
from vt_exam_headers
where ex_date > dateadd(qq, datediff(qq , 0 , getdate())-1 , 0) AND ex_date < dateadd(qq, datediff(qq , 0 , getdate()), 0);
GO

/*  TASK 05 */

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

select count(case when an_type = 'cat' then an_type end) as 'Kitty Cats'
, count(case when an_type = 'dog' then an_type end) as 'Doggies'
, count(case when an_type in ('hamster', 'capybara', 'porcupine', 'dormouse') then an_type end) as 'Rodents'
, count(an_type) as 'All Animals'
from vt_animals;
GO

/*  TASK 07 */

select C.cl_id
, C.cl_name_last
from vt_clients as C
INNER JOIN vt_animals as A on A.cl_id = C.cl_id
group by C.cl_id, C.cl_name_last
having count(an_id) = 1
GO

/* tast 8 */

select A.an_id
, an_type
, coalesce(an_name, 'no name') 
, coalesce((cast(datepart(mm , max(ex_date)) as varchar) + '/' + cast(datepart(dd , max(ex_date)) as varchar) + 
'/' + cast(datepart(yyyy , max(ex_date)) as varchar)), 'No Exam') as MostRecentExam
from vt_animals as A
LEFT JOIN vt_exam_headers as EH ON EH.an_id = A.an_id
group by A.an_id, an_type, an_name

/*  TASK 09 */

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
