/**********************************************************************************************************************
* Author: Alex Keil
* Program: mtcs_cleaning_20140828.sas
* Date: Thursday, August 28, 2014 at 9:44:22 PM
* Project:
* Tasks: importing, cleaning data, creating analytic variables
* Data in:  (raw text files with arsenic data given by NCI)
* Data out:
* Description: uses data created by mtcs_split_data_20140901.sh to create sas datasets
* Released under the GNU General Public License: http://www.gnu.org/copyleft/gpl.html
**********************************************************************************************************************/
*clear the log window and the output window;
DM LOG 'clear;' CONTINUE; DM OUT 'clear;' CONTINUE; 
OPTIONS MERGENOBY = warn NODATE NONUMBER LINESIZE = 120  PAGESIZE=80 SKIP = 2 FORMDLIM = '-' MPRINT NOCENTER;
OPTIONS FORMCHAR = '|----|+|---+=|-/\<>*';

%INCLUDE "Z:/Documents/macros/daspline.sas";
LIBNAME mtcs "Z:/EpiProjects/MT_copper_smelters/data";

PROC CONTENTS DATA = dg; TITLE "Demographic data";
PROC PRINT DATA = dg (OBS=10);
PROC MEANS DATA = dg NOPRINT;VAR dlvs dlo;OUTPUT OUT=max MAX=dlvs dlo; 
PROC PRINT DATA = max; FORMAT dlvs dlo mmddyy10.; LABEL dlvs ="Max. observed time of death"; VAR dlvs dlo;
RUN;
PROC CONTENTS DATA = ex; TITLE "Exposure data";
PROC PRINT DATA = ex (FIRSTOBS=100 OBS=120);
RUN;


DATA ex (DROP=h1-h8);
 SET mtcs.mtcs_ex01;
 BY smid age;
  *Lubin's exposure metrics;
 *unknown exposures not included in dose metric, but included in tabulated analyses;
 ds01 = aslt*0.29 + asmd*0.58 + ashi*1.13;
 ds10 = aslt*0.29 + asmd*0.58 + ashi*11.3;

 *annual exposures;
 RETAIN h1 h2 h3 h4 h5 h6 h7 h8 h9 0;
 IF first.smid THEN DO; h1=0;h2=0;h3=0;h4=0;h5=0;h6=0;h7=0;h8=0; h9=0; END;
 aslt_ann_dur = aslt-h1;
 asmd_ann_dur = asmd-h2;
 ashi_ann_dur = ashi-h3;
 asuk_ann_dur = asuk-h4;
 so2lt_ann_dur = so2lt-h5;
 so2md_ann_dur = so2md-h6;
 so2hi_ann_dur = so2hi-h7;
 so2uk_ann_dur = so2uk-h8;
 h1=aslt;h2=asmd;h3=ashi;h4=asuk;
 h5=so2lt;h6=so2md;h7=so2hi;h8=so2uk;

 
 timeatwork = empdur-h9;
 h9=empdur;
 timeoffwork=1-timeatwork;

PROC MEANS DATA = dg NOPRINT;
  VAR dob hiredate;
  OUTPUT OUT = std MEAN= STD= / AUTONAME;

DATA dg (DROP= chg _icd );
 SET mtcs.mtcs_dg01;
 yob = YEAR(dob);
 yoh = YEAR(hiredate);

 *approximately standardized variables;
 dob_cen=(dob-'04jan1910'd)/'27nov1975'd;
 hiredate_cen=(hiredate-'09jul1938'd)/'01apr1974'd;

 *person years at risk;
 totpy = YRDIF(start_fu,dlo, 'ACT/ACT');

 *hertz-picciotto et al 2000 control for age and year of hire;
 *Lubin 2000 cross classifies by age, calendar year (5 year increments), age at hire [year of birth, time since termination included 'as needed'];
 *Lubin also stratified by current employment to address the outcome 'causing the retirement';

 *birth cohort;
 /*
Variable       Minimum       Maximum          Mean        Median      5th Pctl     10th Pctl     25th Pctl     50th Pctl
------------------------------------------------------------------------------------------------------------------------
yob            1853.00       1938.00       1909.52       1912.00       1879.00       1886.00       1900.00       1912.00
------------------------------------------------------------------------------------------------------------------------

Variable     75th Pctl       90th Pctl       95th Pctl
------------------------------------------------------
yob            1922.00         1928.00         1931.00
------------------------------------------------------
*/
 *cut points: 1880, 1890, 1900, 1910, 1920, 1930;
 birthcohort6 = (yob>1880/*referent*/)+(yob>1890)+(yob>1900)+(yob>1910)+(yob>1920)+(yob>1930);
 birthcohort9 = (yob>1880/*referent*/)+(yob>1890)+(yob>1900)+(yob>1905)+(yob>1910)+(yob>1915)+(yob>1920)+(yob>1925)+(yob>1930);
 *year of hire;
/*
Variable       Minimum       Maximum          Mean        Median      5th Pctl     10th Pctl     25th Pctl     50th Pctl
------------------------------------------------------------------------------------------------------------------------
yoh            1884.00       1955.00       1938.07       1942.00       1908.00       1916.00       1929.00       1942.00
------------------------------------------------------------------------------------------------------------------------

Variable     75th Pctl       90th Pctl       95th Pctl
------------------------------------------------------
yoh            1949.00         1953.00         1954.00
------------------------------------------------------
*/
  *cut points: 1910, 1920, 1930, 1940, 1950;
  hirecohort5 = (yoh>1910/*referent*/)+(yoh>1920)+(yoh>1930)+(yoh>1940)+(yoh>1950)+(yoh>1955);
  hirecohort7 = (yoh>1910/*referent*/)+(yoh>1920)+(yoh>1925)+(yoh>1935)+(yoh>1940)+(yoh>1945)+(yoh>1950)+(yoh>1955);


 
*cause of death;
*   vstat = 1   alive
        2   alive as of 12/31/89, died after with DC
        3   alive as of 12/31/89, died after without DC
        4   died before 12/31/89, with DC
        5   died before 12/31/89, without DC
        6   unknown status; *assumed dead by lubin if over 90 years old, reassigned a 7 (assumed dead);
IF vstat IN(1,2,3,6) AND dob <= '31dec1899'd THEN vstat=7; *typo in Lubin 2000 table - actually births before 1900, not 1990; 
*should revisit for main analysis - could censor individuals at 90 years of age - this adds 81 deaths exactly at age 90;

y_allcause=0;
IF vstat IN(4,5,7) THEN y_allcause=1; *only counting deaths that occured before 12/31/89;

*SPECIFIC CAUSES OF DEATH;
*code from Jay Lubin to convert ICD-6 to ICD-8;
_icd = icd3;
odate = YEAR(dlo);
chg = 0;
IF .z<odate<1964 AND 190<_icd<192 THEN _icd=172 ; * skin;
IF .z<odate<1964 AND _icd=177 THEN _icd=185 ; * prostate;
IF .z<odate<1964 AND _icd=181 THEN _icd=188 ; * bladder;
IF .z<odate<1964 AND _icd=180 THEN _icd=189 ; * kidney;
IF .z<odate<1964 AND 340<=_icd<400 THEN _icd=320 ; * nerv sys/sense organs;
IF .z<odate<1964 AND _icd=260 THEN DO;_icd=250;chg=1;END; * diabetes mellitus;
IF .z<odate<1964 AND 420<=_icd<423 THEN DO;_icd=410;chg=1;END; *arterios AND CHD;
IF .z<odate<1964 AND 330<=_icd<335 THEN DO;_icd=430;chg=1;END; *vasc lesions CNS;
IF .z<odate<1964 AND 490<=_icd<494 THEN DO;_icd=480;chg=1;END; *pneumonia;
IF .z<odate<1964 AND _icd=581 THEN DO;_icd=571;chg=1;END; * cirrhosis;
IF .z<odate<1964 AND chg=0 AND 240<=_icd<290 THEN _icd=240 ; * allergic;
IF .z<odate<1964 AND chg=0 AND 400<=_icd<470 THEN _icd=390 ; *circ dis-arter+vas-CNS;
IF .z<odate<1964 AND chg=0 AND 470<=_icd<528 THEN _icd=460 ; * NMRD;
IF .z<odate<1964 AND chg=0 AND 530<=_icd<590 THEN _icd=520 ; * dis digest sys;
icd3 = _icd ;


y_respcancer=0;
 IF y_allcause=1 AND 160<=ICD3<=164 THEN y_respcancer=1;
y_lungcancer=0;
 IF y_allcause=1 AND 162<=ICD3<=163 THEN y_lungcancer=1;

*icd8 codes from hertz-picciotto 2000;
y_cd=0;*circulatory disease: 390-458;
 IF y_allcause=1 AND 390<=ICD3<=458 THEN y_cd=1;
 LABEL y_cd ="Circulatory disease (390<=ICD<=458)";
y_cvd=0;*cardiovascular icd8 codes 410-414, 420-429;
 IF y_allcause=1 AND (410<=ICD3<=414 OR 420<=ICD3<=429) THEN y_cvd=1;
 LABEL y_cvd ="Cardiovascular disease (410<=ICD<=414 OR 420<=ICD<=429)";
y_achd=0;*arteriosclerosis and CHD icd8 codes 410-414, 420-429;
 IF y_allcause=1 AND (410<=ICD3<=414) THEN y_achd=1;
 LABEL y_achd ="Arteriosclerosis and CHD (410<=ICD<=414)";
y_cbvd=0;*cerebrovascular icd8 codes 430-438;
 IF y_allcause=1 AND 430<=ICD3<=438 THEN y_cbvd=1;
 LABEL y_cbvd ="Cerebrovascular disease (430<=ICD<=438)";
y_pvd=0; *peripheral vascular disease icd8 codes 440-448;
 IF y_allcause=1 AND 440<=ICD3<=448 THEN y_pvd=1;
 LABEL y_pvd ="Peripheral vascular disease (440<=ICD<=448)";
y_othercirc=0; *icd8 codes 448-458;
 IF y_allcause=1 AND 448<=ICD3<=458 THEN y_othercirc=1;
 LABEL y_othercirc ="Other circulatory disease (448<=ICD<=458)";

 *admin censoring, loss to follow-up;
ltfu=0;
 IF vstat IN(1,2,3,6) AND dlo < '31dec1990'd THEN ltfu=1; *admin censoring date not quite right as given in paper;
 LABEL ltfu="Lost to follow-up";
admincens=0;
IF ltfu=0 THEN admincens = 1-y_allcause;
 LABEL admincens= "Administratively censored (31Dec1989)";


PROC FREQ DATA = dg;
 TITLE "Vital status, Specific causes of death (cross check with Lubin 2000)";
 TABLE vstat y_: ltfu*admincens*y_allcause / LIST;
RUN;

PROC FCMP OUTLIB=work.misc.addyrs;
 FUNCTION addyrs(startdate, years);
  floor = INTNX('YEAR', startdate, years, "sameday");
  days = (years-FLOOR(years))*(INTNX('YEAR', floor, 1, 'sameday')-floor);
  enddate = floor+days;
 RETURN(enddate);
 ENDSUB;
RUN;
OPTIONS CMPLIB=work.misc;

DATA an1;
LENGTH smid agein ageout datein dateout 8;
MERGE dg(DROP=asex so2ex dlvs icd) ex(DROP=cumas cumso2 maxas maxso2); 
 *MERGE dg(KEEP=smid dob hiredate start_fu dlo termdate y_allcause) ex(KEEP=smid age aslt asmd ashi asuk empdur) ; 
 BY smid;
 agein=age;
 *back-calculate dates at person-period changes;
 *this seems to add a bit of fuzz to the data versus strict calculation from dates = max 0.005 py difference per id;
 datein=addyrs(dob, agein); 
 agestop=YRDIF(dob,dlo, 'ACT/ACT');
 ageout=MIN(age+1, agestop);
 agestart=YRDIF(dob, start_fu);
 dateout=addyrs(dob, ageout);
 FORMAT datein dateout MMDDYY10.;

 *fix time off work for person periods in which employment starts;
 *assume that there is no time off work in first record;
 *no way to know if early missing exposure is due to late start or to missed work;
 IF dateout<hiredate THEN timeoffwork=0;
 ELSE IF datein<hiredate<dateout THEN timeoffwork = MAX(0,YRDIF(hiredate, dateout)-timeatwork);
 ELSE IF dateout=hiredate THEN timeoffwork=0;
 IF datein>termdate THEN timeoffwork=0;
 ELSE IF datein<termdate<dateout THEN timeoffwork = MAX(0,YRDIF(datein, termdate)-timeatwork);
 ELSE IF datein=termdate THEN timeoffwork=0;

 *split up individual records between followed and unfollowed person-time;
 *rationale: eliminate immortal person-time (equal to 1.5% of person time);
  *age handled continuously in g-formula and will already need to account for person time in each record - no real added complexity;
 markfix=0;
 IF datein<start_fu<dateout THEN DO;
 markfix=1;
   temp1=dateout;
   temp2=ageout;
   dateout = start_fu;
   ageout = YRDIF(dob, start_fu);
   timeatwork = timeatwork*(ageout-agein);
   timeoffwork = timeoffwork*(ageout-agein);
   OUTPUT;
   agein = ageout;
   ageout=temp2;
   datein = start_fu;
   dateout=temp1;
   timeatwork = timeatwork*(ageout-agein);
   timeoffwork = timeoffwork*(ageout-agein);

 END;
 OUTPUT;
RUN;
DATA an (DROP = aslt asmd ashi asuk _pfut);
 LENGTH smid agein ageout datein dateout py cumpy totpy taw cumtaw timeoffwork cumtow agestop 8 d_allcause d_respcancer d_lungcancer d_cd d_cvd d_achd d_cbvd d_pvd d_othercirc c_ltfu c_admin 3;
 SET an1;
 BY smid;
 *person time at risk;
 IF dateout < start_fu THEN py=0;
 ELSE py = MAX(0,MIN(YRDIF(start_fu, dateout), YRDIF(datein, dateout)));
 py1=MAX(1,ageout-agestart);

 RETAIN cumpy;
 IF first.smid THEN cumpy=0;
 cumpy=cumpy+py;

 *time at work;
 IF dateout < hiredate OR datein > termdate THEN taw=0;
 ELSE taw = MAX(0,MIN(YRDIF(hiredate, dateout), YRDIF(datein, termdate), YRDIF(datein, dateout), timeatwork));
 IF taw>0 THEN anywork=1; ELSE anywork=0;
 anywork_time=anywork*(ageout-agein);
 RETAIN cumtaw cumtow;
 IF first.smid THEN DO; cumtaw=0; cumtow=0; END;
 cumtaw=cumtaw+taw;
 cumtow=cumtow+timeoffwork;

 *fix exposure values for split observations (unless split occurs at hire date);
 IF markfix AND start_fu NE hiredate THEN DO;
  aslt_ann_dur = aslt_ann_dur*(ageout-agein);
  asmd_ann_dur=asmd_ann_dur*(ageout-agein);
  ashi_ann_dur=ashi_ann_dur*(ageout-agein);
  asuk_ann_dur=asuk_ann_dur*(ageout-agein);
  so2lt_ann_dur=so2lt_ann_dur*(ageout-agein);
  so2md_ann_dur=so2md_ann_dur*(ageout-agein);
  so2hi_ann_dur=so2hi_ann_dur*(ageout-agein);
  so2uk_ann_dur=so2uk_ann_dur*(ageout-agein);
 END;
 *time at work, exposure during or before follow-up only;
 IF datein>=start_fu THEN DO;
 *person periods during follow-up;
  tawdfu=taw;
  tawbfu=0;
  towbfu=0;
  aslt_ann_durdfu = aslt_ann_dur;
  asmd_ann_durdfu = asmd_ann_dur;
  ashi_ann_durdfu = ashi_ann_dur;
  asuk_ann_durdfu = asuk_ann_dur;
  aslt_ann_durbfu = 0;
  asmd_ann_durbfu = 0;
  ashi_ann_durbfu = 0;
  asuk_ann_durbfu = 0;
  so2lt_ann_durdfu = so2lt_ann_dur;
  so2md_ann_durdfu = so2md_ann_dur;
  so2hi_ann_durdfu = so2hi_ann_dur;
  so2uk_ann_durdfu = so2uk_ann_dur;
  so2lt_ann_durbfu = 0;
  so2md_ann_durbfu = 0;
  so2hi_ann_durbfu = 0;
  so2uk_ann_durbfu = 0; END;
 ELSE IF dateout<=start_fu THEN DO;
 *person periods before follow-up;
  tawdfu=0;
  tawbfu=taw;
  towbfu=timeoffwork;
  aslt_ann_durdfu = 0;
  asmd_ann_durdfu = 0;
  ashi_ann_durdfu = 0;
  asuk_ann_durdfu = 0;
  aslt_ann_durbfu = aslt_ann_dur;
  asmd_ann_durbfu = asmd_ann_dur;
  ashi_ann_durbfu = ashi_ann_dur;
  asuk_ann_durbfu = asuk_ann_dur;
  so2lt_ann_durdfu = 0;
  so2md_ann_durdfu = 0;
  so2hi_ann_durdfu = 0;
  so2uk_ann_durdfu = 0;
  so2lt_ann_durbfu = so2lt_ann_dur;
  so2md_ann_durbfu = so2md_ann_dur;
  so2hi_ann_durbfu = so2hi_ann_dur;
  so2uk_ann_durbfu = so2uk_ann_dur;
 END;
 ELSE IF datein<start_fu<dateout THEN DO;
  *person periods in which follow-up starts;
  tawdfu = MIN(YRDIF(start_fu, dateout), YRDIF(hiredate, termdate), timeatwork);
  tawbfu = taw-tawdfu;
  towdfu = timeoffwork;
  towbfu = timeoffwork-towdfu;
  *get proportion of exposed time that occured during follow-up, multiply by recorded exposure;
  *yields linear interpolation of exposure during follow-up;
  IF hiredate<datein OR start_fu<=hiredate THEN _pfut=1;
  ELSE IF datein<hiredate<dateout THEN _pfut = (taw-py)/taw;
  aslt_ann_durdfu = aslt_ann_dur*_pfut;
  asmd_ann_durdfu = asmd_ann_dur*_pfut;
  ashi_ann_durdfu = ashi_ann_dur*_pfut;
  asuk_ann_durdfu = asuk_ann_dur*_pfut;
  aslt_ann_durbfu = aslt_ann_dur*(1-_pfut);
  asmd_ann_durbfu = asmd_ann_dur*(1-_pfut);
  ashi_ann_durbfu = ashi_ann_dur*(1-_pfut);
  asuk_ann_durbfu = asuk_ann_dur*(1-_pfut);
  so2lt_ann_durdfu = so2lt_ann_dur*_pfut;
  so2md_ann_durdfu = so2md_ann_dur*_pfut;
  so2hi_ann_durdfu = so2hi_ann_dur*_pfut;
  so2uk_ann_durdfu = so2uk_ann_dur*_pfut;
  so2lt_ann_durbfu = so2lt_ann_dur*(1-_pfut);
  so2md_ann_durbfu = so2md_ann_dur*(1-_pfut);
  so2hi_ann_durbfu = so2hi_ann_dur*(1-_pfut);
  so2uk_ann_durbfu = so2uk_ann_dur*(1-_pfut);
 END;
 RETAIN cumtawdfu;
 IF first.smid THEN cumtawdfu=0;
 cumtawdfu=cumtawdfu+tawdfu;



 *time specific causes of death;
 ARRAY y[*] y_allcause y_respcancer y_lungcancer y_cd y_cvd y_achd y_cbvd y_pvd y_othercirc ltfu admincens;
 ARRAY d[*] d_allcause d_respcancer d_lungcancer d_cd d_cvd d_achd d_cbvd d_pvd d_othercirc c_ltfu c_admin;
 IF agestop>ageout THEN DO;
  DO i = 1 TO DIM(y);
   d[i]=0;
  END;
 END;
 ELSE DO;
  DO i = 1 TO DIM(y);
   d[i]=y[i];
  END;
 END;
 IF ageout>=agein;

*add observations if dlo-dob > 88 years;
 IF agestop > 88 AND ageout=88 THEN DO ;
  OUTPUT ; 
  DO WHILE (ageout < agestop);
  agein=ageout;
  ageout=MIN(agein+1, agestop);
  *back-calculate dates at person-period changes;
  *this seems to add a bit of fuzz to the data versus strict calculation from dates = max 0.005 py difference per id;
  datein=addyrs(dob, agein); 
  dateout=addyrs(dob, ageout);

 *person time at risk;
 IF dateout < start_fu THEN py=0;
 ELSE py = MAX(0,MIN(YRDIF(start_fu, dateout), YRDIF(datein, dateout)));

 cumpy=cumpy+py;
 *time at work;
 IF dateout < hiredate OR datein > termdate THEN taw=0;
 ELSE taw = MAX(0,MIN(YRDIF(hiredate, dateout), YRDIF(datein, termdate), YRDIF(datein, dateout)));
 IF taw>0 THEN anywork=1; ELSE anywork=0;
 IF first.smid THEN cumtaw=0;
 cumtaw=cumtaw+taw;



 *time specific causes of death;
 IF agestop>ageout THEN DO;
  DO i = 1 TO DIM(y);
   d[i]=0;
  END;
 END;
 ELSE DO;
  DO i = 1 TO DIM(y);
   d[i]=y[i];
  END;
 END;
 OUTPUT ;
 END;
 END;
 ELSE OUTPUT ;

*rounding some values to eliminate machine error quirks;
 *timeoffwork = ROUND(timeoffwork, 1e-10);
 *cumtow = ROUND(cumtow, 1e-10);
 *does not work;
RUN;
*create splines;
*put knots at .05     .275    .5      .725    .95 quantiles;
%DASPLINE(dob_cen hiredate_cen, NK=5, DATA=an, norm=2);
OPTIONS SYMBOLGEN;
DATA an;
 SET an;
 *create spline variables from code given (number of variables = NK-2);
 &_dob_cen ;
 &_hiredate_cen ;
RUN;
OPTIONS NOSYMBOLGEN;
/* from log
Knots for dob_cen:-2.073334481 -0.356860045 0.427956619 1.301600964
Knots for hiredate_cen:-2.215411222 -0.072636434 0.4878939277 1.1214450423
*/

DATA lastan;
 SET an(KEEP = smid cumpy py totpy agestop start_fu hiredate termdate dlo taw cumtaw);
 BY smid;
 IF last.smid;
 *IF py>0;
RUN;


PROC MEANS DATA = an SUM MIN MAX;
 TITLE "Person years of follow-up, time at work";
 VAR py taw timeoffwork anywork anywork_time; *256,900 (256,861 from epicure) reported in lubin's paper;
 * 256,376 with dlo variable as end of follow-up;
 * 235,298 with dlvs variable as end of follow-up;
RUN;
PROC MEANS DATA = dg SUM MIN MAX;
 TITLE "Person years of follow-up, time at work (demographic dataset)";
 VAR totpy; *256,900 (256,861 from epicure) reported in lubin's paper;
 * 257,387 with dlo variable as end of follow-up;
 * 325,619 with dlvs variable as end of follow-up;
RUN;


RUN;QUIT;RUN;
/*DM ODSRESULTS 'clear;' CONTINUE; *clear ODS generated datasets;*/

