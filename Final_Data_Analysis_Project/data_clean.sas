options nocenter validvarname=any;

*---Read in space-delimited ascii file;

libname fdap "/home/u59566911/sasuser.v94/BIOSTAT 236/Data";
data fdap.new_data;


infile '/home/u59566911/sasuser.v94/BIOSTAT 236/Data/default.dat' lrecl=63 missover DSD DLM=' ' print;
input
  R0000100
  R0536300
  R0536401
  R0536402
  R0551500
  R1194100
  R1200400
  R1235800
  R1318200
  R1482600
  R3961900
  R3989200
  R5473700
  R5821400
  R7237400
  R9701700
  S1552700
;
array nvarlist _numeric_;


*---Recode missing values to SAS custom system missing. See SAS
      documentation for use of MISSING option in procedures, e.g. PROC FREQ;

  label R0000100 = "ID";
  label R0536300 = "Sex";
  label R0536401 = "KEY!BDATE M/Y (SYMBOL) 1997";
  label R0536402 = "KEY!BDATE M/Y (SYMBOL) 1997";
  label R0551500 = "Parent born in US";
  label R1194100 = "Baseline Age";
  label R1200400 = "Region";
  label R1235800 = "CV_SAMPLE_TYPE 1997";
  label R1318200 = "CV_PIAT_STANDARD_UPD 1997";
  label R1482600 = "Race/ethnicity";
  label R3961900 = "CV_PIAT_STANDARD_UPD 1999";
  label R3989200 = "CV_PIAT_STANDARD_UPD 1998";
  label R5473700 = "CV_PIAT_STANDARD_SCORE 2000";
  label R5821400 = "R BORN IN U.S OR TERRITORIES 2001";
  label R7237400 = "CV_PIAT_STANDARD_SCORE 2001";
  label R9701700 = "Primary Reading Language is English";
  label S1552700 = "CV_PIAT_STANDARD_SCORE 2002";

/*---------------------------------------------------------------------*
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
  /* *start* */

 RENAME
  R0000100 = id
  R0536300 = Sex
  R0551500 = parent_born_in_US
  R1194100 = age_at_baseline
  R1200400 = region
  R1318200 = PIAT_0
  R1482600 = Race_Ethnicity
  R3961900 = PIAT_2
  R3989200 = PIAT_1
  R5473700  = PIAT_3
  R5821400 = born_in_US
  R7237400 = PIAT_4
  R9701700 = English_primary_reading
  S1552700 = PIAT_5
;

keep id
  Sex
   parent_born_in_US
   parent_speak_other_lang
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
   PIAT_5;
run;

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
value ID
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
value Sex
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
value YN
  1='Yes'
  0='No'
;
value baseline_age
  0-11='0 TO 11: LESS THAN 12'
  12='12'
  13='13'
  14='14'
  15='15'
  16='16'
  17='17'
  18='18'
  19-999='19 TO 999: GREATER THAN 18'
;
value region
  1='Northeast (CT, ME, MA, NH, NJ, NY, PA, RI, VT)'
  2='North Central (IL, IN, IA, KS, MI, MN, MO, NE, OH, ND, SD, WI)'
  3='South (AL, AR, DE, DC, FL, GA, KY, LA, MD, MS, NC, OK, SC, TN , TX, VA, WV)'
  4='West (AK, AZ, CA, CO, HI, ID, MT, NV, NM, OR, UT, WA, WY)'
;
value vx7f
  1='Cross-sectional'
  0='Oversample'
;
value vx8f
  50-59='50 TO 59'
  60-69='60 TO 69'
  70-79='70 TO 79'
  80-89='80 TO 89'
  90-99='90 TO 99'
  100-109='100 TO 109'
  110-119='110 TO 119'
  120-129='120 TO 129'
  130-139='130 TO 139'
  140-149='140 TO 149'
;
value ethnicity
  1='Black'
  2='Hispanic'
  3='Mixed Race (Non-Hispanic)'
  4='Non-Black / Non-Hispanic'
;
value vx10f
  50-59='50 TO 59'
  60-69='60 TO 69'
  70-79='70 TO 79'
  80-89='80 TO 89'
  90-99='90 TO 99'
  100-109='100 TO 109'
  110-119='110 TO 119'
  120-129='120 TO 129'
  130-139='130 TO 139'
  140-149='140 TO 149'
;
value vx11f
  50-59='50 TO 59'
  60-69='60 TO 69'
  70-79='70 TO 79'
  80-89='80 TO 89'
  90-99='90 TO 99'
  100-109='100 TO 109'
  110-119='110 TO 119'
  120-129='120 TO 129'
  130-139='130 TO 139'
  140-149='140 TO 149'
;
value vx12f
  50-59='50 TO 59'
  60-69='60 TO 69'
  70-79='70 TO 79'
  80-89='80 TO 89'
  90-99='90 TO 99'
  100-109='100 TO 109'
  110-119='110 TO 119'
  120-129='120 TO 129'
  130-139='130 TO 139'
  140-149='140 TO 149'
;
value vx13f
  1='YES'
  0='NO'
;
value x
  50-59='50 TO 59'
  60-69='60 TO 69'
  70-79='70 TO 79'
  80-89='80 TO 89'
  90-99='90 TO 99'
  100-109='100 TO 109'
  110-119='110 TO 119'
  120-129='120 TO 129'
  130-139='130 TO 139'
  140-149='140 TO 149'
;
value English
  1='YES'
  2='NO'
;
value vx16f
  50-59='50 TO 59'
  60-69='60 TO 69'
  70-79='70 TO 79'
  80-89='80 TO 89'
  90-99='90 TO 99'
  100-109='100 TO 109'
  110-119='110 TO 119'
  120-129='120 TO 129'
  130-139='130 TO 139'
  140-149='140 TO 149'
;
*/

/* 
 *--- Tabulations using reference number variables;
proc freq data=new_data;
tables _ALL_ /MISSING;
  format R0000100 vx0f.;
  format R0536300 vx1f.;
  format R0536401 vx2f.;
  format R0551500 vx4f.;
  format R1194100 vx5f.;
  format R1200400 vx6f.;
  format R1235800 vx7f.;
  format R1318200 vx8f.;
  format R1482600 vx9f.;
  format R3961900 vx10f.;
  format R3989200 vx11f.;
  format R5473700 vx12f.;
  format R5821400 vx13f.;
  format R7237400 vx14f.;
  format R9701700 vx15f.;
  format S1552700 vx16f.;
run;
*/

/*
*--- Tabulations using default named variables;
proc freq data=new_data;
tables _ALL_ /MISSING;
  format 'PUBID_1997'n vx0f.;
  format 'KEY!SEX_1997'n vx1f.;
  format 'KEY!BDATE_M_1997'n vx2f.;
  format 'P2-001_1997'n vx4f.;
  format 'CV_AGE_INT_DATE_1997'n vx5f.;
  format 'CV_CENSUS_REGION_AGE_12_1997'n vx6f.;
  format 'CV_SAMPLE_TYPE_1997'n vx7f.;
  format 'CV_PIAT_STANDARD_UPD_1997'n vx8f.;
  format 'KEY!RACE_ETHNICITY_1997'n vx9f.;
  format 'CV_PIAT_STANDARD_UPD_1999'n vx10f.;
  format 'CV_PIAT_STANDARD_UPD_1998'n vx11f.;
  format 'CV_PIAT_STANDARD_SCORE_2000'n vx12f.;
  format 'YHHI-55701_2001'n vx13f.;
  format 'CV_PIAT_STANDARD_SCORE_2001'n vx14f.;
  format 'ASVAB_ENG_READ_1999'n vx15f.;
  format 'CV_PIAT_STANDARD_SCORE_2002'n vx16f.;
run;
*/