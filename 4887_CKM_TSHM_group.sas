PROC IMPORT
	out=EADATA.Project_Data
	datafile='/home/u59794020/EAdata/Project_Housing.csv'
	dbms=csv
	replace;
run;

*Generate (5 to 10 rows) processed renting post records. (5M);
proc print data=EADATA.Project_Data(firstobs=5 obs=10);
run;

*What kind of property is having the most number of the bathroom on average? (5M);
proc sql;
	create table Result as
	select FlatType, avg(TotalBaths) as average_baths
	from EADATA.Project_Data
	group by FlatType;
	
	select * from Result
	having average_baths = max(average_baths);
run;

*What is the contribution of house type in the record? What is the most common type of property in the UK? (5M);
proc sql;
	create table Pie as
	select FlatType, count(FlatType) as Flat_count from EADATA.Project_Data
	group by FlatType;

run;

proc sgpie data=Pie;
	title "contribution of house type";
	pie FlatType / response=Flat_count;
run;
title;


title;

*What is the value distribution of the number of Reception between the semi-detached house
and terraced house? (10M)
title 'Actual Sales by Product and Year';
proc sgplot data=EADATA.Project_Data;
	where FlatType in("semi-detached house" "terraced house");
	vbar FlatType/response=TotalReceptions stat=freq;
run;

*What kind of property is contain the second most turnover? (5M);
proc sql;
	create table tmp1 as
	select FlatType,sum(price) as price
	from EADATA.Project_Data
	group by FlatType
	order by price desc;
 
	create table tmp2 as
	select FlatType, price, monotonic() as rank
	from tmp1
	where calculated rank = 2;
	
	create table Q5 as
	select *
	from tmp1
	where price in (select price from tmp2);
	
	select * from Q5;
run;

*Is there any relationship between the number of bedrooms, the number of bathrooms and the
average price of a different property? (10M);

