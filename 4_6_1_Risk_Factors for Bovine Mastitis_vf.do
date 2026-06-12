*******************************************************************************
* Author: Sylvia Onchaga
* Purpose: To determine the risk factors of bovine mastitis
* Date of creation: 28/07/2025
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
*A: Data preparation for Risk Factors determination
*===============================================================================
	*Run do file!
	
	do "${manuscript_2}/4_6_0_Risk_Factors_data prep_v2.do"
	
	*Then merge with incidence data
	
	merge 1:1 hhid cowid_ survey_round using "${manuscript_2}/0_Tempdata/Incidence_data.dta", ///
		keepusing(t0 t1 cow_months case_mast1 case_clin1 case_sub1 ///
				  case_mast2 case_clin2 case_sub2 visit_date ///
				  subclinical_dx1 clinical_dx1 mastitis_dx1 ///
				  subclinical_dx2 clinical_dx2 mastitis_dx2)
	
	/*Note that when computing incidence, in 2_2_1_Incidence_Rate_Estimation_vf dofile, 
	  we drop baseline since t0 is missing - (All cows were negative for BV at enrollment) */
	  
	drop _merge
	
	tab survey_round
	count
	
	
	
*===============================================================================
*B: Construct the excel table for risk factor analysis
*===============================================================================

	/*A few points to note:
		1. The event (bovine mastitis +ve diagnosis) in this model is recurrent
		2. The dependent variable "time to event" is considered discrete; one month interval
		3. Given the recurrent nature of the event, it is difficult to determine the distribution of time to event; 
		we will therefore fit a semi-parametric cox regression model, using robust SE

	*/
	
	
	*Risk factor analysis variables
	describe region resp_sex enr_cow_age_new enr_cow_breed_ enr_cow_parity_new enr_cow_calv_disinf_new ///
	   enr_cow_dct_new enr_cow_lact_seal_new enr_cow_bv_prev_hx_new enr_cow_milk_hist_ cow_bcs_ ///
	   cow_bcs_ diet_mineral_yesno enr_cow_lymp_szie_new enr_cow_lameness_new enr_cow_feces_ ///
	   cow_clean_udder_new adeq_zero_gra_unit cow_leaking_teats_new diet_water diet_forage ///
	   clean_barn clean_cubicles bedding_obs subclinical_dx1 clinical_dx1 mastitis_dx1 t0 t1 ///
	   cow_months case_mast1 case_clin1 case_sub1 bov_know_score farm_hyg_prac_score self_rep_milk_prac_score
	

	*1. Survival analysis data set up for recurrent events
		
		//Ensure these are stata dates
		format t0 t1 %td		
		
				
		//Declare recurrent-event survival data: multiple records per cow
		stset t1, enter(time t0) failure(case_mast1 == 1) id(cowid_)
		
		
		//Model fit using robust standard errors at cow (recurrent events within cow)
		local vceopt "vce(cluster cowid_)"
		

		

*===============================================================================
* Exporting table 3: Hazard ratios (HR) for the association between risk factors and incidence of bovine mastitis (N=215 cows, M= 1526.8 cow-months under observation)
*===============================================================================
	
	
	*Constructing the table as designed in the PAP
	putexcel set "${fileout}", sheet("Table_3 Risk Factors") modify
	
	
	putexcel A1 = ""
	
	putexcel C2 = "Univariable analysis"
	putexcel C3 = "HR"
	putexcel D3 = "95% CI"
	putexcel E3 = "p-value"
	
	putexcel F2 = "Multivariable model"
	putexcel F3 = "HR"
	putexcel G3 = "95% CI"
	putexcel H3 = "p-value"
	
	
	*Summarizing the variables of interest
	putexcel B4 = "Farm Characteristics"
	putexcel B5 = "Country"
	putexcel B6 = "  Kenya"
	putexcel B7 = "  Uganda"
	putexcel B8 = "Gender of the farmer"
	putexcel B9 = "  Male"
	putexcel B10 = "  Female"
	putexcel B11 = "Total number of lactating dairy cows"
	putexcel B12 = "Farmer's bovine mastitis knowledge score at baseline"
	putexcel B13 = "Farmer's self-reported hygeine practices at baseline"
	putexcel B14 = "Farmer's self-reported milking practices at baseline"
	
	putexcel B15 = "Cow demographics & medical history"
	putexcel B16 = "Age (Months)"
	putexcel B17 = "Breed"
	putexcel B18 = "  Fresian"
	putexcel B19 = "  Aryshire"
	putexcel B20 = "  Cross breed"
	putexcel B21 = "  Other, specify"
	putexcel B22 = "Parity"
	putexcel B23 = "  One"
	putexcel B24 = "  Two"
	putexcel B25 = "  Three"
	putexcel B26 = "  At least Four"
	putexcel B27 = "Received teat disinfection before calving"
	putexcel B28 = "  No"
	putexcel B29 = "  Yes"
	putexcel B30 = "  Cow is a first time calver"
	putexcel B31 = "History of Dry Cow Therapy (DCT) before end of last lactation"
	putexcel B32 = "  No, DCT administered"
	putexcel B33 = "  Yes, DCT administered"
	putexcel B34 = "  Cow is a first time calver"
	putexcel B35 = "Received internal teat sealant before end of last lactation"
	putexcel B36 = "  No"
	putexcel B37 = "  Yes"
	putexcel B38 = "  Cow is a first time calver"
	putexcel B39 = "Cow' status in the previous month (Time-variant variables)"
	putexcel B40 = "  Self-reported days in milk"
	putexcel B41 = "  Body condition score"
	putexcel B42 = "  Had received mineral supplementation in the past 30 days"
	putexcel B43 = "Size of the cow's superficial lymph nodes"
	putexcel B44 = "  Normal"
	putexcel B45 = "  At least slightly swollen"
	putexcel B46 = "Cow's lameness score"
	putexcel B47 = "  Normal"
	putexcel B48 = "  Mild"
	putexcel B49 = "Cow's current consistency"
	putexcel B50 = "  Hard"
	putexcel B51 = "  Soft"
	putexcel B52 = "  Watery"
	putexcel B53 = "Cow has a clean udder"
	
	putexcel B54 = "Farm environment in the previous month"
	putexcel B55 = "Adequacy of zero-graze unit based on herd size"
	putexcel B56 = "  Inadequate structure"
	putexcel B57 = "  Adequate structure"
	putexcel B58 = "At least one other cow in the herd has signs, symptoms, or a clinical diagnosis of bovine mastitis"
	putexcel B59 = "Drinking water is ad libitum (present all times)"
	putexcel B60 = "Forage is ad libitum (present at all times)"
	putexcel B61 = "Barn is free of manure or has scanty manure"
	putexcel B62 = "Cubicles are clean or manure or have scanty manure"
	putexcel B63 = "Cubicles include at least one form of bedding**"
	putexcel B64 = "**Bedding: Sawdust, Hay, Cow mattress, Tree leaves, Wood shavings, Straw mat"


	cap matrix drop rtable
	mat rtable = J(65,9,.)
	
	
	
	
*===============================================================================
* Results
*===============================================================================
	
	*1) Update N cows and cow-months in the title
	
	preserve
		*Computing unique cows contributing intervals
		qui egen _cowtag = tag(cowid_)
		qui count if _cowtag == 1
		local N_cows = r(N)
		
		
		*Cow-months under observation
		qui gen _w_cow_months = cow_months
		qui sum _w_cow_months, meanonly
		local M_cow_months = r(sum)
		
		
		
		*Updating title with computed N and M
		local M_fmt: display %9.1f `M_cow_months'
		putexcel A1 = "Table 3: Hazard ratios (HR) for the association between risk factors and incidence of bovine mastitis (N = `N_cows' cows, M = `M_fmt' cow-months under observation)"
	
	restore

	
	
	*2) Preparing model options: cluster-robust
	
	local vceopt "vce(cluster cowid_)"
	local wopt ""
	
	
	*3) To write HR, 95% CI, P-value for a single coefficient - for univariable and multivariable regression
	
	cap program drop _xl_write_coef
		program define _xl_write_coef
			syntax, COEF(string) ROW(integer) MODEL(string)
			
			
			local HR ""
			local CI ""
			local PV ""
			
			
			*If coef exists, compute HR, 95% CI, P-value
			matrix b = e(b)
			local cn: colnames b
			local found 0
			foreach c of local cn {
				if "`c'" == "`coef'" local found 1
				}
				
			if (`found') {
				quietly lincom `coef', eform
				
				
			*Suppress 0 coefficients (zero events categories); SE is effectively zero
				local _hr = r(estimate)
				local _se = r(se)
				local _lb = r(lb)
				local _ok = (`_se' > 1e-6 & `_se' <. & `_hr' > 0.005 & `_hr' <.)
				
				if (`_ok') {
					local HR: display %6.2f r(estimate)
					local CI "`:display %6.2f r(lb)' - `:display %6.2f r(ub)'"
				
			*P-value formatted to 3 decimal places
					if (r(p) < 0.001) local PV "<0.001"
				else				local PV: display %9.3f r(p)
				}
		}
		
		
			if "`model'"=="UNI" {
				putexcel C`row' = ("`HR'") D`row' = ("`CI'") E`row' = ("`PV'")
			}
			
			else if "`model'"=="MULTI" {
				putexcel F`row' = ("`HR'") G`row' = ("`CI'") H`row' = ("`PV'")
				
			}
			end
			
			
	
	*3b) Write ALL non-base levels for multi-category variables
	cap program drop _xl_write_fvlevels
	program define _xl_write_fvlevels
		syntax, VAR(name) BASE(integer) ROWSTART(integer) MODEL(string) NROWS(integer)

		*Get the distinct levels that exist in the estimation sample
		qui levelsof `var' if e(sample), local(levs)

		local r = `rowstart'
		local rmax = `rowstart' + `nrows' - 1
		foreach L of local levs {
			if (`r' > `rmax') continue, break
			if (`L' != `base') {
				_xl_write_coef, coef("`L'.`var'") row(`r') model("`model'")
				local ++r
			}
		}
	end
	
		
	
	*4) Obtain term p-value for selection of variables: using testparm for categorical vars and coeffient p-val for continous variables
					
		cap program drop _term_p
			program define _term_p, rclass
				syntax, TERM(string)
				
				return scalar p = .
				
				
				*For categorical variable
				if strpos("`term'", "i.") == 1 | strpos("`term'", "ib") == 1 {
					
				*Extract the variable name after the last dot
					local v = substr("`term'", strpos("`term'", ".")+1,.)
					cap testparm i.`v'
					if _rc == 0 return scalar p = r(p)
				exit
				
				}
				
				
				*For continuous term, the coefficient name is the var itself
				local v = subinstr("`term'","c.","",.)
				cap test `v'
				if _rc == 0 return scalar p = r(p)	
			end
	
	
	
	
	*5) Take account of time-invariant variables in the model
	*Let's lag time-varying covariates within cow
	
		sort cowid_ t0
		by cowid_: gen _first = (_n == 1)
		
			foreach v in ///
				cow_bcs_ ///
				enr_cow_milk_hist_ ///
				diet_mineral_yesno ///
				enr_cow_lymp_szie_new ///
				enr_cow_lameness_new ///
				enr_cow_feces_ ///
				cow_clean_udder_new ///
				clean_barn clean_cubicles bedding_obs ///
				diet_water diet_forage cow_bv_yn_ mastitis_dx1 clinical_dx1 {
					
					bysort cowid_: gen L_`v' = `v'[_n-1]
				}
	
	
		*Note that after lagging the data, the first observation for each cow has no previous row to look back at. It effectively corresponds to the baseline visit where t0 is also missing
		count
		drop if _first
		count
		drop _first
	
	

	
	*6) Define candidate terms for selection using bases consistent with the table
	
	
		local cterms ///
			ib1.region ///
			ib1.resp_sex ///
			c.herd_lact_cows ///
			c.bov_know_score ///
			c.farm_hyg_prac_score ///
			c.self_rep_milk_prac_score ///
			c.enr_cow_age_new ///
			ib1.enr_cow_breed_ ///
			ib1.cow_parity_cat ///
			ib0.enr_cow_calv_disinf_new ///
			ib0.enr_cow_dct_new ///
			ib0.enr_cow_lact_seal_new ///
			ib0.enr_cow_bv_prev_hx_new ///
			c.enr_cow_milk_hist_ ///
			c.L_cow_bcs_ ///
			ib0.L_diet_mineral_yesno ///
			ib0.L_enr_cow_lymp_szie_new ///
			ib0.L_enr_cow_lameness_new ///
			ib0.L_enr_cow_feces_ ///
			ib0.L_cow_clean_udder_new ///
			ib0.adeq_zero_gra_unit ///
			ib0.L_cow_bv_yn_ ///
			ib0.L_diet_water ///
			ib0.L_diet_forage ///
			ib0.L_clean_barn ///
			ib0.L_clean_cubicles ///
			ib0.bedding_obs
			
			
			
	*6) Fitting Univariate Models: run each term and store results in excel
	
		*Country
		qui stcox ib1.region, `vceopt'
		_xl_write_coef, coef("2.region") row(7) model("UNI")
		
		
		*Gender
		qui stcox ib1.resp_sex, `vceopt'
		_xl_write_coef, coef("2.resp_sex") row(10) model("UNI")
		
		
		*Lactating cows
		qui stcox c.herd_lact_cows, `vceopt'
		_xl_write_coef, coef("herd_lact_cows") row(11) model("UNI")
		
			
		*Knowledge score
		qui stcox c.bov_know_score, `vceopt'
		_xl_write_coef, coef("bov_know_score") row(12) model("UNI")
		
		
		*Hygiene score
		qui stcox c.farm_hyg_prac_score, `vceopt'
		_xl_write_coef, coef("farm_hyg_prac_score") row(13) model("UNI")
		
		
		*Milking score
		qui stcox c.self_rep_milk_prac_score, `vceopt'
		_xl_write_coef, coef("self_rep_milk_prac_score") row(14) model("UNI")
		
		
		*Cow age
		qui stcox c.enr_cow_age_new, `vceopt'
		_xl_write_coef, coef("enr_cow_age_new") row(16) model("UNI")
	
	
		*Breed
		qui stcox ib1.enr_cow_breed_, `vceopt'
		_xl_write_fvlevels, var("enr_cow_breed_") base(1) rowstart(19) model("UNI") nrows(3)  
		
		*Parity
		qui stcox ib1.cow_parity_cat, `vceopt'		
		_xl_write_fvlevels, var("cow_parity_cat") base(1) rowstart(24) model("UNI")  nrows(3) 
		
	
		*Teat disinfection
		qui stcox ib0.enr_cow_calv_disinf_new, `vceopt'
		_xl_write_fvlevels, var("enr_cow_calv_disinf_new") base(0) rowstart(29) model("UNI") nrows(2)

		
		*DCT History
		qui stcox ib0.enr_cow_dct_new, `vceopt'
		_xl_write_fvlevels, var("enr_cow_dct_new") base(0) rowstart(33) model("UNI") nrows(2) 
		
	
		*Teat sealant
		qui stcox ib0.enr_cow_lact_seal_new, `vceopt'
		_xl_write_fvlevels, var("enr_cow_lact_seal_new") base(0) rowstart(37) model("UNI")  nrows(2) 


		*Days in milk
		qui stcox c.enr_cow_milk_hist_, `vceopt'
		_xl_write_coef, coef("enr_cow_milk_hist_") row(40) model("UNI")		
	
	
		*Body condition
		qui stcox c.L_cow_bcs_, `vceopt'
		_xl_write_coef, coef("L_cow_bcs_") row(41) model("UNI")		
		
		
		*Mineral supplementation
		qui stcox ib0.L_diet_mineral_yesno, `vceopt'
		_xl_write_coef, coef("1.L_diet_mineral_yesno") row(42) model("UNI")		
	
	
		*Lymph nodes
		qui stcox ib0.L_enr_cow_lymp_szie_new, `vceopt'
		_xl_write_coef, coef("1.L_enr_cow_lymp_szie_new") row(45) model("UNI")		
	
	
		*Lameness
		qui stcox ib0.L_enr_cow_lameness_new, `vceopt'
		_xl_write_coef, coef("1.L_enr_cow_lameness_new") row(48) model("UNI")	
	
	
		*Consistency of feces
		qui stcox ib0.L_enr_cow_feces_, `vceopt'
		_xl_write_fvlevels, var("enr_cow_feces_") base(0) rowstart(51) model("UNI") nrows(2) 

	
		*Clean udder
		qui stcox ib0.L_cow_clean_udder_new, `vceopt'
		_xl_write_coef, coef("1.L_cow_clean_udder_new") row(53) model("UNI")		
	
	
		*Adequacy of the dairy structure
		qui stcox ib0.adeq_zero_gra_unit, `vceopt'
		_xl_write_coef, coef("1.adeq_zero_gra_unit") row(57) model("UNI")		
		
		
		*At least one cow in the herd was diagnosed with bovine mastitis
		qui stcox ib0.L_cow_bv_yn_, `vceopt'
		_xl_write_coef, coef("1.L_cow_bv_yn_") row(58) model("UNI")		
				
	
		*Water ad lib
		qui stcox ib0.L_diet_water, `vceopt'
		_xl_write_coef, coef("1.L_diet_water") row(59) model("UNI")	
		
		
		*Forage ad lib
		qui stcox ib0.L_diet_forage, `vceopt'
		_xl_write_coef, coef("1.L_diet_forage") row(60) model("UNI")
		
		
		*Barn clean
		qui stcox ib0.L_clean_barn, `vceopt'
		_xl_write_coef, coef("1.L_clean_barn") row(61) model("UNI")		
		
		
		*Cubicles clean
		qui stcox ib0.L_clean_cubicles, `vceopt'
		_xl_write_coef, coef("1.L_clean_cubicles") row(62) model("UNI")		
		
		
		*Bedding observed
		qui stcox ib0.bedding_obs, `vceopt'
		_xl_write_coef, coef("1.bedding_obs") row(63) model("UNI")	
		
		
		
		
	*7) Building multivariable start list based on Univariate p-vals <= 0.20
		
		local start ""
		
		foreach T of local cterms {
			qui stcox `T', `vceopt'
			
			*Continuous variables (c. prefix): Always use individual coefficient test
			if strpos("`T'", "c.") == 1 {
				qui _term_p, term("`T'")
				local p = r(p)
				}
				
			*Categorical variables (ib prefix): Use Overall testparm for vars with >2 levels;
			*or individual testparm (equivalent) for binary vars
			
			else {
				local vname = substr("`T'", strpos("`T'",".")+1, .)
				qui levelsof `vname' if e(sample), local(_levs)
				local _nlevs = wordcount("`_levs'")
				cap testparm i.`vname'
				if _rc == 0 local p = r(p)
				else	    local p = .
			}
			
			if (`p' < . & `p' <= 0.20) local start "`start' `T'"
		}
		
		
		*Failsafe
		if trim("`start'") == "" local start "ib1.region ib1.resp_sex"
		di as txt "Start terms (p<=0.20): `start'"
		
		
		
	*8) Backward elimination in multivariable model (retain if p <= 0.20)
		
		local current "`start'"
		local changed 1
		
		
		while `changed' {
			local changed 0
			qui stcox `current', `vceopt'
			
			local worstp = -1
			local worstT ""
			
			foreach T of local current {
			
			*Continuous variables
			if strpos("`T'", "c.") == 1 {
				qui _term_p, term("`T'")
				local p = r(p)
				}
				
			*Categorical variables
			else {
				local vname = substr("`T'", strpos("`T'", ".")+1, .)
				cap testparm i.`vname'
				if _rc == 0 local p = r(p)
				else        local p = .
				}
				
			if (`p' < .) {
				if (`p' < . & `p' > `worstp') {
					local worstp = `p'
					local worstT "`T'"
					}
				}
			}
			
			if (`worstp' > 0.20 & "`worstT'" != "") {
			
				*Format p-value to 3 decimals (use < 0.001 if very small)
				local ptxt: display %9.3f `worstp'
				if (`worstp' < 0.001) local ptxt "<0.001"
			
				di as txt "Dropping: `worstT' (p =`ptxt')"
				local current: list current - worstT
				local current: list retok current
				local changed 1
			}
		}
		
		di as txt "Final multivariable terms (p <= 0.20): `current'"
				
				
		*Fit the final multivariable model
		qui stcox `current', `vceopt'
		
		
		
		
	*9) Write multivariable outputs to the same rows
	
		*Country
		_xl_write_coef, coef("2.region") row(7) model("MULTI")
		
		
		*Gender
		_xl_write_coef, coef("2.resp_sex") row(10) model("MULTI")
		
		
		*Lactating cows
		_xl_write_coef, coef("herd_lact_cows") row(11) model("MULTI")
		
			
		*Knowledge score
		_xl_write_coef, coef("bov_know_score") row(12) model("MULTI")
		
		
		*Hygiene score
		_xl_write_coef, coef("farm_hyg_prac_score") row(13) model("MULTI")
		
		
		*Milking score
		_xl_write_coef, coef("self_rep_milk_prac_score") row(14) model("MULTI")
		
		
		*Cow age
		_xl_write_coef, coef("enr_cow_age_new") row(16) model("MULTI")
	
	
		*Breed
		_xl_write_fvlevels, var("enr_cow_breed_") base(1) rowstart(19) model("MULTI") nrows(3) 

	
		*Parity
		_xl_write_fvlevels, var("cow_parity_cat") base(1) rowstart(24) model("MULTI") nrows(3) 	
	
	
		*Teat disinfection
		_xl_write_fvlevels, var("enr_cow_calv_disinf_new") base(0) rowstart(29) model("MULTI")  nrows(2) 

		
		*DCT History
		_xl_write_fvlevels, var("enr_cow_dct_new") base(0) rowstart(33) model("MULTI") nrows(2) 
		
		
		*Teat sealant
		_xl_write_fvlevels, var("enr_cow_lact_seal_new") base(0) rowstart(37) model("MULTI") nrows(2) 		
	

		*Days in milk
		_xl_write_coef, coef("enr_cow_milk_hist_") row(40) model("MULTI")		
	
	
		*Body condition
		_xl_write_coef, coef("L_cow_bcs_") row(41) model("MULTI")		
		
		
		*Mineral supplementation
		_xl_write_coef, coef("1.L_diet_mineral_yesno") row(42) model("MULTI")		
	
	
		*Lymph nodes
		_xl_write_coef, coef("1.L_enr_cow_lymp_szie_new") row(45) model("MULTI")		
	
	
		*Lameness
		_xl_write_coef, coef("1.L_enr_cow_lameness_new") row(48) model("MULTI")	
	
	
		*Consistency of feces
		_xl_write_fvlevels, var("enr_cow_feces_") base(0) rowstart(51) model("MULTI")  nrows(2) 

	
	
		*Clean udder
		_xl_write_coef, coef("1.L_cow_clean_udder_new") row(53) model("MULTI")		
	
	
		*Adequacy of the dairy structure
		_xl_write_coef, coef("1.adeq_zero_gra_unit") row(57) model("MULTI")		
	
	
		*At least one cow in the herd was diagnosed with bovine mastitis
		_xl_write_coef, coef("1.L_cow_bv_yn_") row(58) model("MULTI")		
			
	
		*Water ad lib
		_xl_write_coef, coef("1.L_diet_water") row(59) model("MULTI")	
	
	
		*Forage ad lib
		_xl_write_coef, coef("1.L_diet_forage") row(60) model("MULTI")
		
		
		*Barn clean
		_xl_write_coef, coef("1.L_clean_barn") row(61) model("MULTI")		
		
		
		*Cubicles clean
		_xl_write_coef, coef("1.L_clean_cubicles") row(62) model("MULTI")		
		
		
		*Bedding observed
		_xl_write_coef, coef("1.bedding_obs") row(63) model("MULTI")		
		
		
		
		
*===============================================================================
*Stratified analysis by country
*===============================================================================
	
	
	
