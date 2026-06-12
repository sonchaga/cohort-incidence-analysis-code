*******************************************************************************
* Author: Sylvia Onchaga, onchagasylvia@gmail.com
* Purpose: To estimate the incidence of Bovine Mastitis and determine the risk factors
* Date of creation: 17/12/2025
********************************************************************************

clear 
clear mata
clear matrix
set more off 
set maxvar 5000


	*Paths
	global root "G:/Shared drives/PROJECT FOLDER/Data"
	cd "${root}/4_Analysis"
	
	
	*Output folders
	*global randomization "4_1_Phone_intervention"
	global base_charact "4_2_0_Baseline_stats"
	global phone_intervention "4_1_Phone_intervention"
	global incidence "4_2_1_Incidence"
	global manuscript_2 "2_Manuscript_2"
	
	
	*Output date	
	global date: display %tdYND date(c(current_date), "DMY") 	
	
	
	*Output file
	global fileout "${manuscript_2}/${date}_Manuscript_2_Results.xlsx"
	
	
	*Data
	global baseline "${root}/1_Baseline/4_Clean_data/baseline_combined_clean"
	global alldata "${root}/2_Monthly_followup/4_Clean_data/alldata_clean_long"
	global tempdata "4_4_Interim datasets"
	
	
	

	*Graph settings
	
	graph set window fontface "Arial"

	
	*Set up globals for laterite colors
	global laterite_red "218 48 44"
	global laterite_green "208 238 214"
	global laterite_teal "125 217 186"
	global laterite_orange "242 115 23"
	global laterite_gray "36 31 33"
	global laterite_ltred "236 151 149"
	global laterite_ltgreen "231 246 234"
	global laterite_ltteal "190 236 220"
	global laterite_ltorange "248 185 134"
	global laterite_ltgray "144 142 143"
	global laterite_dkgreen "78 114 85"

	
	
	//A. Preparing indicators for Table 2.2 Incidence Rates (PAP)
***************************************************************************************************************************************
	use "${alldata}.dta", clear
	tab survey_round
	
	
	*Lets merge with baseline only data to fill in missing data only collected at baseline
	merge m:1 hhid using "${baseline}.dta", update
	drop _merge
	tab survey_round
	
	
	//1. Checking variables used for disaggregation
	tab1 survey_round region treatment, m
	
	
	
	//1. Computing the cow years, incidence rate and 95 confidence interval
	*We need the data in long format, each row representing a unique cow visit.
	*First summarize the bovine mastitis testing variables
	*Also note for clinical mastitis in Uganda was determined using presence of clinical symptoms and having a positive CMT test when SCC scanner had broken down.
			
	tab1 enr_cow_breed_oth_2 enr_cow_breed_oth_3
	
	
	//1a. Begin with reshaping data to long format
	
	*Let's select the variables used for this section based on the PAP; and reshape the data so each row corresponds to the cow
	*!! Checking if hhid uniquely identifies the farmers	
	keep region hhid cowid_1 cowid_2 cowid_3 enr_cow_age_1 enr_cow_age_2 enr_cow_age_3 ///
		 enr_cow_breed_1 enr_cow_breed_2 enr_cow_breed_3 ///
		 enr_cow_breed_oth_1 enr_cow_breed_oth_2 enr_cow_breed_oth_3 ///
		 enr_cow_parity_1 enr_cow_parity_2 enr_cow_parity_3 ///
		 enr_cow_calving_date_1 enr_cow_calving_date_2 enr_cow_calving_date_3 ///
		 today enr_cow_milk_hist_1 enr_cow_milk_hist_2 enr_cow_milk_hist_3 ///
		 enr_cow_calv_disinf_1 enr_cow_calv_disinf_2 enr_cow_calv_disinf_3 ///
		 enr_cow_dct_1 enr_cow_dct_2 enr_cow_dct_3 ///
		 enr_cow_lact_seal_1 enr_cow_lact_seal_2 enr_cow_lact_seal_3 ///
		 enr_cow_bv_prev_hx_1 enr_cow_bv_prev_hx_2 enr_cow_bv_prev_hx_3 ///
		 enr_cow_milk_hist_1 enr_cow_milk_hist_2 enr_cow_milk_hist_3 ///
		 cow_bcs_1 cow_bcs_2 cow_bcs_3 ///
		 diet_mineral_kgs diet_minerals diet_minerals_score ///
		 enr_cow_lymp_szie_1 enr_cow_lymp_szie_2 enr_cow_lymp_szie_3 ///
		 enr_cow_lameness_1 enr_cow_lameness_2 enr_cow_lameness_3 ///
		 enr_cow_feces_1 enr_cow_feces_2 enr_cow_feces_3 ///
		 cow_clean_back_1 cow_clean_back_2 cow_clean_back_3 ///
		 cow_clean_flank_1 cow_clean_flank_2 cow_clean_flank_3 ///
		 cow_clean_tail_1 cow_clean_tail_2 cow_clean_tail_3 ///
		 cow_clean_limb_1 cow_clean_limb_2 cow_clean_limb_3 ///
		 cow_clean_udder_1 cow_clean_udder_2 cow_clean_udder_3 ///
		 scc_count_1 scc_mastitis_status_1 scc_count_2 scc_mastitis_status_2  ///
		 scc_count_3 scc_mastitis_status_3 ///
		 cow_bv_sign_yn_1 cow_bv_sign_yn_2 cow_bv_sign_yn_3 ///
		 cmt_mastitis_status_1 cmt_mastitis_status_2 cmt_mastitis_status_3 ///
		 list_cmt_right_fore_1 list_cmt_left_fore_1 list_cmt_right_hind_1 ///
		 list_cmt_left_hind_1 list_cmt_right_fore_2 list_cmt_left_fore_2 ///
		 list_cmt_right_hind_2 list_cmt_left_hind_2 list_cmt_right_fore_3 ///
		 list_cmt_left_fore_3 list_cmt_right_hind_3 list_cmt_left_hind_3 ///
		 treatment resp_sex survey_round
	
	tab survey_round
	
		*3. Let's save the original variable labels
	local cowvars cowid enr_cow_age enr_cow_breed enr_cow_parity enr_cow_calving_date enr_cow_milk_hist enr_cow_calv_disinf ///
	enr_cow_dct enr_cow_lact_seal enr_cow_bv_prev_hx cow_bcs enr_cow_lymp_szie enr_cow_lameness enr_cow_feces ///
	cow_clean_back cow_clean_flank cow_clean_tail cow_clean_limb cow_clean_udder scc_count scc_mastitis_status ///
	cow_bv_sign_yn ///
	list_cmt_right_fore list_cmt_left_fore list_cmt_right_hind list_cmt_left_hind cmt_mastitis_status 

	foreach v of local cowvars {
		local L_`v': variable label `v'_1
		
		}
	
	*4. Reshape data from wide to long
	*Install reshape8 if not already installed. Only works for stata version 8 and above
	*reshape8 preserves the original variable labels to some extent when reshaping data
	
	reshape long ///
		cowid_ ///
		enr_cow_age_ ///
		enr_cow_breed_ ///
		enr_cow_parity_ ///
		enr_cow_calving_date_ ///
		enr_cow_milk_hist_ ///
		enr_cow_calv_disinf_ ///
		enr_cow_dct_ ///
		enr_cow_lact_seal_ ///
		enr_cow_bv_prev_hx_ ///
		cow_bcs_ ///
		enr_cow_lymp_szie_ ///
		enr_cow_lameness_ ///
		enr_cow_feces_ ///
		cow_clean_back_ ///
		cow_clean_flank_ ///
		cow_clean_tail_ ///
		cow_clean_limb_ ///
		cow_clean_udder_ ///
		scc_count_ ///
		scc_mastitis_status_ ///
		cow_bv_sign_yn_ ///
		list_cmt_right_fore_ ///
		list_cmt_left_fore_ ///
		list_cmt_right_hind_ ///
		list_cmt_left_hind_ ///
		cmt_mastitis_status_ , ///
		i(hhid survey_round) j(cowno)
		
		lab var cowno "Cow number within household"
		
		
	*5. Label variables after reshape
	
	foreach v of local cowvars {
		label var `v'_ "`L_`v''"
		}
		
	lab var cowno "Cow number within household"

		
	*Drop empty rows
	drop if missing(cowid_)
	tab survey_round
	
	
	*Confirm there are no duplicate cow ids
	*isid cowid_
	cap drop dup
	duplicates tag cowid_ survey_round, gen(dup)
	br if dup >0
	
	sort cowid_ survey_round
	duplicates list cowid_ survey_round
	

	
*===========================================================================
	*Bovine Mastitis Incidence Rate variables
	*Prepare variables for incidence rates estimation: 
	*	cowid, visit, visit_date, case counts at time t based on mastitis status - subclinical and clinical, 
*===========================================================================
	
	*i) Visit date
	cap drop visit_date
	clonevar visit_date = today
	
	
	*ii) Visit
	tab survey_round, m

		*Checking the SCC count summary - extreme values	
		bysort region: list region survey_round scc_count_ if scc_count_ <1000
		
		
	*iii) Mastitis status
	
		*Reclassifying mastitis status using CMT tests
		
		tab1 list_cmt_right_fore_ list_cmt_left_fore_ list_cmt_right_hind_ list_cmt_left_hind_ cmt_mastitis_status_
		*Looking at the distribution, it is possible that we classified many mild cases as +ve for mastitis when indeed they could be negative
		
		*label define cmt_status 0 "CMT negative" 1 "CMT positive", replace
		
		foreach v of varlist list_cmt_right_fore_ list_cmt_left_fore_ ///
					 list_cmt_right_hind_ list_cmt_left_hind_ {
					 
				cap drop `v'p
				clonevar `v'p = `v'
				replace `v'p = 0 if inlist(`v',0,1)
				replace `v'p = 1 if inlist(`v',2,3)
				label define cmt_status 0 "CMT negative" 1 "CMT positive", replace
				lab values `v'p posneglbl
				}
		
				
		cap drop cmt_mastitis_status_p
			clonevar cmt_mastitis_status_p = cmt_mastitis_status_
			replace cmt_mastitis_status_p = 0 if list_cmt_right_fore_p == 0 & ///
												  list_cmt_left_fore_p == 0 & ///
												  list_cmt_right_hind_p == 0 & ///
												  list_cmt_left_hind_p == 0
				
		tab cmt_mastitis_status_p 
		label values cmt_mastitis_status_p posneglbl

		
*===============================================================================
	/*	(a) Clinical mastitis: A positive test (CMT +ve & SCC > accompanied by clinical symptoms
		  Subclinical mastitis: A positive test without clinical symptoms
	*/
*===============================================================================
	
	/*1. Subclinical mastitis:
		 Having a postive CMT test without clinical signs if SCC count is missing; or
		 having SCC count above 200,000 cells/dl
		 */
	cap drop subclinical_dx1
	gen subclinical_dx1 = 0
	replace subclinical_dx1 = 1 if ((cmt_mastitis_status_p == 1 & missing(scc_count_)) | ///
								  (scc_count_ >= 200000 & !missing(scc_count_))) & cow_bv_sign_yn_ == 0
	lab var subclinical_dx1 "Def2_Subclinical mastitis case"
	tab subclinical_dx1
	
	
	/*2. Clinical mastitis: 
		 Having a positive CMT with clinical signs if SCC count is missing; or 
		 having SCC count above 200,000 cells/dl with clinical signs
		*/
	cap drop clinical_dx1
	gen clinical_dx1 = 0
	replace clinical_dx1 = 1 if ((cmt_mastitis_status_p == 1 & missing(scc_count_)) | ///
								  (scc_count_ >= 200000) & !missing(scc_count_)) &  cow_bv_sign_yn_ == 1
	lab var clinical_dx1 "Def2_Clinical mastitis case"
	tab clinical_dx1
	
	
	*Subclinical or Clinical mastitis
	cap drop mastitis_dx1
	gen mastitis_dx1 = 0
	replace mastitis_dx1 = 1 if subclinical_dx1 == 1 | clinical_dx1 == 1
	lab var mastitis_dx1 "Def2_Subclinical or clinical mastitis case"
	
	
	
*===============================================================================
	*(b) Bovine mastitis classification based on CMT and bovine mastitis clinical signs
*===============================================================================
	
	/*1. Subclinical mastitis:
		 Having a postive CMT test without clinical signs
		*/
	cap drop subclinical_dx2
	gen subclinical_dx2 = 0
	replace subclinical_dx2 = 1 if cmt_mastitis_status_p == 1 & cow_bv_sign_yn_ == 0
	lab var subclinical_dx2 "Def3_Subclinical mastitis case"
	tab subclinical_dx2
		
	
	/*2. Clinical mastitis: 
		 Having a positive CMT with clinical signs
		*/
	cap drop clinical_dx2
	gen clinical_dx2 = 0
	replace clinical_dx2 = 1 if cmt_mastitis_status_p == 1 &  cow_bv_sign_yn_ == 1
	lab var clinical_dx2 "Def3_Clinical mastitis case"
	tab clinical_dx2
	
	
	*3. Subclinical or Clinical mastitis
	cap drop mastitis_dx2
	gen mastitis_dx2 = 0
	replace mastitis_dx2 = 1 if subclinical_dx2 == 1 | clinical_dx2 == 1
	lab var mastitis_dx2 "Def3_Subclinical or clinical mastitis case"
	tab mastitis_dx2
	
	
*===============================================================================
	*(d) Checking how the two bovine mastitis classifications compare
*===============================================================================
	
	tab clinical_dx1 clinical_dx2
		//19 CMT positive cases classified as clinical but negative for clinical mastitis using SCC + Clinical signs
	
	tab subclinical_dx1 subclinical_dx2
		//248 subclinical cases identified when using SCC but negative using CMT only
		//48 subclinical cases identified when using CMT, that are otherwise classified as negative using SCC
	
	mean clinical_dx1 clinical_dx2
		//Clinical mastitis is slightly higher when using CMT + clinical signs versus SCC + clinical signs
		

	tab cow_bv_sign_yn_
		//81 cases in total had clinical signs of bovine mastitis
		
		
	*Checking the SCC and CMT test results for cases that had clinical signs
	tab scc_mastitis_status_ cmt_mastitis_status_p if cow_bv_sign_yn_ == 1
		//Based on this summary, we have 19 cases that tested positive for mastitis using CMT but has less than 200,000 SCC
		//Only three cases were both CMT and SCC negative but showed at least one clinical sign of mastitis
	
	
	*Checking the subclinical mastitis totals by classification
	mean subclinical_dx1 subclinical_dx2 clinical_dx1 clinical_dx2
		//Subclinical mastitis is substantially high when using SCC compared to CMT test results
	
	


*===============================================================================
	*(d) Creating time intervals and cow months
*===============================================================================

	*i)Let's now create time intervals between visits
	sort cowid_ visit_date
	bysort cowid_: gen t0 = visit_date[_n-1]
	gen t1 = visit_date
	
	*Format t0 and t1 as dates
	format t0 %td
	format t1 %td
	

	
	*ii)Generate cow months - t0 and t1 are currently reported as days
	cap drop cow_months
	gen cow_months = (t1-t0)/(365.25/12)  	//Number of days in a month = 365.25/12
	lab var cow_months "Total time contributed by each cow in months"
	sum cow_months
	
	

*===============================================================================
	*(e) Let's define bovine mastitis cases in the time interval - event occurred at t1 visit
*===============================================================================
	

	*i) Based SCC + Clinical signs / CMT + clinical signs where SCC is missing
	cap drop case_mast1
	gen case_mast1 = (mastitis_dx1 == 1) if mastitis_dx1 < .
		lab var case_mast1 "Def2_Mastitis case in interval at t1 visit"
	
	
	cap drop case_clin1
	gen case_clin1 = (clinical_dx1 == 1) if clinical_dx1 < .
		lab var case_clin1 "Def2_Clinical mastitis case in interval at t1 visit"
	
	
	cap drop case_sub1
	gen case_sub1 = (subclinical_dx1 == 1) if subclinical_dx1 < .
		lab var case_sub1 "Def2_Subclinical mastitis case in interval at t1 visit"
	
	
	
	*iii) Based on CMT test results and clinical signs
	cap drop case_mast2
	gen case_mast2 = (mastitis_dx2 == 1) if mastitis_dx2 < .
		lab var case_mast2 "Def3_Mastitis case in interval at t1 visit"
	
	
	cap drop case_clin2
	gen case_clin2 = (clinical_dx2 == 1) if clinical_dx2 < .
		lab var case_clin2 "Def3_Clinical mastitis case in interval at t1 visit"
	
	
	cap drop case_sub2
	gen case_sub2 = (subclinical_dx2 == 1) if subclinical_dx2 < .
		lab var case_sub2 "Def3_Subclinical mastitis case in interval at t1 visit"
	
	
	
	
	
*===============================================================================
	*Save the Bovine Mastitis events data
*===============================================================================
	save "${manuscript_2}/0_Tempdata/Incidence_data.dta", replace
	
	

	
