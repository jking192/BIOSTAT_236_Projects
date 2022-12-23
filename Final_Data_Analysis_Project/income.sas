options nocenter validvarname=any;

*---Read in space-delimited ascii file;
libname fdap "/home/u59566911/sasuser.v94/BIOSTAT 236/Data";
data fdap.income;


infile '/home/u59566911/sasuser.v94/BIOSTAT 236/Data/income.dat' lrecl=31 missover DSD DLM=' ' print;
input
  R0000100
  R02
  R03
  R04
  R1204500
; 
 RENAME
  R0000100 = id
  R1204500 = gross_income;
drop 
 R02
  R03
  R04;
run;
---------------------------------------------------------------------*
 *  Crosswalk for Reference number & Question name                     *
 *---------------------------------------------------------------------*
 * Uncomment and edit this RENAME statement to rename variables
 * for ease of use.  You may need to use  name literal strings
 * e.g.  'variable-name'n   to create valid SAS variable names, or 
 * alter variables similarly named across years.
 * This command does not guarantee uniqueness

 * See SAS documentation for use of name literals and use of the
 * VALIDVARNAME=ANY option.     
 *---------------------------------------------------------------------*/

	

proc means data=new_data n mean min max;
run;


/*---------------------------------------------------------------------*
 *  FORMATTED TABULATIONS                                              *
 *---------------------------------------------------------------------*
 * You can uncomment and edit the PROC FORMAT and PROC FREQ statements 
 * provided below to obtain formatted tabulations. The tabulations 
 * should reflect codebook values.
 * 
 * Please edit the formats below reflect any renaming of the variables
 * you may have done in the first data step. 
 *---------------------------------------------------------------------*/


proc format; 
value vx0f
  0='0'
  1-999='1 TO 999'
  1000-1999='1000 TO 1999'
  2000-2999='2000 TO 2999'
  3000-3999='3000 TO 3999'
  4000-4999='4000 TO 4999'
  5000-5999='5000 TO 5999'
  6000-6999='6000 TO 6999'
  7000-7999='7000 TO 7999'
  8000-8999='8000 TO 8999'
  9000-9999='9000 TO 9999'
;
value vx1f
  1='Male'
  2='Female'
  0='No Information'
;
value vx2f
  1='1: January'
  2='2: February'
  3='3: March'
  4='4: April'
  5='5: May'
  6='6: June'
  7='7: July'
  8='8: August'
  9='9: September'
  10='10: October'
  11='11: November'
  12='12: December'
;
proc format;
value income_cat
  1= 'Less than $10,000'
  2 = '$10,000 to $49,999'
 3 ='$50,000 to $99,999'
  4 = '$100,000 or more'
;
value vx5f
  1='Cross-sectional'
  0='Oversample'
;
value vx6f
  1='Black'
  2='Hispanic'
  3='Mixed Race (Non-Hispanic)'
  4='Non-Black / Non-Hispanic'
;
*/

/* 
 *--- Tabulations using reference number variables;
proc freq data=new_data;
tables _ALL_ /MISSING;
  format R0000100 vx0f.;
  format R0536300 vx1f.;
  format R0536401 vx2f.;
  format R1204500 vx4f.;
  format R1235800 vx5f.;
  format R1482600 vx6f.;
run;
*/

/*
*--- Tabulations using default named variables;
proc freq data=new_data;
tables _ALL_ /MISSING;
  format 'PUBID_1997'n vx0f.;
  format 'KEY!SEX_1997'n vx1f.;
  format 'KEY!BDATE_M_1997'n vx2f.;
  format 'CV_INCOME_GROSS_YR_1997'n vx4f.;
  format 'CV_SAMPLE_TYPE_1997'n vx5f.;
  format 'KEY!RACE_ETHNICITY_1997'n vx6f.;
run;
*/