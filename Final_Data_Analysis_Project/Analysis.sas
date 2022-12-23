libname fdap "/home/u59566911/sasuser.v94/BIOSTAT 236/Data";

proc contents data = fdap.new_data;
proc print data = fdap.new_data;
proc print data = fdap.income;
proc sort data = fdap.new_data;
by id;
proc sort data = fdap.income;
by id;
data fdap.new_data_final;
merge fdap.new_data fdap.income;
 by id;
keep ID
  Sex
   parent_born_in_US
   age_at_baseline
  region
   PIAT_0
   Race_Ethnicity
   PIAT_2
   PIAT_1
   PIAT_3
   born_in_US
   PIAT_4
   English_primary_reading
   PIAT_5
   gross_income;
   if PIAT_0 < 0 OR PIAT_1 < 0  then delete;
run;
proc print data = fdap.new_data_final;
proc contents data = fdap.new_data_final;
proc sort data = fdap.new_data_final;
by id;
proc print data = fdap.new_data_final;
proc transpose data = fdap.new_data_final out = fdap.analysis_data prefix = PIAT;
by id;
var PIAT_0 PIAT_1 PIAT_2 PIAT_3 PIAT_4 PIAT_5;

data fdap.almost_cleaned;
merge fdap.analysis_data fdap.new_data_final;
by id;
rename PIAT1 = PIAT_score;
years_since_baseline = input(substr(_name_, 6, 1), 1.);
drop _name_ _label_ PIAT_0 PIAT_1 PIAT_2 PIAT_3 PIAT_4 PIAT_5;

data fdap.cleaned;
	set fdap.almost_cleaned;
	if PIAT_score <= 10 then delete;
	if parent_born_in_US < 0 then delete;
	if english_primary_reading <1 then delete;
	if region < 1 then delete;
	if gross_income < 0 then delete;
	if gross_income < 10000 then income_cat = 1;
	if gross_income < 50000 and gross_income >= 10000 then income_cat = 2;
	if gross_income < 100000 and gross_income >= 50000 then income_cat = 3;
	if gross_income >=100000 then income_cat = 4;
	rename years_since_baseline = time;
run;
proc freq data = fdap.cleaned nlevels;
	table id;
	table PIAT_score;
proc sql;
	create table count as select count (*) as Number_of_Observations from fdap.cleaned;
	create table y as select count(unique(ID)) as Number_of_Subjects from fdap.cleaned ;
quit;
proc sgplot data = fdap.cleaned;
	histogram PIAT_score;
proc univariate data=fdap.cleaned normal; 
		VAR PIAT_score;
		run;



*Emperical within-residuals;
proc means data = fdap.cleaned NWAY;
	class id;
	var PIAT_score;
	output OUT = means  (drop = _TYPE_ _FREQ_) mean = mean_score;

proc sort data = fdap.cleaned;
	by id;

data fdap_plot;
	merge means fdap.cleaned;
	by id;
	residual = PIAT_score - mean_score;
run;

/* data outliers; */
/* 	set fdap_plot; */
/* 	if residual > 20 or residual < -20 then output; */
/* run; */
/* proc sql; */
/* create table fdap.cleaned as */
/* select *  */
/* from fdap_plot */
/* where ID not in (select ID from outliers); */
/* quit; */
/* proc freq data = fdap.cleaned nlevels; */
/* 	table id; */
/* axis1 minor=none label=(angle = 90 rotate = 0 ' Standard PIAT Score') order=(-20 to 20 by 5); */
/* axis2 minor=none label=('Years since baseline') order=(0 to 5 by 1) offset=(3,3);	 */
*Profile Plot;
proc surveyselect data = fdap_plot
	out = fdap.random_sample
	seed = 1234
	sampsize = 50;
	cluster id;
proc surveyselect data = fdap_plot
	out = fdap.random_sample_2
	seed = 1323
	sampsize = 50;
	cluster id;

axis1 minor=none label=(angle = 90 rotate = 0 'PIAT Score') order=(50 to 150 by 10);
axis2 minor=none label=('Years since baseline') order=(0 to 5 by 1) offset=(3,3);
proc gplot data= fdap.random_sample;
	*by gender;
	plot PIAT_score*time = id /vaxis=axis1 haxis=axis2 nolegend;
*Profile Plot;
	symbol1 i=join r= 50 color = black;
	title 'Profile Plot of PIAT Scores over time';
	run;
axis1 minor=none label=(angle = 90 rotate = 0 'PIAT Score') order=(50 to 150 by 10);
axis2 minor=none label=('Years since baseline') order=(0 to 5 by 1) offset=(3,3);
proc gplot data= fdap.random_sample_2;
	*by gender;
	plot PIAT_score*time = id /vaxis=axis1 haxis=axis2 nolegend;
*Profile Plot;
	symbol1 i=join r= 50 color = black;
	title 'Profile Plot of PIAT Scores over time';
	run;
axis1 minor=none label=(angle = 90 rotate = 0 'PIAT Score') order=(-40 to 40 by 5);
axis2 minor=none label=('Years since baseline') order=(0 to 5 by 1) offset=(3,3);
*Profile Plot;
proc gplot data=fdap.random_sample;
	plot residual*time = id /vaxis=axis1 haxis=axis2 nolegend;
	symbol1 i=join  r = 50 color = black;
	title 'Emperical Within-Subject Residual Plot';
run;
axis1 minor=none label=(angle = 90 rotate = 0 'PIAT Score') order=(-40 to 40 by 5);
axis2 minor=none label=('Years since baseline') order=(0 to 5 by 1) offset=(3,3);
*Profile Plot;
proc gplot data=fdap.random_sample_2;
	plot residual*time = id /vaxis=axis1 haxis=axis2 nolegend;
	symbol1 i=join  r = 50 color = black;
	title 'Emperical Within-Subject Residual Plot';
run;
* Sex;
proc freq data = fdap.cleaned nlevels;
	table id;

*Profile Plot;
proc sort data = fdap.cleaned;
	by id;

goptions cback=white; /*background color is white*/
axis1 minor=none label=(angle = 90 rotate = 0 ' Standard PIAT Score') order=(50 to 150 by 10);
axis2 minor=none label=('Years since baseline') order=(0 to 5 by 1) offset=(3,3);	
proc gplot data= fdap.cleaned;
	*by sex;
	plot PIAT_score*time = id /vaxis=axis1 haxis=axis2 nolegend;
*Profile Plot;
	symbol1 i=join r= 3 color = black value = none;
	title 'Profile Plot of PIAT Scores over time';
	run;
data test;
set fdap.cleaned;
	by ID; 
	retain test;
	if first.ID then test + 1;
	if test <= 50 then output;
run;
proc sort data = test;
	by sex;
axis1 minor=none label=(angle = 90 rotate = 0 ' Standard PIAT Score') order=(50 to 150 by 10);
axis2 minor=none label=('Years since baseline') order=(0 to 5 by 1) offset=(3,3);	
proc gplot data= test;
	by sex;
	plot PIAT_score*time = id /vaxis=axis1 haxis=axis2 nolegend;
*Profile Plot;
	symbol1 i=join r= 50 color = black value = none;
	title 'Profile Plot of PIAT Scores over time';
	format sex sex.;
	run;
*Overall emperical;
axis1 minor=none label=(angle = 90 rotate = 0 ' Standard PIAT Score') order=(85 to 105 by 1);
axis2 minor=none label=('Years since baseline') order=(0 to 6 by 1) offset=(3,3);	
proc gplot data= fdap.cleaned;
	plot PIAT_score*time /vaxis=axis1 haxis=axis2;
*Profile Plot;
	symbol1 i=std2mjt r= 1 mode = include;
	title 'Overall Average PIAT Score +/- 2 SE';
	format sex sex.;
	run;
* Gender;
data fdap_gender;
	set fdap.cleaned;
if sex = 1 then time = time + 0.10;
run;
axis1 minor=none label=(angle = 90 rotate = 0 'PIAT Score') order=(85 to 105 by 1);
axis2 minor=none label=('Years since baseline') order=(0 to 6 by 1) offset=(3,3);	
proc gplot data= fdap_gender;
	plot PIAT_score*time = sex/vaxis=axis1 haxis=axis2;
*Profile Plot;
	symbol1 i=std2mjt r= 1 mode = include;
	title 'Average PIAT Score +/- 2 SE by Sex';
	format sex sex.;
	run;
* Born in US empirical;
proc freq data = fdap.cleaned;
	table parent_born_in_US;
data fdap_born_in_US;
	set fdap.cleaned;
if parent_born_in_US = 1 then time = time + 0.10;
run;
axis1 minor=none label=(angle = 90 rotate = 0 'PIAT Score') order=(85 to 105 by 1);
axis2 minor=none label=('Years since baseline') order=(0 to 6 by 1) offset=(3,3);	
proc gplot data= fdap_born_in_US;
	plot PIAT_score*time = parent_born_in_US/vaxis=axis1 haxis=axis2;
*Profile Plot;
	symbol1 i=std2mjt r= 1 mode = include;
	title 'Average PIAT Score +/- 2 SE by Parent Birthplace';
	format parent_born_in_US YN.;
	run;
* Age at baseline;
proc freq data = fdap.cleaned;
	table parent_born_in_US;
data fdap_age_at_baseline;
	set fdap.cleaned;
if age_at_baseline = 13 then time = time + 0.10;
if age_at_baseline = 14 then time = time + 0.20;
run;
axis1 minor=none label=(angle = 90 rotate = 0 'PIAT Score') order=(80 to 105 by 1);
axis2 minor=none label=('Years since baseline') order=(0 to 6 by 1) offset=(3,3);	
proc gplot data= fdap_age_at_baseline;
	plot PIAT_score*time = age_at_baseline/vaxis=axis1 haxis=axis2;
*Profile Plot;
	symbol1 i=std2mjt r= 1 mode = include;
	title 'Average PIAT Score +/- 2 SE by Age at Baseline';
	run;
* Baseline household income;
data fdap_gross_income;
	set fdap.cleaned;
if income_cat = 2 then time = time + 0.10;
if income_cat = 3 then time = time + 0.20;
if income_cat = 4 then time = time + 0.30;
run;
axis1 minor=none label=(angle = 90 rotate = 0 'PIAT Score') order=(80 to 125 by 5);
axis2 minor=none label=('Years since baseline') order=(0 to 6 by 1) offset=(3,3);	
proc gplot data= fdap_gross_income;
	plot PIAT_score*time = income_cat/vaxis=axis1 haxis=axis2;
*Profile Plot;
	symbol1 i=std2mjt r= 1 mode = include;
	title 'Average PIAT Score +/- 2 SE by Income Category';
	format income_cat income_cat.;
	run;
* Region;
data fdap_region;
	set fdap.cleaned;
if region = 2 then time = time + 0.10;
if region = 3 then time = time + 0.20;
if region = 4 then time = time + 0.30;
run;
axis1 minor=none label=(angle = 90 rotate = 0 'PIAT Score') order=(85 to 110 by 2);
axis2 minor=none label=('Years since baseline') order=(0 to 6 by 1) offset=(3,3);	
proc gplot data= fdap_region;
	plot PIAT_score*time = region/vaxis=axis1 haxis=axis2;
*Profile Plot;
	symbol1 i=std2mjt r= 1 mode = include;
	title 'Average PIAT Score +/- 2 SE by Baseline Region';
	format region region.;
	run;
* Ethnicity;
data fdap_ethnicity;
	set fdap.cleaned;
if race_ethnicity = 2 then time = time + 0.10;
if race_ethnicity = 3 then time = time + 0.20;
if race_ethnicity = 4 then time = time + 0.30;
run;
axis1 minor=none label=(angle = 90 rotate = 0 ' Standard PIAT Score') order=(80 to 120 by 4);
axis2 minor=none label=('Years since baseline') order=(0 to 6 by 1) offset=(3,3);	
proc gplot data= fdap_ethnicity;
	plot PIAT_score*time = race_ethnicity/vaxis=axis1 haxis=axis2;
*Profile Plot;
	symbol1 i=std2mjt r= 1 mode = include;
	title 'Average PIAT Score +/- 2 SE by Race/Ethnicity';
	format race_ethnicity ethnicity.;
	run;
*Reading;
data fdap_reading;
	set fdap.cleaned;
if English_primary_reading = 2 then time = time + 0.10;
axis1 minor=none label=(angle = 90 rotate = 0 'PIAT Score') order=(76 to 102 by 2);
axis2 minor=none label=('Years since baseline') order=(0 to 6 by 1) offset=(3,3);	
proc gplot data = fdap_reading;
     plot PIAT_score*time = English_primary_reading/vaxis=axis1 haxis=axis2;
*Profile Plot;
	symbol1 i=std2mjt r= 1 mode = include;
	title 'Average PIAT Score +/- 2 SE by Primary Reading Language';
	format English_primary_reading English.;
	run;
* Model Selection;

proc mixed data = fdap.cleaned method = reml;
	class id;
	model PIAT_score = time/s;
	random intercept /subject = id type = un;

proc mixed data = fdap.cleaned method = reml;
	class id;
	model PIAT_score = time time*time/s;
	random intercept /subject = id type = un;

proc mixed data = fdap.cleaned method = reml;
	class id;
	model PIAT_score = time time*time time*time*time/s;
	random intercept /subject = id type = un;

proc mixed data = fdap.cleaned method = reml;
	class id;
	model PIAT_score = time time*time time*time*time time*time*time*time/s;
	random intercept /subject = id type = un;

* Covariate addition;
proc mixed data = fdap.cleaned method = reml;
	class id sex;
	model PIAT_score = time time*time time*time*time sex sex*time/s;
	random intercept /subject = id type = un;
	format sex sex.; 
proc mixed data = fdap.cleaned method = reml;
	class id sex race_ethnicity;
	model PIAT_score = time time*time time*time*time race_ethnicity /s;
	random intercept /subject = id type = un;
	format sex sex. race_ethnicity ethnicity.; 

proc mixed data = fdap.cleaned method = reml;
	class id sex race_ethnicity income_cat;
	model PIAT_score = time time*time time*time*time race_ethnicity income_cat sex  /s;
	random intercept /subject = id type = un;
	format sex sex. race_ethnicity ethnicity. income_cat income_cat; 

proc mixed data = fdap.cleaned method = reml;
	class id sex race_ethnicity income_cat;
	model PIAT_score = time time*time time*time*time race_ethnicity income_cat  /s;
	random intercept /subject = id type = un;
	format sex sex. race_ethnicity ethnicity. income_cat income_cat.; 

proc mixed data = fdap.cleaned method = reml;
	class id sex race_ethnicity income_cat;
	model PIAT_score = time time*time time*time*time race_ethnicity income_cat /s;
	random intercept /subject = id type = un;
	format sex sex. race_ethnicity ethnicity. income_cat income_cat.; 

* Colinearity test;
data multico;
	set fdap.cleaned;
	if sex = 1 then gen_m = 1; else gen_m = 0;
	if income_cat = 2 then income_2 =1; else income_2 = 0;
	if income_cat = 3 then income_3 = 1; else income_3 = 0;
	if income_cat = 4 then income_4 = 1; else income_4 = 0;
	if race_ethnicity = 1 then black = 1; else black = 0;
	if race_ethnicity = 2 then hispanic = 1; else hispanic = 0;
	if race_ethnicity = 3 then mixed = 1; else mixed = 0;
run;
proc reg data = multico;
	var PIAT_score black hispanic mixed income_2 income_3 income_4;
	model PIAT_score = black hispanic mixed income_2 income_3 income_4 /vif;

proc mixed data = fdap.cleaned method = reml;
	class id sex race_ethnicity income_cat region;
	model PIAT_score = time time*time time*time*time race_ethnicity income_cat /s;
	random intercept region/subject = id type = un;
	format sex sex. race_ethnicity ethnicity. income_cat income_cat. region 
	region.; 
proc mixed data = fdap.cleaned method = reml;
	class id sex race_ethnicity income_cat region;
	model PIAT_score = time time*time time*time*time race_ethnicity income_cat region /s;
	random intercept  /subject = id type = un;
	format sex sex. race_ethnicity ethnicity. income_cat income_cat. region 
	region.; 
proc mixed data = fdap.cleaned method = reml;
	class id sex race_ethnicity income_cat region parent_born_in_us;
	model PIAT_score = time time*time time*time*time race_ethnicity income_cat region parent_born_in_us/s;
	random intercept  /subject = id type = un;
	format sex sex. race_ethnicity ethnicity. income_cat income_cat. region 
	region. parent_born_in_us YN.; 
proc mixed data = fdap.cleaned method = reml;
	class id sex race_ethnicity income_cat region English_primary_reading;
	model PIAT_score = time time*time time*time*time race_ethnicity income_cat region English_primary_reading sex age_at_baseline/s;
	random intercept  /subject = id type = un;
	format sex sex. race_ethnicity ethnicity. income_cat income_cat. region 
	region. English_primary_reading English. ; 

proc mixed data = fdap.cleaned method = reml;
	class id sex race_ethnicity income_cat region English_primary_reading;
	model PIAT_score = time time*time time*time*time region race_ethnicity income_cat English_primary_reading/s;
	random intercept  /subject = id type = un;
	format sex sex. race_ethnicity ethnicity. income_cat income_cat. region 
	region. English_primary_reading English.;
	
proc mixed data = fdap.cleaned method = reml;
	class id sex race_ethnicity income_cat region English_primary_reading;
	model PIAT_score = time time*time time*time*time region race_ethnicity income_cat English_primary_reading 
	English_primary_reading*time /s;
	random intercept  /subject = id type = un;
	format sex sex. race_ethnicity ethnicity. income_cat income_cat. region 
	region. English_primary_reading English. ; 

*Final Model;
proc mixed data = fdap.cleaned method = ml;
	class id sex race_ethnicity income_cat region English_primary_reading;
	model PIAT_score = time time*time time*time*time sex region race_ethnicity income_cat English_primary_reading 
 income_cat*time race_ethnicity*time/s;
	random intercept  /subject = id type = un;
	format sex sex. race_ethnicity ethnicity. income_cat income_cat. region 
	region. English_primary_reading English. ; 
* Covariance Model Selection;
data fdap.cleaned_final;
	set fdap.cleaned;
ctime = time;
run;

%macro model(i,title,rr,what,type);
title "&title";
proc mixed method=reml covtest noclprint data= fdap.cleaned_final;
class id ctime race_ethnicity income_cat region English_primary_reading;
model PIAT_score = time sex time*time time*time*time region race_ethnicity income_cat English_primary_reading 
 income_cat*time race_ethnicity*time /s;
&rr &what / type=&type subject=id;
ods output covparms=c&i fitstatistics=f&i dimensions=d&i;
format sex sex. race_ethnicity ethnicity. income_cat income_cat. region 
	region. English_primary_reading English. ; 
run;

data new&i (keep=descr value type model);
format descr $30.;
set c&i(rename=(covparm=descr estimate=value)) f&i d&i;
if (index(descr,'Res')>0 or index(descr, 'm')>0) and index(descr,'CC')=0 and index(descr,'mm')=0;
type="&title";
model=&i;
run;

proc sort data=new&i; by descr;run;
%mend;

%model(1,RI, random, intercept,un);
%model(2,RIAS, random, intercept time,un);
%model(10,UN,repeated, ctime,UN);
%model(3,RIASAQ, random, intercept time time*time, un);
%model(4,CSH,repeated, ctime,CSH);
%model(5,IND,repeated, ctime,SIMPLE);
%model(6,ARH(1),repeated, ctime,ARH(1));
%model(7,AR(1),repeated, ctime,AR(1));
%model(8,ARMA(1,1),repeated, ctime,ARMA(1,1));
%model(9,ANTE(1),repeated, ctime,ANTE(1));
%model(11,FA(1),repeated, ctime, FA(1));

%macro nprme;
%do i = 1 %to 11;
 new&i
 %end;
 %mend nprme;

 data newtotal;
 format type $10.;
 set %nprme;
 by type;
 if first.type then count=1;
 else count+1;
run;
proc print data=newtotal;run;
proc freq data=newtotal;tables count;run;
proc sort data=newtotal;by model count;run;
proc transpose data=newtotal out=wide prefix=value;
by model type;
var value;
id count;
run;
data temp;
set wide;
parms=sum (of value4-value6);
label parms='# Parameters';
run;
proc sort data=temp;by model;run;
proc print data=temp label;
title 'Table';
var model type value6 value1 value2 value3 value7;
format value6 2.;
label
type = "Cov Model"
value1='REML: -2 Res Log Likelihood'
value2='AIC (smaller is better)'
value3='BIC (smaller is better)'
value4='Columns in X'
value5='Columns in Z'
value6='Covariance Parameters'
value7='Residual';
run;
* LRT;
data LRT_table;
	set temp;
if model ~= 10 then do;
	 Chisq = value1 - 34391;
	 df = 21 - value6;
	 p_value = 1-probchi(Chisq,df);
 end;
proc print data=LRT_table label noobs;
title 'Table';
var  Chisq p_value;
label type = "Cov Model"
Chisq ='Test Statistic'
p_value ='p value';
format p_value 11.10;
run;
proc mixed method=reml covtest noclprint data= fdap.cleaned_final;
class sex ctime id race_ethnicity income_cat region English_primary_reading;
model PIAT_score = time time*time time*time*time sex region race_ethnicity income_cat English_primary_reading 
 income_cat*time race_ethnicity*time/s;
repeated ctime / subject = id type = UN r = 2;
format sex Sex. race_ethnicity ethnicity. income_cat income_cat. region 
	region. English_primary_reading English. ;
run;
%model(10,UN,repeated, ctime,UN);

* Colinearity test;
data multico;
	set fdap.cleaned;
	if sex = 1 then gen_m = 1; else gen_m = 0;
	if income_cat = 2 then income_2 =1; else income_2 = 0;
	if income_cat = 3 then income_3 = 1; else income_3 = 0;
	if income_cat = 4 then income_4 = 1; else income_4 = 0;
	if race_ethnicity = 1 then black = 1; else black = 0;
	if race_ethnicity = 2 then hispanic = 1; else hispanic = 0;
	if race_ethnicity = 3 then mixed = 1; else mixed = 0;
	if region = 2 then region_2 = 1; else region_2 = 0;
	if region = 3 then region_3 = 1; else region_3 = 0;
	if region = 4 then region_4 = 1; else region_4 = 0;
	if English_primary_reading = 2 then no = 1; else no = 0;
run;
proc reg data = multico;
	var gen_m PIAT_score black hispanic mixed income_2 income_3 income_4 region_2 region_3 region_4;
	model PIAT_score = gen_m black hispanic mixed income_2 income_3 income_4 region_2 region_3 region_4 no /vif;
