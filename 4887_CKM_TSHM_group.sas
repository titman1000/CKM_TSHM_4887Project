PROC IMPORT
	out=classb.Project_Data
	datafile='/home/u59459038/data/Project_Housing.csv'
	dbms=csv
	replace;
run;

*Generate (5 to 10 rows) processed renting post records. (5M);
proc print data=classb.Project_Data(firstobs=5 obs=10);
run;

*What kind of property is having the most number of the bathroom on average? (5M);
proc sql;
	create table Result as
	select FlatType, avg(TotalBaths) as average_baths
	from classb.Project_Data
	group by FlatType;
	
	select * from Result
	having average_baths = max(average_baths);
run;

*What is the contribution of house type in the record? What is the most common type of property in the UK? (5M);
proc sql;
	create table Pie as
	select FlatType, count(FlatType) as Flat_count from classb.Project_Data
	group by FlatType;

run;

proc sgpie data=Pie;
	title "contribution of house type";
	pie FlatType / response=Flat_count;
run;
title;

*What is the value distribution of the number of Reception between the semi-detached house and terraced house? (10M) ;
proc sql;
	create table Pie as
	select Reception, count(FlatType) as Flat_count from classb.Project_Data
	where FlatType ==
	group by FlatType;

run;


proc sgpie data=Pie;
	title "contribution of house type";
	pie FlatType / response=Flat_count;
run;
title;