# Prevalence of Cannabis Use Disorder Post Legalization - Uruguay Case Study

 Author: [Camilo Vargas](https://www.github.com/cvas91)

**Licence and Acknowledgements**

To construct the SCM for this paper, the *synth* package in Stata developed by Abadie et al. (2011) was implemented following the guidelines of Cunningham (2021).

### Abstract:
- Uruguay was the first country to legalize cannabis for recreational consumption in 2013. Its effects have been a public health concern in the last decade across the continent as more countries examine similar strategies. 
- This paper aims to measure the post-legalization impact on the prevalence of cannabis use disorder among Uruguayan consumers by constructing a synthetic control method covering data from 1990 to 2017 through 19 Latin American countries. 
- The findings suggest that the prevalence of cannabis use disorder decreased in Uruguay after the legalization. However, these results are not unique since placebo tests indicate that other countries would have experienced similar outcomes. 
- Thus, it cannot be confirmed that the decreasing effect in the prevalence of cannabis disorders is only due to the legalization in 2013. 
- The added value of this paper is to add empirical econometric research to public health studies in Latin America. For further analysis and discussion, the full printed version of this project is available upon request.

### Motivation
- Abuse of illegal substances is a global struggle that significantly impacts individuals and society. 
- Roth et al. (2018) reported that worldwide smoking, alcohol, and illicit drug use kill directly and indirectly 11.8 million people annually, exceeding the total number of deaths caused by all types of cancer. 
- Direct deaths from alcohol and illicit drug use disorders estimate that over 350,000 people die each year globally, with over half of these deaths occurring in males younger than 50. 
- Substance abuse also contributes to the global disease burden, with 1.5% resulting from alcohol and illicit drug addiction; in some countries like the U.S., it is over 5%. Additionally, over 2% of the world population has an alcohol or illicit drug addiction.

### Data

Panel data across 27 years from 1990 to 2017 for a total sample of 19 Latin American countries. 
- Data on the prevalence of drug use disorders is drawn from the Institute for Health Metrics and Evaluation (IHME), Global Burden of Disease (GBD 2019). These data measure the number of persons of both sexes and all ages per country and year that have reported the prevalence use disorder of the following substances: amphetamine, cannabis, cocaine, opioid and other drugs. 
- Public healthcare indicators per country and year are drawn from the World Health Organization Global Health Expenditure database. 
- Macroeconomic and demographic variables per country and year are drawn from the World Bank – World Development Indicators.

The descriptive statistics of the variables are summarized as follows.

![Table A1: Descriptive Statistics](https://github.com/cvas91/CannabisLegalization/blob/main/Screenshot%202023-05-13%20172804.png)

## Synthetic Control Method (SCM)

This paper uses a counterfactual analytical approach to evaluate what would have been the outcome in the prevalence of cannabis use disorders if Uruguay had not legalized cannabis for recreational use in 2013 by implementing the synthetic control method (SCM) and following the guidelines from Abadie (2021), creating a combination of weights during the pre-legalization period from 18 non-treated Latin American countries, which are considered the donor pool or the control group because these countries did not approve of cannabis legalization during the period of study. This weighted combination, the synthetic control, closely estimates a counterfactual scenario without legalization. Then the synthetic trend is forecasted in the post-legalization period to be compared with treated Uruguay.

### Results

Figure below illustrates the prevalence of drug use disorders detailed by substances in some of the most populous Latin American countries measured as a per capita share of their population. From there, it can be assumed that Uruguay’s prevalence of cannabis disorder has remained constant at 0.47%; on average, 15823 people reported this condition annually. The figure also highlights that cannabis disorders are the most prevalent among the observed countries.

```stata
#delimit;
use ${RAW}DataCannabisLatam.dta, clear ;
keep if Code == "URY" | Code == "ARG" | Code == "COL" | Code == "CHL" | Code == "BRA" 	| Code == "MEX" ;
twoway line 
	PrevalenceCannabisShare PrevalenceCocaineShare PrevalenceAmphetamineShare PrevalenceOpioidShare PrevalenceOtherDrugShare PrevalenceAlcoholusedisorde 
	Year ,
	sort lwidth(thick)
	by(Entity) 
	scheme(s1color) ytitle(Share of Pop. (%)) 
	legend(off rows(2) forces size(small)
		lab(1 "Cannabis") lab(2 "Cocaine") lab(3 "Amphetamine") lab(4 "Opioid") lab(5 "Other Drug") lab(6 "Alcohol")) 
	xlabel(, labsize(small) )
	; 
#delimit cr
```

![Figure 1: Prevalence of drug use disorders by country](https://github.com/cvas91/CannabisLegalization/blob/main/Figure1.jpg)

In the SCM, the control group and the experimental unit are equally balanced pre-intervention on several predictors that could predict the dependent variable, creating a quasi-experimental setting. In this current study, the period before intervention was from 1990 to 2012, and the posterior intervention was from 2013 to 2017. The predictors are the prevalence use disorder of illegal substances like amphetamine, cocaine, opioid, alcohol and other public health indicators described in the previous section of the text. The primary outcome of concern has been stated to be the prevalence of cannabis use disorder.

```stata
* Install the synthetic control method package:
ssc install synth, all
*net install synth_runner, from(https://raw.github.com/bquistorff/synth_runner/master/) replace

* Set the data as time series, using tsset 
use ${RAW}DataCannabisLatam.dta, clear 
tsset CodeCountry Year 

* Perform synt control method:

#delimit;
synth PrevalenceCannabisShare // depvar
	PrevalenceCannabisShare(1990) PrevalenceCannabisShare(2000)
	PrevalenceCannabisShare(2012) PrevalenceOtherDrugShare(2012)
	PrevalenceAmphetamineShare(2012) PrevalenceCocaineShare(2012)
	PrevalenceOpioidShare(2012) PrevalenceAlcoholusedisorde(2012) 
	Currenthealthexpenditureof DomGenGovHeaExpGDP(2012) 
	Domesticprivatehealthexpendit(2012) Outofpocketexpenditureof(2012)
	lnGDPpercapita PopulationtotalSPPOPTOTL , // predictors
	trunit(858) // trunit(858) = Uruguay
	trperiod(2013) unitnames(Entity) 
	mspeperiod(1990(1)2013)	resultsperiod(1990(1)2017)
	fig 
	nested keep(${RAW}synth_results_data.dta) replace
;
#delimit cr
```

The table below shows the relative contribution of each of the 18 countries and their respective weights to the synthetic control of Uruguay. The synthetic version is a weighted average of mainly Panama and Suriname, followed by Belize, Chile and Colombia, with weights in decreasing order.

![Table 1: Synthetic control weights for Uruguay.](https://github.com/cvas91/CannabisLegalization/blob/main/Screenshot%202023-05-13%20185145.png)

The figure below displays the results of the synthetic control method examining the effects of legalizing cannabis in Uruguay on the prevalence of cannabis disorder. Synthetic Uruguay, composed of the five countries from the donor pool indicated previously, traced well the trend beside actual Uruguay’s outcome throughout the pre-legalization period (1990 – 2012). However, after the policy was enacted (2013), the true prevalence of cannabis use disorder fell remarkably below 0.47%, whereas the synthetic estimates that the prevalence will increase at pre-legalization levels above 0.48%. 

![Figure 2: Synthetic control trends on the prevalence of cannabis disorder.](https://github.com/cvas91/CannabisLegalization/blob/main/Screenshot%202023-05-13%20190057.png)

From the previous results, the difference between treatment and counterfactual can be computed as shown next. Therefore, the evidence suggests that the treatment effect post-legalization of cannabis in Uruguay caused a decrease in the share of the population that reported the prevalence of cannabis disorder compared to the synthetic control group.

```stata
use ${RAW}synth_results_data.dta, clear 
drop _Co_Number _W_Weight // Drops the columns that store the donor state weights
gen GapUry = _Y_treated - _Y_synthetic // The counterfactual is _Y_synthetic

twoway line (GapUry _time), scheme(s1color) lcolor(green) lwidth(thick) xline(2013) xmlabel(2013 "Legalization") yline(0) xtitle(Year) ytitle(Gap in Prevalence Cannabis Prediction Error) legend(on) // title("Difference between treatment and counterfactual") 
```

![Figure 3: Difference between Uruguay and synthetic.]()
