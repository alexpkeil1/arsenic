/**********************************************************************************************************************
* Author: Alex Keil
* Program: mtcs_cleaning_20140828.sas
* Date: Thursday, August 28, 2014 at 9:44:22 PM
* Project: Anaconda copper smelter data processing
* Tasks: importing, cleaning data, creating analytic variables
* Data in:  (raw text files with arsenic data given by NCI)
* Data out:
* Description: uses data created by mtcs_split_data_20140901.sh to create sas datasets
* Released under the GNU General Public License: http://www.gnu.org/copyleft/gpl.html
**********************************************************************************************************************/
*clear the log window and the output window;

OPTIONS MERGENOBY = warn NODATE NONUMBER LINESIZE = 120  PAGESIZE=80 SKIP = 2 FORMDLIM = '-' MPRINT NOCENTER;
OPTIONS FORMCHAR = '|----|+|---+=|-/\<>*';
%LET progname = mtcs_cleaning_20140828.sas;

%INCLUDE "Z:/Documents/macros/daspline.sas";
LIBNAME mtcs "Z:/EpiProjects/MT_copper_smelters/data";


%LET dolubin=0; *kill all workers at age 90 from unknown cause = 1, don't do this = any other value ;
PROC FCMP OUTLIB=work.misc.addyrs;
 FUNCTION addyrs(startdate, years);
  floor = INTNX('YEAR', startdate, years, "sameday");
  days = (years-FLOOR(years))*(INTNX('YEAR', floor, 1, 'sameday')-floor);
  enddate = floor+days;
 RETURN(enddate);
 ENDSUB;
RUN;
OPTIONS CMPLIB=work.misc;



DATA ex (DROP=h1-h9);
 SET mtcs.mtcs_ex01;
 BY smid agein;
  *Lubin's exposure metrics;
 *unknown exposures not included in dose metric, but included in tabulated analyses;
 ds01 = aslt*0.29 + asmd*0.58 + ashi*1.13;
 ds10 = aslt*0.29 + asmd*0.58 + ashi*11.3;
 ds01_rate = 0; IF (aslt+asmd+ashi)>0 THEN ds01_rate =  ds01/(aslt+asmd+ashi);

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

 LABEL aslt_ann_dur = "Person-period As exposure: light"
       asmd_ann_dur = "Person-period As exposure: medium"
       ashi_ann_dur = "Person-period As exposure: hight"
       asuk_ann_dur = "Person-period As exposure: unknown"
	   so2lt_ann_dur = "Person-period SO2 exposure: light"
       so2md_ann_dur = "Person-period SO2 exposure: medium"
       so2hi_ann_dur = "Person-period SO2 exposure: hight"
       so2uk_ann_dur = "Person-period SO2 exposure: unknown";
 
 timeatwork = empdur-h9;
 h9=empdur;
 timeoffwork=1-timeatwork;

PROC MEANS DATA = mtcs.mtcs_dg01 NOPRINT;
 VAR dob hiredate hireage;
 OUTPUT OUT = ai_cen MEAN=dobmean hiredatemean hireagemean STD=dobstd hiredatestd hireagestd;

DATA _null_; SET ai_cen; 
 CALL SYMPUT("dobmean", PUT(dobmean, BEST9.)); CALL SYMPUT("hiredatemean", PUT(hiredatemean, BEST9.)); CALL SYMPUT("hireagemean", PUT(hireagemean, BEST9.));
 CALL SYMPUT("dobstd", PUT(dobstd, BEST9.)); CALL SYMPUT("hiredatestd", PUT(hiredatestd, BEST9.));CALL SYMPUT("hireagestd", PUT(hireagestd, BEST9.));
PUT dobmean hiredatemean hireagemean;
PUT dobstd hiredatestd hireagestd;
RUN;

DATA dg(DROP= chg _icd odate i) mtcs.mtcs_dg02(DROP= _icd chg odate i);
 SET mtcs.mtcs_dg01 (DROP=icd);
 yob = YEAR(dob);
 yoh = YEAR(hiredate);

 usborn = (pob<30);
 LABEL usborn = "Born in the USA";

 *approximately standardized variables;
 dob_cen=(dob-&DOBMEAN)/&DOBSTD;
 hiredate_cen=(hiredate-&HIREDATEMEAN)/&HIREDATESTD;
 hireage_cen=(hireage-&HIREAGEMEAN)/&HIREAGESTD;
 LABEL dob_cen = "Date of birth, standardized"
       hiredate_cen = "Date of hire, standardized"
       hireage_cen = "Age at hire, standardized";


 *person years at risk;
 totpy = YRDIF(start_fu,dlo, 'AGE');
 LABEL totpy = "Lifetime person years at risk";

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
 birthcohort7 = (yob>1879/*referent*/)+(yob>1889)+(yob>1899)+(yob>1909)+(yob>1919)+(yob>1929);
 birthcohort10 = (yob>1879/*referent*/)+(yob>1889)+(yob>1899)+(yob>1904)+(yob>1909)+(yob>1914)+(yob>1919)+(yob>1924)+(yob>1929);

 LABEL birthcohort7 = "Birth cohort (<1880, 1880-1889, 1890-1899, 1900-1909, 1910-1919, 1920-1929, 1930+)"
 birthcohort10 = "Birth cohort (<1880, 1881-1889, 1890-1899, 1900-1904, 1905-1909, 1910-1914, 1915-1919, 1920-1924, 1925-1929, 1930+)"; 
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
  hirecohort7 = (yoh>1909/*referent*/)+(yoh>1919)+(yoh>1929)+(yoh>1939)+(yoh>1949)+(yoh>1954);
  hirecohort9 = (yoh>1909/*referent*/)+(yoh>1919)+(yoh>1924)+(yoh>1934)+(yoh>1939)+(yoh>1944)+(yoh>1949)+(yoh>1954);
 LABEL hirecohort7 = "Period of hire (<1910, 1910-1919, 1920-1929, 1930-1939, 1940-1949, 1950-1955, 1955+)"
 hirecohort9 = "Period of hire (<1910, 1910-1919, 1920-1924, 1924-1934, 1935-1939, 1940-1944, 1945-1949, 1950-1955, 1955+)"; 


 
*cause of death;
*   vstat = 1   alive
        2   alive as of 12/31/89, died after with DC
        3   alive as of 12/31/89, died after without DC
        4   died before 12/31/89, with DC
        5   died before 12/31/89, without DC
        6   unknown status; *assumed dead by lubin if over 90 years old, reassigned a 7 (assumed dead);
IF vstat IN(1,2,3,6) AND dob <= '31dec1899'd AND &dolubin THEN vstat=7; *typo in Lubin 2000 table - actually births before 1900, not 1990; 
*should revisit for main analysis - could censor individuals at 90 years of age - this adds 81 deaths exactly at age 90;

y_allcause=0;
IF vstat IN(4,5,7) THEN y_allcause=1; *only counting deaths that occured before 12/31/89;

*Lubin's way of handling old age;
IF YRDIF(dob, dlo)>90 AND YEAR(dob)<1990 AND &DOLUBIN=1 THEN DO;
 y_allcause=1;
 icdx =.o;
 icd = .o;
 dlo = ADDYRS(dob, 90);
END;

*SPECIFIC CAUSES OF DEATH;
*create numeric icd code, set to 999 if unknown;
IF y_allcause=1 THEN DO;
IF icdx >.z AND ICD3 > .z THEN icd = INPUT(TRIM(TRIM(PUT(icd3, 3.)) || "." || TRIM(PUT(icdx, 1.))), 5.2);
ELSE IF icdx <= .z AND ICD3 > .z THEN icd = INPUT(TRIM(PUT(icd3, 3.) || ".0"), 5.2);
ELSE IF icdx <=.z AND ICD3 <= .z THEN icd = 999;
END;

*code from Jay Lubin to convert ICD-6 to ICD-8;
*icd = icd3;
odate = YEAR(dlo);
chg = 0;
_icd = icd;
IF .z<odate<1964 AND 190<=_icd<192 THEN icd=172 ; * skin;
IF .z<odate<1964 AND _icd=177 THEN icd=185 ; * prostate;
IF .z<odate<1964 AND _icd=181 THEN icd=188 ; * bladder;
IF .z<odate<1964 AND _icd=180 THEN icd=189 ; * kidney;
IF .z<odate<1964 AND 340<=_icd<400 THEN icd=320 ; * nerv sys/sense organs;
IF .z<odate<1964 AND _icd=260 THEN DO;icd=250;chg=1;END; * diabetes mellitus;
IF .z<odate<1964 AND 420<=_icd<423 THEN DO;icd=410;chg=1;END; *arterios AND CHD;
IF .z<odate<1964 AND 330<=_icd<335 THEN DO;icd=430;chg=1;END; *vasc lesions CNS;
IF .z<odate<1964 AND 490<=_icd<494 THEN DO;icd=480;chg=1;END; *pneumonia;
IF .z<odate<1964 AND _icd=581 THEN DO;icd=571;chg=1;END; * cirrhosis;
IF .z<odate<1964 AND chg=0 AND 240<=_icd<290 THEN icd=240 ; * allergic;
IF .z<odate<1964 AND chg=0 AND 400<=_icd<470 THEN icd=390 ; *circ dis-arter+vas-CNS;
IF .z<odate<1964 AND chg=0 AND 470<=_icd<528 THEN icd=460 ; * NMRD;
IF .z<odate<1964 AND chg=0 AND 530<=_icd<590 THEN icd=520 ; * dis digest sys;

ARRAY ys[*]y_tb y_allcancer y_bucccancer y_digestcancer y_esophcancer y_stomachcancer y_lrgincancer 
           y_rectumcancer y_livercancer y_panccancer y_othdigcancer y_respcancer y_larynxcancer y_lungcancer 
           y_othrespcancer y_prostatecancer y_testescancer y_kidneycancer y_bladdercancer y_melanomacancer 
           y_eyecancer y_cnscancer y_thyroidcancer y_bonecancer y_alllymcancer y_lymsarcancer y_cd y_cvd y_achd 
           y_cbvd y_pvd y_diabmell y_othercirc;
IF y_allcause=0 THEN DO i = 1 TO DIM(ys);
 ys[i]=0;
END;
ELSE IF y_allcause=1 THEN DO;
*icd8 codes from Jay Lubin (to match 2000, 2008 papers);
*tuberculosis;
y_tb = (icd>=10)*(icd<=19);    * tb;

*cancer outcomes;
y_allcancer =     (140<=icd < 210);  * all ca;
y_bucccancer =    (140<=icd < 150);  * Cancer of Buccal Cavity & Pharynx;
y_digestcancer =  (150<=icd < 160);  * Cancer of Digestive Organs & Peritoneum;
y_esophcancer  =  (icd=150);             * Cancer of Esophagus;
y_stomachcancer = (151<=icd<=151.9);* Cancer of Stomach;
y_lrgincancer  =  (icd=153);             * Cancer of Large Intestine;
y_rectumcancer =  (icd=154);             * Cancer of Rectum;
y_livercancer  =  (155<=icd<157);  * Cancer of Biliary Passages & Liver;
y_panccancer =    (icd=157);             * Cancer of Pancreas;
y_othdigcancer =  (icd=152)+(158<=icd< 160);  * Cancer of All Other Digestive Organs;
y_respcancer =    (160<=icd<=164.9);  * Cancer of Respiratory System;
y_larynxcancer =  (161<=icd<=161.9);  * Cancer of Larynx;
y_lungcancer =    (162<=icd<=163);  * Cancer of Bronchus, Trachea, Lung (also includes pleura - ak);
y_othrespcancer = (icd=164);             * Cancer of All other Respiratory;
y_prostatecancer =(icd=185);             * Cancer of Prostate (Males only);
y_testescancer =  (icd=172.5)+(icd=173.5)+(186 <= icd < 188);  * Cancer of Testes and Other Male Genital;
y_kidneycancer =  (189<icd<=189.9); * Cancer of Kidney & Other Urinary Organs;
y_bladdercancer = (188<=icd<=188.9); * Cancer of Bladder;
y_melanomacancer =(172<=icd<=172.4)+(172.6<=icd<=172.9);* Malignant Melanoma of Skin;         
y_eyecancer =     (icd=190);             * Cancer of Eye;
y_cnscancer =     (191<=icd<=192.9);* Cancer of CNS;
y_thyroidcancer = (193<=icd<=194.9);* Cancer of Thyroid Gland & Other Endocrin;
y_bonecancer =    (icd=170);             * Cancer of Bone;
y_alllymcancer =  (200<=icd<=209.9);* Cancer of All Lymphatic & Haematopoietic;
y_lymsarcancer =  (icd=200);             * Lymphosarcoma & Reticulosarcoma;

*cardiovascular outcomes;
y_cd =            (390<=icd<= 458.9);                           * CIRCULATORY SYS       ;
y_cvd  =          (410<=icd<= 414.9) + (420<=icd<=429.9); * ARTERIOSCL & CHD + endocarditis etc;
y_achd =          (410<=icd<= 414.9);                           * ARTERIOSCL & CHD    ;
y_cbvd  =         (430<=icd<= 438.9);                           * VASC LESIONS CNS   ;
y_pvd  =          (440<=icd<= 448.9);                           * Peripheral vascular disease;
y_diabmell    =   (250<=icd<= 250.9);                           * DIABETES MELLITUS  ;
y_othercirc =     (449<=icd<= 458.9); * other circulatory diseases;
END;
/*
y_respcancer=0;
 IF y_allcause=1 AND 160<=ICD3<=164 THEN y_respcancer=1;
 *IF y_allcause=1 AND 160<=ICD3<=163 THEN y_respcancer=1; *9/11/14 change;
y_lungcancer=0;
 IF y_allcause=1 AND 162=ICD3 THEN y_lungcancer=1;
 y_lungpleura=0;
 IF y_allcause=1 AND 162<=ICD3<=163 THEN y_lungpleura=1;
 *IF y_allcause=1 AND 162=ICD3 THEN y_lungcancer=1; *9/11/14 change;

y_cd=0;*circulatory disease: 390-458;
 IF y_allcause=1 AND 390<=ICD3<=458 THEN y_cd=1;
y_cvd=0;*cardiovascular icd8 codes 410-414, 420-429 (other heart disease);
 IF y_allcause=1 AND (410<=ICD3<=414 OR 420<=ICD3<=429) THEN y_cvd=1;
y_achd=0;*arteriosclerosis and CHD (ischemic heart disease) icd8 codes 410-414, 420-429;
 IF y_allcause=1 AND (410<=ICD3<=414) THEN y_achd=1;
y_cbvd=0;*cerebrovascular disease icd8 codes 430-438;
 IF y_allcause=1 AND 430<=ICD3<=438 THEN y_cbvd=1;
y_pvd=0; *peripheral vascular disease icd8 codes 440-448;
 IF y_allcause=1 AND 440<=ICD3<=448 THEN y_pvd=1;
y_othercirc=0; *icd8 codes 448-458;
 IF y_allcause=1 AND 448<=ICD3<=458 THEN y_othercirc=1;
*/

 LABEL y_allcause = "Death from any cause (incl. missing cause) ever"
  y_respcancer ="Any respiratory cancer death (160<=ICD<=164) ever"
  y_lungcancer ="Lung, bronchus cancer death (ICD3=162) ever"
  /*y_lungpleura = "Lung, bronchus, pleura cancer death (162<=ICD3<=163) ever"*/
  y_cd ="Circulatory disease death (390<=ICD<=458) ever"
  y_cvd ="Cardiovascular disease death (410<=ICD<=414 OR 420<=ICD<=429) ever"
  y_achd ="Arteriosclerosis or CHD death (410<=ICD<=414) ever"
  y_cbvd ="Cerebrovascular disease death (430<=ICD<=438) ever"
  y_pvd ="Peripheral vascular disease death (440<=ICD<=448) ever"
  y_othercirc ="Other circulatory disease death (448<=ICD<=458) ever"
  ltfu="Lost to follow-up ever"
  admincens= "Administratively censored (31Dec1989) ever";

 *admin censoring, loss to follow-up;
ltfu=0;
 IF vstat IN(1,2,3,6) AND dlo < '31dec1989'd THEN ltfu=1; *admin censoring date not quite right as given in paper;
admincens=0;
IF ltfu=0 THEN admincens = 1-y_allcause;

RUN;

PROC CONTENTS DATA = dg; TITLE "Demographic data";
PROC PRINT DATA = dg (OBS=10);
PROC MEANS DATA = dg NOPRINT;VAR dlvs dlo;OUTPUT OUT=max MAX=dlvs dlo; 
PROC PRINT DATA = max; FORMAT dlvs dlo mmddyy10.; LABEL dlvs ="Max. observed time of death"; VAR dlvs dlo;
RUN;
PROC CONTENTS DATA = ex; TITLE "Exposure data";
PROC PRINT DATA = ex (FIRSTOBS=100 OBS=120);
RUN;


PROC FREQ DATA = dg;
 TITLE "Vital status, Specific causes of death (cross check with Lubin 2000)";
 TABLE vstat y_: ltfu*admincens*y_allcause / LIST;
RUN;


DATA an1;
LENGTH smid agein ageout datein dateout 8;
MERGE dg(DROP=asex so2ex dlvs icd3 icdx) ex(DROP=cumas cumso2 maxas maxso2); 
 *MERGE dg(KEEP=smid dob hiredate start_fu dlo termdate y_allcause) ex(KEEP=smid age aslt asmd ashi asuk empdur) ; 
 BY smid;
 *back-calculate dates at person-period changes;
 *this seems to add a bit of fuzz to the data versus strict calculation from dates = max 0.005 py difference per id;
 datein=addyrs(dob, agein); 
 agestop=YRDIF(dob,dlo, 'AGE');
 ageout=MIN(agein+1, agestop);
 agestart=YRDIF(dob, start_fu, 'AGE');
 dateout=addyrs(dob, ageout);
 IF (dlo-2.5) < dateout < (dlo+2.5) AND ageout-agein<1 THEN DO;
 *ensure that some date fuzziness by different time scales is reduced;
  dateout=dlo; 
  ageout=YRDIF(dob, dateout, 'AGE');
  agestop=ageout;
 END;
 FORMAT datein dateout MMDDYY10.;
 LABEL agein = "Age at start of person period"
       datein = "Date at start of person period" 
       agestop = "Age at recorded date of last observation"
	   ageout = "Age at end of person period"
	   agestart = "Age at recorded start of follow-up"
	   dateout = "Date at end of person period";

 *fix time off work for person periods in which employment starts;
 *assume that there is no time off work in first record;
 *no way to know if early missing exposure is due to late start or to missed work;
 IF dateout<hiredate THEN timeoffwork=0;
 ELSE IF datein<=hiredate<dateout THEN timeoffwork = MAX(0,YRDIF(hiredate, dateout, 'AGE')-timeatwork);
 ELSE IF dateout=hiredate THEN timeoffwork=0;
 IF datein>termdate THEN timeoffwork=0;
 ELSE IF datein<termdate<=dateout THEN timeoffwork = MAX(0,YRDIF(datein, termdate, 'AGE')-timeatwork);
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
   ageout = YRDIF(dob, start_fu, 'AGE');
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
 LABEL timeatwork = "Active employment time in person period";
 OUTPUT;
RUN;
DATA an (DROP = aslt asmd ashi asuk _pfut markfix afe ale tfe tle) ale(KEEP = smid afe ale tfe tle);
 LENGTH smid agein ageout datein dateout py cumpy totpy taw cumtaw timeoffwork cumtow agestop 8 d_allcause d_respcancer d_lungcancer /*d_lungpleura*/ d_cd d_cvd d_achd d_cbvd d_pvd d_othercirc c_ltfu c_admin 3;
 SET an1;
 BY smid;
 *person time at risk;
 IF dateout < start_fu THEN py=0;
 ELSE py = MAX(0,MIN(YRDIF(start_fu, dateout, 'AGE'), YRDIF(datein, dateout, 'AGE')));
 LABEL py = "Person time at risk in person-period";

 RETAIN cumpy;
 IF first.smid THEN cumpy=0;
 cumpy=cumpy+py;
 LABEL py = "Cumulative person time at risk";

 *fix probable small date discrepancies that lead to apparent time off work;
 IF timeoffwork < 2.1/365.5 THEN timeoffwork=0;

 *time at work;
 IF dateout < hiredate OR datein > termdate THEN taw=0;
 ELSE taw = MAX(0,MIN(YRDIF(hiredate, dateout, 'AGE'), YRDIF(datein, termdate, 'AGE'), YRDIF(datein, dateout, 'AGE'), timeatwork));
 IF taw>0 THEN anywork=1; ELSE anywork=0;
 anywork_time=anywork*(ageout-agein);
 RETAIN cumtaw cumtow;
 IF first.smid THEN DO; cumtaw=0; cumtow=0; END;
 cumtaw=cumtaw+taw;
 cumtow=cumtow+timeoffwork;
 LABEL taw = "Active employment time in person period "
       timeoffwork = "Inactive employment time in person period (pre-termination)"
       cumtaw = "Cumulative active employment time in person period "
       cumtow = "Cumulative inactive employment time in person period (pre-termination)";

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
  towdfu=timeoffwork;
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
  towdfu=0;
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
  *assume all time at work occurs during follow-up for this period only;
  tawdfu = MIN(YRDIF(start_fu, dateout, 'AGE'), YRDIF(hiredate, termdate, 'AGE'), timeatwork);
  tawbfu = taw-tawdfu;
  towdfu = MIN(YRDIF(start_fu, dateout, 'AGE'), YRDIF(hiredate, termdate, 'AGE'))-timeatwork;
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

 *age at first, last exposure;
 RETAIN ale afe tle tfe .;
 FORMAT tle tfe MMDDYY10.;
 IF first.smid THEN DO; ale=.; afe=.;tle=.; tfe=.; END;
 IF afe=. AND SUM(aslt_ann_dur,asmd_ann_dur,ashi_ann_dur,asuk_ann_dur)>0 AND datein<=hiredate<dateout THEN DO; afe=hireage; tfe=hiredate; END;
 ELSE IF afe=. AND SUM(aslt_ann_dur,asmd_ann_dur,ashi_ann_dur,asuk_ann_dur)>0 AND dateout<hiredate THEN DO; afe=agein; tfe=datein; END;
 IF SUM(aslt_ann_dur,asmd_ann_dur,ashi_ann_dur,asuk_ann_dur)>0 AND datein<=termdate<dateout THEN DO; ale=termage; tle=termdate; END;
 ELSE IF SUM(aslt_ann_dur,asmd_ann_dur,ashi_ann_dur,asuk_ann_dur)>0 AND dateout>termdate THEN DO; ale=ageout; tle=dateout; END;
 IF last.smid THEN OUTPUT ale;
 LABEL afe = "Age at start of first exposure"
       ale = "Age at end of last exposure"
	   tfe = "Date at start of first exposure"
       tle = "Date at end of last exposure"
;


RETAIN cumtowdfu cumtawdfu cumtowbfu cumtawbfu 0;
 IF first.smid THEN DO; cumtowdfu=0;cumtawdfu=0;cumtowbfu=0; cumtawbfu=0; END;
 cumtowdfu=cumtowdfu+towdfu;
 cumtawdfu=cumtawdfu+tawdfu;
 cumtowbfu=cumtowbfu+towbfu;
 cumtawbfu=cumtawbfu+tawbfu;


 LABEL aslt_ann_durdfu = "Person-period As exposure during follow up: light"
       asmd_ann_durdfu = "Person-period As exposure during follow up: medium"
       ashi_ann_durdfu = "Person-period As exposure during follow up: hight"
       asuk_ann_durdfu = "Person-period As exposure during follow up: unknown"
	   so2lt_ann_durdfu = "Person-period SO2 exposure during follow up: light"
       so2md_ann_durdfu = "Person-period SO2 exposure during follow up: medium"
       so2hi_ann_durdfu = "Person-period SO2 exposure during follow up: hight"
       so2uk_ann_durdfu = "Person-period SO2 exposure during follow up: unknown"
       aslt_ann_durbfu = "Person-period As exposure before follow up: light"
       asmd_ann_durbfu = "Person-period As exposure before follow up: medium"
       ashi_ann_durbfu = "Person-period As exposure before follow up: hight"
       asuk_ann_durbfu = "Person-period As exposure before follow up: unknown"
	   so2lt_ann_durbfu = "Person-period SO2 exposure before follow up: light"
       so2md_ann_durbfu = "Person-period SO2 exposure before follow up: medium"
       so2hi_ann_durbfu = "Person-period SO2 exposure before follow up: hight"
       so2uk_ann_durbfu = "Person-period SO2 exposure before follow up: unknown"
       tawdfu = "Person-period time at work during follow up"
       tawbfu = "Person-period time at work before follow up"
       cumtawbfu = "Cumulative time at work before follow up"
       cumtawdfu = "Cumulative time at work during follow up"
       towdfu = "Person-period time off work during follow up"
       towbfu = "Person-period time off work before follow up"
       cumtowdfu = "Cumulative time off work during follow up"
       cumtowbfu = "Cumulative time off work before follow up";

 *time specific causes of death;
 ARRAY y[*] y_tb y_allcancer y_bucccancer y_digestcancer y_esophcancer y_stomachcancer y_lrgincancer 
            y_rectumcancer y_livercancer y_panccancer y_othdigcancer y_respcancer y_larynxcancer y_lungcancer 
            y_othrespcancer y_prostatecancer y_testescancer y_kidneycancer y_bladdercancer y_melanomacancer 
            y_eyecancer y_cnscancer y_thyroidcancer y_bonecancer y_alllymcancer y_lymsarcancer y_cd y_cvd y_achd 
            y_cbvd y_pvd y_diabmell y_othercirc y_allcause  ltfu admincens;
 ARRAY d[*] d_tb d_allcancer d_bucccancer d_digestcancer d_esophcancer d_stomachcancer d_lrgincancer 
            d_rectumcancer d_livercancer d_panccancer d_othdigcancer d_respcancer d_larynxcancer d_lungcancer 
            d_othrespcancer d_prostatecancer d_testescancer d_kidneycancer d_bladdercancer d_melanomacancer 
            d_eyecancer d_cnscancer d_thyroidcancer d_bonecancer d_alllymcancer d_lymsarcancer d_cd d_cvd d_achd 
            d_cbvd d_pvd d_diabmell d_othercirc d_allcause  c_ltfu c_admin;
 IF dlo>dateout THEN DO;
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
 LABEL d_allcause = "Death from any cause (incl. missing cause) in person period"
  d_respcancer ="Any respiratory cancer death (160<=ICD<=164 in person period)"
  d_lungcancer ="Lung cancer death (ICD=162) in person period"
  /*d_lungpleura ="Lung/pleural cancer death (ICD=162, 163) in person period"*/
  d_cd ="Circulatory disease death (390<=ICD<=458) in person period"
  d_cvd ="Cardiovascular disease death (410<=ICD<=414 OR 420<=ICD<=429) in person period"
  d_achd ="Arteriosclerosis or CHD death (410<=ICD<=414) in person period"
  d_cbvd ="Cerebrovascular disease death (430<=ICD<=438) in person period"
  d_pvd ="Peripheral vascular disease death (440<=ICD<=448) in person period"
  d_othercirc ="Other circulatory disease death (448<=ICD<=458) in person period"
  c_ltfu="Lost to follow-up in person period"
  c_admin= "Administratively censored (31Dec1989) in person period";

*rounding some values to eliminate machine err0r quirks;
 timeoffwork = ROUND(timeoffwork, 1e-8);
 cumtow = ROUND(cumtow, 1e-8);


*add observations if dlo-dob > 88 years;
 IF agestop > 88 AND ageout=88 THEN DO ;
  OUTPUT an; 
  DO WHILE (dateout < dlo);
  agein=ageout;
  ageout=MIN(agein+1, agestop);
  *back-calculate dates at person-period changes;
  *this seems to add a bit of fuzz to the data versus strict calculation from dates = max 0.005 py difference per id;
  datein=addyrs(dob, agein); 
  dateout=addyrs(dob, ageout);
 IF (dlo-2.5) < dateout < (dlo+2.5) AND ageout-agein<1 THEN DO;
 *ensure that some date fuzziness by different time scales is reduced;
  dateout=dlo; 
  ageout=YRDIF(dob, dateout, 'AGE');
  agestop=ageout;
 END;

 *person time at risk;
 IF dateout < start_fu THEN py=0;
 ELSE py = MAX(0,MIN(YRDIF(start_fu, dateout, 'AGE'), YRDIF(datein, dateout, 'AGE')));

 cumpy=cumpy+py;
 *time at work;
 IF dateout < hiredate OR datein > termdate THEN taw=0;
 ELSE taw = MAX(0,MIN(YRDIF(hiredate, dateout, 'AGE'), YRDIF(datein, termdate, 'AGE'), YRDIF(datein, dateout, 'AGE')));
 IF taw>0 THEN anywork=1; ELSE anywork=0;
 IF first.smid THEN cumtaw=0;
 cumtaw=cumtaw+taw;
 cumtowdfu=cumtowdfu+towdfu;
 cumtawdfu=cumtawdfu+tawdfu;
 cumtowbfu=cumtowbfu+towbfu;
 cumtawbfu=cumtawbfu+tawbfu;



 *time specific causes of death;
 IF dlo>dateout THEN DO;
  DO i = 1 TO DIM(y);
   d[i]=0;
  END;
 END;
 ELSE DO;
  DO i = 1 TO DIM(y);
   d[i]=y[i];
  END;
 END;
 OUTPUT an;
 END;*IF agestop > 88 AND ageout=88;
 END;*;
 ELSE OUTPUT an;

RUN;
*create splines;
*put knots at .05     .275    .5      .725    .95 quantiles;
%DASPLINE(dob_cen hiredate_cen hireage_cen,
           knot1=-1.0 -0.5 0.5 1.0, 
           knot2=-1.0 -0.5 0.5 1.0,
           knot3=-1.0 -0.5 0.5 1.0, DATA=an, norm=2);
OPTIONS SYMBOLGEN;
DATA an ;
 MERGE an ale;
 BY smid;
 IF ale>50 THEN lubin_group=1;
 ELSE lubin_group=0;
 LABEL lubin_group = "Group of miners last exposed after age 50";
 *create spline variables from code given (number of variables = NK-2);
 &_dob_cen ;
 &_hiredate_cen ;
 &_hireage_cen ;

 *some transformed variables;
 logpy=.;
 IF py>0 THEN logpy = log(py);
 LABEL logpy="LN(person years at risk) in person period";

 *Lubin's dose variables;
 ds01_ann_dfu = aslt_ann_durdfu*0.29 + asmd_ann_durdfu*0.58 + ashi_ann_durdfu*1.13;
 ds10_ann_dfu = aslt_ann_durdfu*0.29 + asmd_ann_durdfu*0.58 + ashi_ann_durdfu*11.3;
 LABEL ds01_ann_dfu="Derived arsenic concentration, mg/m^3 (during enrollment)"
       ds10_ann_dfu="Derived arsenic concentration, mg/m^3 (during enrollment)";
 ds01_ann_bfu = aslt_ann_durbfu*0.29 + asmd_ann_durbfu*0.58 + ashi_ann_durbfu*1.13;
 ds10_ann_bfu = aslt_ann_durbfu*0.29 + asmd_ann_durbfu*0.58 + ashi_ann_durbfu*11.3;
 LABEL ds01_ann_bfu="Derived arsenic concentration, mg/m^3 (pre enrollment)"
       ds10_ann_bfu="Derived arsenic concentration, mg/m^3 (pre enrollment)";

 IF taw>0 THEN activework=1;
 ELSE activework=0;
 IF tawdfu>0 THEN activeworkdfu=1;
 ELSE activeworkdfu = 0;
 LABEL activework = "Any work during person period"
       activeworkdfu = "Any work during person period (during follow-up only)";
 *censor at old age (can be done later);
 *%LET censage=100;
 *IF ageout<=&censage;
 *IF agestop>&censage THEN admincens=1;
	   *ordinal exposure; 
 as_ann_ordinal = 0;
 IF SUM(aslt_ann_durdfu, asmd_ann_durdfu, ashi_ann_durdfu)>0 THEN DO;
  IF MAX(aslt_ann_durdfu, asmd_ann_durdfu, ashi_ann_durdfu)=aslt_ann_durdfu THEN as_ann_ordinal=1;
  ELSE IF MAX(aslt_ann_durdfu, asmd_ann_durdfu, ashi_ann_durdfu)=asmd_ann_durdfu THEN as_ann_ordinal=2;
  ELSE IF MAX(aslt_ann_durdfu, asmd_ann_durdfu, ashi_ann_durdfu)=ashi_ann_durdfu THEN as_ann_ordinal=3;
 END;

 *binary: high, medium vs. light and none;
 as_ann_binary=0;
 IF SUM(asmd_ann_durdfu, ashi_ann_durdfu)>0 THEN as_ann_binary=1;
LABEL as_ann_binary = "Binary person period exposure: 0=none/low, 1=med/high arsenic" 
      as_ann_ordinal = "Ordinal person period exposure: 0=none, 1=low, 2=med , 3=high arsenic"; 

 as_ann_ordinal_nl_m_h = (as_ann_ordinal>1)+(as_ann_ordinal>2); *0 = low, none, 1=medium, 2=high;
  c_age = YRDIF(dob, '31dec1989'd, 'AGE');
  LABEL c_age = "Expected age at administrative censoring date(12/31/1989)";

  *time since last exposure;
 IF datein>tle>.z THEN tsle = YRDIF(tle, datein, 'AGE');
 ELSE tsle=0;
 LABEL tsle = "Years since last exposure (at beginning of person period)";

RUN;
DATA an(drop=h1 h2);
 SET an;
 BY smid ageout;
 *fix c_admin variable;
 IF last.ageout AND admincens=1 THEN c_admin=1;
 ELSE c_admin=0;

 *leaving, returning to work;
 RETAIN  h1 h2 0;
 IF first.smid THEN DO; h1=activework; h2=cumtaw; END;
 IF activework=0 THEN DO;
  returnwork=0;
  IF h1=1 THEN leavework=1;
  ELSE leavework=0;
 END;
 ELSE IF activework=1 THEN DO;
  leavework=0;
  IF h1 = 0 AND hiredate<datein THEN returnwork=1;
  ELSE returnwork=0;
 END;

 OUTPUT;
 h1 = activework; h2=cumtaw;

PROC MEANS DATA = an MEAN SUM NMISS;
 TITLE "leaving, returning to work";
 VAR leavework returnwork;
RUN;
PROC MEANS DATA = an MEAN SUM NMISS;
 TITLE "leaving, returning to work (active py only)";
 WHERE py>0;
 VAR leavework returnwork;
RUN;

PROC PRINT DATA = an;
 WHERE leavework=1 OR returnwork=1;
 VAR smid activework leavework returnwork;
RUN;
 

OPTIONS NOSYMBOLGEN;
/* from log
Knots for dob_cen:-2.072864256 -0.355359027 0.4300665453 1.3027616255
Knots for hiredate_cen:-2.215400191 -0.073961767 0.4888263125 1.119248876
Knots for hireage_cen:-1.111636011 -0.599663658 0.2668678969 2.0869890832
*/

DATA lastan;
 SET an(KEEP = smid cumpy py totpy agestop ageout start_fu hiredate termdate dlo taw cumtaw d_:);
 BY smid;
 IF last.smid;
 *IF py>0;
RUN;
ODS GRAPHICS ON;


PROC UNIVARIATE DATA = lastan ;
 TITLE "Lifetime distribution";
 WHERE d_allcause=1;
 VAR ageout;
 HISTOGRAM ageout;
RUN;
ODS GRAPHICS OFF;

PROC MEANS DATA = an SUM MIN MAX;
 TITLE "Person years of follow-up, time at work (follow-up dataset)";
 TITLE2 "Will be some reduction in person years due to artificial censoring/imputed deaths at age 90";
 VAR py tawdfu tawbfu taw towdfu towbfu anywork anywork_time; *256,900 (256,861 from epicure) reported in lubin's paper;
 * 256,376 with dlo variable as end of follow-up;
RUN;
PROC MEANS DATA = dg SUM MIN MAX;
 TITLE "Person years of follow-up, time at work (demographic dataset)";
 VAR totpy; *256,900 (256,861 from epicure) reported in lubin's paper;
 * 257,387 with dlo variable as end of follow-up;
RUN;

*some cumulative amounts at the start of follow-up;
PROC SQL;
 CREATE TABLE work.an_pre AS 
 SELECT smid,
        SUM(aslt_ann_durbfu) AS tot_aslt_ann_durbfu,
        SUM(asmd_ann_durbfu) AS tot_asmd_ann_durbfu,
        SUM(ashi_ann_durbfu) AS tot_ashi_ann_durbfu,
        SUM(asuk_ann_durbfu) AS tot_asuk_ann_durbfu,
        SUM(so2lt_ann_durbfu) AS tot_so2lt_ann_durbfu,
        SUM(so2md_ann_durbfu) AS tot_so2md_ann_durbfu,
        SUM(so2hi_ann_durbfu) AS tot_so2hi_ann_durbfu,
        SUM(so2uk_ann_durbfu) AS tot_so2uk_ann_durbfu
 FROM work.an
 GROUP BY smid;
QUIT;

*shed extra variables, make a permanent dataset;
DATA mtcs.mtcs_an01 (LABEL="Analytic dataset: person-period format, all person-time, no lagged exposure");
 MERGE an(DROP = anywork anywork_time i temp1 temp2 yob yoh) an_pre;
 BY smid;
 LABEL tot_aslt_ann_durbfu = "Total As exposure duration before follow up: light"
       tot_asmd_ann_durbfu = "Total As exposure duration before follow up: medium"
       tot_ashi_ann_durbfu = "Total As exposure duration before follow up: hight"
       tot_asuk_ann_durbfu = "Total As exposure duration before follow up: unknown"
	   tot_so2lt_ann_durbfu = "Total SO2 exposure duration before follow up: light"
       tot_so2md_ann_durbfu = "Total SO2 exposure duration before follow up: medium"
       tot_so2hi_ann_durbfu = "Total SO2 exposure duration before follow up: hight"
       tot_so2uk_ann_durbfu = "Total SO2 exposure duration before follow up: unknown";


PROC CONTENTS DATA = mtcs.mtcs_an01;
TITLE "Analytic dataset";
RUN;




RUN;QUIT;RUN;
/*DM ODSRESULTS 'clear;' CONTINUE; *clear ODS generated datasets;*/

