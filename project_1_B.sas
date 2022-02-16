
/* A- count of our record is more than 100, we have to ad  MAXPOINTS option */
proc corr data=mydata.daily nosimple plots(MAXPOINTS=NONE)=matrix(histogram) fisher;
var registered atemp temp hum windspeed ;
run;

/* B- save residual in output */
proc reg data= mydata.daily plots = diagnostics(unpack);
model registered = atemp / clb;
/* by gender; */
output out=work.daily_res residual=residual_r;
run;

proc reg data= mydata.daily plots = (CooksD RStudentByLeverage DFFITS DFBETAS);
model registered = atemp / clb;

run;

proc corr data=work.daily_res nosimple plots(MAXPOINTS=NONE)=matrix(histogram) fisher;
var residual_r temp hum windspeed;
run;

proc reg data=mydata.daily plots(only)=none;
	model registered=atemp temp hum windspeed / 
		selection=rsquare adjrsq cp best=3;
run;

proc reg data=mydata.daily plots(only)=none;
	model registered=atemp temp hum windspeed / VIF;
	model registered=atemp hum windspeed / VIF;
	run;
proc reg data=mydata.daily plots(label) = diagnostics(unpack);
	id month;
	model registered=atemp hum windspeed;
	run;
proc reg data=mydata.daily plots(label)= (CooksD RStudentByLeverage DFFITS DFBETAS);
	id month;
	model registered=atemp hum windspeed;
	run;
proc reg data=mydata.daily PLOTS=NONE NOPRINT;
  model registered=atemp hum windspeed / influence r;
       output out=daily_output residual=registered_residual rstudent=registered_rstudent 
          h=registered_leverage dffits=registered_dffits cookd=registered_cookd;
run;quit;

proc reg data=daily_output PLOTS=NONE NOPRINT;
  model registered=atemp / influence r;
       output out=daily_output  rstudent=atemp_rstudent 
          h=atemp_leverage dffits=atemp_dffits cookd=atemp_cookd;
run;

proc sgplot data=daily_output;
	series x=dteday y=registered_cookd / curvelabel="three_var" curvelabelpos=max 
		lineattrs=(color=CXf72893) ;
	series x=dteday y=atemp_cookd / curvelabel="atemp" curvelabelpos=max 
		lineattrs=(color=CX1da828)  ;
run;

proc sgplot data=daily_output;
	series x=dteday y=registered_leverage / curvelabel="three_var" curvelabelpos=max 
		lineattrs=(color=CXf72893) ;
	series x=dteday y=atemp_leverage / curvelabel="atemp" curvelabelpos=max 
		lineattrs=(color=CX1da828)  ;
run;

proc sgplot data=daily_output;
	series x=dteday y=registered_dffits / curvelabel="three_var" curvelabelpos=max 
		lineattrs=(color=CXf72893) ;
	series x=dteday y=atemp_dffits / curvelabel="atemp" curvelabelpos=max 
		lineattrs=(color=CX1da828)  ;
run;

title "Observations with large residuals";

proc print data=daily_output ;
	var registered month weekday season dteday;
	where abs(registered_rstudent)>2;
run;

title "Observations with high leverage";

proc print data=daily_output ;
	var registered month weekday season dteday;
	where registered_leverage > 8/731;
run;

title "Observations with high Cook's D values";

proc print data=daily_output ;
	var registered month weekday season dteday;
	where registered_cookd > 4/731;
run;

title "Observations with high dffits values";

proc print data=daily_output ;
	var registered month weekday season dteday;
	where abs(registered_dffits) > 2*sqrt(4/731);
run;


proc sgplot data=mydata.daily;
/* vbar season ; */
/* vbar month; */
vbar weekday;
run;

data daily;
set mydata.daily;
Lregistered= sqrt(registered);
if month= 'February' then February=1; else February=0;
if month= 'March' then March=1; else March=0;
if month= 'April' then April=1; else April=0;
if month= 'May' then May=1; else May=0;
if month= 'June' then June=1; else June=0;
if month= 'July' then July=1; else July=0;
if month= 'August' then August=1; else August=0;
if month= 'September' then September=1; else September=0;
if month= 'October' then October=1; else October=0;
if month= 'November' then November=1; else November=0;
if month= 'December' then December=1; else December=0;

if season= 'summer' then summer=1; else summer=0;
if season= 'fall' then fall=1; else fall=0;
if season= 'winter' then winter=1; else winter=0;

if weekday= 'Saturday' then Saturday=1; else Saturday=0;
if weekday= 'Sunday' then Sunday=1; else Sunday=0;
if weekday= 'Monday' then Monday=1; else Monday=0;
if weekday= 'Tuesday' then Tuesday=1; else Tuesday=0;
if weekday= 'Wednesday' then Wednesday=1; else Wednesday=0;
if weekday= 'Thursday' then Thursday=1; else Thursday=0;

run;


proc reg data=daily plots(label) = diagnostics(unpack);
	id month;
	model registered=atemp hum windspeed workingday yr
	February March April May June July August September October November December
	summer fall winter
	Saturday Sunday Monday Tuesday Wednesday Thursday  / selection=stepwise vif;
	run;
	
proc reg data=daily plots= diagnostics;
	id yr;
	model registered=atemp hum windspeed workingday yr
	May  July  September  November 
	fall winter
	Saturday  Monday ;
	run;

proc reg data=daily PLOTS=NONE NOPRINT;
  model registered=atemp hum windspeed workingday yr
	February March April May June July August September October November December
	summer fall winter
	Saturday Sunday Monday Tuesday Wednesday Thursday / selection=stepwise influence r;
	
       output out=outly residual=registered_residual rstudent=registered_rstudent 
          h=registered_leverage dffits=registered_dffits cookd=registered_cookd;
run;
	

/* proc reg data=outly PLOTS(label) = diagnostics(unpack); */
/* 	where abs(registered_rstudent)<2  */
/* 	and registered_leverage < 52/731  */
/* 	and	registered_cookd < 26/731  */
/* 	and abs(registered_dffits) < 2*sqrt(26/731); */
/* 	 */
/* model registered=atemp hum windspeed workingday yr */
/* 	May  July  September  November  */
/* 	fall winter */
/* 	Saturday  Monday ; */
/* run; */
proc reg data=outly PLOTS(label) = diagnostics(unpack);
id month;
	where abs(registered_rstudent)<2 
	and registered_leverage < 30/731 
	and	registered_cookd < 4/731
	and abs(registered_dffits) < 2*sqrt(30/731);
	
model registered=atemp hum windspeed workingday yr
	May  July  September  November December
	fall winter
	Saturday  Monday ;
run;
proc reg data=outly PLOTS= diagnostics;
id month;
	where abs(registered_rstudent)<3
	and registered_leverage <  30/731
	and	registered_cookd <1
	and abs(registered_dffits) <1;

model registered=atemp hum windspeed workingday yr
	May  July  September  November December
	fall winter
	Saturday  Monday ;
run;

title "Observations with large residuals";

proc print data=outly ;
	var registered month weekday ;
	where abs(registered_rstudent)>2;
run;