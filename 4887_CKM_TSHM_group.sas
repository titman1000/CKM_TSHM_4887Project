PROC IMPORT
	out=EADATA.Project_Data
	datafile='/home/u59794020/EAdata/Project_Housing.csv'
	dbms=csv
	replace;
run;

*Generate (5 to 10 rows) processed renting post records. (5M);
proc print data=EADATA.Project_Data(firstobs=5 obs=10);
run;
ods text = 'Here are turnover processed renting post records from row 5 to row 10.';

*What kind of property is having the most number of the bathroom on average? (5M);
proc sql;
	create table Result as
	select FlatType, avg(TotalBaths) as average_baths
	from EADATA.Project_Data
	group by FlatType;
	
	select * from Result
	having average_baths = max(average_baths);
ods text='The detached house property has the highest average bathroom which is 2.22.'
run;

*What is the contribution of house type in the record? What is the most common type of property in the UK? (5M);
proc sql;
	create table Pie as
	select FlatType, count(FlatType) as Flat_count from EADATA.Project_Data
	group by FlatType;
run;

proc sgpie data=Pie;
	title "Contribution of house type";
	pie FlatType / response=Flat_count;
run;
title;
ods text='The most common type of property in the UK is Flat type.';

*What is the value distribution of the number of Reception between the semi-detached house
and terraced house? (10M);
title 'Value distribution of the number of Reception';
proc sgplot data=EADATA.Project_Data;
	where FlatType in("semi-detached house" "terraced house");
	vbar FlatType/group=TotalReceptions groupdisplay=cluster stat=freq;
run;
ods text='These both plots follows normal distribution.';
ods text='In semi-detached house, it follows  left-skewed distribution.';
ods text='In terraced house,  it seems like no skewness because the number of receptions at the middle is too high.';

*What kind of property is contain the second most turnover? (5M);
title 'What kind of property is contain the second most turnover';
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
ods text='Terraced house contain the second most turnover.';

*Is there any relationship between the number of bedrooms, the number of bathrooms and the
average price of a different property? (10M);
/* Summarize SASHELP.CARS for mean MPG_HIGHWAY */
proc sql;
	create table Bed as
	select FlatType, mean(price) as price, TotalBeds from EADATA.Project_Data
	group by FlatType, TotalBeds;
	

proc sgplot data=Bed;
   title 'Beds price';
   scatter x=TotalBeds y=price /group=FlatType;
   reg x=TotalBeds y=price;
run;

proc sql;
	create table Bath as
	select FlatType, mean(price) as price, TotalBaths from EADATA.Project_Data
	group by FlatType, TotalBaths;
	

proc sgplot data=Bath;
   title 'Baths price';
   scatter x=TotalBaths y=price /group=FlatType;
   reg x=TotalBaths y=price;
run;
ods text='The number of bathrooms and bedrooms is proportional to the average price.'