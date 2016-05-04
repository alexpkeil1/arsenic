*clear the log window and the output window;
DM LOG 'clear;' CONTINUE; DM OUT 'clear;' CONTINUE; 
/**********************************************************************************************************************
* Author: Alex Keil
* Program: mtcs_table1_20141017.sas
* Date: Friday, October 17, 2014 at 4:31:36 PM
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
%LET PROGNAME =	mtcs_table1_20141017;
TITLE;
FOOTNOTE "&progname run at &systime on &sysdate";

LIBNAME mtcs "Z:/EpiProjects/MT_copper_smelters/data";
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

RETAIN cum_as_score cum_so2_score cum_as_score_lag1 cum_so2_score_lag1 cum_as_score_lag2 cum_as_score_lag3 cum_so2_score_lag2 
        cum_as_score_lag5 cum_so2_score_lag5 cum_as_score_lag10 cum_so2_score_lag10 cum_as_score_lag20 cum_so2_score_lag20;

 ARRAY anns[*] as_score so2_score as_score_lag1 so2_score_lag1 as_score_lag2 as_score_lag3 so2_score_lag2 
        as_score_lag5 so2_score_lag5 as_score_lag10 so2_score_lag10 as_score_lag20 so2_score_lag20;

 ARRAY cums[*] cum_as_score cum_so2_score cum_as_score_lag1 cum_so2_score_lag1 cum_as_score_lag2 cum_as_score_lag3 cum_so2_score_lag2 
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
 cum_as_5_10 = cum_as_score_lag5-cum_as_score_lag10;
 *cum_so2_5_10 = cum_so2_score_lag5-cum_so2_score_lag10;;
 cum_as_10_20 = cum_as_score_lag10-cum_as_score_lag20;;
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
 anl_5_10 = cum_as_5_10*(1-activework);
 anl_10_20 = cum_as_10_20*(1-activework);
 anl_lag20 = cum_as_score_lag20*(1-activework);
 al = as_score*(activework);
 al_1_5 = cum_as_1_5*(activework);
 al_2_5 = cum_as_2_5*(activework);
 al_3_5 = cum_as_3_5*(activework);
 al_5_20 = cum_as_5_20*(activework);
 al_5_10 = cum_as_5_10*(activework);
 al_10_20 = cum_as_10_20*(activework);

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
*simplified prior exposure;
 cum_as_score_bfu = lowc*tot_aslt_ann_durbfu + tot_asmd_ann_durbfu*midc + tot_ashi_ann_durbfu*hic;
 cum_so2_score_bfu = tot_so2lt_ann_durbfu + tot_so2md_ann_durbfu*2 + tot_so2hi_ann_durbfu*3;

 RETAIN timesinceleavework retired 0;
 IF FIRST.smid THEN DO; timesinceleavework=0; retired=0; END;
 IF leavework=1 THEN timesinceleavework=py;
 ELSE IF leavework=0 AND activework=1 AND returnwork=0 THEN timesinceleavework=0;
 ELSE timesinceleavework= timesinceleavework + py;
 IF ageout>60 AND leavework THEN retired=1;

 IF d_respcancer=1 OR d_cvd=1 OR d_allcause=0  THEN d_allothercauses=0;
 IF d_respcancer=0 AND d_cvd=0 AND d_allcause=1 THEN d_allothercauses=1;
;

caltime = (YEAR(datein)-1950)/20;
over65=(ageout>65);
RETAIN retired;
IF first.smid THEN retired=0;
ELSE IF over65 AND leavework THEN retired=1;
*IF ageout<100.5 AND 1938<=YEAR(hiredate)<1948;
IF ageout<=90;
%LET age_ex = cum_as_score_lag1*(agein>65);
%LET age_ex2 = cum_as_score_lag1*(agein>75);
age_ex = &age_ex;
age_ex2 = &age_ex2;

age_ex_smooth = cum_as_score_lag1*(agein_cen);
incidenthire = (hiredate>'01jan1938'd);

%LET avg_int = cum_as_score*(cum_as_score/cumtawdfu);
IF cumtawdfu>0 THEN avg_int = &avg_int;
ELSE avg_int=0;
age_years = ROUND(agein);
date_years = YEAR(datein);
RUN;

DATA dg;
 SET mtcs.mtcs_dg01;
 agedlo = YRDIF(dob, dlo, "AGE");
RUN;

 


*exposure quantiles for plotting;
PROC MEANS DATA = an NOPRINT ; 
 CLASS date_years;
 WHERE activework=1;
 VAR cum_as_score as_score;
 OUTPUT OUT=mtcs.mtcs_expcentiles_yr P50= P75= P90= P95= P99= SUM= MEAN= /AUTONAME;
RUN;

PROC MEANS DATA = an NOPRINT;
 CLASS age_years;
 WHERE activework=1;
 VAR cum_as_score as_score;
 OUTPUT OUT=mtcs.mtcs_expcentiles_age P50= P75= P90= P95= P99= SUM= MEAN= /AUTONAME;
RUN;



DATA anfirst; 
 SET an;
 BY smid agein;
 IF first.smid;
 if cum_as_score_bfu>0 THEN exposedbfu=1; ELSE exposedbfu=0;
DATA anlast; 
 SET an;
 BY smid agein;
 IF last.smid;
PROC MEANS DATA = anfirst N SUM MEAN MEDIAN p25 p75;
 TITLE "variable distributions at first observation";
 VAR agein datein hiredate usborn cumtawbfu ;
RUN;


PROC MEANS DATA = an N SUM MEAN MEDIAN p25 p75;
 TITLE "variable distributions over all person time";
 VAR agein hiredate datein usborn cumtawbfu tawdfu cum_as_score py;
RUN;

PROC MEANS DATA = an MAX;
 VAR datein;
 WHERE as_score>0;
RUN;


*n, % of categorical variables at baseline;
PROC FREQ DATA = anfirst;
 TABLES usborn ;
RUN;

*n, % at end of follow up;
PROC MEANS DATA = anlast N SUM MEAN;
 TITLE "last observations";
 VAR d_allcause d_allothercauses d_respcancer d_cvd d_cd d_achd d_cbvd d_pvd d_othercirc c_admin / LIST;
RUN;

*continuous variables at baseline;
PROC MEANS DATA = anfirst N SUM MEAN MEDIAN p25 p75 NOLABEL FW=6;
 TITLE "First observations";
 VAR agein datein hiredate dob exposedbfu cum_as_score;
RUN;
PROC MEANS DATA = anfirst N SUM MEAN MEDIAN p25 p75;
 TITLE "cum. AS score before follow up, exposed only";
WHERE cum_as_score_bfu>0;
 VAR cum_as_score_bfu;
RUN;


*continuous variables at end of follow-up/death;
PROC MEANS DATA = anlast N SUM MEAN MEDIAN p25 p75 NOLABEL FW=6;
 TITLE "last observations";
 VAR  ageout dateout cumtawbfu cumtaw cumtawdfu cum_as_score  cumpy termage hireage ale afe;
RUN;

PROC MEANS DATA = an N SUM MEAN  NOLABEL FW=6;
 TITLE "outcomes, total and rates";
 VAR  d_:;
RUN;
PROC MEANS DATA = anlast N SUM MEAN  NOLABEL FW=6;
 TITLE "outcomes, total and risks";
 VAR  d_:;
RUN;

RUN;QUIT;RUN;
/*DM ODSRESULTS 'clear;' CONTINUE; *clear ODS generated datasets;*/
DM "LOG; FILE Z:/EpiProjects/MT_copper_smelters/logs/sas/&progname..log REPLACE";
DM "OUT; FILE Z:/EpiProjects/MT_copper_smelters/output/sas/&progname..lst REPLACE";

