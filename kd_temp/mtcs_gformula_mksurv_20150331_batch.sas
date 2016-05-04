*clear the log window and the output window;

/**********************************************************************************************************************
* Author: Alex Keil
* Program: mtcs_gformula_mksurv_20150331.sas
* Date: Tuesday, March 31, 2015 at 10:02:23 AM
* Project: Anaconda copper smelter, arsenic exposures
* Tasks: take output from g-formula (anaconda copper smelter) and turn into cumulative incidence data
* Data in: 
* Data out:
* Description: 
* Keywords:
* Released under the GNU General Public License: http://www.gnu.org/copyleft/gpl.html

* TODO: 
4)fix original g-formula natural course for respiratory cancer

*IMPLEMENTATION NOTES;
*  needs sas 9.3/m2 at minimum (sas/stat 12.1) [otherwise set METHOD=CH instead of METHOD=FH]
**********************************************************************************************************************/
OPTIONS MERGENOBY = warn NODATE NONUMBER LINESIZE = 120  PAGESIZE=80 SKIP = 2 FORMDLIM = '-' MPRINT NOCENTER;
OPTIONS FORMCHAR = "|----|+|---+=|-/\<>*";
%LET PROGNAME =	mtcs_gformula_mksurv_20150331.sas;
TITLE;
FOOTNOTE "&progname run at &systime on &sysdate";
/*
LIBNAME mtcs "/nas02/home/a/k/akeil/EpiProjects/MT_copper_smelters/data";
LIBNAME gformula "/nas02/home/a/k/akeil/EpiProjects/MT_copper_smelters/data/mcdata";
*/
%INCLUDE "/nas02/home/a/k/akeil/Documents/macros/daspline.sas";

********* BEGIN PROGRAMMING STATEMENTS ************************;
PROC FORMAT CNTLIN=mtcs.mtcs_formats;

*must run;
DATA obs; SET gformula.obschanges;
DATA nc; SET gformula.natcourse;
DATA ne; SET gformula.noexposure;
DATA hi; SET gformula.hiexposure;
DATA med; SET gformula.medexposure;
DATA lo; SET gformula.loexposure;
%MACRO makehaz(suf=);
 RETAIN lastch;
 IF _N_=1 THEN lastch=0;
 haz_&suf = cumhaz-lastch;
 OUTPUT;
 lastch=cumhaz;
 DROP lastch cumhaz;
%MEND;

%MACRO mksurvdata (ds=nc, outvar=age);
*PHREG cannot handle negative times, so convert sas dates to number of days from the minimum start time (will be converted back at end);
%LET mintime = -900000; *cause an obvious problem in the graph if assignment of this does not work;
DATA ___sur;
 SET &DS;
PROC MEANS DATA = ___SUR;VAR &outvar.in_alt;
 OUTPUT OUT=___SURMIN min=minval;
DATA _null_;SET ___surmin; CALL SYMPUT('mintime', PUT(minval, BEST9.));RUN;
DATA ___sur;
 SET ___sur;
 &outvar.in_alt =  &outvar.in_alt - &mintime;
 &outvar.out = &outvar.out - &mintime;
RUN;
*causes of death;
PROC PHREG DATA = ___sur;
 MODEL (&outvar.in_alt &outvar.out)*d_respcancer(0) =  / TIES=EFRON;
 BASELINE out=surv_rc_&outvar._&ds SURVIVAL=surv_rc CUMHAZ=cumhaz / METHOD=FH ;
PROC PHREG DATA = ___sur;
 MODEL (&outvar.in_alt &outvar.out)*d_cvd(0) =  / TIES=EFRON;
 BASELINE out=surv_cv_&outvar._&ds SURVIVAL=surv_cv CUMHAZ=cumhaz / METHOD=FH ;
PROC PHREG DATA = ___sur;
 MODEL(&outvar.in_alt &outvar.out)*d_allothercauses(0) =  / TIES=EFRON;
 BASELINE out=surv_oc_&outvar._&ds SURVIVAL=surv_oc CUMHAZ=cumhaz / METHOD=FH;
*employment;
PROC PHREG DATA = ___sur;
 MODEL (&outvar.in_alt &outvar.out)*d_allcause(0) =  / TIES=EFRON;
 BASELINE out=surv_ac_&outvar._&ds SURVIVAL=surv_ac CUMHAZ=cumhaz/ METHOD=FH ;
RUN;
PROC PHREG DATA = ___sur;
 WHERE leavework=1 OR (activework=1 AND returnwork=0);
 MODEL (&outvar.in_alt &outvar.out)*leavework(0) =  / TIES=EFRON;
 BASELINE out=gformula.surv_lw_&outvar._&ds._&ROOT CUMHAZ=cumhaz_lw  / METHOD=FH;
RUN;
PROC PHREG DATA = ___sur;
 WHERE returnwork=1 OR (activework=0 AND leavework=0);
 MODEL (&outvar.in_alt &outvar.out)*returnwork(0) = / TIES=EFRON;
 BASELINE out=gformula.surv_rw_&outvar._&ds._&ROOT CUMHAZ=cumhaz_rw / METHOD=FH;
RUN;

DATA gformula.surv_rw_&outvar._&ds._&ROOT; SET gformula.surv_rw_&outvar._&ds._&ROOT;&outvar.out = &outvar.out + &mintime;
DATA gformula.surv_lw_&outvar._&ds._&ROOT; SET gformula.surv_lw_&outvar._&ds._&ROOT;&outvar.out = &outvar.out + &mintime;
DATA surv_rc_&outvar._&ds; SET surv_rc_&outvar._&ds; &outvar.out = &outvar.out + &mintime; %makehaz(suf=rc);
DATA surv_cv_&outvar._&ds; SET surv_cv_&outvar._&ds; &outvar.out = &outvar.out + &mintime; %makehaz(suf=cv);
DATA surv_oc_&outvar._&ds; SET surv_oc_&outvar._&ds; &outvar.out = &outvar.out + &mintime; %makehaz(suf=oc);
DATA surv_ac_&outvar._&ds; SET surv_ac_&outvar._&ds; &outvar.out = &outvar.out + &mintime; %makehaz(suf=ac);

DATA cidata_&outvar._&ds;
 SET surv_ac_&outvar._&ds(KEEP=&outvar.out surv_ac )
  surv_rc_&outvar._&ds(KEEP=&outvar.out haz_rc surv_rc)
  surv_cv_&outvar._&ds(KEEP=&outvar.out haz_cv surv:)
  surv_oc_&outvar._&ds(KEEP=&outvar.out haz_oc surv:)
  ;
RUN;
PROC SORT DATA = cidata_&outvar._&ds; BY &outvar.out DESCENDING surv_ac;
DATA gformula.cidata_&outvar._&ds._&ROOT (KEEP = &outvar.out surv_ac km_: ci_: altci: auc_:);
 SET cidata_&outvar._&ds;
BY &outvar.out DESCENDING surv_ac;
RETAIN lastsurv_ac km_rc km_cv km_oc 1 ci_ac ci_rc ci_cv ci_oc auc_ac auc_rc auc_cv auc_oc 0 lasttime 0;
  IF FIRST.&OUTVAR.OUT THEN DO; ci_ac=1-surv_ac;;END;
  ci_rc  + lastsurv_ac*MAX(haz_rc, 0);
  ci_cv  + lastsurv_ac*MAX(haz_cv, 0);
  ci_oc  + lastsurv_ac*MAX(haz_oc, 0);
  altci_ac = SUM(ci_rc, ci_cv, ci_oc);
  IF haz_rc>0 THEN km_rc = surv_rc;
  IF haz_cv>0 THEN km_cv = surv_cv;
  IF haz_oc>0 THEN km_oc = surv_oc;
  IF surv_ac<.z THEN surv_ac = 1-ci_ac;
IF LAST.&OUTVAR.OUT THEN DO;  
  auc_rc = (1-ci_rc)*(&outvar.out-lasttime) + auc_rc;
  auc_cv = (1-ci_cv)*(&outvar.out-lasttime) + auc_cv;
  auc_oc = (1-ci_oc)*(&outvar.out-lasttime) + auc_oc;
  auc_ac = (1-ci_ac)*(&outvar.out-lasttime) + auc_ac;
END;  
 IF LAST.&OUTVAR.OUT THEN DO;
    OUTPUT;
    lasttime = &outvar.out;
    lastsurv_ac=1-ci_ac;
 END;
RUN;
%MEND;

%mksurvdata(DS=obs, outvar=age);
*%mksurvdata(DS=obs, outvar=date);
%mksurvdata(DS=nc , outvar=age);
*%mksurvdata(DS=nc , outvar=date);
%mksurvdata(DS=ne , outvar=age);
*%mksurvdata(DS=ne , outvar=date);
%mksurvdata(DS=hi , outvar=age);
*%mksurvdata(DS=hi , outvar=date);
%mksurvdata(DS=lo , outvar=age);
*%mksurvdata(DS=lo , outvar=date);
%mksurvdata(DS=med, outvar=age);
*%mksurvdata(DS=med, outvar=date);
RUN;


RUN;QUIT;RUN;
/*DM ODSRESULTS 'clear;' CONTINUE; *clear ODS generated datasets;*/



