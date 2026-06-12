*******************************************************************************
* Author: Sylvia Onchaga
* Purpose: To prepare cow characteristics variables used in the risk factor analysis
* Date of creation: 15/01/2026
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
	global tempdata "${manuscript_2}/0_Tempdata/Farmer_Baseline_characteristics"
	
	
	*Output date	
	global date: display %tdYND date(c(current_date), "DMY") 	
	
	
	
	*Data
	global baseline "${root}/1_Baseline/4_Clean_data/baseline_combined_clean"
	global alldata "${root}/2_Monthly_followup/4_Clean_data/alldata_clean_long"
	global rfdata "Risk_factors_data"
	
	


*===============================================================================
* Starting with the complete clean data
*===============================================================================

	/*NOTE:
	- Each farmer (hhid) can have upto 5 enrolled cows labelled with suffixes 1,2,3. In this study we only had 
	- cowid_1 cowid_2 ... are the cow identifiers
	- Farm and farmer level variables repear across cows after reshape
	*/
	
	
	*1. Use alldata_clean_long - which is farmer level wide dataset and includes all survey rounds
	
	use "${alldata}.dta", clear
	tab survey_round region
	
	
	*Lets merge with baseline only data to fill in missing data only collected at baseline
		merge m:1 hhid using "${baseline}.dta", update
		drop _merge
	tab survey_round
	
	
	*2. Keep only variables (farm-level + all cow-level wide variables)
	
	keep region hhid today survey_round treatment resp_sex ///
		 cowid_1 cowid_2 cowid_3 enr_cow_age_1 enr_cow_age_2 enr_cow_age_3 ///
		 enr_cow_breed_1 enr_cow_breed_2 enr_cow_breed_3 ///
		 enr_cow_breed_oth_1 enr_cow_breed_oth_2 enr_cow_breed_oth_3 ///
		 enr_cow_parity_1 enr_cow_parity_2 enr_cow_parity_3 ///
		 enr_cow_calving_date_1 enr_cow_calving_date_2 enr_cow_calving_date_3 ///
		 enr_cow_milk_hist_1 enr_cow_milk_hist_2 enr_cow_milk_hist_3 ///
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
		 cow_bv_yn_1 cow_bv_yn_2 cow_bv_yn_3 ///
		 cow_bv_sign_yn_1 cow_bv_sign_yn_2 cow_bv_sign_yn_3 ///
		 cow_cea_rx_yn_1 cow_cea_rx_yn_2 cow_cea_rx_yn_3 ///
		 cow_susp_yn_1 cow_susp_yn_2 cow_susp_yn_3 ///
		 enr_cow_bv_prev_hx_1 enr_cow_bv_prev_hx_2 enr_cow_bv_prev_hx_3 ///
		 enr_cow_bv_latest_hx_1 enr_cow_bv_latest_hx_2 enr_cow_bv_latest_hx_3 ///
		 enr_cow_bv_prev_freq_1 enr_cow_bv_prev_freq_2 enr_cow_bv_prev_freq_3 ///
		 enr_cow_bv_rx_1 enr_cow_bv_rx_2 enr_cow_bv_rx_3 ///
		 enr_cow_susp_hx_1 enr_cow_susp_hx_2 enr_cow_susp_hx_3 ///
		 list_cmt_right_fore_1 list_cmt_left_fore_1 list_cmt_right_hind_1 list_cmt_left_hind_1 cmt_mastitis_status_1 ///
		 list_cmt_right_fore_2 list_cmt_left_fore_2 list_cmt_right_hind_2 list_cmt_left_hind_2 cmt_mastitis_status_2 ///
		 list_cmt_right_fore_3 list_cmt_left_fore_3 list_cmt_right_hind_3 list_cmt_left_hind_3 cmt_mastitis_status_3 ///
		 enr_cow_milk_hist_1 enr_cow_milk_hist_2 enr_cow_milk_hist_3 ///
		 tot_herd_size herd_dry_cows herd_lact_cows infra_cube_total cow_leaking_teats_num ///
		 diet_water diet_forage obs_clean_barn obs_clean_cub obs_bed_type obs_bed_type_oth ///
		 obs_bed_type_1 obs_bed_type_2 obs_bed_type_3 obs_bed_type_4 obs_bed_type_5 obs_bed_type_6 obs_bed_type_7 obs_bed_type__96
		 
	*3. Let's save the original variable labels
	local cowvars cowid enr_cow_age enr_cow_breed enr_cow_parity enr_cow_calving_date enr_cow_milk_hist enr_cow_calv_disinf ///
		enr_cow_dct enr_cow_lact_seal enr_cow_bv_prev_hx cow_bcs enr_cow_lymp_szie enr_cow_lameness enr_cow_feces ///
		cow_clean_back cow_clean_flank cow_clean_tail cow_clean_limb cow_clean_udder scc_count scc_mastitis_status ///
		cow_bv_sign_yn cow_cea_rx_yn cow_susp_yn enr_cow_bv_latest_hx enr_cow_bv_prev_freq enr_cow_bv_rx enr_cow_susp_hx ///
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
		cow_bv_yn_ ///
		cow_bv_sign_yn_ ///
		cow_cea_rx_yn_ ///
		cow_susp_yn_ ///
		enr_cow_bv_latest_hx_ ///
		enr_cow_bv_prev_freq_ ///
		enr_cow_bv_rx_ ///
		enr_cow_susp_hx_ ///
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
		
	*Drop empty rows
	drop if missing(cowid_)
	
	tab survey_round
	
	
*===============================================================================
*Updating key indicator variables that required recoding
*===============================================================================
		
		*1. Cow breed
		replace enr_cow_breed_ = 96 if enr_cow_breed_ == -96
		tab enr_cow_breed_
		list hhid cowid_ enr_cow_age_ enr_cow_parity_ if enr_cow_breed_ == . & survey_round == 0
		
		tab enr_cow_breed_
		lab define enr_cow_breed 1	"Fresian" 2	"Ayrshire" 3 "Jersey" 4	"Guernsey" 5 "Cross breed" 96 "Other, specify", replace
		lab values enr_cow_breed_ enr_cow_breed
		tab enr_cow_breed_, m
	
		
		
		*2. Cow age
		
		sum enr_cow_age_
		tab enr_cow_age_ if enr_cow_age_ > 96
		clonevar enr_cow_age_new = enr_cow_age_
		replace enr_cow_age_new = . if enr_cow_age_ == 998						//These entries were confirmed as unknown ages, therefore recoded to missing
		tab enr_cow_age_new, m
		
		
		tab cowid_ if enr_cow_age_ == .
		tab cowid_ if  enr_cow_age_new == .
		*Checking parity and how it compares with reported age
		
		
		*3. Parity
		tab enr_cow_parity_														
		list hhid cowid_ enr_cow_age_ enr_cow_parity_ if enr_cow_parity_ == . & survey_round == 0	//These cows are missing parity data without any explanation
		
		cap drop enr_cow_parity_new
			clonevar enr_cow_parity_new = enr_cow_parity_
			replace enr_cow_parity_new = . if enr_cow_parity_ == 998
		
		tab enr_cow_parity_new
			
		cap drop cow_parity_cat
		clonevar cow_parity_cat = enr_cow_parity_new
		replace cow_parity_cat = 4 if enr_cow_parity_new >= 4 & enr_cow_parity_new <=13
		replace cow_parity_cat = . if enr_cow_parity_new == .
		label define cow_parity_cat 1 "Parity 1" 2 "Parity 2" 3 "Parity 3" 4 "Parity 4-13", replace
		label values cow_parity_cat cow_parity_cat
		lab var cow_parity_cat "Number of times cow has given birth (parity)"
		tab cow_parity_cat, nol
		
		
		*4. Cow received teat disinfection before calving?
		tab enr_cow_calv_disinf_
		list hhid cowid_ enr_cow_age_ enr_cow_parity_ enr_cow_calv_disinf_ if enr_cow_calv_disinf_ == . & survey_round == 0 
	
		cap drop enr_cow_calv_disinf_new
		clonevar enr_cow_calv_disinf_new = enr_cow_calv_disinf_
		replace enr_cow_calv_disinf_new = 2 if enr_cow_calv_disinf_new == -99
		lab define enr_cow_calv_disinf_3 2 "First time calver, not applicable", modify
		tab enr_cow_calv_disinf_new
		
		
		*5. DCT before end of last lactation
		tab enr_cow_dct_
		list hhid cowid_ enr_cow_age_ enr_cow_parity_ enr_cow_calv_disinf_ enr_cow_dct_ if enr_cow_dct_ == . & survey_round == 0 
	
		clonevar enr_cow_dct_new = enr_cow_dct_
		replace enr_cow_dct_new = 2 if enr_cow_dct_new == -99
		lab define enr_cow_dct_3 2 "First time calver, not applicable", modify
		tab enr_cow_dct_new survey_round
		
		
		*6. Received internal teat sealant
		tab enr_cow_lact_seal_
		list hhid cowid_ enr_cow_age_ enr_cow_parity_ enr_cow_calv_disinf_ enr_cow_dct_ enr_cow_lact_seal_ if enr_cow_lact_seal_ == . & survey_round == 0 
	
		clonevar enr_cow_lact_seal_new = enr_cow_lact_seal_
		replace enr_cow_lact_seal_new = 2 if enr_cow_lact_seal_ == -99
		lab define enr_cow_lact_seal_3 2 "First time calver, not applicable", modify
		tab enr_cow_lact_seal_new survey_round
		
		
		*7. Days in Milk
		tab enr_cow_milk_hist_			//This too doesn't make sense. Some cows were past 30 days in milk by the time of enrollment
		
		count if enr_cow_milk_hist_ == 0 & survey_round == 0
		
		*Computing days in milk as the difference between interview date and date cow gave birth
		cap drop days_in_milk 
		gen days_in_milk = today - enr_cow_calving_date_ 
		tab days_in_milk									//May not be reliable because of errors in the calving date
		
		
		*8. Body Score Condition
		tab cow_bcs_
		
		*9. Received mineral supplementation
		tab diet_minerals
		
		cap drop diet_mineral_yesno
		clonevar diet_mineral_yesno = diet_minerals
		replace diet_mineral_yesno = 1 if diet_mineral_yesno != 0
		label define diet_minerals 1 "Mineral supplementation received in the past 30 days", modify
		tab diet_mineral_yesno
		
		
		*10. Lymp size
		tab enr_cow_lymp_szie_					//Lets combine slightly swollen + swollen for regression because of the small number of cases with swollen lymph nodes
		
		cap drop enr_cow_lymp_szie_new
		clonevar enr_cow_lymp_szie_new = enr_cow_lymp_szie_
		replace enr_cow_lymp_szie_new = 1 if enr_cow_lymp_szie_ == 2
		tab enr_cow_lymp_szie_new
		
		
		*11. Cow's lameness
		tab enr_cow_lameness_
		
		cap drop enr_cow_lameness_new
		clonevar enr_cow_lameness_new = enr_cow_lameness_
		replace enr_cow_lameness_new = 1 if enr_cow_lameness_ == 2 //combining mild and moderate lameness because only 1 observation is equal to moderate
		tab enr_cow_lameness_new
		
		
		*12. Cow's feces consistency
		tab enr_cow_feces_					//Distribution quite skewed, 
		
		
		*13 Cow cleanliness: Based on the feedback from Peter & Zoetis team, we are will consider udder cleanliness
		local cleanvars cow_clean_back_ cow_clean_flank_ cow_clean_tail_ cow_clean_limb_ cow_clean_udder_
		
		lab define clean_var 0 "Dirty - An area or dirtiness seen or very dirty" 1 "Clean - No diret or only minor fresh or dried splashes", replace
		
		*Let's create binary clean vars
			foreach v of local cleanvars {
				cap drop `v'new
				clonevar `v'new = `v'
				replace `v'new = 1 if `v' == 0
				replace `v'new = 0 if inlist(`v', 1,2)
				lab values `v'new clean_var
				tab `v'new
				}
		
		
		//Farm environment in the previous month variables
		
		*14. Adequacy of zero-graze unit based on herd size.
			*Based on the first report brief feedback, we will only consider ratio of herd size to number of cubicles
			
		cap drop zero_cubic_ratio
			gen zero_cubic_ratio = round(tot_herd_size/infra_cube_total, 0.1)
			lab var zero_cubic_ratio "Total herd size to number of cubicles in the zero graze unit"
			tab zero_cubic_ratio, m
		
			list tot_herd_size infra_cube_total if zero_cubic_ratio == .
			replace zero_cubic_ratio = tot_herd_size if infra_cube_total == 0			//All animals sleep in a single room; there are no cubicles which isn't ideal
			
		
		*Recode to generate a proxy adequacy indicator

		cap drop adeq_zero_gra_unit
		recode zero_cubic_ratio (min/1.6 = 1 "Adequate structure") ///
								 (1.7/max = 0 "Inadequate structure"), gen(adeq_zero_gra_unit)
		lab var adeq_zero_gra_unit "Adequacy of the zero-graze unit"
		
		tab adeq_zero_gra_unit
		
		
		
		*15. We did not have a variable explicitly confirming occurence of bovine mastitis in the herd in the previous 30 days; but we had a question asking if any of the cows had leaking teats
		*Number of cows with leaking teats
		
		tab cow_leaking_teats_num
		cap drop cow_leaking_teats_new
		clonevar cow_leaking_teats_new = cow_leaking_teats_num
		tab cow_leaking_teats_new
		
		*Responding to Laura's comment about creating a new variable for history of mastitis in the past 30 days
		
		tab cow_bv_yn_				//Just 22 cases with history of mastitis
		
		
		*16. Drinking water
		tab diet_water
			
			
		*17. Forage access
		tab diet_forage
		
		
		*18. Cleanliness of the barn
		tab obs_clean_barn
		cap drop clean_barn
		clonevar clean_barn = obs_clean_barn
		replace clean_barn = 1 if clean_barn < 3
		replace clean_barn = 0 if clean_barn >= 3
		label define clean_dairy 0 "Moderate or lots of slurry observed" 1 "Clean or scanty manure observed", modify
		label values clean_barn clean_dairy
		tab clean_barn
	
		
		*19. Cleanliness of the cubicle
		tab obs_clean_cub
		cap drop clean_cubicles
		clonevar clean_cubicles = obs_clean_cub
		replace clean_cubicles = 1 if clean_cubicles < 3
		replace clean_cubicles = 0 if clean_cubicles >= 3
		label values clean_cubicles clean_dairy
		tab clean_cubicles
		

		*20. Atleast one form of bedding
		cap drop beddings 
		egen beddings = rowtotal(obs_bed_type_1 obs_bed_type_2 obs_bed_type_3 ///
								 obs_bed_type_4 obs_bed_type_5 obs_bed_type_6 ///
								 obs_bed_type_7 obs_bed_type__96)
		
		tab beddings
		
		cap drop bedding_obs
		gen bedding_obs = 1
		replace bedding_obs = 0 if beddings == 0
		
		label define bedding_obs 0 "No bedding observed" 1 "At least one form of bedding", replace
		label values bedding_obs bedding_obs
		tab bedding_obs
	
		
		
		*21. History of bovine mastitis
		
		tab enr_cow_bv_prev_hx_
		cap drop enr_cow_bv_prev_hx_new
		clonevar enr_cow_bv_prev_hx_new = enr_cow_bv_prev_hx_
		replace enr_cow_bv_prev_hx_new = 2 if enr_cow_bv_prev_hx_new == -99
		lab define enr_cow_bv_prev_hx_3 2 "Does not apply. The cow is a first time calver", modify

		
	
		*21: Add in the farmer's knowledge, self-reported hygeine, and self-reported miliking practices
		*These variables were generated in the KAPs do file:
		*Run this do file, to ensure you are merging the most updated data
		
		
		merge m:1 hhid survey_round using "${tempdata}.dta", keepusing(bov_know_score bov_know_ind1 mastitis_cause_1 mastitis_cause_2 ///
						 mastitis_cause_3 mastitis_cause_4 mastitis_cause__96 mastitis_cause__98 ///
						 bov_know_ind1 mastitis_detect_1 mastitis_detect_2 mastitis_detect_3 ///
						 mastitis_detect_4 mastitis_detect__96 mastitis_detect__98 ///
						 bov_know_ind3 bov_know_ind4 mastitis_impact_1 mastitis_impact_2 ///
						 mastitis_impact_3 mastitis_impact_4 mastitis_impact_5 ///
						 mastitis_impact__96 mastitis_impact__98 ///
						 bov_know_ind5 mastitis_prevent_1 mastitis_prevent_2 mastitis_prevent_3 ///
						 mastitis_prevent_4 mastitis_prevent_5 ///
						 mastitis_prevent_6 mastitis_prevent_7 mastitis_prevent__96 mastitis_prevent__98 ///
						 bov_know_ind6 bov_know_ind7 bov_know_ind8 bov_know_ind9 bov_know_ind10 bov_know_ind11 ///
						 bov_know_ind12 bov_know_ind13 bov_know_ind14 farm_hyg_prac_score ///
						 farm_hyg_prac1 farm_hyg_prac2 farm_hyg_prac3 gen_milking_prac5 ///
						 self_rep_milk_prac_score gen_milking_prac1b gen_milking_prac2b gen_milking_prac3b ///
						 gen_milking_prac4b gen_milking_prac5b gen_milking_prac6b ///
						 hand_milking_prac1b hand_milking_prac2b hand_milking_prac3b)
		drop _merge
		tab survey_round					//In the manuscript it would make sense to drop round 8
		
		count
		
		
		
		//Save data
		save "${manuscript_2}/0_Tempdata/${rfdata}.dta", replace
