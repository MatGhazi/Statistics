/* A */
data insurance;
set mydata.insurance;
log_charges=log(charges);
run;

proc sgplot data=insurance;
vbar children / response=log_charges fillattrs=(color=big)
limits=both
limitstat=clm numstd=1  stat=Mean;
run; 

proc univariate data=insurance normaltest;
var log_charges;
class children;
histogram / normal(noprint mu=est sigma=est) nrows=3; 
qqplot /normal(mu=est sigma=est);
ods select histogram testsfornormality  moments histogram qqplot;
run;

proc glm data=insurance plots=diagnostics;
class children;
model log_charges=children/ solution; /* solution gives detail for parameter estimate */
means children / hovtest Welch Tukey;
lsmeans children / pdiff adjust=Tukey;
estimate '0 children vs 1 children' children 1 0 -1 0 0 0 ;
estimate '1 children vs 3 children' children 0 1 0 -1 0 0;
estimate '1 children vs 2 children' children 0 1 -1 0 0 0;
estimate '1 children vs 2 children' children 0 1 0 0 -1 0;
run;

/* B */

proc means data=insurance;
var log_charges;
class children smoker;
run;

proc sgplot data=insurance;
vbar smoker / group= children groupdisplay=cluster response=log_charges stat=mean
limits= both limitstat=clm;
/* format female genderF.; */
run;

/* Assume assumption for factorial ANOVA is satisfied */
proc glm data=insurance plots=diagnostics;
class children smoker;
model log_charges=children | smoker / ss3 solution; /* another form: model write=ses female ses*female */
lsmeans children | smoker / pdiff adjust=tukey; /* post hoc */
/* Simple interaction effects */
lsmeans children * smoker / slice=children; 
lsmeans children * smoker / slice=smoker;
/* format female genderF.; */
run;

