*clear the log window and the output window;
DM LOG 'clear;' CONTINUE; DM OUT 'clear;' CONTINUE; 
/**********************************************************************************************************************
* Author: Alex Keil
* Program: mtcs_maketableddata_201498.sas
* Date: Monday, September 8, 2014 at 2:22:04 PM
* Project: Anaconda copper smelter, arsenic exposures
* Tasks: make person-time tables using data from anaconda copper smelter data
* Data in: 
* Data out:
* Description: based on macro taken from my sas program x5_MACRO_enddateshift_03292013.sas, which was originally based
*  on code developed for analysis of Oak Ridge National Labs worker data at UNC.
*  Adaptations: making usable for a single data, person period data set
* Based on lubin 2008, tables should be created by:
*  attained age (9 levels, 45-80, 5 year categories)
*  calendar year (10 levels, 35-90, 5 year categories)
*  cumulative exposure (18 levels, < 0.25, 0.25-0.49, 0.50-0.74, 0.75-0.99, 1.0-1.4, 1.5-1.9, 2.0-3.9, . . . , 22-24.9, - 25)
*  mean arsenic concentration (8 levels, 0, 0.01-0.29, 0.3-0.39, 0.4-0.49, 0.5-0.59, 0.6-0.79, 0.8-0.99, - 1.0)
*  years since last arsenic exposure (three levels: < 5, 5-14, - 15)
*  place of birth (two levels: U.S. or foreign born)
* Keywords:
* Released under the GNU General Public License: http://www.gnu.org/copyleft/gpl.html
**********************************************************************************************************************/
OPTIONS MERGENOBY = warn NODATE NONUMBER LINESIZE = 120  PAGESIZE=80 SKIP = 2 FORMDLIM = '-' MPRINT NOCENTER;
OPTIONS FORMCHAR = "|----|+|---+=|-/\<>*";
%LET PROGNAME = mtcs_maketableddata_201498.sas;
TITLE;
FOOTNOTE "&progname run at &systime on &sysdate";

LIBNAME mtcs "Z:/EpiProjects/MT_copper_smelters/data";


********* BEGIN PROGRAMMING STATEMENTS ************************;
DATA antest;
 SET mtcs.mtcs_an02;
 WHERE smid<100;
RUN;

/*********************** make_py_table MACRO USAGE **********************************************************************
INPUT: 
OUPUT: 

USAGE NOTES: 
Parameter values for macro call:
%make_py_table(
*data set names*
  indata=,     *analysis file, input*
  outdata=,    *name of tabled data, output*

*study characteristics*
  datein=datein,    *start time for person period, sas date*
  dateout=dateout,    *end time for person period, sas date*
  datefe=, *date of first exposure exposure begins accumulating, sas date*
  datele=, *date at last exposure, sas date*
  workind=, *indicator of active employment (0=unemployed, employed otherwise)*

 *table stratification controls*
  agecenter = ,   *centering term for age variables (centered age = age-&agecenter)*
  agegroups=,   *group cutpoints - age, include numbers outside variable range*
  cumdosegroups=,  *group cutpoints - cumulative dose, include numbers outside variable range *
  dategroups=,   * group cutpoints - calendar year cutpoints for grouping, include numbers outside variable range* 
  tslegroups=,   *  group cutpoints - time since last exposure groups, include numbers outside variable range * 
  meandosegroups = ,  * group cutpoints - mean dose, include numbers outside variable range *

 * Input data set variables *
  pybeginvar = ,   *date at which follow up starts*
  ppexvar=,      *person-period period specific exposure variable (WITH LAG ALREADY PRESENT)*
  ppcumexvar=,      *person-period cumulative exposure variable (WITH LAG ALREADY PRESENT)*
  dlovar = ,   *date of last observation, sas date*
  dobvar=,    *date of birth, sas date*
  vsvar = ,    *person-period specific vital status variable, should be 1=died during period - other values don't matter*
  outcomes=   *list of counted outcomes (other than all cause mortality) in tabled data set*
)
********************************* END MACRO USAGE ********************************************************************/
%MACRO make_py_table(

/*data set names*/
  indata=,     /*analysis file, input*/
  outdata=,    /*name of tabled data, output*/

/*study characteristics*/
  datein=datein,    /*start time for person period, sas date*/
  dateout=dateout,    /*end time for person period, sas date*/
  datefe=, /*date of first exposure exposure begins accumulating, sas date*/
  datele=, /*date at last exposure, sas date*/
  workind=, /*indicator of active employment (0=unemployed, employed otherwise)*/

 /*table stratification controls*/
  agecenter = ,   /*centering term for age variables (centered age = age-&agecenter)*/
  agegroups=,   /*group cutpoints - age, include numbers outside variable range*/
  cumdosegroups=,  /*group cutpoints - cumulative dose, include numbers outside variable range */
  dategroups=,   /* group cutpoints - calendar year cutpoints for grouping, include numbers outside variable range*/ 
  tslegroups=,   /*  group cutpoints - time since last exposure groups, include numbers outside variable range */ 
  meandosegroups = ,  /* group cutpoints - mean dose, include numbers outside variable range */

 /* Input data set variables */
  pybeginvar = ,   /*date at which follow up starts*/
  ppexvar=,      /*person-period period specific exposure variable (WITH LAG ALREADY PRESENT)*/
  ppcumexvar=,      /*person-period cumulative exposure variable (WITH LAG ALREADY PRESENT)*/
  dlovar = ,   /*date of last observation, sas date*/
  dobvar=,    /*date of birth, sas date*/
  vsvar = ,    /*person-period specific vital status variable, should be 1=died during period - other values don't matter*/
  outcomes=   /*list of counted outcomes (other than all cause mortality) in tabled data set*/
);


*****************************************************************************;
DATA &outdata(KEEP = __:);
 SET &indata
    END=EOF ;
 BY SMID;
*TODO add back some counters;
	%LET i=1;
	%DO %UNTIL(%SCAN(&outcomes, %EVAL(&i+1), " ")=);
		%LET i = %EVAL(&i+1);
	%END;
	%LET numoutcomes=&i;	

 ** ARRAY TO COUNT PERSON-DAYS AND SUM DOSE **;
 ** type: 1=person days, 2=summed age,  3= summed log centered age  4= time since last exposure   5=total dose 6=summed calendar time, 7=person years, 8= all deaths, 8+=other outcomes **;
 **  (TYPE,agecat,calyearcat,cumdosecat,meandosecat,tslecat,usborn,atwork_)  **;
 *ARRAY C[%EVAL(9+&numoutcomes),9,10,18,8,3,2,2]  _TEMPORARY_;
 ARRAY C[%EVAL(9+&numoutcomes),9,11,18,8,3,2,2]  _TEMPORARY_;
* cumdosecat=1;
 _i_incdose=0; *incremental dose ***new***;
 _i_cumdose=0; *cumulative dose with incremental dose included ***new***;
 atwork_=1;
 daysinperiod = &dateout-&datein;

 *LAGGED VARIABLES;
 RETAIN lagcum lagtfe lagtle 0;
 IF first.smid THEN DO; lagcum=0;lagtfe=0;lagtle=0; END;
 ********************  MAIN COUNTING LOOP  *****************;
 *counts up by day, defines age, calendar year, employment status, cumulative dose categories and interpolated values;
  DO dy = FLOOR(&datein) TO FLOOR(&dateout) BY 1;
   IF dy=&datein THEN period_day_idx=0;
        ELSE period_day_idx=period_day_idx+1;

  *** age groups**;  
   age=MAX(0,YRDIF(&dobvar, dy, 'ACT/ACT'));
   age_lc = LOG(age/&agecenter);
    %LET i=1;
    %DO %UNTIL(%SCAN(&agegroups, %EVAL(&i+1))=);
     IF %SCAN(&agegroups, &i, " ") <= age < %SCAN(&agegroups, %EVAL(&i+1), " ") 
     THEN agecat=&i; 
     %LET i = %EVAL(&i+1);
    %END;
   *** calendar year groups ** ;
    caly=YEAR(dy);
    %IF %TRIM(&dategroups)^= %THEN %DO; *unimplemented in tables;
    %LET i=1;
    %DO %UNTIL(%SCAN(&dategroups, %EVAL(&i+1))=);
     IF %SCAN(&dategroups, &i, " ") <= caly < %SCAN(&dategroups, %EVAL(&i+1), " ") 
     THEN calyearcat=&i; 
     %LET i = %EVAL(&i+1);
    %END;
    %END;

   ***cumulative person-time of exposure**;
    _i_cumpy = MAX(0,YRDIF(&datefe, dy, 'ACT/ACT'));

    *** exposure **;
    *add incremental dose to cumulative dose from previous period;
    _i_incdose = &ppexvar / daysinperiod;
    _i_cumdose =  lagcum+_i_incdose*(daysinperiod-period_day_idx);

	*** employment status **;
    IF &workind > 0 THEN atwork_ = 2;
    ELSE atwork_=1;

	*usborn;
	_usborn = usborn + 1;

  *** cumulative dose groups **;
  %LET i=1;
  %DO %UNTIL(%SCAN(&cumdosegroups, %EVAL(&i+1), " ")=);
   IF %SCAN(&cumdosegroups, &i, " ") <= _i_cumdose < %SCAN(&cumdosegroups, %EVAL(&i+1), " ") 
   THEN cumdosecat=&i; 
   %LET i = %EVAL(&i+1);
  %END;

  *** mean dose groups **;
   IF _i_cumpy>0 THEN _i_mndose=_i_cumdose/_i_cumpy;
  ELSE _i_mndose=0; %LET i=1;
  %DO %UNTIL(%SCAN(&meandosegroups, %EVAL(&i+1), " ")=);
   IF %SCAN(&meandosegroups, &i, " ") <= _i_mndose < %SCAN(&meandosegroups, %EVAL(&i+1), " ") 
   THEN meandosecat=&i; 
   %LET i = %EVAL(&i+1);
  %END;

  **time since last exposure groups**;
	_i_tsle = MAX(0,YRDIF(&datele, dy-(daysinperiod-period_day_idx), 'ACT/ACT'));
  %LET i=1;
  %DO %UNTIL(%SCAN(&tslegroups, %EVAL(&i+1), " ")=);
   IF %SCAN(&tslegroups, &i, " ") <= _i_tsle < %SCAN(&tslegroups, %EVAL(&i+1), " ") 
   THEN tslecat=&i; 
   %LET i = %EVAL(&i+1);
  %END;



  *cumulating variables by table indices;
  C[1,agecat,calyearcat,cumdosecat,meandosecat,tslecat,_usborn,atwork_] + 1; *total days at risk in category;
  C[2,agecat,calyearcat,cumdosecat,meandosecat,tslecat,_usborn,atwork_] + age; *summed age in category;
  C[3,agecat,calyearcat,cumdosecat,meandosecat,tslecat,_usborn,atwork_] + age_lc; *summed log, centered age in category;
  C[4,agecat,calyearcat,cumdosecat,meandosecat,tslecat,_usborn,atwork_] + _i_tsle; *summed time since last exposure;
  C[5,agecat,calyearcat,cumdosecat,meandosecat,tslecat,_usborn,atwork_] + _i_cumdose; *total dose in category;
  C[6,agecat,calyearcat,cumdosecat,meandosecat,tslecat,_usborn,atwork_] + 1969 + YRDIF('01jan1969'd , dy, 'ACT/ACT'); *summed calendar years in category;
  C[7,agecat,calyearcat,cumdosecat,meandosecat,tslecat,_usborn,atwork_] + YRDIF(dy, dy+1, 'ACT/ACT'); *total years at risk in category;
  C[8,agecat,calyearcat,cumdosecat,meandosecat,tslecat,_usborn,atwork_] + _i_mndose ; *summed mean dose in category;
  *todo: mean exposure, mean calendar year (may be done in next data step);

  *C[9,agecat,calyearcat,cumdosecat,meandosecat,tslecat,usborn,atwork_]; *number of deaths in category (below);
  *C[10,agecat,calyearcat,cumdosecat,meandosecat,tslecat,usborn,atwork_] + MAX(0,afe-age); *total years of exposure in category;
 END;  ****** END MAIN COUNTING LOOP******;

 **** generate deaths from all causes, specific causes ** ;
 IF &vsvar = 1 THEN DO;
  C[9,agecat,calyearcat,cumdosecat,meandosecat,tslecat,_usborn,atwork_]+1;*any death;  
 %LET i=1;
 %DO %UNTIL(%SCAN(&outcomes, %EVAL(&i), " ")=);
  IF %SCAN(&outcomes, %EVAL(&i), " ")=1 THEN
   C[%EVAL(9+&i),agecat,calyearcat,cumdosecat,meandosecat,tslecat,_usborn,atwork_]+1; 
  %LET i = %EVAL(&i+1);
 %END;
 END;  ** End IF VS = D  Loop for classifying dths **;

*outputting tabled data;
 IF EOF THEN 
 DO __ageidx= 1 TO 9; *age;
  DO __yearidx = 1 to 10; *calendar year groups;
   DO __cumdoseidx =1 to 18;*cumulative dose groups;
    DO __meandoseidx = 1 to 8;*mean dose groups;
     DO __tsleidx = 1 to 3;*time since last exposure (years), groups;
     DO __usbornidx = 1 to 2;*us born;
     DO __atworkidx = 1 to 2;*at work;

      IF C[1,__ageidx,__yearidx,__cumdoseidx,__meandoseidx,__tsleidx,__usbornidx, __atworkidx] > 0 THEN DO;
        __totpy=C[7,__ageidx,__yearidx,__cumdoseidx,__meandoseidx,__tsleidx,__usbornidx, __atworkidx];
        dum2=c[9,__ageidx,__yearidx,__cumdoseidx,__meandoseidx,__tsleidx,__usbornidx, __atworkidx]; 
        __ndeaths=sum(dum2,0);*number of total deaths;

         %LET i=1;
         %DO %UNTIL(%SCAN(&outcomes, %EVAL(&i), " ")=);        
          dum%EVAL(9+&i)=C[%EVAL(9+&i),__ageidx,__yearidx,__cumdoseidx,__meandoseidx,__tsleidx,__usbornidx,__atworkidx]; *outcome list of interest;
          __%SCAN(&outcomes, %EVAL(&i), " ")=SUM(dum%EVAL(9+&i) , 0);
          %LET i = %EVAL(&i+1);
         %END;
        
		 *TODO: FIGURE OUT THIS;
		  *cumulative dose mean (py weighted);
         dumext=(c[5,__ageidx,__yearidx,__cumdoseidx,__meandoseidx,__tsleidx,__usbornidx,__atworkidx]);
         __ext=SUM(dumext,0); *cumulative dose total;
         __mext =__ext/(c[1,__ageidx,__yearidx,__cumdoseidx,__meandoseidx,__tsleidx,__usbornidx,__atworkidx]);

         *mean dose mean (py weighted);
		 dumexc=(c[8,__ageidx,__yearidx,__cumdoseidx,__meandoseidx,__tsleidx,__usbornidx,__atworkidx]);
         __exc=SUM(dumexc,0); *mean dose total;
         __mexc =__exc/(c[1,__ageidx,__yearidx,__cumdoseidx,__meandoseidx,__tsleidx,__usbornidx,__atworkidx]); 

         *mean calendar year (py weighted);
		 dumcal=(c[6,__ageidx,__yearidx,__cumdoseidx,__meandoseidx,__tsleidx,__usbornidx,__atworkidx]);
         __cal=SUM(dumcal,0); *cumulative dose total;
         __mcal =__cal/(c[1,__ageidx,__yearidx,__cumdoseidx,__meandoseidx,__tsleidx,__usbornidx,__atworkidx]);

         *mean years since last exposure (py weighted);
         dumtle=(c[4,__ageidx,__yearidx,__cumdoseidx,__meandoseidx,__tsleidx,__usbornidx,__atworkidx]);
         __tle=SUM(dumtle,0); *cumulative dose total;
         __mtle =__tle/(c[1,__ageidx,__yearidx,__cumdoseidx,__meandoseidx,__tsleidx,__usbornidx,__atworkidx]);

         *mean age (py weighted);
         dumage=(c[2,__ageidx,__yearidx,__cumdoseidx,__meandoseidx,__tsleidx,__usbornidx,__atworkidx]);
         __ag=SUM(dumage,0); 
         __meanage = __ag/( c[1,__ageidx,__yearidx,__cumdoseidx,__meandoseidx,__tsleidx,__usbornidx,__atworkidx] ); 

         *mean log, centered age (py weighted);
         dumage_lc=(c[3,__ageidx,__yearidx,__cumdoseidx,__meandoseidx,__tsleidx,__usbornidx,__atworkidx]);
         __lcag=SUM(dumage_lc,0); 
         __lcag2 =__lcag/( c[1,__ageidx,__yearidx,__cumdoseidx,__meandoseidx,__tsleidx,__usbornidx,__atworkidx] ); 

         OUTPUT;
       END;** end IF C(1,__ageidx,__yearidx,__cumdoseidx,__meandoseidx,__tsleidx,__usbornidx,__atworkidx) > 0  loop **;
      END;*__atworkidx;
      END;*__usbornidx; 
      END;*__tsleidx;  
    END;*__meandoseidx;
   END;*__cumdoseidx;
  END;*__yearidx;
 END; *__ageidx;
 *lagged variables;
 lagcum=&ppcumexvar;
 lagtfe=&datefe;
 lagtle=&datele;
RUN;

DATA &outdata;
 SET &outdata;
 RENAME __ageidx = agecat
        __yearidx = yearcat
        __cumdoseidx = cumdosecat
        __meandoseidx = meandosecat
        __tsleidx = tslecat
        __usbornidx = useborn
        __atworkidx = atwork
		__ag = tot_age
		__meanage = age
		__lcag = tot_agelc
		__lcag2 = agelc
		__ext = tot_cumex
		__mext = cumex
		__totpy = py
		__ndeaths = deaths
		__exc = tot_meanex
		__mexc = meanex
		__tle = tot_tsle
		__mtle = tsle
		__cal = tot_caltime
		__mcal = caltime
		deaths = d_allcause
;

        %LET i=1;
        %DO %UNTIL(%SCAN(&outcomes, %EVAL(&i), " ")=);        
         RENAME __%SCAN(&outcomes, %EVAL(&i), " ") = %SCAN(&outcomes, %EVAL(&i), " ");
         %LET i = %EVAL(&i+1);
        %END;


%MEND make_py_table;



* Based on lubin 2008, tables should be created by:
*  attained age (9 levels, 45-80, 5 year categories)
*  calendar year (10 levels, 35-90, 5 year categories) [I count 11]
*  cumulative exposure (18 levels, < 0.25, 0.25-0.49, 0.50-0.74, 0.75-0.99, 1.0-1.4, 1.5-1.9, 2.0-3.9, . . . , 22-24.9, - 25)
*  mean arsenic concentration (8 levels, 0, 0.01-0.29, 0.3-0.39, 0.4-0.49, 0.5-0.59, 0.6-0.79, 0.8-0.99, - 1.0)
*  years since last arsenic exposure (three levels: < 5, 5-14, - 15)
*  place of birth (two levels: U.S. or foreign born);
OPTIONS NOSYMBOLGEN;
%MAKE_PY_TABLE(
/*data set names*/
  indata=mtcs.mtcs_an02,     /*analysis file, input*/
  outdata=an11,    /*name of tabled data, output*/

/*study characteristics*/
  datein=datein,    /*start time for person period, sas date*/
  dateout=dateout,    /*end time for person period, sas date*/
  datefe=tfe, /*date of first exposure exposure begins accumulating, sas date*/
  datele=tle, /*date at last exposure, sas date*/
  workind=taw, /*indicator of active employment (0=unemployed, employed otherwise)*/

 /*table stratification controls*/
  agecenter = 50,   /*centering term for age variables (centered age = age-&agecenter)*/
  agegroups = 0 45 50 55 60 65 70 75 80 200,   /*group cutpoints - age, include numbers outside variable range*/
  dategroups = 1600 1940 1945 1950 1955 1960 1965 1970 1975 1980 1985 2100,   /* group cutpoints - calendar year cutpoints for grouping, include numbers outside variable range*/ 
  cumdosegroups = -0.001 0.25 0.5 0.75 1 1.5 2 4 6 8 10 12 14 16 18 20 22 25 10e8,  /*group cutpoints - cumulative dose, include numbers outside variable range */
  meandosegroups = -0.001 .01 .3 .4 .5 .6 .8 1 10e8,  /* group cutpoints - mean dose, include numbers outside variable range */
  tslegroups = -0.001 5 15 200,   /*  group cutpoints - time since last exposure groups, include numbers outside variable range */ 

 /* Input data set variables */
  pybeginvar = start_fu,   /*date at which follow up starts*/
  ppexvar = ds01_ann_dfu,      /*person-period period specific exposure variable (WITH LAG ALREADY PRESENT)*/
  ppcumexvar = ds01,      /*person-period cumulative exposure variable (WITH LAG ALREADY PRESENT)*/
  dlovar = dlo,   /*date of last observation, sas date*/
  dobvar = dob,    /*date of birth, sas date*/
  vsvar = d_allcause,    /*person-period specific vital status variable, should be 1=died during period - other values don't matter*/
  outcomes= d_lungcancer d_cvd   /*list of counted outcomes (other than all cause mortality) in tabled data set*/
 );


DATA mtcs.mtcs_an11;
 SET an11;
 lpy = log(py);

 LABEL agecat="Age category"
      yearcat="Calender time category"
      cumdosecat="Cumulative dose category"
      meandosecat="Mean dose category"
      tslecat="Time since last exposure category"
      useborn="Born in US"
      atwork="Active work status"
      tot_age="Total age in category"
      age="Mean age in category"
      tot_agelc="Total log(centered age) in category"
      agelc="Mean log(centered age) in category"
      tot_cumex="Total cumulative exposure in category"
      cumex="Mean cumulative exposure in category"
      py="Total person time in category"
	  lpy = "LN(total person time in category)"
      d_allcause="Number of deaths in category"
      tot_meanex="Total average exposure in category"
      meanex="Mean average exposure in category"
      tot_tsle="Total time since last exposure in category"
      tsle="Mean time since last exposure in category"
      tot_caltime="Total calendar time in category"
      caltime="Mean calendar time in category";
;

PROC FREQ DATA = an11;
 TABLES d_lungcancer d_cvd d_allcause;
RUN;


PROC CONTENTS DATA = mtcs.mtcs_an11;
 TITLE "Contents of table data set";
RUN;QUIT;RUN;
/*DM ODSRESULTS 'clear;' CONTINUE; *clear ODS generated datasets;*/

