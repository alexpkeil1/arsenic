

*clear the log window and the output window;
DM LOG 'clear;' CONTINUE; 
DM OUT 'clear;' CONTINUE; 
/**********************************************************************************************************************
* Author: Alex Keil
* Program: mtcs_modelcompare_20141008.sas
* Date: Monday, September 8, 2014 at 2:00:36 PM
* Project: Anaconda copper smelter, arsenic exposures
* Tasks: Initial g-formula analysis of copper smelter data - model checking
* Data in: Z:/EpiProjects/MT_copper_smelters/data/mtcs_an02.sas7bdat
* Data out:
* Description: 
* Keywords:
* Released under the GNU General Public License: http://www.gnu.org/copyleft/gpl.html
**********************************************************************************************************************/
OPTIONS MERGENOBY = warn NODATE NONUMBER LINESIZE = 120  PAGESIZE=80 SKIP = 2 FORMDLIM = '-' MPRINT NOCENTER;
OPTIONS FORMCHAR = "|----|+|---+=|-/\<>*";
%LET PROGNAME =	mtcs_modelcompare_20141008.sas;
TITLE;
FOOTNOTE "&progname run at &systime on &sysdate";

LIBNAME mtcs "Z:/EpiProjects/MT_copper_smelters/data";
*LIBNAME mtcs "/nas02/home/a/k/akeil/EpiProjects/MT_copper_smelters/data";

%INCLUDE "Z:/Documents/macros/daspline.sas";
%INCLUDE "Z:/Documents/macros/daspline_ak.sas";
*%INCLUDE "/nas02/home/a/k/akeil/Documents/macros/daspline.sas";
*%INCLUDE "/nas02/home/a/k/akeil/Documents/macros/daspline_ak.sas";
/*
PROC DATASETS LIB=work KILL;QUIT;
%INCLUDE "Z:/EpiProjects/MT_copper_smelters/code/mtcs_import_20140828.sas";
PROC DATASETS LIB=work KILL;QUIT;
%INCLUDE "Z:/EpiProjects/MT_copper_smelters/code/mtcs_cleaning_20140828.sas";
PROC DATASETS LIB=work KILL;QUIT;
%INCLUDE "Z:/EpiProjects/MT_copper_smelters/code/mtcs_lagdata_201492.sas";
*/
********* BEGIN PROGRAMMING STATEMENTS ************************;
PROC DATASETS LIB=work KILL;QUIT;
PROC FORMAT CNTLIN=mtcs.mtcs_formats;

*step 0a - some dummy variables;
DATA an;
 SET mtcs.mtcs_an02;
 BY smid agein;
 IF NOT last.smid THEN lastobs=0; ELSE lastobs=1;

  *time weighted average for each work area;
 lowc = .29; 
 midc = .58;
 hic = 1.13;

 as_score =        MAX((aslt_ann_durdfu>0)*lowc ,  midc*(asmd_ann_durdfu>0), hic*(ashi_ann_durdfu>0));
 so2_score =       MAX((so2lt_ann_durdfu>0),  2*(so2md_ann_durdfu>0), 3*(so2hi_ann_durdfu>0)); 
 as_score_lag1 =   MAX((aslt_ann_durdfu_lag1>0)*lowc ,  midc*(asmd_ann_durdfu_lag1>0), hic*(ashi_ann_durdfu_lag1>0));
 so2_score_lag1 =  MAX((so2lt_ann_durdfu_lag1>0) ,  2*(so2md_ann_durdfu_lag1>0), 3*(so2hi_ann_durdfu_lag1>0)); 
 as_score_lag2 =   MAX((aslt_ann_durdfu_lag2>0)*lowc ,  midc*(asmd_ann_durdfu_lag2>0), hic*(ashi_ann_durdfu_lag2>0));
 so2_score_lag2 =  MAX((so2lt_ann_durdfu_lag2>0) ,  2*(so2md_ann_durdfu_lag2>0), 3*(so2hi_ann_durdfu_lag2>0)); 
 as_score_lag3 =   MAX((aslt_ann_durdfu_lag3>0)*lowc ,  midc*(asmd_ann_durdfu_lag3>0), hic*(ashi_ann_durdfu_lag3>0));
 so2_score_lag3 =  MAX((so2lt_ann_durdfu_lag3>0) ,  2*(so2md_ann_durdfu_lag3>0), 3*(so2hi_ann_durdfu_lag3>0)); 
 as_score_lag5 =   MAX((aslt_ann_durdfu_lag5>0)*lowc ,  midc*(asmd_ann_durdfu_lag5>0), hic*(ashi_ann_durdfu_lag5>0));
 so2_score_lag5 =  MAX((so2lt_ann_durdfu_lag5>0) ,  2*(so2md_ann_durdfu_lag5>0), 3*(so2hi_ann_durdfu_lag5>0)); 
 as_score_lag10 =  MAX((aslt_ann_durdfu_lag10>0)*lowc ,  midc*(asmd_ann_durdfu_lag10>0), hic*(ashi_ann_durdfu_lag10>0));
 so2_score_lag10 = MAX((so2lt_ann_durdfu_lag10>0),  2*(so2md_ann_durdfu_lag10>0), 3*(so2hi_ann_durdfu_lag10>0)); 
 as_score_lag20 =  MAX((aslt_ann_durdfu_lag20>0)*lowc ,  midc*(asmd_ann_durdfu_lag20>0), hic*(ashi_ann_durdfu_lag20>0));
 so2_score_lag20 = MAX((so2lt_ann_durdfu_lag20>0),  2*(so2md_ann_durdfu_lag20>0), 3*(so2hi_ann_durdfu_lag20>0));

RETAIN cum_as_score cum_so2_score cum_as_score_lag1 cum_so2_score_lag1 cum_as_score_lag2 cum_so2_score_lag2 
       cum_as_score_lag3 cum_so2_score_lag3
        cum_as_score_lag5 cum_so2_score_lag5 cum_as_score_lag10 cum_so2_score_lag10 cum_as_score_lag20 cum_so2_score_lag20;

 ARRAY anns[*] as_score so2_score as_score_lag1 so2_score_lag1 as_score_lag2 so2_score_lag2 as_score_lag3 so2_score_lag3
        as_score_lag5 so2_score_lag5 as_score_lag10 so2_score_lag10 as_score_lag20 so2_score_lag20;

 ARRAY cums[*] cum_as_score cum_so2_score cum_as_score_lag1 cum_so2_score_lag1 cum_as_score_lag2 cum_so2_score_lag2
 cum_as_score_lag3 cum_so2_score_lag3
        cum_as_score_lag5 cum_so2_score_lag5 cum_as_score_lag10 cum_so2_score_lag10 cum_as_score_lag20 cum_so2_score_lag20;

 IF first.smid THEN DO i = 1 TO DIM(anns);
   cums[i] = anns[i];
 END;
 ELSE DO i = 1 TO DIM(anns);
   cums[i] = cums[i] + anns[i];
 END;
 
 cum_as_1_5 = cum_as_score_lag1-cum_as_score_lag5;
 cum_as_2_5 = cum_as_score_lag2-cum_as_score_lag5;
 cum_as_3_5 = cum_as_score_lag3-cum_as_score_lag5;
 *cum_so2_1_5 = cum_so2_score_lag1-cum_so2_score_lag5;
 *cum_as_5_10 = cum_as_score_lag5-cum_as_score_lag10;
 *cum_so2_5_10 = cum_so2_score_lag5-cum_so2_score_lag10;;
 *cum_as_10_20 = cum_as_score_lag10-cum_as_score_lag20;;
 *cum_so2_10_20 = cum_so2_score_lag10-cum_so2_score_lag20;;
 cum_as_5_20 = cum_as_score_lag5-cum_as_score_lag20;
 cum_so2_5_20 = cum_so2_score_lag5-cum_so2_score_lag20;

*interactions;
 cumtawdfu_lag1sq = cumtawdfu_lag1*cumtawdfu_lag1;
*summary exposure variable interactions; 
 anl_1_5 = cum_as_1_5*(1-activework);
 anl_2_5 = cum_as_2_5*(1-activework);
 anl_3_5 = cum_as_3_5*(1-activework);
 anl_5_20 = cum_as_5_20*(1-activework);
 anl_lag20 = cum_as_score_lag20*(1-activework);
 al = as_score*(activework);
 al_1_5 = cum_as_1_5*(activework);
 al_2_5 = cum_as_2_5*(activework);
 al_3_5 = cum_as_3_5*(activework);
 al_5_20 = cum_as_5_20*(activework);

*polynomial terms;
 cumtawbfusq= cumtawbfu*cumtawbfu;
 hireage_censq = hireage_cen*hireage_cen;
 hireage_cencu = hireage_cen*hireage_censq;

 agein_censq = agein_cen*agein_cen;
 agein_cencu = agein_cen*agein_censq;
 agein_cenqu = agein_censq*agein_censq;
 agein_cen5th = agein_censq*agein_cencu;

 dob_censq = dob_cen*dob_cen;
 dob_cencu = dob_cen*dob_censq;
 dob_cenqu = dob_censq*dob*dob_censq;
 dob_cen5th = dob_censq*dob*dob_cenqu;



 RETAIN timesinceleavework retired 0;
 IF FIRST.smid THEN DO; timesinceleavework=0; retired=0; END;
 IF leavework=1 THEN timesinceleavework=py;
 ELSE IF leavework=0 AND activework=1 AND returnwork=0 THEN timesinceleavework=0;
 ELSE timesinceleavework= timesinceleavework + py;
 IF ageout>60 AND leavework THEN retired=1;

 IF d_respcancer=1 OR d_cvd=1 OR d_allcause=0  THEN d_allothercauses=0;
 IF d_respcancer=0 AND d_cvd=0 AND d_allcause=1 THEN d_allothercauses=1;
;

*simplified prior exposure;
 cum_as_score_bfu = lowc*tot_aslt_ann_durbfu + tot_asmd_ann_durbfu*midc + tot_ashi_ann_durbfu*hic;
 cum_so2_score_bfu = tot_so2lt_ann_durbfu + tot_so2md_ann_durbfu*2 + tot_so2hi_ann_durbfu*3;

over65=(ageout>65);
RETAIN retired;
IF first.smid THEN retired=0;
ELSE IF over65 AND leavework THEN retired=1;

%LET age_ex = cum_as_score_lag1*(agein>65);
%LET age_ex2 = cum_as_score_lag1*(agein>75);
age_ex = &age_ex;
age_ex2 = &age_ex2;

%LET avg_int = cum_as_score*(cum_as_score/cumtawdfu);
IF cumtawdfu>0 THEN avg_int = &avg_int;
ELSE avg_int=0;

caltime = (YEAR(datein)-1950)/20;

*categorical variables;
IF ageout<100.5 ;*AND 1938<=YEAR(hiredate)<1948;
  yob = YEAR(dob);
  yob1 = (yob<=1875);
  yob2 = (1875<yob<=1900);
  yob3 = (1875<yob<=1900);
  yob4 = (1900<yob<=1910);
  yob5 = (1910<yob<=1920);
  yob6 = (1920<yob);


RUN;

%MACRO fitmod(outcome=d_allcause, preds=&dpreds, set=1);
ODS LISTING close;
%PUT model &set;
PROC LOGISTIC DATA = an DESCENDING DESCENDING OUT=c_d(DROP=_:);
 MODEL &outcome = &preds;
 ODS OUTPUT fitstatistics = _fs (WHERE=(criterion="AIC"));
 ODS OUTPUT parameterestimates = _pe;
RUN;

PROC TRANSPOSE DATA = _pe(KEEP=variable estimate) OUT=_pet NAME=model ;ID variable;RUN;
DATA mod&set; MERGE _pet _fs;RUN;
%IF &set = 1 %THEN %DO;
 DATA modcompare; LENGTH model $32 criterion $6 InterceptOnly InterceptAndCovariates 8; SET mod&set; MODEL="model &set";
%END;
%IF &set NE 1 %THEN %DO;
  DATA mod&set; LENGTH model $32 criterion $6 InterceptOnly InterceptAndCovariates 8; SET mod&set; MODEL="model &set";;
  DATA modcompare; SET modcompare mod&set;
%END;
PROC SORT DATA = modcompare; BY InterceptAndCovariates; RUN;
ODS LISTING;
%MEND;

/*****************************************************************************************/
/********************** all other causes   ***********************************************/
/*****************************************************************************************/
/*****************************************************************************************/

%DASPLINE_ak( dob_cen, 
           nk=8, DATA=an, norm=2);
%DASPLINE_ak(agein_cen  , 
           nk=7, DATA=an, norm=2);
%DASPLINE_ak(hireage_cen  , 
           nk=5, DATA=an, norm=2);
DATA an;
 SET an;
  &_agein_cen ;
  &_dob_cen;
  &_hireage_cen;
RUN;

%LET dpreds =  agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th  
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu timesinceleavework
 anl_1_5 anl_5_20 aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu al_1_5 al_5_20
;


%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=1);

%DASPLINE_ak(agein_cen  , 
           nk=9, DATA=an, norm=2);
DATA an;
 SET an;
  &_agein_cen ;
  &_dob_cen;
RUN;

 *refining recent work;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu timesinceleavework
 anl_1_5 anl_5_20 aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu al_1_5 al_5_20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=2);

%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu timesinceleavework
 anl_2_5 anl_5_20 aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 al_2_5 al_5_20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=3);

*adding in active work status;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu timesinceleavework activework
 anl_2_5 anl_5_20 aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 al_2_5 al_5_20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=4);


*further refining recent exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu timesinceleavework activework
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=5);

*neglecting recent exposures (2 year lag);
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu timesinceleavework activework
 anl_3_5 anl_5_20 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=6);

*neglecting recent exposures (3 year lag);
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu timesinceleavework activework
 anl_3_5 anl_5_20 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=7);

*removing time off work variables;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq  timesinceleavework activework
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=8);

*adding us born;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq usborn timesinceleavework activework
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=9);


*adding calendar year;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq usborn timesinceleavework activework
caltime
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=10);

*returning time off work variables;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq  cumtowdfu cumtowbfu usborn timesinceleavework activework
caltime
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=11);

*introducing time at work before follow up;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtowdfu cumtowbfu usborn timesinceleavework activework
caltime
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=12);

%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
caltime
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=13);

*removing calendar time again;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=14);

*hireage;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=15);
*hireage;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=16);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen
 anl_3_5 anl_5_20 
tot_aslt_ann_durbfu tot_asmd_ann_durbfu tot_ashi_ann_durbfu tot_asuk_ann_durbfu 
tot_so2lt_ann_durbfu tot_so2md_ann_durbfu tot_so2hi_ann_durbfu tot_so2uk_ann_durbfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=17);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
 anl_3_5 anl_5_20 
tot_aslt_ann_durbfu tot_asmd_ann_durbfu tot_ashi_ann_durbfu tot_asuk_ann_durbfu 
tot_so2lt_ann_durbfu tot_so2md_ann_durbfu tot_so2hi_ann_durbfu tot_so2uk_ann_durbfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=18);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen
 anl_3_5 anl_5_20 
cum_as_score_bfu
cum_so2_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=19);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
 anl_3_5 anl_5_20 
cum_as_score_bfu
cum_so2_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=20);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen
 anl_3_5 anl_5_20 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=21);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
 anl_3_5 anl_5_20 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=22);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
 anl_3_5 anl_5_20 
cum_as_score_bfu
cum_so2_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20 cum_as_score_lag20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=23);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
 anl_1_5 anl_5_20 
cum_as_score_bfu
cum_so2_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
 al_1_5 al_5_20 cum_as_score_lag20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=24);

%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7 
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6 
cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn 
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3 
cum_as_score_bfu 
cumtawdfu_lag1 cumtawdfu_lag1sq
activework
retired
age_ex age_ex2 
anl_1_5 anl_5_20 
al_1_5 al_5_20 cum_as_score_lag20
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=25);

%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7 
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6 
cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn 
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3 
cum_as_score_bfu 
cumtawdfu_lag1 cumtawdfu_lag1sq
activework
retired
age_ex age_ex2 
anl_1_5 anl_5_20 
al_1_5 al_5_20 
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=26);

%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7 
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6 
cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn 
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3 
cum_as_score_bfu 
cumtawdfu_lag1 cumtawdfu_lag1sq
timesinceleavework
retired
age_ex age_ex2 
anl_1_5 anl_5_20 
al_1_5 al_5_20 
;
%FITMOD(outcome=d_allothercauses, preds=&dpreds, set=27);

DATA mtcs.modcomp_allothercauses; SET modcompare;
RUN;

/*****************************************************************************************/
/********************** cardiovascular disease ***********************************************/
/*****************************************************************************************/
/*****************************************************************************************/

%DASPLINE_ak( dob_cen, 
           nk=8, DATA=an, norm=2);
%DASPLINE_ak(agein_cen  , 
           nk=7, DATA=an, norm=2);
DATA an;
 SET an;
  &_agein_cen ;
  &_dob_cen;
RUN;

%LET dpreds =  agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th  
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu timesinceleavework
 anl_1_5 anl_5_20 aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu al_1_5 al_5_20
;


%FITMOD(outcome=d_cvd, preds=&dpreds, set=1);
%DASPLINE_ak(agein_cen  , 
           nk=9, DATA=an, norm=2);
DATA an;
 SET an;
  &_agein_cen ;
  &_dob_cen;
RUN;

 *refining recent work;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu timesinceleavework
 anl_1_5 anl_5_20 aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu al_1_5 al_5_20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=2);

%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu timesinceleavework
 anl_2_5 anl_5_20 aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 al_2_5 al_5_20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=3);

*adding in active work status;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu timesinceleavework activework
 anl_2_5 anl_5_20 aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 al_2_5 al_5_20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=4);


*further refining recent exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu timesinceleavework activework
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=5);

*neglecting recent exposures (2 year lag);
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu timesinceleavework activework
 anl_3_5 anl_5_20 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=6);

*neglecting recent exposures (3 year lag);
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu timesinceleavework activework
 anl_3_5 anl_5_20 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=7);

*removing time off work variables;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq  timesinceleavework activework
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=8);

*adding us born;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq usborn timesinceleavework activework
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=9);


*adding calendar year;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq usborn timesinceleavework activework
caltime
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=10);

*returning time off work variables;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq  cumtowdfu cumtowbfu usborn timesinceleavework activework
caltime
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=11);

*introducing time at work before follow up;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtowdfu cumtowbfu usborn timesinceleavework activework
caltime
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=12);

%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
caltime
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=13);

*removing calendar time again;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=14);

*hireage;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen 
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=15);

*hireage;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=16);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen
 anl_3_5 anl_5_20 
tot_aslt_ann_durbfu tot_asmd_ann_durbfu tot_ashi_ann_durbfu tot_asuk_ann_durbfu 
tot_so2lt_ann_durbfu tot_so2md_ann_durbfu tot_so2hi_ann_durbfu tot_so2uk_ann_durbfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=17);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
 anl_3_5 anl_5_20 
tot_aslt_ann_durbfu tot_asmd_ann_durbfu tot_ashi_ann_durbfu tot_asuk_ann_durbfu 
tot_so2lt_ann_durbfu tot_so2md_ann_durbfu tot_so2hi_ann_durbfu tot_so2uk_ann_durbfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=18);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen
 anl_3_5 anl_5_20 
cum_as_score_bfu
cum_so2_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=19);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
 anl_3_5 anl_5_20 
cum_as_score_bfu
cum_so2_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=20);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen
 anl_3_5 anl_5_20 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=21);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
 anl_3_5 anl_5_20 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=22);


*more exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
 anl_3_5 anl_5_20 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20 cum_as_score_lag20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=23);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen
 anl_3_5 anl_5_20 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20 cum_as_score_lag20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=24);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn activework
hireage_cen
 anl_3_5 anl_5_20 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20 cum_as_score_lag20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=25);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
hireage_cen
 anl_3_5 anl_5_20 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20 cum_as_score_lag20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=26);


*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
hireage_cen
 anl_3_5 anl_5_20 
retired
age_ex age_ex2 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20 cum_as_score_lag20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=27);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
hireage_cen
 anl_1_5 anl_5_20 
retired
age_ex age_ex2 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
 al_1_5 al_5_20 cum_as_score_lag20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=28);


%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
hireage_cen
retired
age_ex age_ex2 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
 cum_as_1_5 cum_as_5_20 cum_as_score_lag20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=29);


%LET dpreds =  agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
hireage_cen
retired
age_ex age_ex2 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
 cum_as_1_5 cum_as_5_20 cum_as_score_lag20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=29);


%LET dpreds =  agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
retired
age_ex age_ex2 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
 cum_as_1_5 cum_as_5_20 cum_as_score_lag20
;
%FITMOD(outcome=d_cvd, preds=&dpreds, set=30);

%LET dpreds =  agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
retired
age_ex age_ex2 
cum_as_score_bfu cum_so2_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
 cum_as_1_5 cum_as_5_20 cum_as_score_lag20;
 
%FITMOD(outcome=d_cvd, preds=&dpreds, set=31);


DATA mtcs.modcomp_cvd; SET modcompare;
RUN;


/*****************************************************************************************/
/********************** respiratory cancer ***********************************************/
/*****************************************************************************************/
/*****************************************************************************************/

%DASPLINE_ak( dob_cen, 
           nk=8, DATA=an, norm=2);
%DASPLINE_ak(agein_cen  , 
           nk=7, DATA=an, norm=2);
DATA an;
 SET an;
  &_agein_cen ;
  &_dob_cen;
RUN;

%LET dpreds =  agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th  
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu timesinceleavework
 anl_1_5 anl_5_20 aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu al_1_5 al_5_20
;


%FITMOD(outcome=d_respcancer, preds=&dpreds, set=1);
%DASPLINE_ak(agein_cen  , 
           nk=9, DATA=an, norm=2);
DATA an;
 SET an;
  &_agein_cen ;
  &_dob_cen;
RUN;

 *refining recent work;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu timesinceleavework
 anl_1_5 anl_5_20 aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu al_1_5 al_5_20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=2);

%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu timesinceleavework
 anl_2_5 anl_5_20 aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 al_2_5 al_5_20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=3);

*adding in active work status;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu timesinceleavework activework
 anl_2_5 anl_5_20 aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 al_2_5 al_5_20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=4);


*further refining recent exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu timesinceleavework activework
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=5);

*neglecting recent exposures (2 year lag);
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu timesinceleavework activework
 anl_3_5 anl_5_20 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=6);

*neglecting recent exposures (3 year lag);
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu timesinceleavework activework
 anl_3_5 anl_5_20 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=7);

*removing time off work variables;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq  timesinceleavework activework
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=8);

*adding us born;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq usborn timesinceleavework activework
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=9);


*adding calendar year;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq usborn timesinceleavework activework
caltime
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=10);

*returning time off work variables;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq  cumtowdfu cumtowbfu usborn timesinceleavework activework
caltime
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=11);

*introducing time at work before follow up;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtowdfu cumtowbfu usborn timesinceleavework activework
caltime
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=12);

%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
caltime
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=13);

*removing calendar time again;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=14);

*hireage;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen 
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=15);

*hireage;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
 anl_3_5 anl_5_20 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=16);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen
 anl_3_5 anl_5_20 
tot_aslt_ann_durbfu tot_asmd_ann_durbfu tot_ashi_ann_durbfu tot_asuk_ann_durbfu 
tot_so2lt_ann_durbfu tot_so2md_ann_durbfu tot_so2hi_ann_durbfu tot_so2uk_ann_durbfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=17);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
 anl_3_5 anl_5_20 
tot_aslt_ann_durbfu tot_asmd_ann_durbfu tot_ashi_ann_durbfu tot_asuk_ann_durbfu 
tot_so2lt_ann_durbfu tot_so2md_ann_durbfu tot_so2hi_ann_durbfu tot_so2uk_ann_durbfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=18);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen
 anl_3_5 anl_5_20 
cum_as_score_bfu
cum_so2_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=19);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
 anl_3_5 anl_5_20 
cum_as_score_bfu
cum_so2_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=20);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen
 anl_3_5 anl_5_20 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=21);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
 anl_3_5 anl_5_20 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=22);


*more exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
 anl_3_5 anl_5_20 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20 cum_as_score_lag20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=23);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn timesinceleavework activework
hireage_cen
 anl_3_5 anl_5_20 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20 cum_as_score_lag20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=24);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn activework
hireage_cen
 anl_3_5 anl_5_20 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20 cum_as_score_lag20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=25);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
hireage_cen
 anl_3_5 anl_5_20 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20 cum_as_score_lag20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=26);


*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
hireage_cen
 anl_3_5 anl_5_20 
retired
age_ex age_ex2 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20 cum_as_score_lag20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=27);

*pre-enrollment exposure;
%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
hireage_cen
 anl_1_5 anl_5_20 
retired
age_ex age_ex2 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
 al_1_5 al_5_20 cum_as_score_lag20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=28);


%LET dpreds =  agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
hireage_cen
retired
age_ex age_ex2 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
 cum_as_1_5 cum_as_5_20 cum_as_score_lag20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=29);


%LET dpreds =  agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
hireage_cen
retired
age_ex age_ex2 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
 cum_as_1_5 cum_as_5_20 cum_as_score_lag20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=29);


%LET dpreds =  agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
retired
age_ex age_ex2 
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
 cum_as_1_5 cum_as_5_20 cum_as_score_lag20
;
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=30);

%LET dpreds =  agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
retired
age_ex age_ex2 
cum_as_score_bfu cum_so2_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
 cum_as_1_5 cum_as_5_20 cum_as_score_lag20;
 
%FITMOD(outcome=d_respcancer, preds=&dpreds, set=31);


DATA mtcs.modcomp_respcancer; SET modcompare;
RUN;






/*****************************************************************************************/
/********************** leaving work *****************************************************/
/*****************************************************************************************/
/*****************************************************************************************/


%MACRO fitmodleavework(outcome=leavework, preds=&dlpreds, set=1);
ODS LISTING close;
%PUT model &set;
PROC LOGISTIC DATA = an DESCENDING;
 WHERE (activework=1 OR leavework=1);
 MODEL &outcome = &preds;
 ODS OUTPUT fitstatistics = _fs (WHERE=(criterion="AIC"));
 ODS OUTPUT parameterestimates = _pe;
RUN;

PROC TRANSPOSE DATA = _pe(KEEP=variable estimate) OUT=_pet NAME=model ;ID variable;RUN;
DATA mod&set; MERGE _pet _fs;RUN;
%IF &set = 1 %THEN %DO;
 DATA modcompare; LENGTH model $32 criterion $6 InterceptOnly InterceptAndCovariates 8; SET mod&set; MODEL="model &set";
%END;
%IF &set NE 1 %THEN %DO;
  DATA mod&set; LENGTH model $32 criterion $6 InterceptOnly InterceptAndCovariates 8; SET mod&set; MODEL="model &set";;
  DATA modcompare; SET modcompare mod&set;
%END;
PROC SORT DATA = modcompare; BY InterceptAndCovariates; RUN;
ODS LISTING;
%MEND;
%LET lpreds = agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 cum_as_3_5 cum_as_5_20;
;
%fitmodleavework(outcome=leavework, preds=&lpreds, set=1);
*refining spline variables;
DATA an;
 SET an;
 agein_cenaw=agein_cen;
 dob_cenaw=dob_cen;
RUN;
%DASPLINE_ak(agein_cenaw, 
           nk=9, DATA=an(WHERE=(activework=1)), norm=2);
%DASPLINE_ak(dob_cenaw  , 
           nk=8, DATA=an(WHERE=(activework=1)), norm=2);
DATA an;
 SET an;
  &_agein_cenaw ;
  &_dob_cenaw;
RUN;
%LET lpreds = agein_cenaw agein_cenaw1 agein_cenaw2 agein_cenaw3 agein_cenaw4 agein_cenaw5 agein_cenaw6 agein_cenaw7
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 cum_as_3_5 cum_as_5_20;
;

%fitmodleavework(outcome=leavework, preds=&lpreds, set=2);

*add so2;
%LET lpreds = agein_cenaw agein_cenaw1 agein_cenaw2 agein_cenaw3 agein_cenaw4 agein_cenaw5 agein_cenaw6 agein_cenaw7
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
/*so2lt_ann_durdfu_lag1 so2md_ann_durdfu_lag1 so2hi_ann_durdfu_lag1*/ 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 cum_as_3_5 cum_as_5_20;
;
%fitmodleavework(outcome=leavework, preds=&lpreds, set=3);

*replace age;
%LET lpreds = agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
/*so2lt_ann_durdfu_lag1 so2md_ann_durdfu_lag1 so2hi_ann_durdfu_lag1*/ 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 cum_as_3_5 cum_as_5_20;
;
%fitmodleavework(outcome=leavework, preds=&lpreds, set=4);

*less exposure refinement;
%LET lpreds = agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
/*so2lt_ann_durdfu_lag1 so2md_ann_durdfu_lag1 so2hi_ann_durdfu_lag1*/ 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
 cum_as_2_5 cum_as_5_20;
;
%fitmodleavework(outcome=leavework, preds=&lpreds, set=5);

*less exposure refinement;
%LET lpreds = agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
/*so2lt_ann_durdfu_lag1 so2md_ann_durdfu_lag1 so2hi_ann_durdfu_lag1*/ 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
 cum_as_1_5 cum_as_5_20;
;
%fitmodleavework(outcome=leavework, preds=&lpreds, set=6);

*less exposure refinement, dob;
%LET lpreds = agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th
dob_cen dob_censq dob_cencu dob_cenqu dob_cen5th   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
/*so2lt_ann_durdfu_lag1 so2md_ann_durdfu_lag1 so2hi_ann_durdfu_lag1*/ 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
 cum_as_1_5 cum_as_5_20;
;
%fitmodleavework(outcome=leavework, preds=&lpreds, set=7);

*so2 cumulative;
%LET lpreds = agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th
dob_cen dob_censq dob_cencu dob_cenqu dob_cen5th   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
 /*cum_so2_score*/
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
 cum_as_1_5 cum_as_5_20;
;
%fitmodleavework(outcome=leavework, preds=&lpreds, set=8);

*take out most recent exposure
%LET lpreds = agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th
dob_cen dob_censq dob_cencu dob_cenqu dob_cen5th   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
 /*cum_so2_score*/
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
 cum_as_2_5 cum_as_5_20;
;
%fitmodleavework(outcome=leavework, preds=&lpreds, set=9);

*take out most recent exposure, 2
%LET lpreds = agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th
dob_cen dob_censq dob_cencu dob_cenqu dob_cen5th   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
 /*cum_so2_score*/
 cum_as_1_5 cum_as_5_20;
;
%fitmodleavework(outcome=leavework, preds=&lpreds, set=10);


*best model with hire age;
%LET lpreds = agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
hireage_cen
/*so2lt_ann_durdfu_lag1 so2md_ann_durdfu_lag1 so2hi_ann_durdfu_lag1*/ 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
 cum_as_1_5 cum_as_5_20;
;
%fitmodleavework(outcome=leavework, preds=&lpreds, set=11);

*best model with hire age;
%LET lpreds = agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
/*so2lt_ann_durdfu_lag1 so2md_ann_durdfu_lag1 so2hi_ann_durdfu_lag1*/ 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
 cum_as_1_5 cum_as_5_20;
;
%fitmodleavework(outcome=leavework, preds=&lpreds, set=12);

%LET lpreds = agein_cenaw agein_cenaw1 agein_cenaw2 agein_cenaw3 agein_cenaw4 agein_cenaw5 agein_cenaw6 agein_cenaw7
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
tot_aslt_ann_durbfu tot_asmd_ann_durbfu tot_ashi_ann_durbfu tot_asuk_ann_durbfu 
tot_so2lt_ann_durbfu tot_so2md_ann_durbfu tot_so2hi_ann_durbfu tot_so2uk_ann_durbfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 cum_as_3_5 cum_as_5_20;
;

%fitmodleavework(outcome=leavework, preds=&lpreds, set=13);

*;
%LET lpreds = agein_cenaw agein_cenaw1 agein_cenaw2 agein_cenaw3 agein_cenaw4 agein_cenaw5 agein_cenaw6 agein_cenaw7
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
tot_aslt_ann_durbfu tot_asmd_ann_durbfu tot_ashi_ann_durbfu tot_asuk_ann_durbfu 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 cum_as_3_5 cum_as_5_20;
;
%fitmodleavework(outcome=leavework, preds=&lpreds, set=14);

*;
%LET lpreds = agein_cenaw agein_cenaw1 agein_cenaw2 agein_cenaw3 agein_cenaw4 agein_cenaw5 agein_cenaw6 agein_cenaw7
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
cum_as_score_bfu
cum_so2_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 cum_as_3_5 cum_as_5_20;
;
%fitmodleavework(outcome=leavework, preds=&lpreds, set=15);

*;
%LET lpreds = agein_cenaw agein_cenaw1 agein_cenaw2 agein_cenaw3 agein_cenaw4 agein_cenaw5 agein_cenaw6 agein_cenaw7
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
cum_as_score_bfu
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 cum_as_3_5 cum_as_5_20;
;
%fitmodleavework(outcome=leavework, preds=&lpreds, set=16);

*;
%LET lpreds = agein_cenaw agein_cenaw1 agein_cenaw2 agein_cenaw3 agein_cenaw4 agein_cenaw5 agein_cenaw6 agein_cenaw7
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
tot_aslt_ann_durbfu tot_asmd_ann_durbfu tot_ashi_ann_durbfu tot_asuk_ann_durbfu 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
over65
 cum_as_3_5 cum_as_5_20;
;
%fitmodleavework(outcome=leavework, preds=&lpreds, set=17);

*;
%LET lpreds = agein_cenaw agein_cenaw1 agein_cenaw2 agein_cenaw3 agein_cenaw4 agein_cenaw5 agein_cenaw6 agein_cenaw7
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn
tot_aslt_ann_durbfu tot_asmd_ann_durbfu tot_ashi_ann_durbfu tot_asuk_ann_durbfu 
aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
over65
 cum_as_3_5 cum_as_5_20 cum_as_score_lag20;
;
%fitmodleavework(outcome=leavework, preds=&lpreds, set=18);



DATA mtcs.modcomp_leavework; SET modcompare;
RUN;

/*****************************************************************************************/
/********************** returning to work ************************************************/
/*****************************************************************************************/
/*****************************************************************************************/

%MACRO fitmodreturnwork(outcome=returnwork, preds=&rpreds, set=1);
ODS LISTING close;
%PUT model &set;
PROC LOGISTIC DATA = an DESCENDING;
 WHERE (activework=0 OR returnwork=1);
 MODEL &outcome = &preds;
 ODS OUTPUT fitstatistics = _fs (WHERE=(criterion="AIC"));
 ODS OUTPUT parameterestimates = _pe;
RUN;

PROC TRANSPOSE DATA = _pe(KEEP=variable estimate) OUT=_pet NAME=model ;ID variable;RUN;
DATA mod&set; MERGE _pet _fs;RUN;
%IF &set = 1 %THEN %DO;
 DATA modcompare; LENGTH model $32 criterion $6 InterceptOnly InterceptAndCovariates 8; SET mod&set; MODEL="model &set";
%END;
%IF &set NE 1 %THEN %DO;
  DATA mod&set; LENGTH model $32 criterion $6 InterceptOnly InterceptAndCovariates 8; SET mod&set; MODEL="model &set";;
  DATA modcompare; SET modcompare mod&set;
%END;
PROC SORT DATA = modcompare; BY InterceptAndCovariates; RUN;
ODS LISTING;
%MEND;


*refining spline variables;
DATA an;
 SET an;
 agein_cenow=agein_cen;
 dob_cenow=dob_cen;
RUN;
%DASPLINE_ak(agein_cenow, 
           nk=9, DATA=an(WHERE=(activework=0)), norm=2);
%DASPLINE_ak(dob_cenow  , 
           nk=8, DATA=an(WHERE=(activework=0)), norm=2);
DATA an;
 SET an;
  &_agein_cenow ;
  &_dob_cenow;
RUN;

*remove some more exposure refinement;
%LET rpreds = agein_cenow agein_cenow1 agein_cenow2 agein_cenow3 agein_cenow4 agein_cenow5 agein_cenow6 agein_cenow7
dob_cenow dob_cenow1 dob_cenow2 dob_cenow3 dob_cenow4 dob_cenow5 dob_cenow6   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu timesinceleavework usborn
 cum_as_1_5 cum_as_5_20;
;
%fitmodreturnwork(outcome=returnwork, preds=&rpreds, set=6);

*remove some more variables;
%LET rpreds = agein_cenow agein_cenow1 agein_cenow2 agein_cenow3 agein_cenow4 agein_cenow5 agein_cenow6 agein_cenow7
dob_cenow dob_cenow1 dob_cenow2 dob_cenow3 dob_cenow4 dob_cenow5 dob_cenow6   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu timesinceleavework 
 cum_as_1_5 cum_as_5_20;
;
%fitmodreturnwork(outcome=returnwork, preds=&rpreds, set=7);

*remove some more variables;
%LET rpreds = agein_cenow agein_cenow1 agein_cenow2 agein_cenow3 agein_cenow4 agein_cenow5 agein_cenow6 agein_cenow7
dob_cenow dob_cenow1 dob_cenow2 dob_cenow3 dob_cenow4 dob_cenow5 dob_cenow6   
cumtawdfu_lag1  cumtawbfu cumtawbfusq timesinceleavework 
 cum_as_1_5 cum_as_5_20;
;
%fitmodreturnwork(outcome=returnwork, preds=&rpreds, set=9);

*remove some more exposure refinement;
%LET rpreds = agein_cenow agein_cenow1 agein_cenow2 agein_cenow3 agein_cenow4 agein_cenow5 agein_cenow6 agein_cenow7
dob_cenow dob_cenow1 dob_cenow2 dob_cenow3 dob_cenow4 dob_cenow5 dob_cenow6   
tot_aslt_ann_durbfu tot_asmd_ann_durbfu tot_ashi_ann_durbfu tot_asuk_ann_durbfu 
tot_so2lt_ann_durbfu tot_so2md_ann_durbfu tot_so2hi_ann_durbfu tot_so2uk_ann_durbfu
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu timesinceleavework usborn
 cum_as_1_5 cum_as_5_20;
;
%fitmodreturnwork(outcome=returnwork, preds=&rpreds, set=13);

*remove some more variables;
%LET rpreds = agein_cenow agein_cenow1 agein_cenow2 agein_cenow3 agein_cenow4 agein_cenow5 agein_cenow6 agein_cenow7
dob_cenow dob_cenow1 dob_cenow2 dob_cenow3 dob_cenow4 dob_cenow5 dob_cenow6   
tot_aslt_ann_durbfu tot_asmd_ann_durbfu tot_ashi_ann_durbfu tot_asuk_ann_durbfu 
tot_so2lt_ann_durbfu tot_so2md_ann_durbfu tot_so2hi_ann_durbfu tot_so2uk_ann_durbfu
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu timesinceleavework 
 cum_as_1_5 cum_as_5_20;
;
%fitmodreturnwork(outcome=returnwork, preds=&rpreds, set=14);


*remove some more exposure refinement;
%LET rpreds = agein_cenow agein_cenow1 agein_cenow2 agein_cenow3 agein_cenow4 agein_cenow5 agein_cenow6 agein_cenow7
dob_cenow dob_cenow1 dob_cenow2 dob_cenow3 dob_cenow4 dob_cenow5 dob_cenow6   
tot_aslt_ann_durbfu tot_asmd_ann_durbfu tot_ashi_ann_durbfu tot_asuk_ann_durbfu 
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu timesinceleavework usborn
 cum_as_1_5 cum_as_5_20;
;
%fitmodreturnwork(outcome=returnwork, preds=&rpreds, set=15);

*remove some more variables;
%LET rpreds = agein_cenow agein_cenow1 agein_cenow2 agein_cenow3 agein_cenow4 agein_cenow5 agein_cenow6 agein_cenow7
dob_cenow dob_cenow1 dob_cenow2 dob_cenow3 dob_cenow4 dob_cenow5 dob_cenow6   
tot_aslt_ann_durbfu tot_asmd_ann_durbfu tot_ashi_ann_durbfu tot_asuk_ann_durbfu 
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu timesinceleavework 
 cum_as_1_5 cum_as_5_20;
;
%fitmodreturnwork(outcome=returnwork, preds=&rpreds, set=16);


*remove some more exposure refinement;
%LET rpreds = agein_cenow agein_cenow1 agein_cenow2 agein_cenow3 agein_cenow4 agein_cenow5 agein_cenow6 agein_cenow7
dob_cenow dob_cenow1 dob_cenow2 dob_cenow3 dob_cenow4 dob_cenow5 dob_cenow6   
cum_as_score_bfu
cum_so2_score_bfu
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu timesinceleavework usborn
 cum_as_1_5 cum_as_5_20;
;
%fitmodreturnwork(outcome=returnwork, preds=&rpreds, set=17);

*remove some more variables;
%LET rpreds = agein_cenow agein_cenow1 agein_cenow2 agein_cenow3 agein_cenow4 agein_cenow5 agein_cenow6 agein_cenow7
dob_cenow dob_cenow1 dob_cenow2 dob_cenow3 dob_cenow4 dob_cenow5 dob_cenow6   
cum_as_score_bfu
cum_so2_score_bfu
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu timesinceleavework 
 cum_as_1_5 cum_as_5_20;
;
%fitmodreturnwork(outcome=returnwork, preds=&rpreds, set=18);

*remove some more exposure refinement;
%LET rpreds = agein_cenow agein_cenow1 agein_cenow2 agein_cenow3 agein_cenow4 agein_cenow5 agein_cenow6 agein_cenow7
dob_cenow dob_cenow1 dob_cenow2 dob_cenow3 dob_cenow4 dob_cenow5 dob_cenow6   
cum_as_score_bfu
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu timesinceleavework usborn
 cum_as_1_5 cum_as_5_20;
;
%fitmodreturnwork(outcome=returnwork, preds=&rpreds, set=19);

*remove some more variables;
%LET rpreds = agein_cenow agein_cenow1 agein_cenow2 agein_cenow3 agein_cenow4 agein_cenow5 agein_cenow6 agein_cenow7
dob_cenow dob_cenow1 dob_cenow2 dob_cenow3 dob_cenow4 dob_cenow5 dob_cenow6   
cum_as_score_bfu
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu timesinceleavework 
 cum_as_1_5 cum_as_5_20;
;
%fitmodreturnwork(outcome=returnwork, preds=&rpreds, set=20);

%LET rpreds = agein_cenow agein_cenow1 agein_cenow2 agein_cenow3 agein_cenow4 agein_cenow5 agein_cenow6 agein_cenow7
dob_cenow dob_cenow1 dob_cenow2 dob_cenow3 dob_cenow4 dob_cenow5 dob_cenow6   
cum_as_score_bfu
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu 
timesinceleavework retired
 cum_as_1_5 cum_as_5_20;
;
%fitmodreturnwork(outcome=returnwork, preds=&rpreds, set=21);

%LET rpreds = agein_cenow agein_cenow1 agein_cenow2 agein_cenow3 agein_cenow4 agein_cenow5 agein_cenow6 agein_cenow7
dob_cenow dob_cenow1 dob_cenow2 dob_cenow3 dob_cenow4 dob_cenow5 dob_cenow6   
cum_as_score_bfu
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu 
timesinceleavework retired
 cum_as_1_5 cum_as_5_20 cum_as_score_lag20;
;
%fitmodreturnwork(outcome=returnwork, preds=&rpreds, set=21);


DATA mtcs.modcomp_returnwork; SET modcompare;
RUN;

/*****************************************************************************************/
/********************** arsenic exposure *************************************************/
/*****************************************************************************************/
/*****************************************************************************************/

%MACRO fitmodmultinom(outcome=as_ann_ordinal_nl_m_h, preds=&aspreds, set=1);
ODS LISTING close;
%PUT model &set;
PROC LOGISTIC DATA = an DESCENDING DESCENDING OUT=c_d(DROP=_:);
 WHERE (activework=1);
 CLASS &outcome;
 MODEL &outcome = &preds;
 ODS OUTPUT fitstatistics = _fs (WHERE=(criterion="AIC"));
 ODS OUTPUT parameterestimates = _pe;
RUN;
DATA _PE; LENGTH variable $32; SET _PE; variable = TRIM(TRIM(variable) || TRIM(PUT(classval0, 2.1)));RUN;

PROC TRANSPOSE DATA = _pe(KEEP=variable estimate) OUT=_pet NAME=model ;ID variable;RUN;
DATA mod&set; MERGE _pet _fs;RUN;
%IF &set = 1 %THEN %DO;
 DATA modcompare; LENGTH model $32 criterion $6 InterceptOnly InterceptAndCovariates 8; SET mod&set; MODEL="model &set";
%END;
%IF &set NE 1 %THEN %DO;
  DATA mod&set; LENGTH model $32 criterion $6 InterceptOnly InterceptAndCovariates 8; SET mod&set; MODEL="model &set";;
  DATA modcompare; SET modcompare mod&set;
%END;
PROC SORT DATA = modcompare; BY InterceptAndCovariates; RUN;
ODS LISTING;
%MEND;
%DASPLINE_ak( dob_cen, 
           nk=8, DATA=an, norm=2);

%DASPLINE_ak(agein_cen  , 
           nk=9, DATA=an, norm=2);
DATA an;
 SET an;
  &_agein_cen ;
  &_dob_cen;
RUN;

%LET aspreds = py 
agein_cen agein_cen1 agein_cen2 agein_cen3 agein_cen4 agein_cen5 agein_cen6 agein_cen7
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5 dob_cen6
dob_cen dob_cen1 dob_cen2 dob_cen3 dob_cen4 dob_cen5   
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu 
 al_1_5 al_5_20
;
%fitmodmultinom(outcome=as_ann_ordinal_nl_m_h, preds=&aspreds, set=1);

*redefining spline variables;
DATA an;
 SET an;
 agein_cenaw=agein_cen;
 dob_cenaw=dob_cen;
RUN;
%DASPLINE_ak(agein_cenaw, 
           nk=9, DATA=an(WHERE=(activework=1)), norm=2);
%DASPLINE_ak(dob_cenaw  , 
           nk=8, DATA=an(WHERE=(activework=1)), norm=2);
DATA an;
 SET an;
  &_agein_cenaw ;
  &_dob_cenaw;
RUN;
%LET aspreds = py 
agein_cenaw agein_cenaw1 agein_cenaw2 agein_cenaw3 agein_cenaw4 agein_cenaw5 agein_cenaw6 agein_cenaw7
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu 
 al_1_5 al_5_20
;
%fitmodmultinom(outcome=as_ann_ordinal_nl_m_h, preds=&aspreds, set=2);

*add time at work before follow up;
%LET aspreds = py 
agein_cenaw agein_cenaw1 agein_cenaw2 agein_cenaw3 agein_cenaw4 agein_cenaw5 agein_cenaw6 agein_cenaw7
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu  
 al_1_5 al_5_20
;
%fitmodmultinom(outcome=as_ann_ordinal_nl_m_h, preds=&aspreds, set=3);



*refine exposure;
%LET aspreds = py 
agein_cenaw agein_cenaw1 agein_cenaw2 agein_cenaw3 agein_cenaw4 agein_cenaw5 agein_cenaw6 agein_cenaw7
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu  
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%fitmodmultinom(outcome=as_ann_ordinal_nl_m_h, preds=&aspreds, set=4);

*add usborn;
%LET aspreds = py 
agein_cenaw agein_cenaw1 agein_cenaw2 agein_cenaw3 agein_cenaw4 agein_cenaw5 agein_cenaw6 agein_cenaw7
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%fitmodmultinom(outcome=as_ann_ordinal_nl_m_h, preds=&aspreds, set=5);


*different dob variables usborn;
%LET aspreds = py 
agein_cenaw agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%fitmodmultinom(outcome=as_ann_ordinal_nl_m_h, preds=&aspreds, set=6);



*add so2 exposure;
%LET aspreds = py 
agein_cenaw agein_cenaw1 agein_cenaw2 agein_cenaw3 agein_cenaw4 agein_cenaw5 agein_cenaw6 agein_cenaw7
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu  
/*so2lt_ann_durdfu_lag1 so2md_ann_durdfu_lag1 so2hi_ann_durdfu_lag1*/ 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%fitmodmultinom(outcome=as_ann_ordinal_nl_m_h, preds=&aspreds, set=7);

*add more so2 exposure;
%LET aspreds = py 
agein_cenaw agein_cenaw1 agein_cenaw2 agein_cenaw3 agein_cenaw4 agein_cenaw5 agein_cenaw6 agein_cenaw7
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu  
/*so2lt_ann_durdfu_lag1 so2md_ann_durdfu_lag1 so2hi_ann_durdfu_lag1*/ 
/*cum_so2_score_lag2*/ 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%fitmodmultinom(outcome=as_ann_ordinal_nl_m_h, preds=&aspreds, set=8);

*age at hire;
%LET aspreds = py 
agein_cenaw agein_cenaw1 agein_cenaw2 agein_cenaw3 agein_cenaw4 agein_cenaw5 agein_cenaw6 agein_cenaw7
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu  
hireage_cen 
/*so2lt_ann_durdfu_lag1 so2md_ann_durdfu_lag1 so2hi_ann_durdfu_lag1*/ 
/*cum_so2_score_lag2*/ 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%fitmodmultinom(outcome=as_ann_ordinal_nl_m_h, preds=&aspreds, set=9);

%LET aspreds = py 
agein_cenaw agein_cenaw1 agein_cenaw2 agein_cenaw3 agein_cenaw4 agein_cenaw5 agein_cenaw6 agein_cenaw7
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu  
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
/*so2lt_ann_durdfu_lag1 so2md_ann_durdfu_lag1 so2hi_ann_durdfu_lag1*/ 
/*cum_so2_score_lag2*/ 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%fitmodmultinom(outcome=as_ann_ordinal_nl_m_h, preds=&aspreds, set=10);

*different dob variables usborn;
%LET aspreds = py 
agein_cenaw agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn 
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%fitmodmultinom(outcome=as_ann_ordinal_nl_m_h, preds=&aspreds, set=11);

%LET aspreds = py 
agein_cenaw agein_cenaw1 agein_cenaw2 agein_cenaw3 agein_cenaw4 agein_cenaw5 agein_cenaw6 agein_cenaw7
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu  
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
tot_aslt_ann_durbfu tot_asmd_ann_durbfu tot_ashi_ann_durbfu tot_asuk_ann_durbfu 
tot_so2lt_ann_durbfu tot_so2md_ann_durbfu tot_so2hi_ann_durbfu tot_so2uk_ann_durbfu
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%fitmodmultinom(outcome=as_ann_ordinal_nl_m_h, preds=&aspreds, set=12);

%LET aspreds = py 
agein_cenaw agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn 
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
tot_aslt_ann_durbfu tot_asmd_ann_durbfu tot_ashi_ann_durbfu tot_asuk_ann_durbfu 
tot_so2lt_ann_durbfu tot_so2md_ann_durbfu tot_so2hi_ann_durbfu tot_so2uk_ann_durbfu
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%fitmodmultinom(outcome=as_ann_ordinal_nl_m_h, preds=&aspreds, set=13);

%LET aspreds = py 
agein_cenaw agein_cenaw1 agein_cenaw2 agein_cenaw3 agein_cenaw4 agein_cenaw5 agein_cenaw6 agein_cenaw7
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu  
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
tot_aslt_ann_durbfu tot_asmd_ann_durbfu tot_ashi_ann_durbfu tot_asuk_ann_durbfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%fitmodmultinom(outcome=as_ann_ordinal_nl_m_h, preds=&aspreds, set=14);

%LET aspreds = py 
agein_cenaw agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn 
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
tot_aslt_ann_durbfu tot_asmd_ann_durbfu tot_ashi_ann_durbfu tot_asuk_ann_durbfu 
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%fitmodmultinom(outcome=as_ann_ordinal_nl_m_h, preds=&aspreds, set=15);

%LET aspreds = py 
agein_cenaw agein_cenaw1 agein_cenaw2 agein_cenaw3 agein_cenaw4 agein_cenaw5 agein_cenaw6 agein_cenaw7
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu  
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
cum_as_score_bfu
cum_so2_score_bfu
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%fitmodmultinom(outcome=as_ann_ordinal_nl_m_h, preds=&aspreds, set=14);

%LET aspreds = py 
agein_cenaw agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn 
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
cum_as_score_bfu
cum_so2_score_bfu
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%fitmodmultinom(outcome=as_ann_ordinal_nl_m_h, preds=&aspreds, set=15);

%LET aspreds = py 
agein_cenaw agein_cenaw1 agein_cenaw2 agein_cenaw3 agein_cenaw4 agein_cenaw5 agein_cenaw6 agein_cenaw7
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu  
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
cum_as_score_bfu
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%fitmodmultinom(outcome=as_ann_ordinal_nl_m_h, preds=&aspreds, set=16);

%LET aspreds = py 
agein_cenaw agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn 
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
cum_as_score_bfu
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20
;
%fitmodmultinom(outcome=as_ann_ordinal_nl_m_h, preds=&aspreds, set=17);

%LET aspreds = py 
agein_cenaw agein_cen agein_censq agein_cencu agein_cenqu agein_cen5th
dob_cenaw dob_cenaw1 dob_cenaw2 dob_cenaw3 dob_cenaw4 dob_cenaw5 dob_cenaw6
cumtawdfu_lag1 cumtawdfu_lag1sq cumtawbfu cumtawbfusq cumtowdfu cumtowbfu usborn 
hireage_cen hireage_cen1 hireage_cen2 hireage_cen3
cum_as_score_bfu
cum_so2_score_bfu
aslt_ann_durdfu_lag1 asmd_ann_durdfu_lag1 ashi_ann_durdfu_lag1 
aslt_ann_durdfu_lag2 asmd_ann_durdfu_lag2 ashi_ann_durdfu_lag2 
 al_3_5 al_5_20 cum_as_score_lag20
;
%fitmodmultinom(outcome=as_ann_ordinal_nl_m_h, preds=&aspreds, set=18);

DATA mtcs.modcomp_multinomexp; SET modcompare;
RUN;

PROC PRINT DATA = mtcs.modcomp_allothercauses; 
 TITLE "all causes other than respiratory cancer";
 VAR model criterion interceptandcovariates;
PROC PRINT DATA = mtcs.modcomp_cvd; 
 TITLE "Cardiovascular disease";
 VAR model criterion interceptandcovariates;
PROC PRINT DATA = mtcs.modcomp_respcancer; 
 TITLE "respiratory cancer";
 VAR model criterion interceptandcovariates;
PROC PRINT DATA = mtcs.modcomp_leavework; 
 TITLE "leaving work";
 VAR model criterion interceptandcovariates;
PROC PRINT DATA = mtcs.modcomp_returnwork; 
 TITLE "returning to work";
 VAR model criterion interceptandcovariates;
PROC PRINT DATA = mtcs.modcomp_multinomexp;
 TITLE "Exposure model";
 VAR model criterion interceptandcovariates;
RUN;

OPTIONS NOSYMBOLGEN;

DM LOG "FILE Z:/EpiProjects/MT_copper_smelters/logs/sas/&progname.log REPLACE" CONTINUE;
DM OUT "FILE Z:/EpiProjects/MT_copper_smelters/output/sas/&progname.lst REPLACE" CONTINUE;
RUN; QUIT; RUN;


