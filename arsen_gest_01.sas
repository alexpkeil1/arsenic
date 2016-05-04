/**********************************************************************************************************************
* Author: Alex Keil
* Program: arsen_gest_01.sas
* Date: 7/16/2012
* Project: Copper smelter cohort - arsenic exposed workers
* Tasks: Apply g-estimation to cohort
* Data in: smdat01.sas7bdat, smdat02.sas7bdat
* Data out:
* Description: 
*TODO fix problem with follow-up time not matching up well - may need to go back to data cleaning files or 
*reconsider how age is defined;
**********************************************************************************************************************/
*clear the log window and the output window;
DM LOG 'clear;' CONTINUE; DM OUT 'clear;' CONTINUE; 
OPTIONS MERGENOBY = warn NODATE NONUMBER LINESIZE = 120 SKIP = 2 FORMDLIM = '-' MPRINT NOCENTER;
OPTIONS FORMCHAR = '|----|+|---+=|-/\<>*';

LIBNAME mtcs "Z:/EpiProjects/MT_copper_smelters/data";

DATA a;
*data to be created;


*POISSON MODEL;
PROC GENMOD DATA = a;
	TITLE "Crude poisson rate model - respiratory cancer";
	MODEL respcan = d_lubin / LINK=log D=p OFFSET=logpy;
	ESTIMATE "Rate ratio" INTERCEPT 0 D_lubin 1;
RUN;

PROC GENMOD DATA = a;
	TITLE "Crude poisson rate model - respiratory cancer";
	MODEL respcan = d_lubin / LINK=log D=p OFFSET=logpy;
	ESTIMATE "Rate ratio" INTERCEPT 0 D_lubin 1;
RUN;


PROC GENMOD DATA = a OUTEST;
	TITLE "Exposure model";
	MODEL d_lubin = in insq incu decade_hire/ LINK=id D=normal ;
RUN;




PROC NLP DATA = gest() OUTEST=grid() OUTGRID OUT=GG OUTITER TECH=NMSIMP BEST=30;
 *PARMS psi1=.5, psi2=1;
 *BOUNDS -1 < psi1-psi2 < 4;
 DECVAR psi1=.1 TO 4 by 0.02, psi2=.1 TO 4 by 0.02;
 RETAIN hk ck U U2 z chisq 0;
 IF lastobs=1 THEN DO;
   hk=day; ck=1825; xk=0;uk=0;c=1825;
 END;
 hk = hk + exp(psi1*gvhd*(day<200) + psi2*gvhd*(day>=200)) - 1;
 ck = day + (1825-day)*EXP(MIN(psi1*0 + psi2*0,psi1*0 + psi2*1,psi1*1 + psi2*0, psi1*1 + psi2*1));
 xk = MIN(hk,ck); *can probably exclude this;
 dk = dobs*(hk<ck);
 uk = ipcw*(gvhd-mx)*dk;
 *uk = ipcw*(gvhd-mx)*dk*xk;
 uksq=uk*uk;
 U = (U+uk);
 U2 = U2+uksq;
 IF eof=1 THEN DO;
  z = (U/SQRT(U2));
  chisq=z*z;
 END;
 MIN CHISQ;
RUN;

RUN;QUIT;RUN;
