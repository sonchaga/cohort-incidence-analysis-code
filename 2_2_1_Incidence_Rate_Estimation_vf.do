*******************************************************************************
* Author: Sylvia Onchaga
* Purpose: To estimate the incidence of Bovine Mastitis and determine the risk factors
* Date: 24 Feb 2026
********************************************************************************

clear 
clear mata
clear matrix
set more off 
set maxvar 5000


	*Paths
	global root "G:/Shared drives/PROJECT_FOLDER/Data"
	cd "${root}/4_Analysis"
	
	
	*Output folders
	global manuscript_2 "2_Manuscript_2"
	
	
	*Output date	
	global date: display %tdYND date(c(current_date), "DMY") 	
	
	
	*Output file
	global fileout "${manuscript_2}/${date}_Manuscript_2_Results.xlsx"
	
	
	*Data
	global baseline "${root}/1_Baseline/4_Clean_data/baseline_combined_clean"
	global alldata "${root}/2_Monthly_followup/4_Clean_data/alldata_clean_long"

	
	

	*Graph settings
	graph set window fontface "Arial"

	
	*Set up globals for graph colors
	global code_red "218 48 44"
	global code_green "208 238 214"
	global code_teal "125 217 186"
	global code_orange "242 115 23"
	global code_gray "36 31 33"
	global code_ltred "236 151 149"
	global code_ltgreen "231 246 234"
	global code_ltteal "190 236 220"
	global code_ltorange "248 185 134"
	global code_ltgray "144 142 143"
	global code_dkgreen "78 114 85"
	
	
*===============================================================================
	//A. Preparing Table 2.2 Incidence Rates (PAP)
*===============================================================================
	
	*i) Read the data
	do "2_Manuscript_2/2_2_0_Incidence Rate_data prep_vf.do"
	

	
*===============================================================================
* Compute: incidence rate per 100 cow-months
*		   95% Poisson CI
*		   SD of the rate - computed as SD(IR) = sqrt(cases) / cow_months * 100
*===============================================================================

	cap program drop ir_bm
	program define ir_bm, rclass
		syntax varname, IF(string)
		
		{
		*Cases and cow-months
		gen wei_cases   = `varlist' if `if'
		gen wei_cmonths = cow_months if `if'
		
		sum wei_cases, meanonly
		scalar cases_w   = r(sum)
		
		sum wei_cmonths, meanonly
		scalar cmonths_w = r(sum)
		
		scalar ir_per100 = (cases_w / cmonths_w) * 100
		
		
		*Poisson exact CI on case counts
		local alpha = 0.05
		scalar ll_cases = 0
		scalar ul_cases = 0
		
		if (cases_w > 0) scalar ll_cases = 0.5 * invchi2(2 * cases_w, `alpha' / 2)
		                 scalar ul_cases = 0.5 * invchi2(2 * (cases_w + 1), 1 - `alpha' / 2)
		                 
		                 scalar ir_ll = (ll_cases / cmonths_w) * 100
		                 scalar ir_ul = (ul_cases / cmonths_w) * 100
		
		
		*SD of the incidence rate using Poisson approximation
		*Var(cases) = cases  (Poisson); therefore  SD(IR) = (sqrt(cases)/cow_months)*100
		if (cases_w > 0) scalar ir_sd = (sqrt(cases_w) / cmonths_w) * 100
		else             scalar ir_sd = 0
		
		
		drop wei_cases wei_cmonths
		}
		
		
		return scalar cases_w  = cases_w
		return scalar cmonths_w = cmonths_w
		return scalar ir_per100 = ir_per100
		return scalar ir_ll    = ir_ll
		return scalar ir_ul    = ir_ul
		return scalar ir_sd    = ir_sd
		
		end


		
*===============================================================================
*	We test the null hypothesis (Ho): IR(Kenya) = IR(Uganda), using a Poisson rate-ratio test
*	Test statistic: Z = (cases_ke/cmonths_ke - cases_ug/cmonths_ug)/ sqrt(cases_ke/cmonths_ke^2 + cases_ug/cmonths_ug^2)
*	And report a two-sided test p-value
*===============================================================================*/

	cap program drop ir_pvalue
	program define ir_pvalue, rclass
		syntax varname
		
		{
		*Kenya
		gen _cases_ke   = `varlist' if region == 1
		gen _cmonths_ke = cow_months if region == 1
		
		sum _cases_ke, meanonly
		scalar n_ke = r(sum)
		sum _cmonths_ke, meanonly
		scalar t_ke = r(sum)
		
		
		*Uganda
		gen _cases_ug   = `varlist' if region == 2
		gen _cmonths_ug = cow_months if region == 2
		
		sum _cases_ug, meanonly
		scalar n_ug = r(sum)
		sum _cmonths_ug, meanonly
		scalar t_ug = r(sum)
		
		
		*Conducting incident rate difference test (Poisson, Wald-type)
		*Reference: Rothman KJ, Greenland S. Modern epidemiology. 3rd ed. Philadelphia: Lippincott Williams & Wilkins, 2008
		*Standard error of the incident rate difference - Computed as the square root of the variance of the incidence rate difference
		scalar ir_ke = n_ke / t_ke				//Incidence rate of BV in Kenya
		scalar ir_ug = n_ug / t_ug				//Incidence rate of BV in Uganda
		
		scalar se_diff = sqrt((n_ke / t_ke^2) + (n_ug / t_ug^2))		
		scalar z_stat  = (ir_ke - ir_ug) / se_diff						//Computing the Wald Z statistics
		scalar p_val   = 2 * (1 - normal(abs(z_stat)))					//P-value for a two-sided test
		
		
		drop _cases_ke _cmonths_ke _cases_ug _cmonths_ug
		}
		
		
		return scalar p_val = p_val
		return scalar z_stat = z_stat
		
		end


		pwd
		

*===============================================================================
* Set up Excel Table output as designed in the PAP
*===============================================================================

	putexcel set "${fileout}", sheet("2.2_Incidence rates") replace

	putexcel B2 = "Incidence rates (per 100 cow-months)"
	putexcel B3 = ""


	*Overall sample
	putexcel B4 = "Overall"
	putexcel B5 = "Cases"
	putexcel C5 = "Cow-Months"
	putexcel D5 = "Incidence Rate"
	putexcel E5 = "SD"
	putexcel F5 = "95% Confidence Interval"

	*Kenya sample
	putexcel G4 = "Kenya"
	putexcel G5 = "Cases"
	putexcel H5 = "Cow-Months"
	putexcel I5 = "Incidence Rate"
	putexcel J5 = "SD"
	putexcel K5 = "95% Confidence Interval"

	*Uganda sample
	putexcel L4 = "Uganda"
	putexcel L5 = "Cases"
	putexcel M5 = "Cow-Months"
	putexcel N5 = "Incidence Rate"
	putexcel O5 = "SD"
	putexcel P5 = "95% Confidence Interval"

	*P-value (Kenya vs Uganda)
	putexcel Q5 = "p-value (Kenya vs Uganda)"


	*Stats
	putexcel A6 = "Any Bovine Mastitis (clinical or subclinical)*"
	putexcel A7 = "Clinical Bovine Mastitis*"
	putexcel A8 = "Subclinical Bovine Mastitis*"

	putexcel A10 = "Any Bovine Mastitis (clinical or subclinical)**"
	putexcel A11 = "Clinical Bovine Mastitis**"
	putexcel A12 = "Subclinical Bovine Mastitis**"

	
*===============================================================================
* Export the results to the Excel tables
*===============================================================================

	cap program drop ir_results
	program define ir_results
		syntax, OUTCOME(name) ROW(integer)
		
		*1. Overall
		ir_bm `outcome', if("`outcome' <.")
			local ov_cases   = round(r(cases_w),  0.01)
			local ov_cmonths = round(r(cmonths_w), 0.01)
			local ov_ir      = round(r(ir_per100), 0.001)
			local ov_sd      = round(r(ir_sd),     0.001)
			local ov_irll    = round(r(ir_ll),     0.001)
			local ov_irul    = round(r(ir_ul),     0.001)
			local ov_ci = "[" + string(`ov_irll', "%9.1f") + ", " + string(`ov_irul', "%9.1f") + "]"

		putexcel B`row' = `ov_cases'   ///
		         C`row' = `ov_cmonths' ///
		         D`row' = `ov_ir'      ///
		         E`row' = `ov_sd'      ///
		         F`row' = "`ov_ci'"


		*2. Kenya
		ir_bm `outcome', if("region == 1 & `outcome' <.")
			local ke_cases   = round(r(cases_w),  0.01)
			local ke_cmonths = round(r(cmonths_w), 0.01)
			local ke_ir      = round(r(ir_per100), 0.001)
			local ke_sd      = round(r(ir_sd),     0.001)
			local ke_irll    = round(r(ir_ll),     0.001)
			local ke_irul    = round(r(ir_ul),     0.001)
			local ke_ci = "[" + string(`ke_irll', "%9.1f") + ", " + string(`ke_irul', "%9.1f") + "]"

		putexcel G`row' = `ke_cases'   ///
		         H`row' = `ke_cmonths' ///
		         I`row' = `ke_ir'      ///
		         J`row' = `ke_sd'      ///
		         K`row' = "`ke_ci'"


		*3. Uganda
		ir_bm `outcome', if("region == 2 & `outcome' <.")
			local ug_cases   = round(r(cases_w),  0.01)
			local ug_cmonths = round(r(cmonths_w), 0.01)
			local ug_ir      = round(r(ir_per100), 0.001)
			local ug_sd      = round(r(ir_sd),     0.001)
			local ug_irll    = round(r(ir_ll),     0.001)
			local ug_irul    = round(r(ir_ul),     0.001)
			local ug_ci = "[" + string(`ug_irll', "%9.1f") + ", " + string(`ug_irul', "%9.1f") + "]"

		putexcel L`row' = `ug_cases'   ///
		         M`row' = `ug_cmonths' ///
		         N`row' = `ug_ir'      ///
		         O`row' = `ug_sd'      ///
		         P`row' = "`ug_ci'"


		*4. P-value: Kenya vs Uganda (Poisson Wald test)
		ir_pvalue `outcome'
			local pv = round(r(p_val), 0.0001)
			
			*Format: display "<0.001" when very small
			if `pv' < 0.001 local pv_fmt "< 0.001"
			else            local pv_fmt = string(`pv', "%9.4f")

		putexcel Q`row' = "`pv_fmt'"
		
		end


	
*===============================================================================
* Export incidence rate estimates from definition 1: 
*	Clinical BV: SCC >= 200,000 cells/ml + Clinical signs or CMT +ve + clinical signs if SCC is missing
*	Subclinical BV: SCC >= 200,000 cells/ml without clinical signs or CMT +ve without clinical signs if SCC is missing
*===============================================================================

	ir_results, outcome(case_mast1) row(6)
	ir_results, outcome(case_clin1) row(7)
	ir_results, outcome(case_sub1)  row(8)


*===============================================================================
* Export incidence rate estimates from definition 2:
*	Clinical BV: CMT +ve with clinical signs
*	Subclinical BV: CMT +ve without clinical signs
*===============================================================================

	ir_results, outcome(case_mast2) row(10)
	ir_results, outcome(case_clin2) row(11)
	ir_results, outcome(case_sub2)  row(12)


*===============================================================================
* Plot time-series graphs: 3 bovine mastitis classifications and two (Def1, Def2)
* Each graph shows Overall; Kenya; Uganda incidence rates across survey rounds
*===============================================================================

	drop if cow_months <= 0 | missing(cow_months) | missing(survey_round)


*===============================================================================
* 	Collapse data to survey_round level and computes IR per 100 cow-months
*   for a given outcome and region (region = 0 means all regions combined)
*===============================================================================

	cap program drop ir_tseries
	program define ir_tseries
		syntax, GROUP(string) REGION(integer) OUTCOME(varname) SAVE(string)
		
		preserve
			if `region' != 0 keep if region == `region'
			
			gen _cases   = `outcome'
			gen _cmonths = cow_months
			collapse (sum) cases_wt = _cases cmonths_wt = _cmonths, by(survey_round)
			
			gen ir_per100 = round((cases_wt / cmonths_wt) * 100, 0.01)
			gen group     = "`group'"
			
			save "`save'", replace
		restore
		end


*==============================================================================
*	Fit a single connected line graph for each incidence rate definition, 
*	showing Overall; Kenya; Uganda trends across survey rounds.
*===============================================================================

	cap program drop ir_graph
	program define ir_graph
		syntax, OUTCOME(varname) TITLE(string) FNAME(string) EXCELCELL(string)
		
		preserve
		
			keep survey_round region cow_months `outcome'
			
			tempfile ts_ov ts_ke ts_ug
			
			ir_tseries, group("Overall") region(0) outcome(`outcome') save("`ts_ov'")
			ir_tseries, group("Kenya")   region(1) outcome(`outcome') save("`ts_ke'")
			ir_tseries, group("Uganda")  region(2) outcome(`outcome') save("`ts_ug'")
			
			use "`ts_ov'", clear
				append using "`ts_ke'"
				append using "`ts_ug'"
			
			
			twoway ///
				(connected ir_per100 survey_round if group == "Overall", ///
					lcolor("${laterite_red}")  mcolor("${laterite_red}") lpattern(solid) ///
					mlabel(ir_per100) mlabsize(vsmall) mlabposition(12) mlabcolor("${laterite_red}")) ///
				(connected ir_per100 survey_round if group == "Kenya", ///
					lcolor("${laterite_teal}") mcolor("${laterite_teal}") lpattern(solid) ///
					mlabel(ir_per100) mlabsize(vsmall) mlabposition(12) mlabcolor("${laterite_teal}")) ///
				(connected ir_per100 survey_round if group == "Uganda", ///
					lcolor("${laterite_gray}") mcolor("${laterite_gray}") lpattern(solid) ///
					mlabel(ir_per100) mlabsize(vsmall) mlabposition(12) mlabcolor("${laterite_gray}")), ///
				title("`title'", size(medsmall)) ///
				ytitle("Incidence rate per 100 cow-months") ylabel(0(10)80, nogrid) ///
				xtitle("Survey round") xlabel(1(1)9) ///
				legend(on order(1 "Overall" 2 "Kenya" 3 "Uganda") rows(1) position(6))
			
			
			putexcel set "${fileout}", sheet("2.2_Incidence rates") modify
			graph save "${manuscript_2}/1_Outputs/`fname'.gph", replace
			graph export "${manuscript_2}/1_Outputs/`fname'.eps", as(eps) replace
			graph export "${manuscript_2}/1_Outputs/`fname'.png", replace
			putexcel `excelcell' = picture("${manuscript_2}/1_Outputs/`fname'.png")			//Requirement by VeriXiv
			
		restore
		end


*===============================================================================
* Export the graphs to the excel table
*===============================================================================
	
		
	*1. Any Bovine Mastitis
	ir_graph, outcome(case_mast1) ///
		title("Any Bovine Mastitis (SCC/CMT + clinical signs)") ///
		fname("Graph_Any_Mastitis_Def1") excelcell(B20)

	ir_graph, outcome(case_mast2) ///
		title("Any Bovine Mastitis (CMT + clinical signs)") ///
		fname("Graph_Any_Mastitis_Def2") excelcell(J20)


	*2. Clinical Bovine Mastitis
	ir_graph, outcome(case_clin1) ///
		title("Clinical Bovine Mastitis (SCC+ve/CMT+ve and clinical signs observed))") ///
		fname("Graph_Clinical_Mastitis_Def1") excelcell(B38)

	ir_graph, outcome(case_clin2) ///
		title("Clinical Bovine Mastitis (CMT+ve and clinical signs observed)") ///
		fname("Graph_Clinical_Mastitis_Def2") excelcell(J38)


	*3. Subclinical Bovine Mastitis
	ir_graph, outcome(case_sub1) ///
		title("Subclinical Bovine Mastitis (SCC+ve/CMT+ve, no clinical signs)") ///
		fname("Graph_Subclinical_Mastitis_Def1") excelcell(B56)

	ir_graph, outcome(case_sub2) ///
		title("Subclinical Bovine Mastitis (CMT+ve, no clinical signs)") ///
		fname("Graph_Subclinical_Mastitis_Def2") excelcell(J56)

	
	*Save interim dataset for Risk factor analysis
	save "${manuscript_2}/0_Tempdata/Incidence_data.dta", replace
