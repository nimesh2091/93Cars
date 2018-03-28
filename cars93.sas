
/*Read the data*/
data cars_1993;
infile 'H:\HW2\93cars.dat';
input #1  manufacturer $ 1-14 
		  model 	   $ 15-29
		  type 		   $ 30-36
		  min_price 	 38-41
		  mid_price 	 43-46
		  max_price 	 48-51
		  mpg_city 		 53-54
		  mpg_highway 	 56-57
		  air_bags 		 59-59
		  drive 		 61-61
		  cylinders 	 63-63
		  engine_cap 	 65-67
		  hp 			 69-71
		  rpm 			 73-76

	  #2  eng_rev_mile	 1-4
	  	  manual_trans	 6-6
		  fuel_cap		 8-11
		  pass_cap		 13-13
		  length		 15-17
		  wheelbase		 19-21
		  width			 23-24
		  u_turn_spc	 26-27
		  rear_seat		 29-32
		  luggage_cap	 34-35
		  weight		 37-40
		  domestic		 42-42;
run;

/*check for missing values;*/
proc means data=cars_1993 n nmiss mean std median Q1 Q3;
run;

proc freq data=cars_1993;
table manufacturer model type /list nopercent nocum;
run;

/*Creating a copy of data in Work and Missing Value treatment*/
data cars_1993;
set cars_1993;
/*number of cylinders for 1993 Mazda RX-7 1.3L twin-turbo charge Sports Edition = 4*/
/*source : https://www.vehiclehistory.com/vehicle-engine-specifications/mazda/rx-7/1993*/
if manufacturer = 'Mazda' and model = 'RX-7' then cylinders = 4;
/*For sports cars with passenger capacity = 2, there is no rear seat and no boot-space*/
if pass_cap = 2 then do;
	rear_seat   = 0;
	luggage_cap = 0;
end;
/*For cars with passenger capacity > 6, there is an additional row of rear seat in-place of boot-space*/
if pass_cap > 6 then luggage_cap = 0; 
run;

proc corr data=cars_1993;
var hp mid_price;
run;

ods select BasicMeasures Quantiles;
proc univariate data= cars_1993;
var mid_price;
run;

/*removing outliers*/
data cars_1993_cut;
set cars_1993(where=(mid_price <= 38));
run;

proc reg data=cars_1993_cut;
model mid_price = mpg_city air_bags manual_trans hp domestic  
/stb;
run;

data cars_1993_cut2;
set cars_1993_cut;
/*non-linear terms*/
sq_mpg_city =mpg_city*mpg_city;
sq_hp = hp*hp;
/*interaction-variables*/
mpg_city_highway = mpg_city*mpg_highway;
mpg_city_cyl = mpg_city*cylinders;
mpg_highway_cyl = mpg_highway*cylinders;
hp_mpg_city = hp*mpg_city;
hp_mpg_highway = hp*mpg_highway;
hp_cyl = hp*cylinders;
/*dummy-variables*/
sporty_ind = (type = 'Sporty');
compact_ind = (type = 'Compact');
large_ind = (type = 'Large'); 
midsize_ind = (type = 'Midsize');
small_ind = (type = 'Small');
run;

proc reg data=cars_1993_cut2;
model mid_price = mpg_city air_bags hp domestic 
sq_mpg_city
/stb;
run;

proc reg data=cars_1993_cut2;
model mid_price = mpg_city air_bags hp domestic hp_mpg_city
sporty_ind compact_ind large_ind small_ind midsize_ind 
/stb;
run;

proc means data = cars_1993_cut2 n mean std;
var hp mid_price;
run;

proc gplot data = cars_1993_cut2;
plot mpg_city*mid_price;
run;

proc gplot data = cars_1993_cut2;
plot sq_mpg_city*mid_price;
run;

proc reg data=cars_1993_cut2;
model mid_price = mpg_city air_bags hp domestic hp_mpg_city drive/stb;
run;

/************************************************* end ********************************************************/
