libname dap "/home/u59566911/sasuser.v94/BIOSTAT 236/Data";

FILENAME REFFILE '/home/u59566911/sasuser.v94/BIOSTAT 236/Data/GCC data set.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=dap.gcc;
	GETNAMES=YES;
RUN;

proc sort data = dap.gcc;
	by id time;
run;
PROC CONTENTS DATA=dap.gcc; RUN;
proc print data = dap.gcc;
data dap.gcc_binned;
	set dap.gcc;
	if time = 0 then adjusted_time = 0; 
	do i = 0.5 to 4 by 0.5;
		if time < i +.255 AND time > i -.255 then adjusted_time = i;
	end;
run;
data gcc_binned_updated;
	set dap.gcc_binned;
	by id adjusted_time;
	if lag1(adjusted_time) = adjusted_time then adjusted_time = adjusted_time+0.5;
	if lag1(adjusted_time) = adjusted_time then adjusted_time = adjusted_time+0.5;
	if lag1(adjusted_time) = adjusted_time then adjusted_time = adjusted_time+0.5;
	if lag1(adjusted_time) = adjusted_time then adjusted_time = adjusted_time+0.5;
	if lag1(adjusted_time) = adjusted_time then adjusted_time = adjusted_time+0.5;
	if adjusted_time = 4.5 then delete;
 run;  
/* data gcc_binned_updated; */
/* 	set dap.gcc_binned; */
/* 	by id adjusted_time; */
/* 	if first.adjusted_time then output; */
****SET GRAPH OPTIONS;
goptions cback=white; /*background color is white*/
data gcc_age;
	set dap.gcc;
	if base_age <= 65 then age_bin = 1;
	else age_bin = 2;
run;

proc format;
	value bin
	1 = "<= 65 years"
	2 = "> 65 years";
proc sort data = gcc_age;
	by id;
run;


axis1 minor=none label=(angle = 90 rotate = 0 'GCC thickness (microns)') order=(52 to 129 by 7);
axis2 minor=none label=('Time (years)') order=(0 to 4.5 by 0.5) offset=(3,3);
proc gplot data=gcc_age;
	plot gcc*time = id /vaxis=axis1 haxis=axis2 nolegend;
*Profile Plot;
	symbol1 i=join r= 47 color = darkblue;
	symbol2 i = join r = 60 color = red;
	title 'Profile Plot of GCC thickness over Time';
	format age_bin bin.;
	run;
	
axis1 minor=none label=(angle = 90 rotate = 0 'GCC thickness (microns)') order=(52 to 129 by 7);
axis2 minor=none label=('Time (years)') order=(0 to 4.5 by 0.5) offset=(3,3);
proc gplot data=gcc_age;
	plot gcc*time = age_bin /vaxis=axis1 haxis=axis2;
*Profile Plot;
	symbol1 i=join r = 2;
	title 'Profile Plot of GCC thickness over Time';
	format age_bin bin.;
	run;	

axis1 minor=none label=(angle = 90 rotate = 0 'GCC thickness (microns)') order=(52 to 94 by 7);
axis2 minor=none label=('Time (years)') order=(0 to 4 by 1) offset=(3,3);
*Profile Plot;
proc gplot data=dap.gcc;
	plot gcc*time = id /vaxis=axis1 haxis=axis2 nolegend;
*Profile Plot;
	symbol1 i=join r= 107 color = black;
	title 'Profile Plot of GCC thickness over Time';
	run;
axis1 minor=none label=(angle = 90 rotate = 0 'GCC thickness (microns)') order=(52 to 94 by 7);
axis2 minor=none label=('Time (years)') order=(0 to 4 by 1) offset=(3,3);
*Profile Plot;
proc gplot data=gcc_binned_updated;
	plot gcc*adjusted_time = id /vaxis=axis1 haxis=axis2 nolegend;
*Profile Plot;
	symbol1 i=join r= 107 color = black;
	title 'Profile Plot of GCC thickness over rounded Time';
	run;	
* Correlation Analysis;
proc sort data = dap.gcc_binned;
	by id adjusted_time;
sort data = gcc_binned_updated;
	by id time;
proc print data = gcc_binned_updated;
proc transpose  data= gcc_binned_updated out=gccwide_1 (drop= _NAME_) prefix=year;
	by id;
	id adjusted_time;
	var gcc;
	copy base_age;
	run;
proc sort data = gccwide_1;
	by ID;
data gccwide;
	set gccwide_1;
	by ID;
	if first.id then output;
	
proc contents data = gccwide;
data gcc_age_wide;
	set gccwide;
	if base_age <=65 then age_bin = 1;
	else age_bin = 2;
run;

proc freq data = gcc_age_wide;
	table age_bin;
ods path work.template(update) sashelp.tmplmst;
	proc template;
   edit base.corr.stackedmatrix;
      column (RowName RowLabel) (Matrix) * (Matrix2) /** (Matrix3)*/ * (Matrix4);
    end;
run;
data dap.gccwide_final;
	retain id year0 'year0.5'n  year1 'year1.5'n  year2 'year2.5'n  year3 'year3.5'n year4;
	set gccwide;
	rename year0 = baseline;
	rename 'year0.5'n = month6;
	rename year1 = month12;
	rename 'year1.5'n = month18;
	rename year2 = month24;
	rename 'year2.5'n = month30;
	rename year3 = month36;
	rename 'year3.5'n = month42;
	rename year4 = month48;
proc corr data= dap.gccwide_final nosimple; 
	var baseline month6--month48;
	ods select pearsoncorr; 
	*only outputs the correlation table;
	ods output pearsoncorr=pearsoncorr; 
	*creates an output dataset for the correlation table;
	title 'Correlation Matrix for Macular Data';
%include "/home/u59566911/sasuser.v94/BIOSTAT 236/Data/boxanno.sas";
%include "/home/u59566911/sasuser.v94/BIOSTAT 236/Data/gdispla.sas";
%include "/home/u59566911/sasuser.v94/BIOSTAT 236/Data/gensym.sas";
%include "/home/u59566911/sasuser.v94/BIOSTAT 236/Data/scatmat.sas";
options device = win;
proc print data = gccwide;

%scatmat(data=dap.gccwide_final, var= baseline month6--month48, anno=BOX);
proc sort data = gcc_binned_updated;
	by gcc;

axis1 minor=none label=(angle = 90 rotate = 0 'GCC thickness (microns)') order=62 to 90 by 4;
axis2 minor=none label=('Time (years)') order=(0 to 4 by 0.5) offset=(3,3);
proc gplot data= gcc_binned_updated;
	plot gcc*adjusted_time/ vaxis=axis1 haxis=axis2;
	symbol1 i=std2mjt v=none color=black r=1 mode = include;
		*std=standard deviations;
		*2=#of SD's; 
		*J=provide line throught means;
		*t=add tops and bottoms to each line;
	title 'Average GCC thickness (microns) +/- 2 SE';
	run;
	
proc means data = dap.gcc NWAY;
	class id;
	var gcc;
	output OUT = means  (drop = _TYPE_ _FREQ_) mean = mean_thickness;

proc sort data = dap.gcc;
	by id;

data gcc_plot;
	merge dap.gcc means;
	by id;
	residual = gcc - mean_thickness;
run;
axis1 minor=none label=(angle = 90 rotate = 0 'Emperical Within-Subject Residual') order=(-15 to 15 by 5);
axis2 minor=none label=('Time (years)') order=(0 to 4.5 by 0.5) offset=(3,3);
*Profile Plot;
proc gplot data=gcc_plot;
	plot residual*time = id /vaxis=axis1 haxis=axis2 nolegend;
	symbol1 i=join  r = 107 color = black;
	title 'Emperical Within-Subject Residual Plot';
run;

*Time Trend Test;
proc mixed data = dap.gcc method = reml covtest;
	class id;
	model gcc = time/s;
	random intercept/ type = un sub = id;
proc mixed data = dap.gcc method = reml;
	class id;
	model gcc = time time*time/s;
	random intercept/ type = un sub = id;
proc mixed data = dap.gcc method = reml;
	class id;
	model gcc = time time*time time*time*time/s;
	random intercept/ type = un sub = id;
	contrast 'test' time*time*time 1;
proc mixed data = dap.gcc method = ml;
	class id;
	model gcc = time time*time time*time*time time*time*time*time;
	random intercept/ type = un sub = id;
	
data gcc_bent_line;
	set dap.gcc;
	month18 = max(0, time -1.5);
run;
proc mixed data = gcc_bent_line method = reml covtest;
	class id;
	model gcc = time time*time month18;
	random intercept time/ type = un sub = id;
	ods output fitstatistics = test;
proc contents data = test;
data test;
	set test;
format value 8.2;
run;
* Covariance Matrix Test;
%macro model(i,title,rr,what,type);
title "&title";
proc mixed method=reml covtest noclprint data= dap.gcc;
class id;
model gcc= time time*time / s;
&rr &what / type=&type subject=id;
ods output covparms=c&i fitstatistics=f&i dimensions=d&i;
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
%model(3, RIASAQ, random, intercept time time*time,un);
%model(4, Spatial-POW, repeated, , SP(POW)(time));
%macro nprme;
%do i = 1 %to 4;
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
* Selected;
proc mixed data= dap.gcc method = reml covtest;
	class id;
	model gcc = time time*time  /s;
	estimate 'test' time 4 time*time 16;
	random intercept time time*time /subject = id type = un;

data gcc_1;
	set dap.gcc;
	observation_id = _N_;
run;
proc mixed data= gcc_1 method = reml covtest;
	class id;
	model gcc = time time*time /s;
	repeated /subject = id type = SP(POW)(time);
*Part D;
proc sort data = gcc_binned_updated;
	by id;
	
run;
* Age Covariate;
proc univariate data = dap.gcc;
	var base_age gcc;
	histogram base_age gcc;

proc mixed data = dap.gcc method = ml;
	class id;
	model gcc = time;
	random intercept time / subject = id type = un;
	proc mixed data = dap.gcc method = ml;
	class id;
	model gcc = base_age time;
	random intercept time / subject = id type = un;
proc mixed data = dap.gcc method = ml;
	class id;
	model gcc = base_age time base_age*time;
	contrast "Age effect" base_age 1, base_age*time 1;
	random intercept time / subject = id type = un;
