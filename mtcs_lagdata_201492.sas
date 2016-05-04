*clear the log window and the output window;
DM LOG 'clear;' CONTINUE; DM OUT 'clear;' CONTINUE; 
/**********************************************************************************************************************
* Author: Alex Keil
* Program: mtcs_lagdata_201492.sas
* Date: Tuesday, September 2, 2014 at 3:20:02 PM
* Project: Anaconda copper smelter, arsenic exposures
* Tasks: apply lags to exposure data
* Data in: 
* Data out:
* Description: Calculates, for one lag interval at a time, the exposure values using linear interpolation of
*  by time in each person period. This program is inefficient due to only handling one lag at a time, but
*  it is flexible in terms of which lags should be calculated
* Keywords: lagging, macro, person period
* Released under the GNU General Public License: http://www.gnu.org/copyleft/gpl.html
**********************************************************************************************************************/
OPTIONS MERGENOBY = warn NODATE NONUMBER LINESIZE = 120  PAGESIZE=80 SKIP = 2 FORMDLIM = '-' MPRINT NOCENTER;
OPTIONS FORMCHAR = "|----|+|---+=|-/\<>*";
%LET PROGNAME =	mtcs_lagdata_201492.sas;
TITLE;
FOOTNOTE "&progname run at &systime on &sysdate";

LIBNAME mtcs "Z:/EpiProjects/MT_copper_smelters/data";
PROC FORMAT CNTLIN=mtcs.mtcs_formats;



********* BEGIN PROGRAMMING STATEMENTS ************************;
DATA an;
 SET mtcs.mtcs_an01();
 IF py>0;agefloor=FLOOR(agein);
PROC MEANS DATA = an;*put in cleaning;
 VAR agein;
 OUTPUT OUT = ai_cen MEAN=ageinmean STD=ageinstd;
DATA _null_; SET ai_cen; CALL SYMPUT("ageinmean", PUT(ageinmean, BEST9.)); CALL SYMPUT("ageinstd", PUT(ageinstd, BEST9.));
DATA an;
 SET an;
  agein_cen = (agein-&ageinmean)/&ageinstd;
  agein_censq = agein_cen*agein_cen;
%DASPLINE(agein_cen, knot1=-1.0 -0.5 0.5 1.0, DATA=an, norm=2);
*-1.655796591 -0.438108535 0.441332838 1.6590208936;
 DATA an;
  SET an;
  &_agein_cen;


*create new dataset with re-annualized exposures;
DATA rean (DROP=i);
 LENGTH smid agein ageout py 8;
 SET an (KEEP = smid py ageout agefloor aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu asuk_ann_durdfu so2lt_ann_durdfu 
         so2md_ann_durdfu so2hi_ann_durdfu so2uk_ann_durdfu tawdfu cumtawdfu ds01_ann_dfu activework activeworkdfu WHERE=(py>0));
 BY smid agefloor;
 ARRAY x[*] aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu asuk_ann_durdfu so2lt_ann_durdfu 
            so2md_ann_durdfu so2hi_ann_durdfu so2uk_ann_durdfu tawdfu activework activeworkdfu;
 DO i = 1 TO DIM(x);
  IF x[i]<.z THEN x[i]=0;
 END;


 IF NOT last.smid THEN agein = ageout-1;
 ELSE agein = FLOOR(ageout-10e-10); *redefine age in temporarily;
RUN;


%MACRO lagdata(lag=0);
DATA lagged&lag (KEEP = smid agefloor py&lag aslt_ann_durdfu_lag&lag asmd_ann_durdfu_lag&lag ashi_ann_durdfu_lag&lag 
                        asuk_ann_durdfu_lag&lag so2lt_ann_durdfu_lag&lag so2md_ann_durdfu_lag&lag
                        so2hi_ann_durdfu_lag&lag so2uk_ann_durdfu_lag&lag tawdfu_lag&lag cumtawdfu_lag&lag ds01_ann_dfu_lag&lag 
                        activework_lag&lag activeworkdfu_lag&lag);
 SET rean;
 ARRAY x[*] py aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu asuk_ann_durdfu so2lt_ann_durdfu 
            so2md_ann_durdfu so2hi_ann_durdfu so2uk_ann_durdfu tawdfu cumtawdfu ds01_ann_dfu activework activeworkdfu;
 ARRAY xlag[*]  py&lag aslt_ann_durdfu_lag&lag asmd_ann_durdfu_lag&lag ashi_ann_durdfu_lag&lag asuk_ann_durdfu_lag&lag so2lt_ann_durdfu_lag&lag 
            so2md_ann_durdfu_lag&lag so2hi_ann_durdfu_lag&lag so2uk_ann_durdfu_lag&lag tawdfu_lag&lag cumtawdfu_lag&lag ds01_ann_dfu_lag&lag 
           activework_lag&lag activeworkdfu_lag&lag;
 DO i = 1 TO DIM(x);xlag[i] = x[i];END; 
 agefloor=agein+&lag;

DATA an (DROP=i);
 MERGE an(IN=ina) lagged&lag();
 BY smid agefloor;
  ARRAY xlag[*] aslt_ann_durdfu_lag&lag asmd_ann_durdfu_lag&lag ashi_ann_durdfu_lag&lag asuk_ann_durdfu_lag&lag so2lt_ann_durdfu_lag&lag 
            so2md_ann_durdfu_lag&lag so2hi_ann_durdfu_lag&lag so2uk_ann_durdfu_lag&lag ds01_ann_dfu_lag&lag 
           activework_lag&lag activeworkdfu_lag&lag;

 *reduce exposure if person-period is shorter than the person-period from which the exposure came;
 IF py&lag<.z THEN py&lag=0;
 IF tawdfu_lag&lag<.z THEN tawdfu_lag&lag=0;
 IF cumtawdfu_lag&lag<.z THEN cumtawdfu_lag&lag=0;
 IF activework_lag&lag<.z THEN activework_lag&lag=0;
 IF activeworkdfu_lag&lag<.z THEN activeworkdfu_lag&lag=0;
 DO i = 1 TO (DIM(xlag) -2); 
  IF xlag[i]<.z THEN xlag[i]=0;
  IF py<py&lag THEN xlag[i] = xlag[i]*(py/py&lag);
 END;
 IF ina;
RUN;
%MEND;
%LAGDATA(lag=1);
%LAGDATA(lag=2);
%LAGDATA(lag=3);
%LAGDATA(lag=4);
%LAGDATA(lag=5);
%LAGDATA(lag=6);
%LAGDATA(lag=7);
%LAGDATA(lag=8);
%LAGDATA(lag=9);
%LAGDATA(lag=10);
%LAGDATA(lag=15);
%LAGDATA(lag=20);




DATA checklags;
 SET an (KEEP=smid agein ageout aslt_ann_durdf:);
RUN;


PROC MEANS DATA = an SUM;
 TITLE "Person-years of potential exposure, work time, by lag";
 VAR py: tawdfu:;
RUN;


*Output analytic dataset;
DATA mtcs.mtcs_an02 (LABEL="Analytic dataset: person-period format, at-risk person-time only, exposure lags included");
 SET an;
RUN;

PROC CONTENTS DATA = mtcs.mtcs_an02;
 TITLE "mtcs.mtcs_an02 contents";
RUN;


RUN;QUIT;RUN;
DM LOG "FILE Z:/EpiProjects/MT_copper_smelters/logs/sas/&progname.log REPLACE" CONTINUE;
DM OUT "FILE Z:/EpiProjects/MT_copper_smelters/output/sas/&progname.lst REPLACE" CONTINUE;
/*DM ODSRESULTS 'clear;' CONTINUE; *clear ODS generated datasets;*/

