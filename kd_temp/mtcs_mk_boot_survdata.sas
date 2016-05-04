* compile bootstrapped survival data into a few key datasets;

LIBNAME boots "/lustre/scr/a/k/akeil/arsenic/boots";
LIBNAME out "/lustre/scr/a/k/akeil/arsenic/out";

%MACRO DS_SELECT(prefix=cidata_age_nc, m=10,n=50, dsopts=);
%GLOBAL ds is;
%LET ds=;
%LET is=;
%LET i=1;

%DO %WHILE(&i<=&m);
	%LET j=1;
	%DO %WHILE(&J<=&N);
		%LET ds=&ds &prefix._&i._&j(IN=in_&i._&j &dsopts);
		%LET is=&is IF in_&i._&j THEN ds="&i._&j"%STR(;);
		%LET j=%EVAL(&j+1);
	%END;
	%LET i=%EVAL(&i+1);
%END;

%MEND;
%MACRO test();
%PUT &ds;
%PUT &is;
%MEND;

%test();

%MACRO age_risk(outdata=out.ncage, pref=boots.cidata_age_nc, age=90);
%DS_SELECT(prefix=&pref, m=10, n=48, dsopts=WHERE=(ageout>=&age) OBS=1);
DATA &outdata;
 LENGTH ds $ 10;
 SET &ds;
&is;
RUN;
%MEND;
%MACRO date_risk(outdata=out.ncdate, pref=boots.cidata_date_nc, date='1jan1980'd);
%DS_SELECT(prefix=&pref, m=10, n=48, dsopts=WHERE=(dateout>=&date) OBS=1);
DATA &outdata;
 LENGTH ds $ 10;
 SET &ds;
&is;
RUN;
%MEND;
OPTIONS MPRINT;
%LET ageint=90;
%LET dateint=1989;
%age_risk(outdata=out.sbootage&ageint.nc, pref=boots.cidata_age_nc, age=&ageint.);;
%age_risk(outdata=out.sbootage&ageint.ne, pref=boots.cidata_age_ne, age=&ageint.);;
%age_risk(outdata=out.sbootage&ageint.obs, pref=boots.cidata_age_obs, age=&ageint.);;
%age_risk(outdata=out.sbootage&ageint.hi, pref=boots.cidata_age_hi, age=&ageint.);;
%age_risk(outdata=out.sbootage&ageint.mid, pref=boots.cidata_age_mid, age=&ageint.);;
%age_risk(outdata=out.sbootage&ageint.lo, pref=boots.cidata_age_lo, age=&ageint.);;
*%date_risk(outdata=out.sbootdate&dateint.nc, pref=boots.cidata_date_nc, date="20jan&dateint."d);;
*%date_risk(outdata=out.sbootdate&dateint.ne, pref=boots.cidata_date_ne, date="20jan&dateint."d);;
*%date_risk(outdata=out.sbootdate&dateint.obs, pref=boots.cidata_date_obs, date="20jan&dateint."d);;
*%date_risk(outdata=out.sbootdate&dateint.hi, pref=boots.cidata_date_hi, date="20jan&dateint."d);;


%LET ageint=80;
%LET dateint=1980;
%age_risk(outdata=out.sbootage&ageint.nc, pref=boots.cidata_age_nc, age=&ageint.);;
%age_risk(outdata=out.sbootage&ageint.ne, pref=boots.cidata_age_ne, age=&ageint.);;
%age_risk(outdata=out.sbootage&ageint.obs, pref=boots.cidata_age_obs, age=&ageint.);;
%age_risk(outdata=out.sbootage&ageint.hi, pref=boots.cidata_age_hi, age=&ageint.);;
%age_risk(outdata=out.sbootage&ageint.mid, pref=boots.cidata_age_mid, age=&ageint.);;
%age_risk(outdata=out.sbootage&ageint.lo, pref=boots.cidata_age_lo, age=&ageint.);;
*%date_risk(outdata=out.sbootdate&dateint.nc, pref=boots.cidata_date_nc, date="20jan&dateint."d);;
*%date_risk(outdata=out.sbootdate&dateint.ne, pref=boots.cidata_date_ne, date="20jan&dateint."d);;
*%date_risk(outdata=out.sbootdate&dateint.obs, pref=boots.cidata_date_obs, date="20jan&dateint."d);;
*%date_risk(outdata=out.sbootdate&dateint.hi, pref=boots.cidata_date_hi, date="20jan&dateint."d);;

%LET ageint=70;
%LET dateint=1970;
%age_risk(outdata=out.sbootage&ageint.nc, pref=boots.cidata_age_nc, age=&ageint.);;
%age_risk(outdata=out.sbootage&ageint.ne, pref=boots.cidata_age_ne, age=&ageint.);;
%age_risk(outdata=out.sbootage&ageint.obs, pref=boots.cidata_age_obs, age=&ageint.);;
%age_risk(outdata=out.sbootage&ageint.hi, pref=boots.cidata_age_hi, age=&ageint.);;
%age_risk(outdata=out.sbootage&ageint.mid, pref=boots.cidata_age_mid, age=&ageint.);;
%age_risk(outdata=out.sbootage&ageint.lo, pref=boots.cidata_age_lo, age=&ageint.);;
*%date_risk(outdata=out.sbootdate&dateint.nc, pref=boots.cidata_date_nc, date="20jan&dateint."d);;
*%date_risk(outdata=out.sbootdate&dateint.ne, pref=boots.cidata_date_ne, date="20jan&dateint."d);;
*%date_risk(outdata=out.sbootdate&dateint.obs, pref=boots.cidata_date_obs, date="20jan&dateint."d);;
*%date_risk(outdata=out.sbootdate&dateint.hi, pref=boots.cidata_date_hi, date="20jan&dateint."d);;

%LET ageint=60;
%LET dateint=1963;
%age_risk(outdata=out.sbootage&ageint.nc, pref=boots.cidata_age_nc, age=&ageint.);;
%age_risk(outdata=out.sbootage&ageint.ne, pref=boots.cidata_age_ne, age=&ageint.);;
%age_risk(outdata=out.sbootage&ageint.obs, pref=boots.cidata_age_obs, age=&ageint.);;
%age_risk(outdata=out.sbootage&ageint.hi, pref=boots.cidata_age_hi, age=&ageint.);;
%age_risk(outdata=out.sbootage&ageint.mid, pref=boots.cidata_age_mid, age=&ageint.);;
%age_risk(outdata=out.sbootage&ageint.lo, pref=boots.cidata_age_lo, age=&ageint.);;
*%date_risk(outdata=out.sbootdate&dateint.nc, pref=boots.cidata_date_nc, date="20jan&dateint."d);;
*%date_risk(outdata=out.sbootdate&dateint.ne, pref=boots.cidata_date_ne, date="20jan&dateint."d);;
*%date_risk(outdata=out.sbootdate&dateint.obs, pref=boots.cidata_date_obs, date="20jan&dateint."d);;
*%date_risk(outdata=out.sbootdate&dateint.hi, pref=boots.cidata_date_hi, date="20jan&dateint."d);;



OPTIONS NOMPRINT;
