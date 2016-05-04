*clear the log window and the output window;
DM LOG 'clear;' CONTINUE; DM OUT 'clear;' CONTINUE; 
/**********************************************************************************************************************
* Author: Alex Keil
* Program: mtcs_gformula_20140908.sas
* Date: Monday, September 8, 2014 at 2:00:36 PM
* Project: Anaconda copper smelter, arsenic exposures
* Tasks: Initial g-formula analysis of copper smelter data
* Data in: Z:/EpiProjects/MT_copper_smelters/data/mtcs_an02.sas7bdat
* Data out:
* Description: 
* Keywords:
* Released under the GNU General Public License: http://www.gnu.org/copyleft/gpl.html
*CHANGE LOG (aside from model selection):
* 4/7/15: changed macro functions to allow explicit interaction terms in the model macro variables
**********************************************************************************************************************/
OPTIONS MERGENOBY = warn NODATE NONUMBER LINESIZE = 120  PAGESIZE=80 SKIP = 2 FORMDLIM = '-' MPRINT NOCENTER;
OPTIONS FORMCHAR = "|----|+|---+=|-/\<>*";
%LET PROGNAME = mtcs_gformula_20140908.sas;
TITLE;
FOOTNOTE "&progname run at &systime on &sysdate";
/*
LIBNAME mtcs "Z:/EpiProjects/MT_copper_smelters/data";
LIBNAME gformula "Z:/EpiProjects/MT_copper_smelters/data/mcdata";
*/
%INCLUDE "Z:/Documents/macros/daspline_ak.sas";
%INCLUDE "Z:/Documents/macros/daspline.sas";
PROC FORMAT CNTLIN=mtcs.mtcs_formats;

%LET ds = mtcs.mtcs_an02;

/*
PROC DATASETS LIB=work KILL;QUIT;
%INCLUDE "Z:/EpiProjects/MT_copper_smelters/code/mtcs_import_20140828.sas";
PROC DATASETS LIB=work KILL;QUIT;
%INCLUDE "Z:/EpiProjects/MT_copper_smelters/code/mtcs_cleaning_20140828.sas";
PROC DATASETS LIB=work KILL;QUIT;
%INCLUDE "Z:/EpiProjects/MT_copper_smelters/code/mtcs_lagdata_201492.sas";
*/
********* BEGIN PROGRAMMING STATEMENTS ************************;
*PROC DATASETS LIB=work KILL;*QUIT;

%LET minage=18;
%LET maxage=90; *age at artificial censoring (in MC algorithm);
%LET mcobs = 50000;*Number of MC samples to take;

******************************************************************************************;
*step 0a - creating variables of interest;
******************************************************************************************;

DATA an;
 SET &ds(WHERE=(agestart>=&MINAGE AND ageout<=&MAXAGE));
 BY smid agein;
 IF first.smid THEN firstobs=1; ELSE firstobs=0;
 IF last.smid THEN lastobs=1; ELSE lastobs=0;

 *time weighted average for each work area;
 lambda=0.1; *or 1;
 lowc = .29; 
 midc = .58;
 hic = 11.3*lambda;

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
 cum_as_1_10 = cum_as_score_lag1-cum_as_score_lag10;
 cum_as_5_10 = cum_as_score_lag5-cum_as_score_lag10;
 cum_as_10_20 = cum_as_score_lag10-cum_as_score_lag20;;
 cum_as_5_20 = cum_as_score_lag5-cum_as_score_lag20;
 cum_so2_5_20 = cum_so2_score_lag5-cum_so2_score_lag20;

*interactions;
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


*age at exposure;
 RETAIN a_age1  a_age2 0;
 IF first.smid THEN DO;
  a_age1=0; a_age2=0;
 END;
 a_age1 = a_age1 + as_score*(agein<60);
 a_age2 = a_age2 + as_score*(60<=agein);

*polynomial or centered terms;
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

 caltime = (datein-'01jan1937'd)/(20*365.25);
 caltimesq = caltime*caltime;
 caltimecu = caltimesq*caltime;

*discrete time functions;
 age50 = agein>50;
 age70 = agein>70;
 cal50 = datein>'01jan1950'd;
 cal60 = datein>'01jan1960'd;
 call60 = datein<='01jan1960'd;
 cal70 = datein>'01jan1970'd;
 
 *log age functions;
 lage=log(agein);
 lagesq=lage*lage;
 lagecu=lage*lage*lage;


*simplified prior exposure;
 cum_as_score_bfu = lowc*tot_aslt_ann_durbfu + tot_asmd_ann_durbfu*midc + tot_ashi_ann_durbfu*hic;
 cum_so2_score_bfu = tot_so2lt_ann_durbfu + tot_so2md_ann_durbfu*2 + tot_so2hi_ann_durbfu*3;

 cum_as_score_bfusq = cum_as_score_bfu*cum_as_score_bfu;
 cum_so2_score_bfusq = cum_so2_score_bfu*cum_so2_score_bfu;

 RETAIN timesinceleavework ;
 IF FIRST.smid THEN DO; timesinceleavework=0;  END;
 IF leavework=1 THEN timesinceleavework=py;
 ELSE IF leavework=0 AND activework=1 AND returnwork=0 THEN timesinceleavework=0;
 ELSE timesinceleavework= timesinceleavework + py;

 inactivelag1 = (timesinceleavework>1);

 IF d_respcancer=1 OR d_cvd=1 OR d_allcause=0  THEN d_allothercauses=0;
 IF d_respcancer=0 AND d_cvd=0 AND d_allcause=1 THEN d_allothercauses=1;

 over65=(ageout>65);
 under65=(ageout<=65);
 under40=(ageout<40);

 *hired after study started?;
 incidenthire = (hiredate>'01jan1938'd);

 *average exposure intensity;
 %LET avg_int = cum_as_score*(cum_as_score/cumtawdfu);
 IF cumtawdfu>0 THEN avg_int = &avg_int;
 ELSE avg_int=0;
RUN;



PROC MEANS DATA = an;
 VAR agein;
 OUTPUT OUT = ai_cen MEAN=ageinmean STD=ageinstd;
DATA _null_; SET ai_cen; CALL SYMPUT("ageinmean", PUT(ageinmean, BEST9.)); CALL SYMPUT("ageinstd", PUT(ageinstd, BEST9.));
RUN;
******************************************************************************************;
*make spline variables;
******************************************************************************************;
DATA an;
 SET an;
  agein_cen = (agein-&ageinmean)/&ageinstd;
  agein_cen_aw=agein_cen;
  agein_cen_ow=agein_cen;
  dob_cen_aw=dob_cen;
  dob_cen_ow=dob_cen;
  caltime_aw=caltime;
  caltime_ow=caltime;

*IF hiredate>'01jan1938'd;

  %DASPLINE_ak(dob_cen, 
      nk=7, DATA=an, norm=2);
  %DASPLINE(hireage_cen , 
      nk=5, DATA=an, norm=2);
  %DASPLINE_ak(dob_cen_ow, 
      nk=7, DATA=an(WHERE=(activework=0)), norm=2);
  %DASPLINE_ak(dob_cen_aw, 
      nk=7, DATA=an(WHERE=(activework=1)), norm=2);

  %DASPLINE_ak(agein_cen, 
      nk=5, DATA=an, norm=2);
  %DASPLINE_ak(agein_cen_ow, 
      nk=5, DATA=an(WHERE=(activework=0)), norm=2);
  %DASPLINE_ak(agein_cen_aw, 
      nk=5, DATA=an(WHERE=(activework=1)), norm=2);

  %DASPLINE_ak(caltime, 
      nk=4, DATA=an, norm=2);
  %DASPLINE_ak(caltime_ow, 
      nk=4, DATA=an(WHERE=(activework=0)), norm=2);
  %DASPLINE_ak(caltime_aw, 
      nk=4, DATA=an(WHERE=(activework=1)), norm=2);


 *agecal intx;

OPTIONS SYMBOLGEN;
DATA an;
 SET an;
  &_agein_cen ;
  &_dob_cen;
  &_hireage_cen ;
  &_agein_cen_ow ;
  &_dob_cen_ow;
  &_agein_cen_aw ;
  &_dob_cen_aw;
  &_caltime ;
  &_caltime_aw ;
  &_caltime_ow;
RUN;
OPTIONS NOSYMBOLGEN;


/*NOTE FOR INTERACTION TERMS: terms must be in order in which main effects appear (i.e. a b a*b instad of a b b*a)*/
/*r code to generate
b1 = "agein_cen"
b2 = "caltime"
suf = ""
base1 <- paste0(b1, suf)
base2 <- paste0(b2,suf)
cat(gsub("0","",c(paste0(base1, 0:2), paste0(base2, 0:2),"\n",
 paste0(paste0(base1, 0:2), "*", base2, 0),"\n",
 paste0(paste0(base1, 0:2), "*", base2, 1),"\n",
 paste0(paste0(base1, 0:2), "*", base2, 2))))

*/

******************************************************************************************;
*step 0b - predictors for each model, ordered by assumed temporal order;
******************************************************************************************;

*leaving work;
%LET lpreds =
agein_cen_aw*over65 agein_cen_aw*under65
cumtawbfu cumtawbfu*cumtawbfu usborn 
cum_as_score_bfu
cumtawdfu_lag1 cumtawdfu_lag1*cumtawdfu_lag1
cum_as_1_5 cum_as_5_10 cum_as_10_20
;

*returning to work;
%LET rpreds =
agein_cen_ow agein_cen_ow1 agein_cen_ow2 agein_cen_ow3 caltime_ow 
agein_cen_ow*caltime_ow agein_cen_ow1*caltime_ow agein_cen_ow2*caltime_ow agein_cen_ow3*caltime_ow
cumtawbfu cumtawbfu*cumtawbfu usborn
cum_as_score_bfu 
over65 
cumtawdfu_lag1 cumtawdfu_lag1*cumtawdfu_lag1
cum_as_1_5 cum_as_5_10 cum_as_10_20
/**/
;
/*last date of tracked employment found by:
proc sql outobs=10;
select dateout from work.an where leavework=1 order by -dateout ;
run;
*/

*arsenic exposure;
%LET aspreds =
agein_cen agein_cen1 agein_cen2 agein_cen3 caltime 
agein_cen*caltime agein_cen1*caltime agein_cen2*caltime  agein_cen3*caltime
cumtawbfu cumtawbfu*cumtawbfu usborn 
cum_as_score_bfu  
cumtawdfu_lag1 cumtawdfu_lag1*cumtawdfu_lag1
cum_as_1_5 cum_as_5_10 cum_as_10_20
/*anl_1_5 anl_1_5*anl_1_5 anl_5_20 anl_5_20*anl_5_20 al_1_5 al_1_5*al_1_5 al_5_20 al_5_20*al_5_20*/
;


*death from other causes;
%LET dpreds =
agein_cen agein_cen1 agein_cen2 agein_cen3 caltime
agein_cen*caltime agein_cen1*caltime agein_cen2*caltime agein_cen3*caltime
cumtawbfu cumtawbfu*cumtawbfu usborn
cum_as_score_bfu 
inactivelag1 activework
cumtawdfu_lag1 cumtawdfu_lag1*cumtawdfu_lag1
cum_as_2_5 cum_as_5_10 cum_as_10_20
/*anl_1_5 anl_1_5*anl_1_5 anl_5_20 anl_5_20*anl_5_20 al_1_5 al_1_5*al_1_5 al_5_20 al_5_20*al_5_20*/
;

*death from respiratory cancer;
%LET drpreds =
agein_cen agein_cen1 agein_cen2 agein_cen3 caltime caltime*caltime
agein_cen*caltime agein_cen1*caltime agein_cen2*caltime agein_cen3*caltime 
cumtawbfu cumtawbfu*cumtawbfu usborn
cum_as_score_bfu 
inactivelag1 activework
cumtawdfu_lag1 cumtawdfu_lag1*cumtawdfu_lag1
cum_as_2_5 cum_as_5_10 cum_as_10_20
/*anl_1_5 anl_1_5*anl_1_5 anl_5_20 anl_5_20*anl_5_20 al_1_5 al_1_5*al_1_5 al_5_20 al_5_20*al_5_20*/
;

*death from cvd;
%LET dcpreds =
agein_cen agein_cen1 agein_cen2 agein_cen3 caltime caltime*caltime
agein_cen*caltime agein_cen1*caltime agein_cen2*caltime agein_cen3*caltime
cumtawbfu cumtawbfu*cumtawbfu usborn 
inactivelag1 activework
cumtawdfu_lag1 cumtawdfu_lag1*cumtawdfu_lag1
cum_as_2_5 cum_as_5_10 cum_as_10_20
/*anl_1_5 anl_1_5*anl_1_5 anl_5_20 anl_5_20*anl_5_20 al_1_5 al_1_5*al_1_5 al_5_20 al_5_20*al_5_20*/
;

*remove asterixes from product terms;
%LET allpreds =  %SYSFUNC(TRANSTRN( &aspreds &lpreds &rpreds &dpreds &drpreds &dcpreds, * , %STR( )) );
%MACRO showpreds();%PUT &allpreds;%MEND;%SHOWPREDS();


******************************************************************************************;
*step 1 - modeling censoring, death, exposure, covariates;
******************************************************************************************;
PROC LOGISTIC DATA = an DESCENDING OUT=c_d(DROP=_:);
 TITLE 'Pooled logistic model for other causes of death';
 MODEL d_allothercauses = &dpreds;
PROC LOGISTIC DATA = an DESCENDING OUT=c_dr(DROP=_:); 
 TITLE 'Pooled logistic model for respiratory cancer death ';
 MODEL d_respcancer = &drpreds;
PROC LOGISTIC DATA = an DESCENDING OUT=c_dc(DROP=_:); 
 TITLE 'Pooled logistic model for cardiovascular death ';
 MODEL d_cvd = &dcpreds;
RUN;
PROC LOGISTIC DATA = an DESCENDING OUT=c_l(DROP=_:); 
 TITLE 'Pooled logistic model for leaving work';
 WHERE leavework=1 OR (activework=1 AND returnwork=0) AND NOT firstobs AND dateout<='31dec1978'd;*last doe is 29dec1978, so this allows one full year for the 'leavework' to register;
 MODEL leavework = &lpreds;
PROC LOGISTIC DATA = an DESCENDING OUT=c_r(DROP=_:); 
 TITLE 'Pooled logistic model for returning to work';
  WHERE returnwork=1 OR (activework=0 AND leavework=0) AND NOT firstobs AND dateout<='29dec1978'd;*last doe is 29dec1978, so this allows one full year for the 'leavework' to register;
 MODEL returnwork = &rpreds;
RUN;

*exposure models;
PROC LOGISTIC DATA = an DESCENDING OUT=c_a(DROP=_:);
 TITLE "Ordinal logistic model for arsenic exposure (ref=0)";
 CLASS as_ann_ordinal_nl_m_h / PARAM=glm ;
 WHERE activework=1;
 MODEL as_ann_ordinal_nl_m_h =  &ASPREDS;* LINK=glogit;
RUN;
PROC LOGISTIC DATA = an DESCENDING;
 WHERE activework=1;
 TITLE "Ordinary logistic high/md vs. light exposure";
 MODEL as_ann_binary =  &ASPREDS;
RUN;


*macro handling of coefficient values to streamline model selection;
%MACRO count();
%GLOBAL rmod lmod dmod drmod dcmod cmod amod nr nl nd ndr ndc nc na nd_cox dmod_cox;
%LET i=1; %LET rmod=_r1; ;%DO %UNTIL(%QSCAN(&rpreds, %EVAL(&i), " ")=);
   %LET rmod=&rmod + _r%EVAL(&i+1) * %QSCAN(&rpreds, %EVAL(&i), " "); %LET i = %EVAL(&i+1); 
 %END;%LET nr = &i;
%LET i=1; %LET lmod=_l1; ;%DO %UNTIL(%QSCAN(&lpreds, %EVAL(&i), " ")=);
   %LET lmod=&lmod + _l%EVAL(&i+1) * %QSCAN(&lpreds, %EVAL(&i), " "); %LET i = %EVAL(&i+1); 
 %END;%LET nl = &i;
%LET i=1; %LET dmod=_d1; %DO %UNTIL(%QSCAN(&dpreds, %EVAL(&i), " ")=);
   %LET dmod=&dmod + _d%EVAL(&i+1) * %QSCAN(&dpreds, %EVAL(&i), " ");  %LET i = %EVAL(&i+1); 
%END;%LET nd = &i;
%LET i=1; %LET drmod=_dr1; %DO %UNTIL(%QSCAN(&drpreds, %EVAL(&i), " ")=);
   %LET drmod=&drmod + _dr%EVAL(&i+1) * %QSCAN(&drpreds, %EVAL(&i), " ");  %LET i = %EVAL(&i+1); 
%END;%LET ndr = &i;
%LET i=1; %LET dcmod=_dc1; %DO %UNTIL(%QSCAN(&dcpreds, %EVAL(&i), " ")=);
   %LET dcmod=&dcmod + _dc%EVAL(&i+1) * %QSCAN(&dcpreds, %EVAL(&i), " ");  %LET i = %EVAL(&i+1); 
%END;%LET ndc = &i;

%LET i=1; %LET amod=_a1 + _a2; %DO %UNTIL(%QSCAN(&aspreds, %EVAL(&i), " ")=);
   %LET amod=&amod + _a%EVAL(&i+2) * %QSCAN(&aspreds, %EVAL(&i), " ");  %LET i = %EVAL(&i+1); 
%END;%LET na = &i;

%MEND;
%COUNT;
*check log for what the data generating models look like;
DATA _NULL_;
 nd=&ND;
 nl=&NL; 
 na=&Na;
 nr=&Nr;
 nDr=&Ndr;
 nDc=&Ndc;
 d = "&DMOD";
 dR = "&DrMOD";
 dc = "&DcMOD";
 l = "&LMOD";
 a = "&aMOD";
 r = "&rMOD";
 spc="";
 PUT na a;PUT spc;
 PUT nd d;PUT spc;
 PUT ndr dr;PUT spc;
 PUT ndc dc;PUT spc;
 PUT nl l;PUT spc;
 PUT nr r;PUT spc;
 PUT spc;
 m="%SYSFUNC(TRANSTRN( &Lpreds , * ,))";PUT spc;
 put m;
run;

DATA c_r2; SET c_r;
 ARRAY coefs[*] intercept %SYSFUNC(TRANSTRN( &rpreds , * ,) ); ARRAY _r[&nr];
 DO j = 1 TO DIM(coefs); _r[j] = coefs[j];END;
 KEEP _r:;
DATA c_l2; SET c_l;
 ARRAY coefs[*] intercept %SYSFUNC(TRANSTRN( &lpreds , * ,) ); ARRAY _l[&nl];
 DO j = 1 TO DIM(coefs); _l[j] = coefs[j];END;
 KEEP _l:;
DATA c_d2; SET c_d;
 ARRAY coefs[*] intercept %SYSFUNC(TRANSTRN( &dpreds , * ,) );ARRAY _d[&nd];
 DO j = 1 TO DIM(coefs);_d[j] = coefs[j];END;
 KEEP _d:;
DATA c_a2; SET c_a;
 ARRAY coefs[*] intercept_1 intercept_2 %SYSFUNC(TRANSTRN( &aspreds , * ,) );ARRAY _a[%EVAL(&na+1)];
 DO j = 1 TO DIM(coefs); _a[j] = coefs[j];END;
 KEEP _a:;
RUN;

DATA c_dr2; SET c_dr;
 ARRAY coefs[*] intercept %SYSFUNC(TRANSTRN( &DRpreds , * ,) );ARRAY _dr[%EVAL(&ndr)];
 DO j = 1 TO DIM(coefs); _dr[j] = coefs[j];END;
 KEEP _dr:;
RUN;
DATA c_dc2; SET c_dc;
 ARRAY coefs[*] intercept %SYSFUNC(TRANSTRN( &DCpreds , * ,) );ARRAY _dc[%EVAL(&ndc)];
 DO j = 1 TO DIM(coefs); _dc[j] = coefs[j];END;
 KEEP _dc:;
RUN;


******************************************************************************************;
*step 2 - Monte carlo sampling;
******************************************************************************************;

 DATA anfirst;
  SET an;
  BY smid agein;
  IF first.smid;
  KEEP smid agein agestart &allpreds y_respcancer start_fu;

PROC SURVEYSELECT DATA=anfirst /*SEED=864527*/ OUT=mcsample METHOD=URS N=&mcobs OUTHITS;
RUN;


DATA sim_cohort;
  SET mcsample();
  IF _n_=1 THEN SET c_r2;
  IF _n_=1 THEN SET c_l2;
  IF _n_=1 THEN SET c_d2;
  IF _n_=1 THEN SET c_dr2;
  IF _n_=1 THEN SET c_dc2;
  IF _n_=1 THEN SET c_a2;
RUN;

PROC MEANS DATA = sim_cohort NOPRINT;
 TITLE 'check for missing data';
 OUTPUT OUT=anymiss(DROP=_TYPE_ _FREQ_) NMISS= / AUTONAME;
RUN;
PROC TRANSPOSE DATA = anymiss OUT=anymiss2;RUN;
PROC PRINT DATA = anymiss2; WHERE col1=1;RUN;
*step 3 - simulate cohort through time;
PROC FCMP OUTLIB=work.misc.addyrs;
 FUNCTION addyrs(startdate, years);
  floor = INTNX('YEAR', startdate, years, "sameday");
  days = (years-FLOOR(years))*(INTNX('YEAR', floor, 1, 'sameday')-floor);
  enddate = floor+days;
 RETURN(enddate);
 ENDSUB;
RUN;
OPTIONS CMPLIB=work.misc;
OPTIONS symbolgen;
%LET postvars = agein datein  d_respcancer d_cvd d_allothercauses cum_as_score activework usborn cumpy py activework  leavework returnwork;
DATA sim_natcourse (KEEP=agein ageout datein dateout as: cum: activework leavework returnwork d_: intervention &allpreds)
     sim_always (KEEP=agein ageout datein dateout as: cum: activework leavework returnwork d_: intervention &allpreds)
     sim_never (KEEP=agein ageout datein dateout as: cum: activework leavework returnwork d_: intervention &allpreds)
     sim_nc_changes (KEEP=smid agein_alt ageout datein_alt dateout done cum: activework d_: intervention leavework returnwork &postvars)
     sim_al_changes (KEEP=smid agein_alt ageout datein_alt dateout done cum: activework d_: intervention leavework returnwork &postvars)
     sim_ne_changes (KEEP=smid agein_alt ageout datein_alt dateout done cum: activework d_: intervention leavework returnwork &postvars)
     sim_lo_changes (KEEP=smid agein_alt ageout datein_alt dateout done cum: activework d_: intervention leavework returnwork &postvars)
     sim_med_changes (KEEP=smid agein_alt ageout datein_alt dateout done cum: activework d_: intervention leavework returnwork &postvars)
     ; 
 LENGTH intervention 3 smid agestart agein ageout datestart datein dateout done as_score activework leavework returnwork d_allothercauses d_respcancer 8;
 SET sim_cohort;
 CALL STREAMINIT(12322);
 *DO intervention = 1 TO 5;
 DO intervention = 5 TO 1 BY -1;
     ctr=1;
     FORMAT datestart datein_alt datein dateout MMDDYY10.;
      *a - draw l(0) from f(l(0));
      *done by sampling from cohort;

      *initial levels of time varying variables;
      oldagestart=agestart;
      oldedatestart = start_fu;
      *agestart=ROUND(agestart);*start them at nearest even year to reduce variability in tail end;
      agestart=(agestart);*or not;
      agein_alt = agestart; *counting in dataset with changepoints for work status;
      *datestart = ADDYRS(start_fu, agestart-oldagestart);
      datestart = start_fu;
      datein_alt = datestart;
      agein=agestart; 
      datein=datestart;
      done=0;
      cumtawdfu_lag1=0;
      cumtawdfu_lag1sq=0;
      cumtawdfu=0;
      cumtowdfu=0;
      activework=1;
      leavework=0;
      timesinceleavework=0;
      cumpy=0;
      cum_as_1_5=0; 
      cum_as_5_20=0;
      cum_as_5_10 =0;
      cum_as_10_20=0;
      cum_as_1_10=0;
      anl_1_5=0;
      anl_5_20=0;
      anl_5_10=0;
      anl_10_20=0;
      anl_lag20=0; 
      al=0; 
      al_1_5=0; 
      al_5_20=0;
      al_5_10=0;
      al_10_20=0;
      cum_as_score_lag20=0;
      cum_as_score=0;
      returnwork=0;
      returnwork_lag1=0;
      inactivelag1=0;
      aslt_ann_durdfu=0; asmd_ann_durdfu=0; ashi_ann_durdfu=0; 
      aslt_ann_durdfu_lag1=0; asmd_ann_durdfu_lag1=0; ashi_ann_durdfu_lag1=0; 
      aslt_ann_durdfu_lag2=0;  asmd_ann_durdfu_lag2=0;  ashi_ann_durdfu_lag2=0; 
      lastdone=0;
      *time weighted average for each work area;
      lowc = .29; 
      midc = .58;
      hic = 1.13;
      *age at exposure;
      a_age1=0; a_age2=0; 

      *initialize cumulative exposure lagged variables at 0;
      ARRAY _cumas[20] _TEMPORARY_; *for lags;
      DO i = 1 TO 20; _cumas[i] = 0; END;

      &_dob_cen_aw;
      &_dob_cen_ow;

     /*========== main programming loop over time ===========*/
      DO WHILE(done=0);
       ageout=MIN(agein+1, &maxage);
       over65=(ageout>65);
       under65=(ageout<=65);
       under40=(ageout<40);
       dateout = ADDYRS(datein, ageout-agein);
   
       *enforce proper censoring at the end of follow-up or age 90;
       IF dateout>'31dec1989'd THEN DO;
         sub = dateout-'31dec1989'd;
         dateout = '31dec1989'd;
         ageout = agein + sub/365;
       END;
   
       py = ageout-agein;
       cumpy = cumpy + py;
       caltime = (datein-'01jan1937'd)/(20*365.25);
       caltime_aw=caltime;
       caltime_ow=caltime;
       caltimesq=caltime*caltime;
       caltimecu=caltimesq*caltime;
       lage=log(agein);
       lagesq=lage*lage;
       lagecu=lage*lage*lage;
   
       *discrete time functions;
       cal50 = datein>'01jan1950'd;
       cal60 = datein>'01jan1960'd;
       call60 = datein<='01jan1960'd;
       cal70 = datein>'01jan1970'd;

       /* time variables */
       agein_cen = (agein-&ageinmean)/&ageinstd;*derived from active work time;
       agein_cen_aw=agein_cen;
       dob_cen_aw=dob_cen;
       agein_cen_ow=agein_cen;
       dob_cen_ow=dob_cen;
       agein_censq  = agein_cen*agein_cen;
       agein_cencu = agein_cen*agein_censq;
       agein_cenqu = agein_censq*agein_censq;
       agein_cen5th = agein_censq*agein_cencu;
       &_agein_cen ; *make spline variables using knots defined above;
       &_agein_cen_ow ;
       &_agein_cen_aw ;
       &_caltime; *make spline variables using knots defined above;
       &_caltime_ow ;
       &_caltime_aw ;

       *b - recursively draw l, a for treatment regime g;
  
      /*========== employment (part of the dynamic intervention) ===========*/

      *Enforce actual dates of observed employment history in data;
      IF dateout <= '29dec1978'd THEN DO;
  
       *leaving employment;
       p_l = 1/(1+exp(-(&lmod)));
       IF activework=1 AND ctr>1 THEN DO;
        timesinceleavework=0;
        timesinceleaveworksq=0;
        timesinceleaveworkcu=0;
        *enforce actual end of exposure monitoring;
        leavework = RAND('BERNOULLI', p_l);
        *consider there is no employment time if individual leaves during person period (mimics the way the variable is created in MTCS data);     
        cumtawdfu = cumtawdfu + (1-leavework); 
        IF leavework THEN activework=0; *leave work at the beginning of the period;
       END;
       *sets leavework=0, for example, if for continuing observations after 1/jan/1979;
       ELSE IF activework=0 OR datein<=ADDYRS(datestart, 1) THEN leavework = 0;
 
       *returning to employment after a leave;
       p_r = 1/(1+exp(-(&rmod)));
       IF activework=0 AND ctr>1 AND leavework = 0 THEN DO;
        /* */
        timesinceleavework=timesinceleavework+1;
        timesinceleaveworksq=timesinceleavework*timesinceleavework;
        timesinceleaveworkcu=timesinceleaveworksq*timesinceleavework;
        returnwork = RAND('BERNOULLI', p_r);
        IF returnwork THEN activework=1; 
       END;
       ELSE IF activework=1 OR datein<=ADDYRS(datestart, 1) OR leavework THEN returnwork=0;
      END; *IF dateout <= '29dec1978'd;
      ELSE IF dateout >  '29dec1978'd AND activework=1 THEN DO;
       leavework=1; activework=0; returnwork=0;
      END;
      ELSE IF dateout >  '29dec1978'd AND activework=0 THEN DO;
         leavework=0; returnwork=0;
      END;
     inactivelag1 = (timesinceleavework>1);


      /*========== exposure ===========*/
       /* intervention variables */
       *probabilities of exposure;
       p_a2 =  1/(1+exp(-(MIN(700,&amod - _a1)))); *probability as_score=3;
       p_a1 = 1/(1+exp(-(MIN(700,&amod - _a2)))) - p_a2; *probability as_score=2;
       p_a0 = 1-p_a1-p_a2; *probability arsenic is light at work, as_score=1;

       IF activework=0 THEN as_score=0;
       ELSE IF activework=1 THEN DO;
        *DYNAMIC INTERVENTION: natural course;
        IF intervention = 1 THEN as_score = RAND('table', p_a0, p_a1, p_a2); *yields values 1, 2, 3;
        *DYNAMIC INTERVENTION: if at work, expose to high levels of arsenic;
        IF intervention = 2 THEN as_score=3;
        *DYNAMIC INTERVENTION: if at work, remain unexposed;
        IF intervention = 3 THEN as_score=0;
        *DYNAMIC INTERVENTION: if at work, remain exposed to low levels of arsenic;
        IF intervention = 4 THEN as_score=1;
        *DYNAMIC INTERVENTION: if at work, remain to medium levels of arsenic;
        IF intervention = 5 THEN as_score=2;
       END;*if activework=1;
       aslt_ann_durdfu = (as_score=1);
       asmd_ann_durdfu = (as_score=2);
       ashi_ann_durdfu = (as_score=3);

       *convert as_score into quantitative estimate;
       IF as_score = 1 THEN as_score = lowc;
       ELSE IF as_score = 2 THEN as_score = midc;
       ELSE IF as_score = 3 THEN as_score = hic;

       DO i = 20 TO 2 BY -1; 
        _cumas[i]=_cumas[i-1]; *lag everything one year;
       END;
       _cumas[1]=cum_as_score; *one year lagged cumulative exposure score;
       cum_as_score = as_score + cum_as_score; *current cumulative exposure score;

       as_score_lag1 = _cumas[1]-_cumas[2];
       as_score_lag2 = _cumas[2]-_cumas[3];
       al = as_score*activework;
 
       *lagged exposures using temporary array;  
       cum_as_score_lag1 = _cumas[1];
       cum_as_score_lag2 = _cumas[2];

       cum_as_1_5 =(_cumas[1]-_cumas[5]);
       cum_as_2_5 =(_cumas[2]-_cumas[5]);
       cum_as_3_5 =(_cumas[3]-_cumas[5]);
       cum_as_5_10  = (_cumas[5]-_cumas[10]);
       cum_as_1_10 =  (_cumas[1]-_cumas[10]);
       cum_as_10_20 = (_cumas[10]-_cumas[20]);
       cum_as_5_20 = (_cumas[5]-_cumas[20]);
       cum_as_score_lag20 = _cumas[20];
       anl_1_5=(cum_as_1_5)*(1-activework);
       anl_2_5=(cum_as_2_5)*(1-activework);
       anl_3_5=(cum_as_3_5)*(1-activework);
       anl_5_10=(cum_as_5_10)*(1-activework);
       anl_5_20=(cum_as_5_20)*(1-activework);
       anl_10_20=(cum_as_10_20)*(1-activework);
       anl_5_20=(cum_as_5_20)*(1-activework);
       anl_lag20=cum_as_score_lag20*(1-activework); 
       al_1_5=(cum_as_1_5)*activework; 
       al_2_5=(cum_as_2_5)*activework; 
       al_3_5=(cum_as_3_5)*activework; 
       al_5_20=(cum_as_5_20)*activework;
       al_5_10=(cum_as_5_10)*activework;
       al_10_20=(cum_as_10_20)*activework;

       IF cumtawdfu>0 THEN avg_int = &avg_int;
       ELSE avg_int=0;

       *age at exposure;
       a_age1 = a_age1 + as_score*(agein<60);
       a_age2 = a_age2 + as_score*(60<=agein);


       /*========== health outcomes ===========*/
       /* death from other causes     */
       p_d = 1/(1+exp(-(&dmod)));
       IF done=0 THEN DO;
        d_allothercauses = RAND('BERNOULLI', p_d);
        IF d_allothercauses THEN done=1; 
       END;
       ELSE d_allothercauses=0;

       /*death from cardiovascular disease*/
       p_dc = 1/(1+exp(-(&dcmod)));
       IF done=0 THEN DO;
        d_cvd = RAND('BERNOULLI', p_dc);
        IF d_cvd THEN done=1; 
       END;
       ELSE d_cvd=0; 

       /*death from respiratory cancer*/
       p_dr = 1/(1+exp(-(&drmod)));
       IF done=0 THEN DO;
        d_respcancer = RAND('BERNOULLI', p_dr);
        IF d_respcancer THEN done=1; 
       END;
       ELSE d_respcancer=0; 

       /*all cause*/
       d_allcause = SUM(d_respcancer, d_cvd, d_allothercauses);

       /*administrative censoring at age 90*/
       IF ageout>=&maxage OR dateout>='31dec1989'd THEN done=1;
   
       *break ties;
       /*
       IF done = 1 THEN DO;
         IF d_allcause THEN jitter = RAND('UNIFORM')*0.01;
         ageout = ageout-jitter;
         dateout = dateout-jitter/365.25;
       END;
        */
       /*administrative censoring at age 90 or artificial end date to emulate Tacoma Smelter*/
       *IF ageout>=&maxage OR dateout>'31dec1962'd THEN done=1;

       /*========== output datasets ===========*/
       *full person period data;
       IF intervention = 1 THEN OUTPUT sim_natcourse;
       ELSE IF intervention = 2 THEN OUTPUT sim_always;
       ELSE IF intervention = 3 THEN OUTPUT sim_never;
       *lower footprint person period data (only major changes recorded, varying time period length);
       IF leavework=1 OR returnwork=1 OR done=1 THEN DO; 
        IF intervention = 1 THEN OUTPUT sim_nc_changes ;
        ELSE IF intervention = 2 THEN OUTPUT sim_al_changes ;
        ELSE IF intervention = 3 THEN OUTPUT sim_ne_changes;
        ELSE IF intervention = 4 THEN OUTPUT sim_lo_changes;
        ELSE IF intervention = 5 THEN OUTPUT sim_med_changes;
        agein_alt = ageout;
        datein_alt = dateout;
       END;

       *lagged variables;
       ctr = ctr + 1;
       cumtawdfu_lag1 = cumtawdfu;
       cumtawdfu_lag1sq = cumtawdfu_lag1*cumtawdfu_lag1;
       agein=ageout;
       datein=dateout;
       returnwork_lag1=returnwork;
       aslt_ann_durdfu_lag2=aslt_ann_durdfu_lag1;  
       asmd_ann_durdfu_lag2=asmd_ann_durdfu_lag1;  
       ashi_ann_durdfu_lag2=ashi_ann_durdfu_lag1; 
       aslt_ann_durdfu_lag1=aslt_ann_durdfu; 
       asmd_ann_durdfu_lag1=asmd_ann_durdfu; 
       ashi_ann_durdfu_lag1=ashi_ann_durdfu; 
       lastdone=done; 
      END;*DO WHILE (done=0);
    /*========== end of main programming loop over time ===========*/
 END; *intervention = 1 to 5;
RUN;
OPTIONS nosymbolgen;


*exporting data for survival curve plotting in R;
DATA anlast(KEEP=smid agein_alt ageout d_allcause d_respcancer d_allothercauses d_cvd leavework returnwork activework dateout datein_alt start_fu cum_as_score usborn)
;
LENGTH smid agein_alt  ageout start_fu datein_alt dateout 8;
 SET an;
 BY smid ageout;
 RETAIN agein_alt datein_alt;
 FORMAT datein_alt MMDDYY10.;
 IF first.smid THEN DO;
   agein_alt=agestart;
   datein_alt=start_fu;
 END;
 IF last.smid OR leavework OR returnwork THEN DO; 
  OUTPUT;
  agein_alt=ageout;
  datein_alt=dateout;
 END;
RUN;
/*
PROC EXPORT DATA = anlast
 OUTFILE ="Z:/EpiProjects/MT_copper_smelters/output/GFORMULA_kmpics/gformula_observed.csv" DBMS=csv REPLACE; RUN;
PROC EXPORT DATA = sim_nc_changes 
 OUTFILE ="Z:/EpiProjects/MT_copper_smelters/output/GFORMULA_kmpics/gformula_natcourse.csv" DBMS=csv REPLACE; RUN;
PROC EXPORT DATA = sim_ne_changes
 OUTFILE ="Z:/EpiProjects/MT_copper_smelters/output/GFORMULA_kmpics/gformula_no_exposure_at_work.csv" DBMS=csv REPLACE; RUN;
PROC EXPORT DATA = sim_al_changes
 OUTFILE ="Z:/EpiProjects/MT_copper_smelters/output/GFORMULA_kmpics/gformula_hi_exposure_at_work.csv" DBMS=csv REPLACE; RUN;
*/
DATA gformula.obschanges; SET anlast;
DATA gformula.natcourse; SET sim_nc_changes;
DATA gformula.noexposure; SET sim_ne_changes;
DATA gformula.hiexposure; SET sim_al_changes;
DATA gformula.loexposure; SET sim_lo_changes;
DATA gformula.medexposure; SET sim_med_changes;
RUN;

/*
*checking models in simulated data;
PROC LOGISTIC DATA = sim_natcourse DESCENDING OUT=gc_d(DROP=_:);
 TITLE 'Pooled logistic model for other causes of death (weight estimation denominator)';
 MODEL d_allothercauses = &dpreds;
PROC LOGISTIC DATA = sim_natcourse DESCENDING OUT=gc_dr(DROP=_:); 
 TITLE 'Pooled logistic model for respiratory cancer death ';
 MODEL d_respcancer = &drpreds;
PROC LOGISTIC DATA = sim_natcourse DESCENDING OUT=gc_dc(DROP=_:); 
 TITLE 'Pooled logistic model for cardiovascular disease death ';
 MODEL d_cvd = &dcpreds;
PROC LOGISTIC DATA = sim_natcourse DESCENDING OUT=gc_l(DROP=_:); 
 TITLE 'Pooled logistic model for leaving work';
 WHERE leavework=1 OR (activework=1 AND returnwork=0) AND '01jan1939'd<dateout<='31dec1978'd;;
 MODEL leavework = &lpreds;
PROC LOGISTIC DATA = sim_natcourse DESCENDING OUT=gc_r(DROP=_:); 
 TITLE 'Pooled logistic model for returning to work';
  WHERE returnwork=1 OR (activework=0 AND leavework=0) AND '01jan1939'd<dateout<='31dec1978'd;;
 MODEL returnwork = &rpreds;
RUN;
PROC LOGISTIC DATA = sim_natcourse DESCENDING OUT=gc_a(DROP=_:);
 TITLE "Ordinal logistic model for arsenic exposure (ref=0)";
 CLASS as_score / PARAM=glm ;
 WHERE activework=1;
 MODEL as_score =  &ASPREDS;* LINK=glogit;
RUN;


PROC MEANS DATA = an NOLABELS N MEAN  SUM STD P50 P25 P75 MAXDEC=5 FW=6;
 TITLE "observed data";
 VAR  agein datein d_respcancer d_cvd d_allothercauses cum_as_score tawdfu usborn cumpy py activework leavework returnwork;
PROC MEANS DATA = sim_natcourse  NOLABELS N MEAN  SUM STD P50 P25 P75 MAXDEC=5 FW=6;
 TITLE "simulated data - natural course";
 VAR agein datein  d_respcancer d_cvd d_allothercauses cum_as_score activework usborn cumpy activework  leavework returnwork; 
PROC MEANS DATA = sim_always  NOLABELS N MEAN  SUM  P50 P25 P75 MAXDEC=5 FW=6;
 TITLE "simulated data - exposed to high levels at work";
 VAR agein datein  d_respcancer d_cvd d_allothercauses cum_as_score activework usborn cumpy activework  leavework returnwork; 
PROC MEANS DATA = sim_never  NOLABELS N MEAN  SUM  P50 P25 P75 MAXDEC=5 FW=6;
 TITLE "simulated data - never exposed";
 VAR agein datein d_respcancer d_cvd d_allothercauses cum_as_score activework usborn cumpy  activework  leavework returnwork; 
RUN;
*/

DM LOG "FILE Z:/EpiProjects/MT_copper_smelters/logs/sas/&progname.log REPLACE" CONTINUE;
DM OUT "FILE Z:/EpiProjects/MT_copper_smelters/output/sas/&progname.lst REPLACE" CONTINUE;

RUN;QUIT;RUN;
/*DM ODSRESULTS 'clear;' CONTINUE; *clear ODS generated datasets;*/
