/* A */
proc means data=mydata.insurance N mean skewness kurtosis stddev maxdec=3;
var bmi;
class region;
run;

proc sgplot data=mydata.insurance;
vbar Region / response=bmi fillattrs=(color=bib)
limits=both
limitstat=clm numstd=1  stat=Mean;
run; 

proc univariate data=mydata.insurance normaltest;
var bmi;
class region;
histogram / normal(noprint mu=est sigma=est) nrows=3; 
qqplot /normal(mu=est sigma=est);
ods select histogram testsfornormality moments histogram qqplot;
run;

proc glm data=mydata.insurance plots=diagnostics;
class Region;
model bmi=Region/ solution; /* solution gives detail for parameter estimate */
means Region / hovtest Welch Tukey;
lsmeans Region / pdiff adjust=Tukey;
estimate 'Northeast vs other regions' Region 3 -1 -1 -1;
estimate 'Northeast vs Southeast' Region 1 0 -1 0;
estimate 'Northeast vs Northwest' Region 1 -1 0 0;
run;


/* B */

proc corr data=mydata.insurance plots=scatter;
var bmi age;
run;

/* chack for independency assumption */
proc glm data=mydata.insurance;
class region;
model age=Region / solution;
means region / hovtest welch tukey;
run;

proc glm data=mydata.insurance plots=diagnostics;
class region;
model bmi=Region age / solution ss3;
lsmeans region / pdiff adjust=tukey;
run;

proc glm data=mydata.insurance;
class region;
model bmi=Region age Region*age/ solution ss3;
/* lsmeans region / pdiff adjust=tukey; */

run;
