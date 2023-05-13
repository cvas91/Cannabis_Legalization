/* Project Appendix Code
Prevalence of Cannabis Use Disorder Post Legalization – Uruguay Case Study

Name: Camilo Andres Vargas Silva					
Banner ID: B00926233
Course: ECON 5525 - Applied Econometrics
Program: MDE
*/

* 1) Set up Global working directories:

global SOURCE "C:\Users\cvas_\OneDrive\Documentos\MDE\Econometrics_Applied\Paper\"
global RAW "${SOURCE}RAW\"
global DO "${SOURCE}DO\"
global OUTPUT "${SOURCE}OUTPUT\"
global GRAPH "${SOURCE}GRAPH\"
global LOG "${SOURCE}LOG\"


* 2) Data loading, cleaning and mining: 

import excel ${RAW}DataCannabis1.xlsx, sheet("Sheet1") firstrow clear

* Drop missing values:
*drop PrevalenceOtherdrugusediso PrevalenceAmphetamineusedis PrevalenceCocaineusedisorde PrevalenceCannabisusedisord PrevalenceOpioidusedisorder ///unnecesary variables that are measured in total numbers
*drop if Code == "SUR" | Code == "BLZ" | Code == "GUY" //Drop small countries states
drop if lnGDPpercapita == .

* Keep countries within Latin America Region:
keep if Region == "South America" | Region == "Central America"

* Rename variables as share of the population:
rename K PrevalenceOtherDrugShare
rename L PrevalenceAmphetamineShare
rename M PrevalenceCocaineShare
rename N PrevalenceCannabisShare
rename O PrevalenceOpioidShare
rename T DeathsAllCausesDrugUse 
rename U DeathsAllCausesAlcoholUse
rename AA DomGenGovHeaExpGDP
rename AB DomGenGovHeaExpGen

* Check variables with string values
ds, has(type string) 

* Defining Global for variables with missing values.
global RepMisVal GDPpercapitaPPPconstant20 Currenthealthexpenditureof Domesticgeneralgovernmentheal DomGenGovHeaExpGDP DomGenGovHeaExpGen Domesticprivatehealthexpendit Externalhealthexpenditureo Outofpocketexpenditureof

* Replace missing values '..' to '.'
destring $RepMisVal, replace force

* Save subset sample in RAW folder
save ${RAW}DataCannabisLatam.dta, replace 


* 3) Descriptive statistics of Latam dataset:

describe
summarize // Table A1 Appendix: Descriptive Statistics.
sum PrevalenceCannabisusedisord if Code == "URY"
sum PrevalenceCannabisShare if Code == "URY"

* Figure A1 Appendix: Trend in prevalence of cannabis disorder in Uruguay vs Latam
*	Graph with the regular trend of prevalence of cannabis in Uruguay vs Latam

use ${RAW}DataCannabisLatam.dta, clear 
collapse (mean) PrevalenceCannabisShare CanMedLatam=PrevalenceCannabisShare if Code != "URY" , by(Year) // collapse all Latam except URY
save ${RAW}DataMedLatamNoUry.dta, replace 

use ${RAW}DataCannabisLatam.dta, clear 
collapse (mean) PrevalenceCannabisShare CanMedUry=PrevalenceCannabisShare if Code == "URY", by(Year) // collapse only URY
save ${RAW}DataMedUry.dta, replace 

merge 1:1 Year using ${RAW}DataMedLatamNoUry.dta

#delimit;
twoway line CanMedUry CanMedLatam Year,
	scheme(s1color) lwidth(thick)
	xline(2013, lcolor(brown) lwidth(thin) lpattern(dash)) 
	xmlabel(2013 "Legalization" )
	legend(on rows(1) lab(1 "Uruguay") lab(2 "Rest of Latam")) 
;
#delimit cr

* Figure 1: Prevalence of drug use disorders by country.
*	Graphs for share of population with a drug use disorders by substance

#delimit;
use ${RAW}DataCannabisLatam.dta, clear ;
keep if Code == "URY" | Code == "ARG" | Code == "COL" | Code == "CHL" | Code == "BRA" 	| Code == "MEX" ;
twoway line 
	PrevalenceCannabisShare PrevalenceCocaineShare PrevalenceAmphetamineShare		 	PrevalenceOpioidShare PrevalenceOtherDrugShare PrevalenceAlcoholusedisorde 
	Year ,
	sort lwidth(thick)
	by(Entity) ///, legend(pos(6)) title(Prevalence of use disorders by substance)
	scheme(s1color) ytitle(Share of Pop. (%)) 
	legend(off rows(2) forces size(small)
		lab(1 "Cannabis") lab(2 "Cocaine") lab(3 "Amphetamine") lab(4 "Opioid") 		lab(5 "Other Drug") lab(6 "Alcohol")) 
	xlabel(, labsize(small) )
	; 
#delimit cr


* 4) Synthetic control method on the Latam Cannabis dataset:

* The next sections are constructed following the guidelines of :
* Cunningham (2021). Causal Inference, The Mixtape.

* Install the synthetic control method package:
*ssc install synth, all
*net install synth_runner, from(https://raw.github.com/bquistorff/synth_runner/master/) replace

* Set the data as time series, using tsset 
use ${RAW}DataCannabisLatam.dta, clear 
tsset CodeCountry Year 

* Perform synt control method:
* Table 1: Synthetic control weights for Uruguay.
* Figure 2: Synthetic control trends on the prevalence of cannabis disorder.

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

* Table 2: Predictors balance pre and post-treatment.
* Predictors – Pre Treatment "2012" are taken from previous step.

use ${RAW}DataCannabisLatam.dta, clear 
tsset CodeCountry Year 

* Predictors – Post Treatment. "2017"
#delimit;
synth PrevalenceCannabisShare
	PrevalenceCannabisShare(2017) PrevalenceOtherDrugShare(2017)
	PrevalenceAmphetamineShare(2017) PrevalenceCocaineShare(2017) 
	PrevalenceOpioidShare(2017) PrevalenceAlcoholusedisorde(2017) 
	Currenthealthexpenditureof DomGenGovHeaExpGDP(2017) 
	Domesticprivatehealthexpendit(2017) Outofpocketexpenditureof(2017)
	lnGDPpercapita PopulationtotalSPPOPTOTL
	, trunit(858) // trunit(858) = Uruguay
	trperiod(2013) unitnames(Entity)
	mspeperiod(1990(1)2015)	resultsperiod(1990(1)2017) //
	// fig
	// nested keep(${RAW}synth_results_data.dta) replace
;
#delimit cr

/* Using synth_runner:
#delimit;
synth_runner PrevalenceCannabisShare 
	PrevalenceCannabisShare(1990) PrevalenceCannabisShare(1995) 
	PrevalenceCannabisShare(2000) PrevalenceCannabisShare(2005) 
	PrevalenceCannabisShare(2012)
	PrevalenceOtherDrugShare(2012) PrevalenceAmphetamineShare(2012) 
	PrevalenceCocaineShare(2012) PrevalenceOpioidShare(2012) 
	PrevalenceAlcoholusedisorde(2012) 
	Currenthealthexpenditureof 
	DomGenGovHeaExpGDP(2012) Domesticprivatehealthexpendit(2012) 		
	Outofpocketexpenditureof(2012)
	lnGDPpercapita PopulationtotalSPPOPTOTL, 
	trunit(858) trperiod(2013) unitnames(Entity)
	mspeperiod(1990(1)2013)	//resultsperiod(1990(1)2017) ;
	fig
	nested keep(${RAW}synth_results_data.dta) replace
*/


* 5) Plot a graph to show difference between treatment and counterfactual:

* Figure 3: Difference between Uruguay and synthetic.
use ${RAW}synth_results_data.dta, clear 
drop _Co_Number _W_Weight // Drops the columns that store the donor state weights
gen GapUry = _Y_treated - _Y_synthetic // The counterfactual is _Y_synthetic

twoway line (GapUry _time), scheme(s1color) lcolor(green) lwidth(thick) xline(2013) xmlabel(2013 "Legalization") yline(0) xtitle(Year) ytitle(Gap in Prevalence Cannabis Prediction Error) legend(on) // title("Difference between treatment and counterfactual") 


* 6) Inference 1: Placebo test:

use ${RAW}DataCannabisLatam.dta, clear 
tsset CodeCountry Year 

*Define list of Countries by numbers: 
levelsof CodeCountry, local(Countries)
display "`Countries'" // to display must execute with the previous local code
global Countries 32 68 76 84 152 170 188 218 222 320 328 340 484 558 591 600 604 740 858

#delimit;
foreach i of global Countries {;
	synth PrevalenceCannabisShare 
	PrevalenceCannabisShare(1990) PrevalenceCannabisShare(1995) 
	PrevalenceCannabisShare(2000) PrevalenceCannabisShare(2005) 
	PrevalenceCannabisShare(2012)
	PrevalenceOtherDrugShare(2012) PrevalenceAmphetamineShare(2012) 
	PrevalenceCocaineShare(2012) PrevalenceOpioidShare(2012) 
	PrevalenceAlcoholusedisorde(2012) 
	Currenthealthexpenditureof 
	DomGenGovHeaExpGDP(2012) Domesticprivatehealthexpendit(2012)  
	Outofpocketexpenditureof(2012)
	lnGDPpercapita PopulationtotalSPPOPTOTL, 
	trunit(`i') trperiod(2013) unitnames(Entity)
	mspeperiod(1990(1)2013)	resultsperiod(1990(1)2017) 
	keep(${RAW}synth_results_`i'.dta) replace
	;	};
#delimit cr

foreach i of global Countries {
	use ${RAW}synth_results_`i', clear
	keep _Y_treated _Y_synthetic _time
	rename _Y_treated treated_`i'
	rename _Y_synthetic counterf_`i'
	rename _time year
	gen gap`i' = treated_`i' - counterf_`i' 
	save ${RAW}synth_gap_`i'.dta, replace
}

foreach i of global Countries {
	merge 1:1 year using ${RAW}synth_gap_`i' 
	drop _merge
	save ${RAW}placebo_merged.dta, replace
}


* Inference 2: Estimate the pre- and post-RMSPE and calculate the ratio of post-pre RMSPE

foreach i of global Countries {
use ${RAW}synth_gap_`i', clear
gen gap3 = gap`i'* gap`i'
egen postmean = mean(gap3) if year > 2013
egen premean = mean(gap3) if year <= 2013
gen rmspe = sqrt(premean) if year <= 2013
replace rmspe = sqrt(postmean) if year > 2013
gen ratio = rmspe/rmspe[_n-1] if year == 2014
gen rmspe_post = sqrt(postmean) if year > 2013
gen rmspe_pre = rmspe[_n-1] if year == 2014
mkmat rmspe_pre rmspe_post ratio if year == 2014, matrix (country`i')
}

* Show pre/post expansion RMSPE ratio for all countries
* Table 3: Pre - Post expansion RMSPE ratio.
foreach i of global Countries {
matrix rownames country`i' = `i'
matlist country`i', names(row)
}

*histogram ratio, bin(20) frequency


* 7) Inference 3: all the placebos on the same figure:

* Figure A2 Appendix: Gaps across all placebos and Uruguay.
use ${RAW}placebo_merged.dta, replace

global GapCountries gap32 gap68 gap76 gap84 gap152 gap170 gap188 gap218 gap222 gap320 gap328 gap340 gap484 gap558 gap591 gap600 gap604 gap740

#delimit;
twoway 
	(line $GapCountries year, lp(solid) lw(vthin)) 
	(line gap858 year, lp(solid) lw(vthick) lcolor(green)), //858 = Uruguay
	yline(0, lpattern(shortdash) lcolor(black))
	xline(2013, lpattern(shortdash) lcolor(black)) xmlabel(2013 "Legalization")
	xtitle(Year) ytitle(Gap Prevalence Cannabis Share) 
	legend(on pos(3) cols(1) forces size(small) lab(17 "GapUry"));
#delimit cr

*graph save Grapgh ${RAW}All.ghp, replace


* Figure 4: Gaps for the relevant placebos and Uruguay.
/* Removing outliers:
gap84=Belize Outlier #1
gap170=Colombia Outlier #2
gap152=Chile Outlier #3
gap320=Guatemala Outlier #4*/

use ${RAW}placebo_merged.dta, replace

global GapNoOutliers gap32 gap68 gap76 gap188 gap218 gap222 gap328 gap340 gap484 gap558 gap591 gap600 gap604 gap740

#delimit;
twoway 
	(line $GapNoOutliers year, lp(solid) lw(vthin)) 
	(line gap858 year, lp(solid) lw(vthick) lcolor(green)), //858 = Uruguay
	yline(0, lpattern(shortdash) lcolor(black))
	xline(2013, lpattern(shortdash) lcolor(black)) xmlabel(2013 "Legalization")
	xtitle(Year) ytitle(Gap Prevalence Cannabis Share) 
	legend(on pos(3) cols(1) forces size(small) lab(15 "GapUry"));
#delimit cr

*graph save Grapgh ${RAW}All_without_outliers.ghp, replace


/*	Prof. Casey: 
Thanks for reading this far. 
I've problably made some mistakes but I tried my best.
This course was really usefull :)
*/							