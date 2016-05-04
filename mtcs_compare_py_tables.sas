*clear the log window and the output window;
DM LOG 'clear;' CONTINUE; DM OUT 'clear;' CONTINUE; 
/**********************************************************************************************************************
* Author: Alex Keil
* Program: mtcs_compare_py_tables.sas
* Date: Tuesday, September 16, 2014 at 4:44:03 PM
* Project: Anaconda copper smelter, arsenic exposures
* Tasks: compare person time tables from my programming to those from the programs nicely provided by Jay Lubin
* Data in: Z:/EpiProjects/MT_copper_smelters/Archive/FromLubin\Derived\AsExpRateData.dta
*          mtcs.mtcs_an21
* Data out:
* Description: 
* Keywords:
* Released under the GNU General Public License: http://www.gnu.org/copyleft/gpl.html
**********************************************************************************************************************/
OPTIONS MERGENOBY = warn NODATE NONUMBER LINESIZE = 120  PAGESIZE=80 SKIP = 2 FORMDLIM = '-' MPRINT NOCENTER;
OPTIONS FORMCHAR = "|----|+|---+=|-/\<>*";
%LET PROGNAME = mtcs_compare_py_tables.sas;
TITLE;
FOOTNOTE "&progname run at &systime on &sysdate";

LIBNAME mtcs "Z:/EpiProjects/MT_copper_smelters/data";
PROC IMPORT OUT= WORK.a 
            DATAFILE= "Z:/EpiProjects/MT_copper_smelters/Archive/FromLubin\Derived\Tabled_data_matchsas.dta" 
            DBMS=STATA REPLACE;


DATA b;
 LENGTH usborn /*afecat*/ yearcat agecat cumdosecat meandosecat tslecat py atwork 8;
 SET mtcs.mtcs_an21;
 FORMAT _NUMERIC_ ;
RUN;

DATA an_ind;
 SET mtcs.mtcs_an04;
RUN;

DATA a;
 LENGTH usborn /*afeg*/ yrg ageg ds01g as_rg tseg pyr afeg 8 ;
 SET a;

PROC SORT DATA = b; BY usborn /*afecat*/ yearcat agecat cumdosecat meandosecat tslecat;
PROC SORT DATA = a; BY usborn /*afeg*/ yrg ageg ds01g as_rg tseg afeg;RUN;


PROC MEANS DATA = a SUM;
 VAR respca PYR;
PROC MEANS DATA = b SUM;
 VAR d_respcancer py;
RUN;

*number of deaths, rate by dose category;
DATA a;
 SET a;
 cumdosecat = ds01g;
 cumdose = ds01;
 meandose=as_r;
 meandosecat=as_rg;
 d_allcause = all;
 d_respcancer = respca;
 r_allcause = all/pyr;
 r_respcancer = respca/pyr;


PROC MEANS DATA = a NOPRINT;
 VAR respca erespca ;
 OUTPUT OUT=smsL SUM= mn_dr  mn_er;

DATA sms2 (DROP=_:);
 SET smsL;
 smrr = mn_dr/mn_er;
RUN;
PROC PRINT DATA = sms2;
 TITLE "Raw SMR - data from Lubin's epicure program";
RUN;

PROC MEANS DATA = an_ind NOPRINT;
 VAR d_respcancer e_ltas_respcancer e_epicure_respcancer d_cd e_ltas_cd e_epicure_cd;
 OUTPUT OUT=sms0 SUM= mn_dr mn_ler mn_eer mn_dc mn_lec mn_eec;
PROC MEANS DATA = b NOPRINT;
 VAR d_respcancer e_respcancer d_cd e_cd;
 OUTPUT OUT=sms SUM= mn_dr mn_er mn_dc mn_ec;

DATA sms3 (DROP=_:);
LENGTH set $12;
 SET sms sms0 (in=inc);
 IF inc THEN set = "Individual"; ELSE set= "Grouped";
 smrresp = mn_dr/mn_er;
 smerresp = mn_dr/mn_eer;
 smlrresp = mn_dr/mn_ler;
 smrcd = mn_dc/mn_ec;
 smercd = mn_dc/mn_eec;
 smlrcd = mn_dc/mn_lec;
RUN;
PROC PRINT DATA = sms3;
 TITLE "Raw SMR - data derived in SAS using orginal records";
RUN;


PROC MEANS DATA = b SUM;
 TITLE "respiratory deaths by cumulative dose groups";
 TITLE2 "my data";
 CLASS cumdosecat;
 VAR  d_respcancer ;
PROC MEANS DATA = a SUM;
 TITLE2 "Lubin's data";
 CLASS ds01g;
 VAR  d_respcancer;
RUN;

PROC SORT DATA = an_ind OUT=cumsort(KEEP=smid d_respcancer ageout );
 BY DESCENDING d_respcancer ds01;

PROC PRINT DATA = cumsort (OBS=10);
 TITLE2 "checking the individual data - lubin's analysis says no death should occur in unexposed, hand checking original data reveals this output is accurate";
 TITLE3 "icd = 162.1 (lung cancer) - conclude Lubin had something wrong";
RUN;

PROC MEANS DATA = b SUM;
 TITLE "respiratory deaths by average dose group";
 TITLE2 "My data";
 CLASS meandosecat;
 VAR d_respcancer;
PROC MEANS DATA = a SUM;
 TITLE2 "Lubin's data";
 CLASS as_rg;
 VAR d_respcancer;
RUN;;

PROC MEANS DATA = b MEAN MIN MAX;
 TITLE "dose distribution by cumulative dose groups";
 TITLE2 "My data";
 CLASS cumdosecat;
 VAR cumdose;
 FORMAT cumdosecat;
PROC MEANS DATA = a MEAN MIN MAX;
 TITLE2 "Lubin's data";
 CLASS ds01g;
 VAR ds01;
RUN;;

PROC MEANS DATA = b MEAN MIN MAX;
 TITLE "Average dose by average dose group";
 TITLE2 "My data";
 CLASS meandosecat;
 VAR meandose;
PROC MEANS DATA = a MEAN MIN MAX;
 TITLE2 "Lubin's data";
 CLASS as_rg;
 VAR as_r;
RUN;;

*compare person time distribution;
PROC MEANS DATA = a SUM;
 TITLE "Person time by age group, Lubin's data";
 CLASS ageg;
 VAR PYR;
RUN;

PROC MEANS DATA = b SUM;
 TITLE "Person time by age group, my data";
 CLASS agecat;
 VAR PY;
RUN;

PROC MEANS DATA = a SUM;
 TITLE "Person time by calendar time group, Lubin's data";
 CLASS yrg;
 VAR PYR;
RUN;

PROC MEANS DATA = b SUM;
 TITLE "Person time by calendar time group, my data";
 CLASS yearcat;
 VAR PY;
RUN;

*compare person time distribution;
PROC MEANS DATA = a SUM;
 TITLE "respiratory cancers by age group, Lubin's data";
 CLASS ageg;
 VAR respca;
RUN;

PROC MEANS DATA = b SUM;
 TITLE "respiratory cancers by age group, my data";
 CLASS agecat;
 VAR d_respcancer;
RUN;

*these match fine (different categorizations, but they are nested);
PROC MEANS DATA = a SUM;
 TITLE "respiratory cancers by calender time group, Lubin's data";
 CLASS yrg;
 VAR respca;
RUN;

PROC MEANS DATA = b SUM;
 TITLE "respiratory cancers by calender time group, my data";
 CLASS yearcat;
 VAR d_respcancer;
RUN;

*look at demographic data for respiratory cancers in first age;
DATA dg;
 SET mtcs.mtcs_dg02;
 agestop = YRDIF(dob, dlo, 'AGE');
 agestart = YRDIF(dob, start_fu, 'AGE');

PROC PRINT DATA = dg;
 TITLE "my data show 5 in agegroup <45, lubin's shows 7 (mine is correct based on actual ages)";
 WHERE y_respcancer=1 AND agestop<=45.5;
 VAR smid y_respcancer agestart agestop hireage termage totpy dob termdate dlo;
RUN;

PROC PRINT DATA = dg;
 TITLE "my data show 23 in agegroup >80, lubin's shows 20 (mine is correct based on actual ages)";
 WHERE y_respcancer=1 AND agestop>=80;
 VAR smid y_respcancer agestart agestop hireage termage totpy dob termdate dlo;
RUN;
