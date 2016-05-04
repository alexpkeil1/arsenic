

****** ON HOLD FOR NOW UNTIL G-FORMULA WORK IS DONE ******;



*clear the log window and the output window;
DM LOG 'clear;' CONTINUE; DM OUT 'clear;' CONTINUE; 
/**********************************************************************************************************************
* Author: Alex Keil
* Program: mtcs_snaft1_2014915.sas
* Date: Monday, September 15, 2014 at 12:41:31 PM
* Project: Anaconda copper smelter, arsenic exposures
* Tasks: structural nested model, keeping exposure in original metric
* Data in: 
* Data out:
* Description: fitting structural nested model and using analysis for dynamic regimes (novel?)
* Keywords:
* Released under the GNU General Public License: http://www.gnu.org/copyleft/gpl.html
**********************************************************************************************************************/
OPTIONS MERGENOBY = warn NODATE NONUMBER LINESIZE = 120  PAGESIZE=80 SKIP = 2 FORMDLIM = '-' MPRINT NOCENTER;
OPTIONS FORMCHAR = "|----|+|---+=|-/\<>*";
%LET PROGNAME =	mtcs_snaft1_2014915.sas;
TITLE;
FOOTNOTE "&progname run at &systime on &sysdate";

LIBNAME mtcs "Z:/EpiProjects/MT_copper_smelters/data";
%INCLUDE "Z:/Documents/macros/daspline.sas";
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
*step 0a - some dummy variables;
DATA an;
 SET mtcs.mtcs_an02;
 BY smid agein;
 IF NOT last.smid THEN lastobs=0; ELSE lastobs=1;

 as_score =        (aslt_ann_durdfu>0)  +  2*(asmd_ann_durdfu>0) + 3*(ashi_ann_durdfu>0);
 so2_score =       (so2lt_ann_durdfu>0) +  2*(so2md_ann_durdfu>0) + 3*(so2hi_ann_durdfu>0); 
 as_score_lag1 =   (aslt_ann_durdfu_lag1>0)  +  2*(asmd_ann_durdfu_lag1>0) + 3*(ashi_ann_durdfu_lag1>0);
 so2_score_lag1 =  (so2lt_ann_durdfu_lag1>0)  +  2*(so2md_ann_durdfu_lag1>0) + 3*(so2hi_ann_durdfu_lag1>0); 
 as_score_lag2 =   (aslt_ann_durdfu_lag2>0)  +  2*(asmd_ann_durdfu_lag2>0) + 3*(ashi_ann_durdfu_lag2>0);
 so2_score_lag2 =  (so2lt_ann_durdfu_lag2>0)  +  2*(so2md_ann_durdfu_lag2>0) + 3*(so2hi_ann_durdfu_lag2>0); 
 as_score_lag5 =   (aslt_ann_durdfu_lag5>0)  +  2*(asmd_ann_durdfu_lag5>0) + 3*(ashi_ann_durdfu_lag5>0);
 so2_score_lag5 =  (so2lt_ann_durdfu_lag5>0)  +  2*(so2md_ann_durdfu_lag5>0) + 3*(so2hi_ann_durdfu_lag5>0); 
 as_score_lag10 =  (aslt_ann_durdfu_lag10>0)  +  2*(asmd_ann_durdfu_lag10>0) + 3*(ashi_ann_durdfu_lag10>0);
 so2_score_lag10 = (so2lt_ann_durdfu_lag10>0) +  2*(so2md_ann_durdfu_lag10>0) + 3*(so2hi_ann_durdfu_lag10>0); 
 as_score_lag20 =  (aslt_ann_durdfu_lag20>0)  +  2*(asmd_ann_durdfu_lag20>0) + 3*(ashi_ann_durdfu_lag20>0);
 so2_score_lag20 = (so2lt_ann_durdfu_lag20>0) +  2*(so2md_ann_durdfu_lag20>0) + 3*(so2hi_ann_durdfu_lag20>0);

RETAIN cum_as_score cum_so2_score cum_as_score_lag1 cum_so2_score_lag1 cum_as_score_lag2 cum_so2_score_lag2 
        cum_as_score_lag5 cum_so2_score_lag5 cum_as_score_lag10 cum_so2_score_lag10 cum_as_score_lag20 cum_so2_score_lag20;

 ARRAY anns[*] as_score so2_score as_score_lag1 so2_score_lag1 as_score_lag2 so2_score_lag2 
        as_score_lag5 so2_score_lag5 as_score_lag10 so2_score_lag10 as_score_lag20 so2_score_lag20;

 ARRAY cums[*] cum_as_score cum_so2_score cum_as_score_lag1 cum_so2_score_lag1 cum_as_score_lag2 cum_so2_score_lag2 
        cum_as_score_lag5 cum_so2_score_lag5 cum_as_score_lag10 cum_so2_score_lag10 cum_as_score_lag20 cum_so2_score_lag20;

 IF first.smid THEN DO i = 1 TO DIM(anns);
   cums[i] = anns[i];
 END;
 ELSE DO i = 1 TO DIM(anns);
   cums[i] = cums[i] + anns[i];
 END;
 
 cum_as_1_5 = cum_as_score_lag1-cum_as_score_lag5;
 *cum_so2_1_5 = cum_so2_score_lag1-cum_so2_score_lag5;
 *cum_as_5_10 = cum_as_score_lag5-cum_as_score_lag10;
 *cum_so2_5_10 = cum_so2_score_lag5-cum_so2_score_lag10;;
 *cum_as_10_20 = cum_as_score_lag10-cum_as_score_lag20;;
 *cum_so2_10_20 = cum_so2_score_lag10-cum_so2_score_lag20;;
 cum_as_5_20 = cum_as_score_lag5-cum_as_score_lag20;
 cum_so2_5_20 = cum_so2_score_lag5-cum_so2_score_lag20;

*interactions;
 cumtawdfu_lag1sq = cumtawdfu_lag1*cumtawdfu_lag1;
 hireage_censq = hireage_cen*hireage_cen;
 hireage_cencu = hireage_cen*hireage_censq;
 dob_censq = dob_cen*dob_cen;
 dob_cencu = dob_cen*dob_censq;
 agein_censq = agein_cen*agein_cen;
 agein_cencu = agein_cen*agein_censq;


 anl_1_5 = cum_as_1_5*(1-activework);
 anl_5_20 = cum_as_5_20*(1-activework);
 anl_lag20 = cum_as_score_lag20*(1-activework);
 al = as_score*(activework);
 al_1_5 = cum_as_1_5*(activework);
 al_5_20 = cum_as_5_20*(activework);

 RETAIN timesinceleavework 0;
 IF FIRST.smid THEN timesinceleavework=0;
 IF leavework=1 THEN timesinceleavework=py;
 ELSE IF leavework=0 AND activework=1 AND returnwork=0 THEN timesinceleavework=0;
 ELSE timesinceleavework= timesinceleavework + py;

 IF d_respcancer=1 OR d_allcause=0  THEN d_allothercauses=0;
 IF d_respcancer=0 AND d_allcause=1 THEN d_allothercauses=1;
;
PROC MEANS DATA = an MEAN MIN MAX NOLABELS;
 TITLE "data checks";
 VAR anl_1_5 anl_5_20 anl_lag20 al al_1_5 al_5_20 cum_as_1_5 cum_as_5_20 cum_as_score_lag20 dob_cen dob_cen1 dob_cen2 agein_cen agein_cen1 agein_cen2  hireage_cen hireage_cen1 hireage_cen2;
 CLASS c_ltfu;
RUN;

PROC MEANS DATA = an MEAN MIN MAX NOLABELS;
 VAR anl_1_5 anl_5_20 anl_lag20 al al_1_5 al_5_20 cum_as_1_5 cum_as_5_20 cum_as_score_lag20 dob_cen dob_cen1 dob_cen2 agein_cen agein_cen1 agein_cen2  hireage_cen hireage_cen1 hireage_cen2;
 WHERE tsle=0;
 CLASS leavework;
RUN;
PROC MEANS DATA = an MEAN MIN MAX NOLABELS;
 VAR timesinceleavework anl_1_5 anl_5_20 anl_lag20 al al_1_5 al_5_20 cum_as_1_5 cum_as_5_20 cum_as_score_lag20 dob_cen dob_cen1 dob_cen2 agein_cen agein_cen1 agein_cen2  hireage_cen hireage_cen1 hireage_cen2;
 WHERE returnwork=1 OR activework=0;;
 CLASS returnwork;
RUN;

PROC MEANS DATA = an MEAN MIN MAX NOLABELS;
 VAR anl_1_5 anl_5_20 anl_lag20 al al_1_5 al_5_20 cum_as_1_5 cum_as_5_20 cum_as_score_lag20 dob_cen dob_cen1 dob_cen2 agein_cen agein_cen1 agein_cen2  hireage_cen hireage_cen1 hireage_cen2;
 CLASS d_allothercauses;
RUN;



*step 0b - predictors for each model;
*arsenic exposure;
%LET aspreds = agein_cen agein_cen1 agein_cen2 cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu cumtowbfu hireage_cen dob_cen
         al_1_5 al_5_20;
*leaving work;
%LET lpreds = agein_cen agein_cen1 agein_cen2 cumtawdfu_lag1 
        cumtawdfu_lag1sq cumtowdfu cumtowbfu hireage_cen hireage_cen1 hireage_cen2 dob_cen dob_cen1 dob_cen2
		 cum_as_1_5 cum_as_5_20;
*returning to work;
 %LET rpreds = agein_cen agein_cen1 agein_cen2 cumtawdfu_lag1 timesinceleavework
        cumtawdfu_lag1sq cumtowdfu cumtowbfu hireage_cen hireage_cen1 hireage_cen2 dob_cen dob_cen1 dob_cen2
		 cum_as_1_5 cum_as_5_20;
*death from other causes;
%LET dpreds = agein_cen agein_cen1 agein_cen2 cumtawdfu_lag1 
        cumtawdfu_lag1sq cumtowdfu tsle  cumtowbfu hireage_cen hireage_cen1 hireage_cen2 dob_cen dob_cen1 dob_cen2
        anl_1_5 anl_5_20 al al_1_5 al_5_20;
%LET dpreds_num = agein_cen agein_cen1 agein_cen2 
        anl_1_5 anl_5_20 al al_1_5 al_5_20;

*censoring from loss to follow-up;
%LET cpreds = agein_cen agein_censq agein_cencu cumtawdfu_lag1 cumtawdfu_lag1sq cumtowdfu tsle cumtowbfu hireage_cen hireage_censq hireage_cencu 
               cum_as_5_20 cum_as_score_lag20 dob_cen dob_censq dob_cencu ;
%LET cpreds_num = agein_cen agein_censq agein_cencu 
               cum_as_5_20 cum_as_score_lag20 ;


*step 1 - censoring weights, modeling exposure;
*l v. m. v h.;

/*
*simulated data to test;
 DATA an;
  DO i = 1 TO 1000;
   z= RAND('uniform');
   u = RAND('uniform')/2 + (z-.5);
   IF u<.15 THEN as_ann_ordinal = 0;
   ELSE IF u<.25 THEN as_ann_ordinal = 1;
   ELSE IF u<.5 THEN as_ann_ordinal = 2;
   ELSE IF u>=.5 THEN as_ann_ordinal = 3;
   IF U<0.5 THEN as_ann_binary = 0;
   ELSE as_ann_binary=1;
   OUTPUT;
  END;
*/

*IP censoring weights;
/*
PROC LOGISTIC DATA = an DESCENDING OUT=c_c(DROP=_:); *model also used for simulation purposes, so is fit to full data;
 TITLE 'Pooled logistic model for censoring (denominator)';
 WHERE dateout < '31dec1989'd;
 MODEL c_ltfu = &cpreds;
 OUTPUT OUT=c_den(KEEP=smid agein c_den) P=c_den;
RUN;
PROC LOGISTIC DATA = an DESCENDING; 
 TITLE 'Pooled logistic model for censoring (numerator)';
 WHERE dateout < '31dec1989'd;
 MODEL c_ltfu = &cpreds_num;
 OUTPUT OUT=c_num(KEEP=smid agein c_num) P=c_num;
RUN;
DATA an ;
 MERGE an c_den c_num;
 BY smid agein;
PROC UNIVARIATE DATA = an NOPRINT;
 VAR ipcwu;
 OUTPUT OUT=ipcw_pctls  PCTLPTS=0.2 99.8 PCTLPRE=ipcw_;
DATA an;
 SET an; IF _N_=1 THEN SET ipcw_pctls;
 IF ipcw_0_2<ipcwu<ipcw_99_8 THEN ipcw=ipcwu;
 ELSE IF ipcwu<= ipcw_0_2 THEN ipcw=ipcw_0_2;
 ELSE IF ipcwu>= ipcw_99_8 THEN ipcw=ipcw_99_8;
PROC MEANS DATA = an;
 TITLE 'Inverse probability of censoring weights';
 CLASS activework;
 VAR ipcw ipcwu;
RUN;
PROC SQL OUTOBS=10;
 TITLE2 "extreme weights";
 SELECT smid, agein, ageout, c_ltfu, c_admin, c_num, c_den, ipcw, ipcwu FROM an ORDER BY -ipcwu;
QUIT;
*/
*IP other causes weights;
PROC LOGISTIC DATA = an DESCENDING OUT=c_d(DROP=_:); 
 TITLE 'Pooled logistic model for other causes of death (weight estimation denominator)';
 WHERE dateout < '31dec1989'd;
 MODEL d_allothercauses = &dpreds;
 OUTPUT OUT=d_den(KEEP=smid agein d_den) P=d_den;
PROC LOGISTIC DATA = an DESCENDING; 
 TITLE 'Pooled logistic model for other causes of death (weight estimation numerator)';
 WHERE dateout < '31dec1989'd;
 MODEL d_allothercauses = &dpreds_num;
 OUTPUT OUT=d_num(KEEP=smid agein d_num) P=d_num;
RUN;
DATA an ;
 MERGE an() d_den d_num;
 BY smid agein;
 RETAIN ipcwu1 ipcwu2;
 IF dateout = '31dec1989'd THEN DO; d_num=0; d_den=0; c_num=0; c_den=0; END;
 IF FIRST.smid THEN DO; ipcwu1=1; ipcwu2=1; END;
 ipcwu2 = ipcwu2*(1-d_num)/(1-d_den);
 *ipcwu1 = ipcwu1*(1-c_num)/(1-c_den);
 ipcwu = ipcwu1*ipcwu2;
PROC UNIVARIATE DATA = an NOPRINT;
 VAR ipcwu;
 OUTPUT OUT=ipcw_pctls  PCTLPTS=0.5 99.5 PCTLPRE=ipcw_;
DATA an;
 SET an; IF _N_=1 THEN SET ipcw_pctls;
 IF ipcw_0_5<ipcwu<ipcw_99_5 THEN ipcwst=ipcwu2;
 ELSE IF ipcwu<= ipcw_0_5 THEN ipcwst=ipcw_0_5;
 ELSE IF ipcwu>= ipcw_99_5 THEN ipcwst=ipcw_99_5;
 ipcw=ipcwu;
PROC MEANS DATA = an;
 TITLE 'Inverse probability of censoring weights';
 CLASS activework;
 VAR ipcw ipcwu ipcwu1 ipcwu2;
RUN;
PROC SQL OUTOBS=10;
 TITLE2 "extreme weights";
 SELECT smid, agein, ageout, c_ltfu, c_admin, c_num, c_den, ipcw, ipcwu, ipcwst, ipcwu1, ipcwu2 FROM an ORDER BY -ipcwu;
QUIT;


DATA an_work;
 SET an;
 WHERE activework=1;

*exposure model;
 *fit only to active work person time;
PROC LOGISTIC DATA = an_work DESCENDING OUT=c_a(DROP=_:);
 TITLE "Ordinal logistic model for arsenic exposure (ref=0)";
 CLASS as_ann_ordinal_nl_m_h / PARAM=glm ;
 WHERE activework=1;
 MODEL as_ann_ordinal_nl_m_h =  &ASPREDS;* LINK=glogit;
 OUTPUT OUT =logisticordout PREDPROBS=(i);
RUN;
PROC LOGISTIC DATA = logisticordout DESCENDING;
 TITLE "Ordinary logistic high/md vs. light exposure";
 MODEL as_ann_binary =  &ASPREDS;
 OUTPUT OUT =logisticordout PRED=e_as_ann_binary;
RUN;
DATA logisticordout(DROP=p  _from_ _into_ i _level_);
 SET logisticordout;

 ARRAY ip_[2]; P=IP_0;e_as_ann_ordinal_nl_m_h=0;
 DO i= 1 TO 2;
  p = ip_[i]; e_as_ann_ordinal_nl_m_h = e_as_ann_ordinal_nl_m_h + i*p;
 END;
RUN;


*step 2 - structural nested model;
*-a) bring back outcomes;
DATA logisticordout;
 MERGE logisticordout(IN=ina) mtcs.mtcs_dg02(KEEP=smid y_respcancer);
 BY smid;
 IF ina;
*a) reverse sort data by time;
PROC SORT DATA = logisticordout;
 BY smid DESCENDING agein;

*b) create potential failure time under no exposure;
DATA gest(KEEP=
               smid lastobs activework c_age agein ageout agestop d_respcancer y_respcancer eof aslt_ann_durdfu asmd_ann_durdfu ashi_ann_durdfu 
               as_ann_ordinal as_ann_binary e_as_ann_ordinal_nl_m_h  as_ann_ordinal_nl_m_h e_as_ann_binary py ipcw IP_: &ASPREDS
          );
 SET logisticordout end=_eof;
 BY smid DESCENDING agein;
 IF _eof=0 THEN eof=0;
 ELSE eof=1;
 ipcw=1;
 IF first.smid THEN DO;   
  lastobs=1;
 END;
 ELSE lastobs=0;
 OUTPUT GEST;
RUN;

*find psi-hat using nelder-mead or grid search;
PROC NLP DATA = gest() OUTEST=grid(RENAME=(_RHS_=chi2) WHERE=(_TYPE_='GRIDPNT')) OUTGRID OUT=GG OUTITER TECH=NONE BEST=30;
 TITLE "SNAFT - binary exposure";
 *PARMS psi1=.5;
 *BOUNDS -1 < psi1 < 4;
 smid = smid;*ensures this makes it into output dataset;
 ageout=ageout;
 DECVAR psi1=-0 TO 3 by 0.01;
 RETAIN hk ck U U2 z chisq 0;
 IF lastobs=1 THEN DO;
   hk=agestop; ck=c_age; xk=0;uk=0;;
 END;
 hk = hk + py*exp(psi1*as_ann_binary ) - py;
 ck = agein + (c_age-agein)*EXP(MIN(psi1*0, psi1*1));
 *xk = MIN(hk,ck); *can probably exclude this;
 dk = y_respcancer*(hk<ck);
 uk = ipcw*(as_ann_binary-e_as_ann_binary)*dk;
 uksq=uk*uk;
 U = (U+uk);
 U2 = U2+uksq;
 IF eof=1 THEN DO;
  z = (U/SQRT(U2));
  chisq=z*z;
 END;
 MIN chisq;
RUN;

ODS GRAPHICS / RESET=index;
PROC SGPLOT DATA = GRID;
 TITLE "Binary current exposure: high/med vs. low/none";
 SERIES x=psi1 y = chi2;
 XAXIS MAX=1.0 MIN=0.0;
 YAXIS MAX=10 MIN=0;
RUN;

*trying with PROC OPTMODEL for a better selection of nonlinear optimizers;
PROC OPTMODEL;
 TITLE "SNAFT - binary exposure (OPTMODEL), global solution + confidence limits";
 ODS SELECT printtable;
 SET OBS;
 NUMBER y{OBS}, t{OBS}, py{OBS}, x{OBS}, e_x{OBS}, lo{OBS}, ct{OBS}, smid{obs}, ppend{OBS};
 READ DATA gest INTO OBS=[_N_] y=y_respcancer x=as_ann_binary e_x=e_as_ann_binary lo=lastobs t=agestop ppend=ageout py=py ct=c_age smid;
 VAR psi1 INIT -1 >= 0 <= 4;
 IMPVAR hk{i IN OBS} = py[i]*(EXP(psi1*x[i]) - 1) + IF lo[i] = 1 THEN t[i] ELSE hk[i-1];  
 IMPVAR ck{i IN OBS} = (t[i]-py[i]) + (ct[i]- (t[i]-py[i]))*EXP(MIN(psi1*0,psi1*1));  
 IMPVAR dk{i IN OBS} = y[i]*(hk[i]<ck[i]);
 IMPVAR uk{i IN OBS} = (x[i]-e_x[i])*dk[i];
 IMPVAR uk2{i IN OBS} = uk[i]*uk[i];
 IMPVAR U = SUM{i IN OBS} uk[i];
 IMPVAR U2 = SUM{i IN OBS} uk2[i];
 MIN chisq = u**2 / u2;
 SOLVE WITH NLP / MULTISTART MSNUMSTARTS=200 PRINTFREQ=1 MAXITER=5000;
 CREATE DATA ggo FROM [i]=OBS smid[i] hk[i] ck[i] dk[i] uk[i] uk2[i] agestop=t[i] as_ann_binar=x[i] e_as_ann_binary=e_x[i] lastobs=lo[i] ageout=ppend[i];
 CREATE DATA psihat FROM psihat=psi1.sol chihat=chisq.sol;
 PRINT 'Solution' psi1.sol chisq.sol;
 *QUIT;
 *uncomment next lines to do a line search for confidence limits;
 /*
 VAR chiup INIT 0;
 VAR chidown INIT 0;
 VAR upper95 INIT 0;
 VAR lower95 INIT 0;
 VAR psihat INIT 0; VAR chihat INIT 0;
 FIX psihat = psi1.sol;
 FIX chihat = chisq.sol;
 NUMBER increment = .1;
      *upper bound;
	   VAR ub INIT 0;
       DO WHILE (chiup <3.84);
	    * READ DATA psihat INTO psihat chihat;
          FIX ub=ub+1;
          FIX PSI1 = ub*increment + psihat ; 
          SOLVE WITH NLP; 
          FIX chiup = chisq.sol;
          FIX upper95 = psi1.sol;
       END;
       CREATE DATA ggoup FROM [i]=OBS hk[i] ck[i] dk[i];
	   *lower bound;
	   VAR lb INIT 0;
       DO WHILE (chidown <3.84);
 	    * READ DATA psihat INTO psihat chihat;
          FIX lb=lb+1; 
          FIX PSI1 = - lb*increment + psihat; 
          SOLVE WITH NLP; 
          FIX chidown = chisq.sol; FIX lower95 = psi1.sol;
       END; 
       CREATE DATA ggolo FROM [i]=OBS hk[i] ck[i] dk[i];
PRINT 'confidence bounds' psihat 4.3 lower95 4.3 upper95 4.3 chihat 4.3  chidown 4.3 chiup 4.3;
 */
QUIT;
/*
DATA bounds;
 MERGE ggoup(RENAME=(hk=hk_up ck=ck_up dk=dk_up)) ggolo(RENAME=(hk=hk_lo ck=ck_lo dk=dk_lo));
 BY i;
DATA ggo;
 MERGE ggo bounds;
 BY i;
*/
*checking estimating equation answer versus logistic model with potential outcome;
DATA an_psihat;
 MERGE ggo(DROP=i) gest;
 BY smid DESCENDING ageout;

PROC LOGISTIC DATA = an_psihat DESCENDING;
 TITLE "Ordinary logistic model as estimating function (check estimating equation approach)";
 TITLE2 "estimate";
 MODEL as_ann_binary =  &ASPREDS dk;
 WEIGHT ipcw;
 ODS SELECT parameterestimates;
RUN;
/*
PROC LOGISTIC DATA = an_psihat DESCENDING;
 TITLE2 "lower bound";
 MODEL as_ann_binary =  &ASPREDS dk_lo;
 ODS SELECT parameterestimates;
RUN;
PROC LOGISTIC DATA = an_psihat DESCENDING;
 TITLE2 "upper bound";
 MODEL as_ann_binary =  &ASPREDS dk_up;
 ODS SELECT parameterestimates;
RUN;
*/

*multiple parameters - can't be done in NLP due to need for matrix inversion;
OPTIONS CMPLIB=work.misc;
PROC FCMP outlib=work.misc.matfuns;
*function to take matrix inverse in proc optmodel;
*https://communities.sas.com/thread/39257;
 SUBROUTINE myinv(x[*,*],y[*,*]);
  OUTARGS y;
  CALL INV(x,y);
 ENDSUB;
QUIT;
*multi-dimensional psi;
PROC OPTMODEL;
 SET OBS, DIMEX=1..2;
 NUMBER y{OBS}, t{OBS}, py{OBS}, x{OBS}, new_ex{OBS, DIMEX}, lo{OBS}, ct{OBS}, smid{obs}, ppend{obs};
 READ DATA gest INTO OBS=[_N_] y=y_respcancer x=as_ann_ordinal_nl_m_h lo=lastobs t=agestop ppend=ageout py=py ct=c_age smid;
 READ DATA gest INTO OBS=[_N_]  {j in DIMEX} < new_ex[_N_,j] = COL('IP_'|| j) >;
 VAR psi{DIMEX} INIT 1 >= -2 <= 10;
 NUMBER new_x{i IN OBS, j in DIMEX} = IF x[i]=j THEN 1 ELSE 0; *if X is given as ordinal variable;
 NUMBER rangex{DIMEX, j in 1..2} = IF j=1 THEN 1 ELSE 0 ; *max (col 1) , min (col 2) of x variables;
 IMPVAR rsk{i IN OBS} = SUM{v in DIMEX} psi[v]*new_x[i,v]; *psi1 corresponds to ordinal variable = 2;
 *need to find a shorthand for csk;
* IMPVAR csk = MIN(
  psi[1]*rangex[1,1] +  psi[2]*rangex[2,1]+  psi[3]*rangex[3,1], psi[1]*rangex[1,1] +  psi[2]*rangex[2,1]+  psi[3]*rangex[3,2],
  psi[1]*rangex[1,1] +  psi[2]*rangex[2,2]+  psi[3]*rangex[3,1], psi[1]*rangex[1,1] +  psi[2]*rangex[2,2]+  psi[3]*rangex[3,2],
  psi[1]*rangex[1,2] +  psi[2]*rangex[2,1]+  psi[3]*rangex[3,1], psi[1]*rangex[1,2] +  psi[2]*rangex[2,1]+  psi[3]*rangex[3,2],
  psi[1]*rangex[1,2] +  psi[2]*rangex[2,2]+  psi[3]*rangex[3,1], psi[1]*rangex[1,2] +  psi[2]*rangex[2,2]+  psi[3]*rangex[3,2]);
 IMPVAR csk = MIN(
  psi[1]*rangex[1,1] +  psi[2]*rangex[2,1], psi[1]*rangex[1,1] +  psi[2]*rangex[2,1],
  psi[1]*rangex[1,1] +  psi[2]*rangex[2,2], psi[1]*rangex[1,1] +  psi[2]*rangex[2,2],
  psi[1]*rangex[1,2] +  psi[2]*rangex[2,1], psi[1]*rangex[1,2] +  psi[2]*rangex[2,1],
  psi[1]*rangex[1,2] +  psi[2]*rangex[2,2], psi[1]*rangex[1,2] +  psi[2]*rangex[2,2]);
 IMPVAR hk{i IN OBS} = py[i]*(EXP(rsk[i]) - 1) + IF lo[i] = 1 THEN t[i] ELSE hk[i-1];  
 IMPVAR ck{i IN OBS} = (t[i]-py[i]) + (ct[i]- (t[i]-py[i]))*EXP(csk);  
 IMPVAR dk{i IN OBS} = y[i]*(hk[i]<ck[i]);
 IMPVAR tdpsi = SUM{i IN OBS} dk[i];
 NUMBER ty = SUM{i IN OBS} y[i];
 IMPVAR penalty = IF tdpsi/ty<0.1 THEN 1 ELSE 0; *disallow values that cause extreme loss of information;
 IMPVAR uk{i IN OBS, j IN DIMEX} = (new_x[i,j]-new_ex[i,j])*dk[i];
 IMPVAR U{j IN DIMEX} = SUM{i IN OBS} uk[i,j];
 IMPVAR vU{j IN DIMEX,k IN DIMEX} = SUM{i IN OBS} uk[i,j]*uk[i,k];*uk times uk_t;
 *need to get U*INV(VU)*Utranspose;
 NUMBER ivU {K IN DIMEX, J IN DIMEX};
 CALL myinv(vU,ivU);
 IMPVAR chi2a {k IN DIMEX} = SUM{l IN DIMEX} U[k]*ivU[l,k]; *result is [1,k] matrix (same as U);
 MIN chisq = SUM{k in DIMEX} chi2a[k]*U[k] + penalty*9999; *result is 1x1;
 SOLVE WITH NLP / MULTISTART MSNUMSTARTS=1000 PRINTFREQ=1 MSDISTTOL=1E-8;
 PRINT 'Best solution';
 PRINT 'Psi:' psi.sol 'chi^2:' chisq;
 PRINT U; 
 PRINT vU;
 PRINT ivU;
 PRINT chi2a;
 CREATE DATA ggo2 FROM [i]=OBS smid[i] hk[i] ck[i] dk[i]{j in DIMEX}<COL("psihat" || j)=psi[j]> agestop=t[i]  
                       ageout=ppend[i] as_ann_ordinal=x[i] {j in DIMEX}<COL("Res_xcat" || j)=(new_x[i,j]-new_ex[i,j])> 
                        lastobs=lo[i];
QUIT;

DATA an_psihat2;
 MERGE ggo2 gest;
 BY smid DESCENDING ageout;

PROC LOGISTIC DATA = an_psihat2 DESCENDING;
 TITLE "Generalized logistic (ref=0)";
 CLASS as_ann_ordinal_nl_m_h / PARAM=glm;
 MODEL as_ann_ordinal_nl_m_h =  &ASPREDS dk;* /  LINK=glogit;
 WEIGHT ipcw;
RUN;


*simulating from structural model for a dynamic regime (robins et al 2009, e.g.);
*step 1: E(Y_(g=0)];
PROC SORT DATA = an_psihat2 OUT=counter(KEEP = smid agestop agein y_respcancer dk hk ck ps:);
 BY smid agein;
DATA counter;
 SET counter;
 BY smid agein;
 IF first.smid;
 RENAME dk = d0 hk=h0 ck=c0;
 x0 = MIN(hk, ck);
RUN;

OPTIONS SYMBOLGEN;
/* from log
Knots for dob_cen:-2.072864256 -0.355359027 0.4300665453 1.3027616255
Knots for hiredate_cen:-2.215400191 -0.073961767 0.4888263125 1.119248876
Knots for hireage_cen:-1.111636011 -0.599663658 0.2668678969 2.0869890832
*/
 %DASPLINE(agein_cen hiredate_cen hireage_cen, 
           knot1=-1.0 -0.5 0.5 1.0, 
           knot2=-1.0 -0.5 0.5 1.0,
           knot3=-1.0 -0.5 0.5 1.0, DATA=an, norm=2);
PROC MEANS DATA = an;
 VAR agein;
 OUTPUT OUT = ai_cen MEAN=ageinmean STD=ageinstd;
DATA _null_; SET ai_cen; CALL SYMPUT("ageinmean", PUT(ageinmean, BEST9.)); CALL SYMPUT("ageinstd", PUT(ageinstd, BEST9.));

DATA an;
 SET an;
  agein_cen = (agein-&ageinmean)/&ageinstd;*derived from active work time;
 &_agein_cen ;
 &_hiredate_cen ;
 &_hireage_cen ;
RUN;
OPTIONS NOSYMBOLGEN;

*step 2 - parametric model for f[l(k)|a(k-1),l(k-1)];

PROC LOGISTIC DATA = an DESCENDING OUT=c_l(DROP=_:); 
 TITLE 'Pooled logistic model for leaving work';
 WHERE activework=1 OR leavework=1;
 MODEL leavework = &lpreds;
PROC LOGISTIC DATA = an DESCENDING OUT=c_r(DROP=_:); 
 TITLE 'Pooled logistic model for returning to work';
 WHERE activework=0 OR returnwork=1;
 MODEL returnwork = &rpreds;
 RUN;
/* already done above
PROC LOGISTIC DATA = an DESCENDING OUT=c_d(DROP=_:); 
 TITLE 'Pooled logistic model for other causes of death';
 MODEL d_allothercauses = &dpreds;
RUN;
 */
/* already done above
PROC LOGISTIC DATA = an DESCENDING OUT=c_c(DROP=_:); 
 TITLE 'Pooled logistic model for censoring';
 MODEL c_ltfu = &cpreds;
RUN;
*/
%MACRO count();
%GLOBAL rmod lmod dmod cmod amod nr nl nd nc na;
%LET i=1; %LET rmod=_r1; ;%DO %UNTIL(%SCAN(&rpreds, %EVAL(&i), " ")=);
   %LET rmod=&rmod + _r%EVAL(&i+1) * %SCAN(&rpreds, %EVAL(&i), " "); %LET i = %EVAL(&i+1); 
 %END;%LET nr = &i;
%LET i=1; %LET lmod=_l1; ;%DO %UNTIL(%SCAN(&lpreds, %EVAL(&i), " ")=);
   %LET lmod=&lmod + _l%EVAL(&i+1) * %SCAN(&lpreds, %EVAL(&i), " "); %LET i = %EVAL(&i+1); 
 %END;%LET nl = &i;
%LET i=1; %LET dmod=_d1; %DO %UNTIL(%SCAN(&dpreds, %EVAL(&i), " ")=);
   %LET dmod=&dmod + _d%EVAL(&i+1) * %SCAN(&dpreds, %EVAL(&i), " ");  %LET i = %EVAL(&i+1); 
%END;%LET nd = &i;
%LET i=1; %LET cmod=_c1; %DO %UNTIL(%SCAN(&cpreds, %EVAL(&i), " ")=);
   %LET cmod=&cmod + _c%EVAL(&i+1) * %SCAN(&cpreds, %EVAL(&i), " ");  %LET i = %EVAL(&i+1); 
%END;%LET nc = &i;
%LET i=1; %LET amod=_a1 + _a2; %DO %UNTIL(%SCAN(&aspreds, %EVAL(&i), " ")=);
   %LET amod=&amod + _a%EVAL(&i+2) * %SCAN(&aspreds, %EVAL(&i), " ");  %LET i = %EVAL(&i+1); 
%END;%LET na = &i;
%MEND;
%COUNT;
*check log for what the data generating models look like;
DATA _NULL_;
 nd=&ND;
 nc=&NC;
 nl=&NL; 
 na=&Na;
 nr=&Nr;
 d = "&DMOD";
 c = "&CMOD";
 l = "&LMOD";
 a = "&aMOD";
 r = "&rMOD";
 PUT na a;
 PUT nc c;
 PUT nd d;
 PUT nl l;
 PUT nr r;
run;




DATA c_r2; SET c_r;
 ARRAY coefs[*] intercept &rpreds; ARRAY _r[&nr];
 DO j = 1 TO DIM(coefs); _r[j] = coefs[j];END;
 DROP &rpreds intercept j;
DATA c_l2; SET c_l;
 ARRAY coefs[*] intercept &lpreds; ARRAY _l[&nl];
 DO j = 1 TO DIM(coefs); _l[j] = coefs[j];END;
 DROP &lpreds intercept j;
DATA c_d2; SET c_d;
 ARRAY coefs[*] intercept &dpreds;ARRAY _d[&nd];
 DO j = 1 TO DIM(coefs);_d[j] = coefs[j];END;
 DROP &dpreds intercept j;
DATA c_c2; SET c_c;
 ARRAY coefs[*] intercept &cpreds;ARRAY _c[&nc];
 DO j = 1 TO DIM(coefs); _c[j] = coefs[j];END;
 DROP &cpreds intercept j;
RUN;
DATA c_a2; SET c_a;
 ARRAY coefs[*] intercept_1 intercept_2 &aspreds;ARRAY _a[%EVAL(&na+1)];
 DO j = 1 TO DIM(coefs); _a[j] = coefs[j];END;
 DROP &aspreds intercept_1 intercept_2 j;
RUN;

/*
PROC LOGISTIC DATA = an DESCENDING; 
 TITLE 'Pooled logistic model for returning to work';
 WHERE activework=0 OR returnwork=1;
 MODEL returnwork = &lpreds;
RUN;
*/

*step 3 - simulate cohort through time;

 DATA an2;
  SET an;
  BY smid agein;
  IF first.smid;
  KEEP smid agein agein_cen: &aspreds &lpreds &dpreds &cpreds c_age y_respcancer;

PROC SURVEYSELECT DATA=counter SEED=864527 OUT=counter_sample METHOD=URS N=300000 OUTHITS;
RUN;


DATA sim_cohort;
  MERGE an2(DROP=agein_cen: ) counter_sample(KEEP=smid d0 h0 c0 x0 psihat: IN=inb);
  BY smid;
  IF _n_=1 THEN SET c_r2;
  IF _n_=1 THEN SET c_l2;
  IF _n_=1 THEN SET c_d2;
  IF _n_=1 THEN SET c_c2;
  IF _n_=1 THEN SET c_a2;
  IF NOT inb THEN DELETE; *drops 11 observations with no work history during follow up;
RUN;

PROC MEANS DATA = sim_cohort NMISS;
 TITLE 'check for missing data';
RUN;
DATA sim_natcourse sim_always sim_never sim_nc_lastobs sim_al_lastobs sim_ne_lastobs; 
 LENGTH intervention smid agein ageout done as_score rsk activework leavework returnwork d_allothercauses d_respcancer 8;
 SET sim_cohort;
 CALL STREAMINIT(1232);
 DO intervention = 1 TO 3;

*a - draw l(0) from f(l(0));
   *done by sampling from cohort;

  *b - recursively draw l, a for treatment regime g;
  *initial levels of time varying variables;
  ageinst=agein;
  done=0;
  cumtawdfu_lag1=0;
  cumtawdfu_lag1sq=0;
  cumtawdfu=0;
  cumtowdfu=0;
  d_other=0;
  activework=1;
  leavework=0;
  leavework_lag1=0;
  py=1;
  tsle=0;
  timesinceleavework=0;
  jobchg=0;
  cumpy=0;
  cum_as_1_5=0; 
  cum_as_5_20=0;
  anl_1_5=0;
  anl_5_20=0;
  anl_lag20=0; 
  al=0; 
  al_1_5=0; 
  al_5_20=0;
  cum_as_score_lag20=0;
  cum_as_score=0;
  _chk=agein;

  ARRAY _cumas[3,20] _TEMPORARY_; *for lags;
  DO i = 1 TO 20; _cumas[intervention,i] = 0; END;


  DO WHILE (agein<c_age AND done=0);
  /* time variables */
   agein_cen = (agein-&ageinmean)/&ageinstd;*derived from active work time;
   agein_censq  = agein_cen*agein_cen;
   agein_cencu = agein_cen*agein_censq;
   &_agein_cen ; *make spline variables using knots defined above;
  /*  */

    *returning to work;
    xb_r = &rmod;
	IF activework=0 THEN DO;
    /*	*/
	 timesinceleavework=timesinceleavework+1;
	 returnwork = RAND('BERNOULLI', 1/(1+exp(MIN(700,-xb_r))));
	 IF returnwork THEN DO;activework=1; jobchg=1; END;
	END;
	IF returnwork_lag1=1 THEN DO;
	 jobchg=0;
     returnwork=0;
	END;
	
	*leaving employment (part of the dynamic intervention);
	IF activework=1 THEN DO;
    /*	*/
	 IF not jobchg THEN returnwork=0;
	 timesinceleavework=0;
     xb_l = &lmod;
	 leavework = RAND('BERNOULLI', 1/(1+exp(MIN(700,-xb_l))));
	 cumtawdfu = cumtawdfu + (1-leavework);
	END;
	IF leavework_lag1=1 THEN DO;
     leavework=0;
	 activework=0;
     timesinceleavework=1;
    END;
	
  /*  */
  /* intervention variables */
   IF activework=0 THEN DO;
	tsle=tsle+1;
	as_score=0;
   END;
   ELSE IF activework=1 THEN DO;
   *DYNAMIC INTERVENTION: natural course;
   IF intervention = 1 THEN DO;
	p_a2 =  1/(1+exp(-(MIN(700,&amod - _a1)))); *probability as>1;
    p_a1 = 1/(1+exp(-(MIN(700,&amod - _a2)))) - p_a2; *probability 0>as>=1;
    p_a0 = 1-p_a1-p_a2; *probability arsenic is light at work;
    as_score = rand('table', p_a0, p_a1, p_a2);
   END;
   *DYNAMIC INTERVENTION: if at work, expose to high levels of arsenic;
    IF intervention = 2 THEN as_score=3;
   *DYNAMIC INTERVENTION: if at work, remain unexposed;
	ELSE IF intervention = 3 THEN as_score=1;
    IF as_score>0 THEN tsle=0;
   END;
    aslt_ann_durdfu = (as_score=1);
    asmd_ann_durdfu = (as_score=2);
    ashi_ann_durdfu = (as_score=3);

  DO i = 20 TO 2 BY -1; 
   _cumas[intervention,i]=_cumas[intervention,i-1]; *lag everything one year;
  END;
  _cumas[intervention,1]=cum_as_score;

   cum_as_score = as_score + cum_as_score;
   al = as_score*activework;

 *lagged exposures using temporary array;  
   cum_as_1_5 =(_cumas[intervention,1]-_cumas[intervention,5]);
   cum_as_5_20 = (_cumas[intervention,5]-_cumas[intervention,20]);
   cum_as_score_lag20 = _cumas[intervention,20];
   anl_1_5=(cum_as_1_5)*(1-activework);
   anl_5_20=(cum_as_5_20)*(1-activework);
   anl_lag20=cum_as_score_lag20*(1-activework); 
   al_1_5=(cum_as_1_5)*activework; 
   al_5_20=(cum_as_5_20)*activework;

   /* l variables */
   /* censoring (loss to follow up) */
   	xb_c = &cmod;
   * ltfu = RAND('BERNOULLI', 1/(1+exp(MIN(700,-xb_c)))); *intervene to prevent censoring;
	ltfu=0;*real natural course, done=0;
    IF ltfu THEN DO; done=1; END; 

	/* death from other causes     */
	xb_d = &dmod;
	d_allothercauses = RAND('BERNOULLI', 1/(1+exp(MIN(700,-xb_d))));
	IF d_allothercauses THEN DO; done=1; END;



  /*structural model*/
	rsk = psihat1*asmd_ann_durdfu + psihat2*ashi_ann_durdfu;
	*rsk = 0;
    _chk = _chk + exp(rsk);
    IF x0 <= _chk THEN DO;
      d_respcancer=y_respcancer;
      ageout = agein + (x0-(_chk - exp(rsk)))*exp(-(rsk));
	  done=1;
    END;*t0 <= _chk;
    ELSE DO;
	 d_respcancer=0;
     ageout = MIN(agein+1, c_age, 90);
	 IF ageout=90 THEN done=1;
    END;
  /*  */
	IF NMISS(activework, rsk, d_respcancer, d_allothercauses)>0 THEN DO;
     PUT "Something is wrong";
	LEAVE;
    END;
	py = ageout-agein;
	cumpy = cumpy + py;
    IF intervention = 1 THEN OUTPUT sim_natcourse  ;
    ELSE IF intervention = 2 THEN OUTPUT sim_always;
    ELSE IF intervention = 3 THEN OUTPUT sim_never;
  *lagged variables;
	cum_as_scorelag1 = cum_as_score;
	cumtawdfu_lag1 = cumtawdfu;
	cumtawdfu_lag1sq = cumtawdfu_lag1*cumtawdfu_lag1;
	agein=ageout;
	leavework_lag1=leavework;
	returnwork_lag1=returnwork;
  END;*DO WHILE (agein<c_age);
  IF done THEN DO; 
    IF intervention = 1 THEN OUTPUT sim_nc_lastobs ;
    ELSE IF intervention = 2 THEN OUTPUT sim_al_lastobs ;
    ELSE IF intervention = 3 THEN OUTPUT sim_ne_lastobs;
	agein=ageinst; *needed to allow all interventions in single step;
  END;
END; *intervention = 1 to 3;
RUN;
PROC MEANS DATA = an NOLABELS;
 TITLE "observed data";
 VAR d_respcancer d_allothercauses c_ltfu cum_as_score tawdfu cumpy py activework ageout;
PROC MEANS DATA = sim_natcourse NOLABELS;
 TITLE "simulated data - natural course";
 VAR d_respcancer d_allothercauses ltfu cum_as_score activework cumpy py activework ageout;
PROC MEANS DATA = sim_nc_lastobs NOLABELS;
 TITLE "simulated data, last observations only - natural course";
 VAR d_respcancer d_allothercauses ltfu cum_as_score activework cumpy py activework ageout;
DATA anlast;
 SET an;
 BY smid ageout;
 IF last.smid;
PROC MEANS DATA = anlast NOLABELS;
 TITLE "observed data, last observations only";
 VAR d_respcancer d_allothercauses c_ltfu cum_as_score tawdfu cumpy py activework ageout;
PROC MEANS DATA = sim_al_lastobs NOLABELS;
 TITLE "simulated data - if at work, always exposed to high levels";
 VAR d_respcancer d_allothercauses ltfu cum_as_score activework cumpy py activework ageout;
PROC MEANS DATA = sim_ne_lastobs NOLABELS;
 TITLE "simulated data, never exposed";
 VAR d_respcancer d_allothercauses ltfu cum_as_score activework cumpy py activework ageout;
RUN;


*exporting data for survival curve plotting;
PROC EXPORT DATA = anlast(KEEP=smid agestart ageout d_respcancer d_allothercauses) 
 OUTFILE ="Z:/EpiProjects/MT_copper_smelters/output/SNAFT_kmpics/snaft_observed.csv" DBMS=csv REPLACE; RUN;
PROC EXPORT DATA = sim_nc_lastobs(KEEP=smid ageinst ageout d_respcancer d_allothercauses) 
 OUTFILE ="Z:/EpiProjects/MT_copper_smelters/output/SNAFT_kmpics/snaft_natcourse.csv" DBMS=csv REPLACE; RUN;
PROC EXPORT DATA = sim_ne_lastobs(KEEP=smid ageinst ageout d_respcancer d_allothercauses) 
 OUTFILE ="Z:/EpiProjects/MT_copper_smelters/output/SNAFT_kmpics/snaft_no_exposure_at_work.csv" DBMS=csv REPLACE; RUN;
PROC EXPORT DATA = sim_al_lastobs(KEEP=smid ageinst ageout d_respcancer d_allothercauses) 
 OUTFILE ="Z:/EpiProjects/MT_copper_smelters/output/SNAFT_kmpics/snaft_hi_exposure_at_work.csv" DBMS=csv REPLACE; RUN;


*plotting survival curves;
/*
*proc lifetest does not work for late entry;

ODS LISTING CLOSE;
PROC LIFETEST DATA = sim_nc_lastobs;
  TIME ageout*d_respcancer(0);
  ODS OUTPUT productlimitestimates = plest(WHERE=(survival NE .));
PROC LIFETEST DATA = sim_nc_lastobs;
  TIME ageout*d_allothercauses(0) ;
  ODS OUTPUT productlimitestimates = plest2(WHERE=(survival NE .));
PROC LIFETEST DATA = sim_al_lastobs;
  TIME ageout*d_respcancer(0) ;
  ODS OUTPUT productlimitestimates = plest3(WHERE=(survival NE .));
PROC LIFETEST DATA = sim_al_lastobs;
  TIME ageout*d_allothercauses(0) ;
  ODS OUTPUT productlimitestimates = plest4(WHERE=(survival NE .));
PROC LIFETEST DATA = sim_ne_lastobs;
  TIME ageout*d_respcancer(0) ;
  ODS OUTPUT productlimitestimates = plest5(WHERE=(survival NE .));
PROC LIFETEST DATA = sim_ne_lastobs;
  TIME ageout*d_allothercauses(0) ;
  ODS OUTPUT productlimitestimates = plest6(WHERE=(survival NE .));
PROC LIFETEST DATA = anlast;
  TIME ageout*d_respcancer(0) ;
  ODS OUTPUT productlimitestimates = plest_obs(WHERE=(survival NE .));
PROC LIFETEST DATA = anlast;
  TIME ageout*d_allothercauses(0) ;
  ODS OUTPUT productlimitestimates = plest_obs2(WHERE=(survival NE .));
RUN;
*/

/*
DATA pl;
 SET plest (IN=ina) plest2 (IN=inb) plest_obs(IN=inc) plest_obs2(IN=ind)
plest3 (IN=ine) plest4 (IN=inf)  plest5 (IN=ing) plest6 (IN=inh);
 LENGTH dat outcome $32;
 IF ina THEN dat="Natural course, MN resp";
 ELSE IF inb THEN dat="Natural course, Other causes";
 ELSE IF inc THEN dat="Observed, MN resp";
 ELSE IF ind THEN dat="Observed, Other causes";
 ELSE IF ine THEN dat="If at work high exposure, MN resp";
 ELSE IF inf THEN dat="If at work high exposure, Other causes";
 ELSE IF ing THEN dat="If at work no exposure, MN resp";
 ELSE IF inh THEN dat="If at work no exposure, Other causes";
 IF ina OR inc OR ine OR ing THEN outcome="MN resp";
 IF inb OR ind OR inf OR inh THEN outcome="Other causes";
 onems = 1-survival;
 LABEL onems = "1-KM" ageout="Age";
RUN;

ODS LISTING  GPATH = "Z:\EpiProjects\MT_copper_smelters\output\SNAFT_kmpics\" STYLE=LISTING;
ODS GRAPHICS ON / RESET=INDEX IMAGENAME="SNAFT_dynamic_respcan";
PROC SGPLOT DATA = pl;
 WHERE 35 < ageout < 91;;
 TITLE; FOOTNOTE;
 STEP X=ageout Y=onems / GROUP=dat LINEATTRS=(THICKNESS=3) TRANSPARENCY=.25;
RUN;
PROC SGPLOT DATA = pl;
 WHERE 35 < ageout < 91 AND outcome="Other causes";
 TITLE; FOOTNOTE;
 STEP X=ageout Y=onems / GROUP=dat LINEATTRS=(THICKNESS=3) TRANSPARENCY=.25;
RUN;
PROC SGPLOT DATA = pl;
 WHERE 35 < ageout < 91 AND outcome = "MN resp";
 TITLE; FOOTNOTE;
 STEP X=ageout Y=onems / GROUP=dat LINEATTRS=(THICKNESS=3) TRANSPARENCY=.25;
RUN;
ODS GRAPHICS OFF;
*/
RUN;QUIT;RUN;
/*DM ODSRESULTS 'clear;' CONTINUE; *clear ODS generated datasets;*/
