*clear the log window and the output window;
DM LOG 'clear;' CONTINUE; DM OUT 'clear;' CONTINUE; 
/**********************************************************************************************************************
* Author: Alex Keil
* Program: mtcs_recreate_lubin_20140908.sas
* Date: Monday, September 8, 2014 at 1:48:18 PM
* Project: Anaconda copper smelter, arsenic exposures
* Tasks: Recreate analyses from Jay Lubin
* Data in: Z:/EpiProjects/MT_copper_smelters/data/mtcs_an11.sas7bdat
* Data out:
* Description: follow and recreate analyses from two papers utilizing the Anaconda copper smelter data
* 1) Lubin JH, Moore LE, Fraumeni JF Jr, and Cantor KP. Respiratory cancer and inhaled inorganic arsenic in copper 
*  smelters workers: a linear relationship with cumulative exposure that increases with concentration. Environ 
*  Health Perspect. 2008; 116:1661-5.
* 2) Lubin JH and Fraumeni JF Jr. Re: {"}Does arsenic exposure increase the risk for circulatory disease?". 
*  Am J Epidemiol. 2000; 152:290-3.
* Keywords: arsenic, lung cancer, neoplasm, cardiovascular disease, cvd, occupational, linear rate ratio
* Released under the GNU General Public License: http://www.gnu.org/copyleft/gpl.html
**********************************************************************************************************************/
OPTIONS MERGENOBY = warn NODATE NONUMBER LINESIZE = 120  PAGESIZE=80 SKIP = 2 FORMDLIM = '-' MPRINT NOCENTER;
OPTIONS FORMCHAR = "|----|+|---+=|-/\<>*";
%LET PROGNAME = mtcs_recreate_lubin_201498.sas;
TITLE;
FOOTNOTE "&progname run at &systime on &sysdate";

LIBNAME mtcs "Z:/EpiProjects/MT_copper_smelters/data";


********* BEGIN PROGRAMMING STATEMENTS ************************;

PROC FORMAT CNTLIN=mtcs.mtcs_formats;
*individual data set with expected deaths included;
DATA an_ind;
 SET mtcs.mtcs_an04;
RUN;

*use tabled dataset from maketableddata program;
DATA an;
 SET mtcs.mtcs_an11;
RUN;
DATA anr;
 SET mtcs.mtcs_an12;
RUN;
DATA an_ref;
 SET mtcs.mtcs_an21;
RUN;
DATA anr_ref;
 SET mtcs.mtcs_an22;
RUN;

TITLE "TABLE 1 information";
PROC MEANS DATA = an_ind SUM;
 TITLE2 "Full cohort";
 VAR py d_respcancer;
PROC MEANS DATA = an SUM;
 TITLE2 "Full cohort";
 VAR py d_respcancer;
PROC MEANS DATA = mtcs.mtcs_an03 SUM;
 TITLE2 "Restricted cohort";
 VAR py d_respcancer;
RUN;
PROC MEANS DATA = anr SUM;
 TITLE2 "Restricted cohort";
 VAR py d_respcancer;
RUN;
/*
PROC MEANS DATA = mtcs.mtcs_an02;
 TITLE2 "Cumulative arsenic concentration, concentrations";
 VAR ds01 ;
RUN;

PROC MEANS DATA = mtcs.mtcs_an02 SUM;
TITLE2 "exposure at work, full cohort";
 VAR ds01_ann_dfu py;
 WHERE taw>0;
RUN;
PROC MEANS DATA = mtcs.mtcs_an03 SUM;
TITLE2 "exposure at work, restricted data";
 VAR ds01_ann_dfu py;
 WHERE taw>0;
RUN;
*/


PROC CONTENTS DATA = an;RUN;
TITLE "Respiratory cancer";
PROC GENMOD DATA = an;
 TITLE2 "Crude rate, respiratory cancer";
 MODEL d_respcancer =  / OFFSET=lpy1k D=P LINK=LOG;
 ESTIMATE "rate" INT 1 / EXP;
 ODS SELECT  ModelFit ParameterEstimates Estimates;
RUN;
PROC GENMOD DATA = anr;
 TITLE2 "Crude rate, respiratory cancer (restricted data)";
 MODEL d_respcancer =  / OFFSET=lpy1k D=P LINK=LOG;
 ESTIMATE "rate" INT 1 / EXP;
 ODS SELECT  ModelFit ParameterEstimates Estimates;
RUN;
PROC GENMOD DATA = an;
 TITLE2 "Crude RR model";
 MODEL d_respcancer = cumdose / OFFSET=lpy1k D=P LINK=LOG;
 ESTIMATE "ln(rate ratio)" int 0 cumdose 1 / EXP;
 ODS SELECT  ModelFit ParameterEstimates Estimates;
RUN;
/*
PROC NLMIXED DATA=an ;
 TITLE2 "Crude RR model";
 PARMS beta0 -1.5 beta2 0;
 lambda = lpy1k + beta0 + beta2*cumdose;
 MODEL d_respcancer ~ POISSON(exp(lambda));
 ESTIMATE "rate ratio" exp(beta2);
 ODS SELECT FitStatistics ParameterEstimates AdditionalEstimates;
RUN;
*/
 
 *linear excess relative rate model - crude;
PROC NLMIXED DATA=an ;
 TITLE2 "Crude ERR model";
 PARMS beta0 -0.5 beta2 0;
 eta = beta0 ;
 lambda = exp(eta)*(1 + beta2*cumdose);
 *MODEL d_respcancer ~ POISSON(py1k*lambda); *does not converge;
 MODEL d_respcancer ~ POISSON(py1k*lambda);
 ESTIMATE "rate ratio" (1+beta2);
 ODS SELECT FitStatistics ParameterEstimates AdditionalEstimates;
RUN;


*table 2 data;
PROC NLMIXED DATA=an_ref;
 TITLE2 "Table 2 SMRs (with external rates)";
 TITLE3 "Unadjusted model? (A - crude, overall SMR, 1.56 in Lubin 2008)";
 FOOTNOTE "Cant match directly due to difference between table categories and reported categories";
 lambda = exp(alpha0);
 MODEL d_respcancer ~ POISSON(e_respcancer*lambda);
 ODS SELECT FitStatistics ParameterEstimates AdditionalEstimates;
 ESTIMATE "Crude SMR" exp(alpha0);
RUN;
PROC NLMIXED DATA=an_ind;
 TITLE2 "Table 2 SMRs (with external rates, individual data, ltas rate files)";
 TITLE3 "Unadjusted model? (A - crude, overall SMR, 1.56 in Lubin 2008)";
 FOOTNOTE "Cant match directly due to difference between table categories and reported categories";
 lambda = exp(alpha0);
 MODEL d_respcancer ~ POISSON(e_ltas_respcancer*lambda);
 ODS SELECT FitStatistics ParameterEstimates AdditionalEstimates;
 ESTIMATE "Crude SMR" exp(alpha0);
RUN;
PROC NLMIXED DATA=an_ind;
 TITLE2 "Table 2 SMRs (with external rates, individual data, epicure rate files)";
 TITLE3 "Unadjusted model? (A - crude, overall SMR, 1.56 in Lubin 2008)";
 FOOTNOTE "Cant match directly due to difference between table categories and reported categories";
 lambda = exp(alpha0);
 MODEL d_respcancer ~ POISSON(e_epicure_respcancer*lambda);
 ODS SELECT FitStatistics ParameterEstimates AdditionalEstimates;
 ESTIMATE "Crude SMR" exp(alpha0);
RUN;
PROC NLMIXED DATA=anr_ref;
 TITLE2 "Table 2 SMRs (with external rates)";
 TITLE3 "Unadjusted model? (A - crude, restricted data, overall SMR, 1.87 in Lubin 2008)";
 FOOTNOTE "Cant match directly due to difference between table categories and reported categories";
 lambda = exp(alpha0);
 MODEL d_respcancer ~ POISSON(e_respcancer*lambda);
 ODS SELECT FitStatistics ParameterEstimates AdditionalEstimates;
 ESTIMATE "Crude SMR" exp(alpha0);
RUN;
/*
 VALUE ynf 1="No" 2="Yes";
 VALUE tslef 1 = "0"  2 = "(0,2)"  3 = "[2,5)"  4 = "[5,10)" 5 = "[10,15)" 6 = "[15,20)" 7 = "[20,25)" 8 = "25+";
 VALUE agef 1 = "<45" 2 = "[45,50)" 3 = "[50,55)" 4 = "[55,60)" 5 = "[60,65)" 6 = "[65,70)" 7 = "[70,75)" 8 = "[75,80)" 9 = "80+";
 VALUE yearf 1 = "<1940" 2 = "[1940,1945)" 3 = "[1945,1950)" 4 = "[1950,1955)" 5 = "[1955,1960)" 6 = "[1960,65)" 7 = "[1965,1970)" 
             8 = "[1970,1975)" 9 = "[1975,1980)" 10 = "[1980,1985)" 11 = "1985+";
 VALUE cumdosef 1 = "0" 2 = "(0,0.25)" 3 = "[0.25,0.5)" 4 = "[0.5,0.75)" 5 = "[0.75,1.0)" 6 = "[1.0,1.5)" 7 = "[1.5,2)" 8 = "[2,4)" 9 = "[4,6)" 
                10 = "[6,8)" 11 = "[8,10)" 12 = "[10,12)" 13 = "[12,14)" 14 = "[14,16)" 15 = "[16,18)" 16 = "[18,20)" 17 = "[20,22)" 
                18 = "[22,25)" 19 = "25+";
 VALUE meandosef 1 = "0" 2 = "(0,0.3)" 3 = "[0.3,0.4)" 4 = "[0.4,0.5)" 5 = "[0.5,0.6)" 6 = "[0.6,0.8)" 7 = "[0.8,1.0)" 8 = "1.0+";
*/

PROC NLMIXED DATA=an_ref;
 TITLE2 "Table 2 SMRs (with external rates)";
 TITLE3 "Unadjusted model? (A - crude, overall SMR)";
 FOOTNOTE "Cant match directly due to difference between table categories and reported categories";
 lambda = exp(alpha0)*(1 +/* gamma2*(2<=cumdosecat<=4)*/
                      + gamma3*(4< cumdosecat<=7)
                      + gamma4*(7< cumdosecat<=9)
                      + gamma5*(9< cumdosecat<=11)
                      + gamma6*(11<cumdosecat<=14)
                      + gamma7*(14<cumdosecat));
 MODEL d_respcancer ~ POISSON(e_respcancer*lambda);
 ODS SELECT FitStatistics ParameterEstimates AdditionalEstimates;
 ESTIMATE "Crude SMR in unexposed" exp(alpha0);
RUN;

PROC NLMIXED DATA=an_ref;*(WHERE=(cumdosecat<=3));
 TITLE2 "Table 2 SMRs (with external rates)";
 TITLE3 "Adjusted model?";
 *PARMS alpha0 -0.5 beta2 0;
 *PARMS alphaAge 0;
 eta = alpha0 + alpha1*(yearcat=1) + alpha2*(yearcat=2)+ alpha3*(yearcat=3)+ alpha4*(yearcat=4)+ alpha5*(yearcat=5)
                  + alpha6*(yearcat=6)+ alpha7*(yearcat=7)+ alpha8*(yearcat=8)+ alpha9*(yearcat=9)+ alpha10*(yearcat=10)
                  + alpha11*(yearcat=11) + alphaU*(usborn=2);

 lambda = exp( + eta)*(1 +/* gamma2*(2<=cumdosecat<=4)*/
                      + gamma3*(4< cumdosecat<=7)
                      + gamma4*(7< cumdosecat<=9)
                      + gamma5*(9< cumdosecat<=11)
                      + gamma6*(11<cumdosecat<=14)
                      + gamma7*(14<cumdosecat)
);
 *MODEL d_respcancer ~ POISSON(py1k*lambda); 
 MODEL d_respcancer ~ POISSON(e_respcancer*lambda);
 ODS SELECT FitStatistics ParameterEstimates AdditionalEstimates;
 ESTIMATE "Adjusted SMR in unexposed" exp(alpha0);
RUN;


 *linear excess relative rate model - crude;
PROC NLMIXED DATA=an ;
 TITLE2 "ERR model 1 from Lubin 2008 (without external rates)";
 *PARMS alpha0 -0.5 beta2 0;
 eta = alpha0 ;
 lambda = exp(eta)*(1 + gamma1*cumdose*(meandosecat=1)
                      + gamma2*cumdose*(meandosecat=2)
                      + gamma3*cumdose*(meandosecat=3)
                      + gamma4*cumdose*(meandosecat=4)
                      + gamma5*cumdose*(meandosecat=5)
                      + gamma6*cumdose*(meandosecat=6)
                      + gamma7*cumdose*(meandosecat=7)
                      + gamma7*cumdose*(meandosecat=8)

);
 *MODEL d_respcancer ~ POISSON(py1k*lambda); *does not converge;
 MODEL d_respcancer ~ POISSON(py1k*lambda);
 ODS SELECT FitStatistics ParameterEstimates;
RUN;


*bring in external rates to do model according to Lubin 2008 (See Breslow and Day 1987, p151);
*offset term should be the expected standard deaths = standard rate * person time;
PROC NLMIXED DATA=an_ref ;
 TITLE2 "ERR model 1 from Lubin 2008 (with external rates)";
 *PARMS alpha0 -0.5 beta2 0;
 eta = alpha0 ;
 lambda = exp(eta)*(1 /*+ gamma1*cumdose*(meandosecat=1)*/
                      + gamma2*cumdose*(meandosecat=2)
                      + gamma3*cumdose*(meandosecat=3)
                      + gamma4*cumdose*(meandosecat=4)
                      + gamma5*cumdose*(meandosecat=5)
                      + gamma6*cumdose*(meandosecat=6)
                      + gamma7*cumdose*(meandosecat=7)
                      + gamma7*cumdose*(meandosecat=8)

);
 *MODEL d_respcancer ~ POISSON(py1k*lambda); *does not converge;
 MODEL d_respcancer ~ POISSON(e_respcancer*lambda);
 ODS SELECT FitStatistics ParameterEstimates;
RUN;

/*DM ODSRESULTS 'clear;' CONTINUE; *clear ODS generated datasets;*/

