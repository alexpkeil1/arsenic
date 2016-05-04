/**********************************************************************************************************************
* Author: Alex Keil
* Program: mtcs_import_20140828.sas
* Date: Thursday, August 28, 2014 at 9:44:22 PM
* Project: Anaconda copper smelter data processing
* Tasks: importing  data from raw text files
* Data in: mtcs_demographic.txt, mtcs_longitudinal.txt  (raw text files with arsenic data given by NCI)
* Data out:
* Description: uses data created by mtcs_split_data_20140901.sh to create sas datasets
* Released under the GNU General Public License: http://www.gnu.org/copyleft/gpl.html
**********************************************************************************************************************/
*clear the log window and the output window;
DM LOG 'clear;' CONTINUE; DM OUT 'clear;' CONTINUE; 
OPTIONS MERGENOBY = warn NODATE NONUMBER LINESIZE = 120  PAGESIZE=80 SKIP = 2 FORMDLIM = '-' MPRINT NOCENTER;
OPTIONS FORMCHAR = '|----|+|---+=|-/\<>*';
%LET progname=mtcs_import_20140828.sas;
/* old stata files
PROC IMPORT DATAFILE = "Z:/EpiProjects/MT_copper_smelters/data/stata/smdat01.dta" DBMS=DTA REPLACE OUT=dg;
PROC IMPORT DATAFILE = "Z:/EpiProjects/MT_copper_smelters/data/stata/smdat02.dta" DBMS=DTA REPLACE OUT=ex;
*/
*LIBNAME mtcs "C:\Users\akeil\Documents\EpiProjects\MT_copper_smelters\data";
LIBNAME mtcs "Z:/EpiProjects/MT_copper_smelters/data";
FILENAME ex "Z:/EpiProjects/MT_copper_smelters/data/mtcs_longitudinal.txt";
FILENAME dg "Z:/EpiProjects/MT_copper_smelters/data/mtcs_demographic.txt";

* Read in the Demographic and Vital Status data;

DATA mtcs.mtcs_dg01 (DROP=term_yy term_mm term_dd dlo_yy dlo_mm dlo_dd dlvs_yy dlvs_mm dlvs_dd);
 INFILE dg LRECL=98 MISSOVER PAD ;
 INPUT
      @1   smid           5.
      @8   dob            yymmdd8.
          @18  hiredate       yymmdd8.
          @28  term_yy        4.
          @32  term_mm        2.
          @34  term_dd        2.
          @38  dlvs_yy        4.
          @42  dlvs_mm        2.
          @44  dlvs_dd        2.
          @48  start_fu       yymmdd8.
          @58  DLO_YY         4.
          @62  DLO_MM         2.
          @64  DLO_DD         2.
          @70  ICD3           3.
          @73  ICDx           1.
          @76  vstat          1.
		  @80  pob            2.
          @88  ASex           1.
          @91  SO2ex          1.
;
 IF dlo_mm=term_mm AND dlo_yy=term_yy THEN dlo_dd=term_dd; *change after performing logic checks;
 ELSE IF dlo_dd=0 THEN dlo_dd=15;
 dlo=MDY(dlo_mm,dlo_dd,dlo_yy);

 IF dlvs_dd=0 THEN dlvs_dd=15;
 dlvs=MDY(dlvs_mm,dlvs_dd,dlvs_yy);

 IF term_mm=11 and term_dd=31 then term_dd=30;
 termdate=MDY(term_mm,term_dd,term_yy);

 LENGTH ICD $ 6;
 IF ICDX = . THEN ICD = TRIM(PUT(ICD3, 3.));
 ELSE ICD = TRIM(PUT(ICD3, 3.0) || "." || PUT(ICDX, 1.0));

 *age at hire/term;
 hireage = YRDIF(dob, hiredate, 'AGE');
 termage = YRDIF(dob, termdate, 'AGE');
 LABEL hireage = "Age at hire (derived from dob, hiredate)"
       termage = "Age at termination (derived from dob, termdate)";

 FORMAT dob hiredate termdate dlo start_fu dlvs mmddyyd10.;
 LABEL smid = 'Smelter Cohort ID'
 dob = 'Date of Birth'
 dlo = 'Date of Last Observation'
 hiredate = 'Date of First Employment'
 termdate = 'Date of Termination'
 dlvs = 'Date of Last Known Status'
 start_fu = 'Start of Follow-up Date'
 asex	 	= 'Arsenic Exposure Code'
 sO2ex = 'SO2 Exposure Code'
 icd3 = 'Underlying Cause of Death [ICD6 pre-1964, ICD8 1964+]'
 icdx = 'ICD Decimal Point'
 icd = 'Full ICD Code (Underlying Cause of Death): ICD6 pre-1964, ICD8 1964+)'
 vstat = 'Vital Status'
 pob = "Place of birth (US=pob<30)";

*exclude 11 workers with term dates prior to start of follow-up;
 *IF smid NOT IN (3703, 4564, 4888, 5886, 7237, 11373, 11374, 17828, 17929, 18273, 19733);
 *save for later;
RUN;



DATA mtcs.mtcs_ex01 ( );
 INFILE ex LRECL=98 MISSOVER PAD ;
 INPUT
  @1   smid           5.
  @9   agein          2.
  @11  aslt           7.
  @18  asmd           7.
  @25  ashi           7.
  @32  asuk           7.
  @39  so2lt          7.
  @46  so2md          7.
  @53  so2hi          7.
  @60  so2uk          7.
  @67  empdur         7.
  @74  cumas          9.
  @83  cumso2         8.
  @94  maxas          2.
  @96  maxso2         3.
;
LABEL agein ='Age at start of person period'
  aslt ='As-light (cumulative duration)'
  asmd ='As-medium (cumulative duration)'
  ashi ='As-heavy (cumulative duration)'
  asuk ='As-unk (cumulative duration)'
  smid ='Smelter Cohort, individual ID'
  so2lt ='SO2-light (cumulative duration)'
  so2md ='SO2-medium (cumulative duration)'
  so2hi ='SO2-heavy (cumulative duration)'
  so2uk ='SO2-unknown (cumulative duration)'
  empdur ='Cumulative duration of employment'
  cumas ='Cumulative rank sum As'
  cumso2 ='Cumulative rank sum SO2'
  maxas ='Maximum rank As'
  maxso2 ='Maximum rank SO2';

*exclude 11 workers with term dates prior to start of follow-up;
 *IF smid NOT IN (3703, 4564, 4888, 5886, 7237, 11373, 11374, 17828, 17929, 18273, 19733);
 *save for later;
RUN;
DM LOG "FILE Z:/EpiProjects/MT_copper_smelters/logs/sas/&progname.log REPLACE" CONTINUE;
DM OUT "FILE Z:/EpiProjects/MT_copper_smelters/output/sas/&progname.lst REPLACE" CONTINUE;
