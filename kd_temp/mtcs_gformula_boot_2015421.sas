*clear the log window and the output window;

/**********************************************************************************************************************
* Author: Alex Keil
* Program: mtcs_gformula_boot_2015421.sas
* Date: Tuesday, April 21, 2015 at 10:37:10 AM
* Project: Anaconda copper smelter, arsenic exposures
* Tasks: 
* Data in: 
* Data out:
* Description: 
* Keywords:
* Released under the GNU General Public License: http://www.gnu.org/copyleft/gpl.html
**********************************************************************************************************************/
OPTIONS MERGENOBY = warn NODATE NONUMBER LINESIZE = 120  PAGESIZE=80 SKIP = 2 FORMDLIM = '-' MPRINT NOCENTER;
OPTIONS FORMCHAR = "|----|+|---+=|-/\<>*";
%LET PROGNAME =	mtcs_gformula_boot_2015421.sas;
TITLE;
FOOTNOTE "&progname run at &systime on &sysdate";
%GLOBAL root;
%LET root = ;*unique, numerical root name to help distinguish results;


LIBNAME mtcs "/nas02/home/a/k/akeil/EpiProjects/MT_copper_smelters/data";
LIBNAME gformula "/lustre/scr/a/k/akeil/arsenic/boots/&root";
********* BEGIN PROGRAMMING STATEMENTS ************************;

PROC FORMAT CNTLIN=mtcs.mtcs_formats;


%MACRO bootgf(niter);
%LET iter=1;
%DO %WHILE(%EVAL(&iter<=&niter));
*1) bootstrap sample from original data;
PROC SURVEYSELECT DATA = mtcs.mtcs_an02 OUT=bootdata_&ROOT METHOD=URS N=8014 NOPRINT ; SAMPLINGUNIT smid;RUN;

*1A) reassign smid value to guarantee uniqueness in bootstrap data;
DATA bootdata_&root; 
 LENGTH smid 8;
 SET bootdata_&root(RENAME=(smid=oldsmid));
 DO add = 1 TO numberhits; *from proc surveyselect - default is not to output multiple observations, just give number of hits;
  smid = oldsmid*10000 + add;
  OUTPUT;
 END;
RUN;

PROC SORT DATA = bootdata_&root; BY smid agein;
PROC PRINT DATA = bootdata_&root (OBS=200);
 VAR oldsmid smid agein agestart datein start_fu add;
RUN;  
 
 
*2) g-formula on bootstrap sample;
%INCLUDE "/lustre/scr/a/k/akeil/arsenic/boots/mtcs_gformula_20140908_batch_&ROOT..sas";

*3) compile, store results on bootstrap sample;
%INCLUDE "/lustre/scr/a/k/akeil/arsenic/boots/mtcs_gformula_mksurv_20150331_batch_&ROOT..sas";

*4) clean up;
PROC DATASETS LIBRARY=gformula /*NOLIST*/;
 /*DELETE hiexposure_&root noexposure_&root obschanges_&root natcourse_&root;*/
 CHANGE 
 cidata_age_med_&ROOT = cidata_age_med_&ROOT._&ITER
 cidata_age_lo_&ROOT = cidata_age_lo_&ROOT._&ITER
 cidata_age_hi_&ROOT = cidata_age_hi_&ROOT._&ITER
 cidata_age_nc_&ROOT = cidata_age_nc_&ROOT._&ITER
 cidata_age_ne_&ROOT = cidata_age_ne_&ROOT._&ITER
 cidata_age_obs_&ROOT = cidata_age_obs_&ROOT._&ITER
/* 
 cidata_date_hi_&ROOT = cidata_date_hi_&ROOT._&ITER
 cidata_date_nc_&ROOT = cidata_date_nc_&ROOT._&ITER
 cidata_date_ne_&ROOT = cidata_date_ne_&ROOT._&ITER
 cidata_date_obs_&ROOT = cidata_date_obs_&ROOT._&ITER
*/
 surv_lw_age_med_&ROOT = surv_lw_age_med_&ROOT._&ITER
 surv_lw_age_lo_&ROOT = surv_lw_age_lo_&ROOT._&ITER
 surv_lw_age_hi_&ROOT = surv_lw_age_hi_&ROOT._&ITER
 surv_lw_age_nc_&ROOT = surv_lw_age_nc_&ROOT._&ITER
 surv_lw_age_ne_&ROOT = surv_lw_age_ne_&ROOT._&ITER
 surv_lw_age_obs_&ROOT = surv_lw_age_obs_&ROOT._&ITER
/* 
 surv_lw_date_hi_&ROOT = surv_lw_date_hi_&ROOT._&ITER
 surv_lw_date_nc_&ROOT = surv_lw_date_nc_&ROOT._&ITER
 surv_lw_date_ne_&ROOT = surv_lw_date_ne_&ROOT._&ITER
 surv_lw_date_obs_&ROOT = surv_lw_date_obs_&ROOT._&ITER
*/
 surv_rw_age_med_&ROOT = surv_rw_age_med_&ROOT._&ITER
 surv_rw_age_lo_&ROOT = surv_rw_age_lo_&ROOT._&ITER
 surv_rw_age_hi_&ROOT = surv_rw_age_hi_&ROOT._&ITER
 surv_rw_age_nc_&ROOT = surv_rw_age_nc_&ROOT._&ITER
 surv_rw_age_ne_&ROOT = surv_rw_age_ne_&ROOT._&ITER
 surv_rw_age_obs_&ROOT = surv_rw_age_obs_&ROOT._&ITER
/* 
 surv_rw_date_hi_&ROOT = surv_rw_date_hi_&ROOT._&ITER
 surv_rw_date_nc_&ROOT = surv_rw_date_nc_&ROOT._&ITER
 surv_rw_date_ne_&ROOT = surv_rw_date_ne_&ROOT._&ITER
 surv_rw_date_obs_&ROOT = surv_rw_date_obs_&ROOT._&ITER
*/
;
QUIT;
%LET iter=%EVAL(&iter+1);
%END;
%MEND;
%BOOTGF(niter=3);

RUN;QUIT;RUN;
/*DM ODSRESULTS 'clear;' CONTINUE; *clear ODS generated datasets;*/



