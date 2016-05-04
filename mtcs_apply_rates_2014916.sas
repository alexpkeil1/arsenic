*clear the log window and the output window;
DM LOG 'clear;' CONTINUE; DM OUT 'clear;' CONTINUE; 
/**********************************************************************************************************************
* Author: Alex Keil
* Program: mtcs_apply_rates_2014916.sas
* Date: Tuesday, September 16, 2014 at 4:44:03 PM
* Project: Anaconda copper smelter, arsenic exposures
* Tasks: add in expected deaths based on rates from LTAS system
* Data in: 
* Data out:
* Description: 
* Keywords:
* Released under the GNU General Public License: http://www.gnu.org/copyleft/gpl.html
**********************************************************************************************************************/
OPTIONS MERGENOBY = warn NODATE NONUMBER LINESIZE = 120  PAGESIZE=80 SKIP = 2 FORMDLIM = '-' MPRINT NOCENTER;
OPTIONS FORMCHAR = "|----|+|---+=|-/\<>*";
%LET PROGNAME =	mtcs_apply_rates_2014916.sas;
TITLE;
FOOTNOTE "&progname run at &systime on &sysdate";

LIBNAME mtcs "Z:/EpiProjects/MT_copper_smelters/data";

********* BEGIN PROGRAMMING STATEMENTS ************************;
PROC FORMAT CNTLIN=mtcs.mtcs_formats;

PROC IMPORT DATAFILE="Z:/EpiProjects/Std_mortalityrates/ltas_ratefiles/output/ltas_all.csv" OUT=ltasrates DBMS=CSV REPLACE;
RUN;

PROC IMPORT DATAFILE="Z:/EpiProjects/Std_mortalityrates/epicure_ratefiles/output/usmortwh.csv" OUT=epicurerates DBMS=CSV REPLACE; GUESSINGROWS=MAX;
RUN;
PROC FREQ DATA = epicurerates;
  TABLE outcome;
RUN;

*New offset term should be the log of the expected deaths in strata of the covariates;
*Lubin uses age and calendar specific rates for respiratory cancer;
*define new categories for LTAS rate merge;
 *ltas_cause ltas_causes of death: 
  MN larynx: ltas_cause 14 (ICD 8 161)
  MN trachea, lung, bronchus: ltas_cause 15 (162)                      = d_lungcancer [lubin also includes pleural (ltas_cause=16) and SOME other respiratory cases in this group for the SMR paper]
  MN pleura: ltas_cause 16 (163)
  MN other: ltas_cause 17 (160, 163.9)
  rheumatic heart disease: ltas_cause 51 (ICD 8 390-398)
  ischemic heart disease: ltas_cause 52 (ICD 8 410-414)                = d_achd
  chronic disease of the endocardium: ltas_cause 53 (ICD 8 424-424)
  hypertension with heart disease: ltas_cause 54 (ICD 8 400-404)
  other heart disease: ltas_cause 55 (ICD 8 420-429)
  hypertension without heart disease: ltas_cause 56 (400-403)
  cerebrovascular disease: ltas_cause 57 (430-438)                     = d_cbvd
  diseases of arteries veins pulm, circ: ltas_cause 58 (ICD 8 440-458) = d_pvd + d_othercirc
  ltas_causes 51-58 = d_cd
  ltas_causes 14-17 = d_respcancer
  ltas_causes 52, 55 = d_cvd;
 *notes: ICD codes 164, 399, 405-409,415-419, 439 not assigned to any diseases in ICD v8;
PROC SORT DATA = ltasrates(WHERE=(ltas_cause IN(14 15 16 17 15 51 52 53 54 55 56 57 58) AND male=1 AND white=1)) OUT=rates;
 BY ltas_cause agecat yearcat;

PROC SORT DATA = epicurerates(WHERE=(LOWCASE(outcome) 
IN( "all cause" "all malignant"  "circulatory sys" "arterioscl & chd" "vasc lesions cns" "respiratory ca" "lung ca"
        ) AND male=1 AND white=1)) OUT=Erates(RENAME=(outcome=epicure_cause));
 BY outcome ageratestart yearratestart;

 /*lagging rates to allow fractional rates for person periods in two different cells*/
DATA rates;
 SET rates;
 BY ltas_cause ageratestart yearratestart;
 RETAIN lastyearrate .;
 IF first.ageratestart THEN lastyearrate=rate;
 OUTPUT;
 lastyearrate=rate;
RUN;
PROC SORT DATA = rates;
 BY ltas_cause  yearratestart ageratestart;
DATA rates;
 SET rates;
 BY ltas_cause  yearratestart ageratestart;
 RETAIN lastagerate .;
 IF first.yearratestart THEN lastagerate=rate;
 OUTPUT;
 lastagerate=rate;
RUN;

DATA erates;
 SET erates;
 BY epicure_cause ageratestart yearratestart;
 RETAIN lastyearrate .;
 IF first.ageratestart THEN lastyearrate=rate;
 OUTPUT;
 lastyearrate=rate;
RUN;
PROC SORT DATA = erates;
 BY epicure_cause  yearratestart ageratestart;
DATA erates;
 SET erates;
 BY epicure_cause  yearratestart ageratestart;
 RETAIN lastagerate .;
 IF first.yearratestart THEN lastagerate=rate;
 OUTPUT;
 lastagerate=rate;
RUN;

DATA an;
 SET mtcs.mtcs_an02;
 BY smid agein;
 ageratestart = MIN(85,MAX(15, FLOOR(ageout/5)*5));
 yearratestart = MIN(2005,MAX(1940, FLOOR(YEAR(dateout)/5)*5));
 *requires partial cartesian product merge - each outcome should show up for each year/age combo;
run;

OPTIONS FULLSTIMER;
PROC SQL;
 CREATE TABLE y AS SELECT ageratestart, yearratestart, epicure_cause, rate, lastagerate, lastyearrate FROM work.erates;
 CREATE TABLE x AS SELECT smid, agein, datein, ageratestart, yearratestart FROM work.an;
 CREATE TABLE work.ana
  AS SELECT *
   FROM 
    x 
    cross JOIN 
	y
  WHERE x.ageratestart=y.ageratestart AND x.yearratestart=y.yearratestart
  ORDER BY smid, agein, x.ageratestart, x.yearratestart, epicure_cause;
;QUIT;
PROC SQL;
 CREATE TABLE y AS SELECT ageratestart, yearratestart, ltas_cause, rate, lastagerate, lastyearrate FROM work.rates;
 CREATE TABLE x AS SELECT smid, agein, datein, ageratestart, yearratestart FROM work.an;
 CREATE TABLE work.anb
  AS SELECT *
   FROM 
    x 
    cross JOIN 
	y
  WHERE x.ageratestart=y.ageratestart AND x.yearratestart=y.yearratestart
  ORDER BY smid, agein, x.ageratestart, x.yearratestart, ltas_cause;
;QUIT;

DATA anc;
 MERGE ana(DROP=datein yearratestart ageratestart) an();
 BY smid agein;
  RETAIN e_epicure_allcause e_epicure_allcancer E_epicure_lungcancer E_epicure_achd E_epicure_cbvd   E_epicure_cd E_epicure_respcancer   0;
 ARRAY e[*] e_epicure_allcause e_epicure_allcancer E_epicure_lungcancer E_epicure_achd E_epicure_cbvd   E_epicure_cd E_epicure_respcancer  ;
 IF first.agein THEN DO i = 1 TO DIM(e);
  e[i] = 0;
 END;
 newrate = rate;
 *fractional rates for being partly in the next category;
 IF  agein <= ageratestart AND ageout > ageratestart AND YEAR(datein) > yearratestart THEN DO; 
 *age is split, year is correctly classified;
 pyla = ageratestart-agein;
 pyna = ageout-ageratestart;
 newrate = (pyla*lastagerate + pyna*rate)/py;
 END;
 ELSE IF YEAR(datein) < yearratestart AND YEAR(dateout)>=yearratestart AND agein > ageratestart THEN DO; 
 *age is correct, year is split;
 pyly = YRDIF(datein, MDY(1,1,yearratestart), 'AGE');
 pyny = YRDIF(MDY(1,1,yearratestart), dateout, 'AGE');
 newrate = (pyly*lastyearrate + pyny*rate)/py;

 END;
 ELSE IF  agein <= ageratestart AND ageout > ageratestart AND YEAR(datein) < yearratestart AND YEAR(dateout)>=yearratestart THEN DO; 
  *age is correct, both are split;
 pyla = ageratestart-agein;
 pyna = ageout-ageratestart;
 pyly = YRDIF(datein, MDY(1,1,yearratestart), 'AGE');
 pyny = YRDIF(MDY(1,1,yearratestart), dateout, 'AGE');
 newrate = .5*(pyla*lastagerate + pyna*rate + pyna*lastyearrate + pyna*rate)/py;
 END;
 /*
 "all cause" "all malignant"  "circulatory sys" "arterioscl & chd" "vasc lesions cns" "respiratory ca" "lung ca"  
 */
 IF LOWCASE(epicure_cause) IN ("all cause") THEN  e_epicure_allcause = e_epicure_allcause + py*newrate;
 IF LOWCASE(epicure_cause) IN ("all malignant") THEN  e_epicure_allcancer = e_epicure_allcancer + py*newrate;
 IF LOWCASE(epicure_cause) IN ("circulatory sys") THEN  e_epicure_cd = e_epicure_cd + py*newrate;
 IF LOWCASE(epicure_cause) IN ("arterioscl & chd") THEN e_epicure_achd = e_epicure_achd + py*newrate;
 IF LOWCASE(epicure_cause) IN ("vasc lesions cns") THEN e_epicure_cbvd = e_epicure_cbvd + py*newrate;
 IF LOWCASE(epicure_cause) IN ("lung ca") THEN e_epicure_lungcancer = e_epicure_lungcancer + py*newrate;
 IF LOWCASE(epicure_cause) IN ("respiratory ca") THEN e_epicure_respcancer = e_epicure_respcancer + py*newrate;
DROP i rate newrate epicure_cause;
IF last.agein THEN OUTPUT;
RUN;
RUN;

DATA mtcs_an04 ;
 MERGE anb(DROP=datein yearratestart ageratestart) anc(DROP=lastagerate lastyearrate pyla pyna pyly pyny) ;;
 BY smid agein;
  newrate = rate;
 *fractional rates for being partly in the next category;
 IF  agein <= ageratestart AND ageout > ageratestart AND YEAR(datein) > yearratestart THEN DO; 
 *age is split, year is correctly classified;
 pyla = ageratestart-agein;
 pyna = ageout-ageratestart;
 newrate = (pyla*lastagerate + pyna*rate)/py;
 END;
 ELSE IF YEAR(datein) < yearratestart AND YEAR(dateout)>=yearratestart AND agein > ageratestart THEN DO; 
 *age is correct, year is split;
 pyly = YRDIF(datein, MDY(1,1,yearratestart), 'AGE');
 pyny = YRDIF(MDY(1,1,yearratestart), dateout, 'AGE');
 newrate = (pyly*lastyearrate + pyny*rate)/py;

 END;
 ELSE IF  agein <= ageratestart AND ageout > ageratestart AND YEAR(datein) < yearratestart AND YEAR(dateout)>=yearratestart THEN DO; 
  *age is correct, both are split;
 pyla = ageratestart-agein;
 pyna = ageout-ageratestart;
 pyly = YRDIF(datein, MDY(1,1,yearratestart), 'AGE');
 pyny = YRDIF(MDY(1,1,yearratestart), dateout, 'AGE');
 newrate = .5*(pyla*lastagerate + pyna*rate + pyly*lastyearrate + pyny*rate)/py;
 END;

 RETAIN E_ltas_lungcancer E_ltas_achd E_ltas_cbvd E_ltas_pvd E_ltas_othercirc E_ltas_cd E_ltas_respcancer E_ltas_cvd  e_ltas_lungpleura 0;
 ARRAY e[*] E_ltas_lungcancer E_ltas_achd E_ltas_cbvd E_ltas_pvd E_ltas_othercirc E_ltas_cd E_ltas_respcancer E_ltas_cvd e_ltas_lungpleura;
 IF first.agein THEN DO i = 1 TO DIM(e);
  e[i] = 0;
 END;
 IF 51 <= ltas_cause <= 58 THEN DO;
  e_ltas_cd = e_ltas_cd + py*newrate;
  IF ltas_cause=52 OR ltas_cause=55 THEN DO;
   e_ltas_cvd = e_ltas_cvd + py*newrate;
   IF ltas_cause=52 THEN e_ltas_achd = e_ltas_achd + py*newrate;
  END;
  ELSE IF ltas_cause=57 THEN e_ltas_cbvd = e_ltas_cbvd + py*newrate;
  ELSE IF ltas_cause=58 THEN DO; e_ltas_pvd = e_ltas_pvd + py*newrate; e_ltas_othercirc = e_ltas_othercirc + py*newrate;  END;
 END;*51 <= ltas_cause <= 58;
 ELSE IF 14<= ltas_cause <= 17 THEN DO;
  e_ltas_respcancer = e_ltas_respcancer + py*newrate;
  IF ltas_cause=15 THEN e_ltas_lungcancer = e_ltas_lungcancer + py*newrate;
  IF ltas_cause IN (15,16) THEN e_ltas_lungpleura = e_ltas_lungpleura + py*newrate;
 END;
DROP i rate newrate ltas_cause pyla pyna pyly pyny;
IF last.agein THEN OUTPUT;
RUN;
DATA mtcs.mtcs_an04 (LABEL="Analytic dataset: person-period format, at-risk person-time only, exposure lags included, external rates included");
 SET mtcs_an04;
RUN;

PROC CONTENTS DATA = mtcs.mtcs_an04;
 TITLE "mtcs.mtcs_an04 contents";
RUN;
RUN;QUIT;RUN;
DM LOG "FILE Z:/EpiProjects/MT_copper_smelters/logs/sas/&progname.log REPLACE" CONTINUE;
DM OUT "FILE Z:/EpiProjects/MT_copper_smelters/output/sas/&progname.lst REPLACE" CONTINUE;

/*DM ODSRESULTS 'clear;' CONTINUE; *clear ODS generated datasets;*/

