/**********************************************************************************************************************
* Author: Alex Keil
* Program: mtcs_logicchecks_20140901.sas
* Date: Monday, September 1, 2014 at 2:05:22 PM
* Project: Anaconda copper smelter data processing
* Tasks: perform logic checks on MT copper smelter data, derived variables, QC on subsample of data;
* Data in: mtcs.mtcs_an02
* Data out: mtcs.mtcs_qc01
* Description: 
* Released under the GNU General Public License: http://www.gnu.org/copyleft/gpl.html
**********************************************************************************************************************/
*clear the log window and the output window;
DM LOG 'clear;' CONTINUE; DM OUT 'clear;' CONTINUE; 
OPTIONS MERGENOBY = warn NODATE NONUMBER LINESIZE = 120  PAGESIZE=80 SKIP = 2 FORMDLIM = '-' MPRINT NOCENTER;
OPTIONS FORMCHAR = '|----|+|---+=|-/\<>*';
LIBNAME mtcs "Z:/EpiProjects/MT_copper_smelters/data";
PROC DATASETS LIB=work KILL;QUIT;
%INCLUDE "Z:/EpiProjects/MT_copper_smelters/code/mtcs_import_20140828.sas";
PROC DATASETS LIB=work KILL;QUIT;
%INCLUDE "Z:/EpiProjects/MT_copper_smelters/code/mtcs_cleaning_20140828.sas";
PROC DATASETS LIB=work KILL;QUIT;
%INCLUDE "Z:/EpiProjects/MT_copper_smelters/code/mtcs_lagdata_201492.sas";
PROC DATASETS LIB=work KILL;QUIT;
%INCLUDE "Z:/EpiProjects/MT_copper_smelters/code/mtcs_maketableddata_201498.sas";
PROC DATASETS LIB=work KILL;QUIT;
%INCLUDE "Z:/EpiProjects/MT_copper_smelters/code/mtcs_apply_rates_2014916.sas";
PROC DATASETS LIB=work KILL;QUIT;
PROC FORMAT CNTLIN=mtcs.mtcs_formats;

*analysis dataset;
DATA an;
 LENGTH flagerr $16 hiredate termdate start_fu dlo tawdfu towdfu ageout agein py aslt_an: asmd_ann: ashi_an: asuk_ann: 8;
 SET mtcs.mtcs_an02;
 flagerr="";

*time variables - check for correct ordering, check that all times occur within the study interval;
 IF hiredate>=termdate THEN flagerr=CATT(flagerr,"1");
 IF start_fu>=dlo THEN flagerr=CATT(flagerr,"2");

*at work variables, exposure duration variables: check that exposure duration, timeatwork+timeoffwork does not exceed person period time;
 IF tawdfu+towdfu>(ageout-agein + 2.75e-3) THEN flagerr=CATT(flagerr,"3");*accept 1 day of fuzz;
 IF tawbfu+towbfu>(ageout-agein + 2.75e-3) THEN flagerr=CATT(flagerr,"4");*accept 1 day of fuzz;
*time related exposure variables - check that exposure occurs only during work, exposed-follow-up time is only during follow-up;
ARRAY x[*] aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu asuk_ann_durdfu
           aslt_ann_durbfu asmd_ann_durbfu ashi_ann_durbfu asuk_ann_durbfu;
DO i = 1 TO DIM(x);
 IF x[i] > (ageout-agein + 11e-3) THEN flagerr=CATT(flagerr,"5"); *accept 4 days of fuzz - keep the exposure quantity of record;
END;

*person time;
IF py > (ageout-agein + 2.75e-3) THEN flagerr=CATT(flagerr,"6"); *accept 1 day of fuzz;

*ages;
IF ageout <= agein THEN flagerr=CATT(flagerr,"7");

 *date ordering: dob<hiredate<=start_fu<=termdate<=dlo;
IF NOT (dob<hiredate<=start_fu<=termdate<=dlo) THEN flagerr=CATT(flagerr,"8");


*check coherence of outcomes, person time totals;
DATA an_check (keep=smid agein ageout dlo agestop datein dateout cumpy totpy); 
 SET mtcs.mtcs_an01;
 BY smid agein;
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
 IF last.smid THEN DO i = 1 TO DIM(y);;
   IF y[i] NE D[i] THEN DO; OUTPUT; RETURN; END;
 END;
 IF last.smid AND (cumpy>totpy+.005 OR cumpy<totpy-.005) and agestop NE 90 THEN DO; OUTPUT; RETURN; END;
RUN;


*baseline fixed dataset;
DATA dg;
 LENGTH flagerr $16;
 SET mtcs.mtcs_dg01;
 flagerr="";
 *date ordering: dob<hiredate<=start_fu<=termdate<=dlo;
 IF NOT (dob<hiredate<=start_fu<=termdate<=dlo) THEN flagerr=CATT(flagerr,"8");

*tabled dataset;
 DATA ant;
  LENGTH flagerr $16;
  SET mtcs.mtcs_an11;
  flagerr="";

 *tabled dataset with reference rates;
 DATA ant_ref;
  LENGTH flagerr $16;
  SET mtcs.mtcs_an21;
  flagerr="";


*tabulation;
PROC SORT DATA = an OUT=anerr;
 WHERE flagerr NE "";
 BY flagerr;
PROC SORT DATA = dg OUT=dgerr;
 WHERE flagerr NE "";
 BY flagerr;
PROC FREQ DATA = anerr;
 TITLE "Analysis dataset - observations to fix (err=8 is ok for 11 inds)";
 TABLES flagerr;
PROC FREQ DATA = dgerr;
 TITLE "Demographics dataset - observations to fix (err=8 is ok for 11 inds)";
 TABLES flagerr;
RUN;QUIT;RUN;

DATA ant_ref;
 SET ant_ref;
 r_allcause = d_allcause/py;
 r_respcancer = d_respcancer/py1k;
 r_cvd = d_cvd/py1k;
PROC MEANS DATA = ant_ref SUM;
 CLASS cumdosecat;
 VAR d_allcause d_respcancer;
run;
PROC MEANS DATA = ant_ref MEAN MAX;
 CLASS cumdosecat;
 VAR r_allcause r_respcancer;
run;
PROC MEANS DATA = ant_ref MEAN MIN MAX;
 CLASS cumdosecat;
 VAR cumdose;
 FORMAT cumdosecat;
run;
PROC MEANS DATA = ant_ref MEAN MIN MAX;
 CLASS meandosecat;
 VAR meandose;
 FORMAT meandosecat;
run;
/*DM ODSRESULTS 'clear;' CONTINUE; *clear ODS generated datasets;*/
