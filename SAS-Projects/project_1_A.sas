proc format ;
value TypeF 0='2011' 1='2012';
run;

proc means data=mydata.daily n nmiss mean median std
min max  maxdec=3 q1 q3 kurtosis skewness clm  stderr alpha=0.01;
/* printalltypes; */
var registered;
class yr;
format yr TypeF.;
run;

proc univariate data=mydata.daily noprint;
var registered;
histogram /  nrows=2 ;
/* histogram / normal ; */
/* probplot / normal (mu=est sigma=est); */
/* qqplot/normal(mu=est sigma=est); */
class yr;
format yr TypeF.;
run;

proc sgplot data=mydata.daily;
	hbox registered;
run;

proc sgplot data=mydata.daily;
	hbox registered/group=season;
run;
proc sgplot data=mydata.daily;
	hbox registered/group=yr datalabel=weekday
	fillattrs=fill;
	format yr TypeF.;
run;
proc sgplot data=mydata.daily;
	hbox registered/group=weekday;
run;
proc sgplot data=mydata.daily;
	hbox registered/group=month;
run;

/* proc sgplot data=mydata.daily; */
/* 	series x=dteday y=registered / group=yr; */
/* run; */

proc sgplot data=mydata.daily;
scatter x=dteday y=registered / group=yr;
format yr TypeF.;
run;