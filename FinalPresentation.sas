/* ANOVA of Socio-Economic Status
Kevin Wang */

PROC IMPORT out=dat
    datafile="/home/u63564356/DSCI 507/Final/master_edit.csv"
    dbms=csv replace; getnames=YES;
RUN;

* Descriptive statistics;
PROC MEANS DATA=dat (DROP=hdi_rank_2021) N MEAN MEDIAN STDDEV MIN MAX MAXDEC=2;
RUN;

*Generate histograms of 4 indicators;
proc univariate data=dat NOPRINT;
    var co2_prod_2021;
    histogram;
run;
proc univariate data=dat NOPRINT;
    var gnipc_2021;
    histogram;
run;
proc univariate data=dat NOPRINT;
    var le_2021;
    histogram;
run;
proc univariate data=dat NOPRINT;
    var hdi_2021;
    histogram;
run;

* Scatterplots of 3 other indicators vs HDI;
TITLE "Scatterplot of CO2 Production vs HDI";
proc sgplot data=dat;
    scatter x=co2_prod_2021 y=hdi_2021 / group=continent markerattrs=(symbol=CircleFilled size=10);
run;
TITLE "Scatterplot of GNI vs HDI";
proc sgplot data=dat;
    scatter x=gnipc_2021 y=hdi_2021 / group=continent markerattrs=(symbol=CircleFilled size=10);
run;
TITLE "Scatterplot of Life Expectancy vs HDI";
proc sgplot data=dat;
    scatter x=le_2021 y=hdi_2021 / group=continent markerattrs=(symbol=CircleFilled size=10);
run;
TITLE;

* Check correlation;
PROC CORR DATA = dat (drop=hdi_rank_2021) spearman PLOTS =(SCATTER MATRIX(histogram)) NOSIMPLE;
RUN;

* Tests for normality, output mean and sd for qqplot;
proc univariate data=dat normal;
	VAR hdi_2021;
	CLASS continent;
	output out=Parameters mean=mean std=std;
    run;

* Print out parameters;
proc print data=parameters;
	RUN;

* Sort by continent;
PROC SORT DATA = dat;
	BY continent;
	RUN;

* QQplots with ref line;
PROC UNIVARIATE DATA = dat NOPRINT;
	QQPLOT hdi_2021 /normal(mu=0.5589811321 sigma=0.1044167852);
	WHERE continent='Africa';
	RUN;

PROC UNIVARIATE DATA = dat NOPRINT;
	QQPLOT hdi_2021 /normal(mu=0.7438958333 sigma=0.1214019593);
	WHERE continent='Asia';
	RUN;
	
PROC UNIVARIATE DATA = dat NOPRINT;
	QQPLOT hdi_2021 /normal(mu=0.8787142857 sigma=0.0597446949);
	WHERE continent='Europe';
	RUN;

PROC UNIVARIATE DATA = dat NOPRINT;
	QQPLOT hdi_2021 /normal(mu=0.7493478261 sigma=0.0911864268);
	WHERE continent='North America';
	RUN;

PROC UNIVARIATE DATA = dat NOPRINT;
	QQPLOT hdi_2021 /normal(mu=0.6998461538	 sigma=0.1265252584);
	WHERE continent='Oceania';
	RUN;

PROC UNIVARIATE DATA = dat NOPRINT;
	QQPLOT hdi_2021 /normal(mu=0.7548333333 sigma=0.0544256513);
	WHERE continent='South America';
	RUN;


* For levene's test and Welch;
PROC GLM data=dat;
class continent;
model hdi_2021=continent;
means continent / HOVTEST=levene welch;
run; 

* Anova with CLDIFF;
PROC ANOVA data=dat;
class continent;
Model hdi_2021=continent;
means continent/tukey CLDIFF lines;
run;