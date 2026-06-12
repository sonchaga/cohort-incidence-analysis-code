*******************************************************************************
* Author: Sylvia Onchaga
* Purpose: To describe cow characteristics at baseline
* Date of creation: 28/07/2025
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
	global randomization "4_1_Phone_intervention"
	global base_charact "4_2_0_Baseline_stats"
	global tempdata "4_4_Interim datasets"
	
	
	*Output date	
	global date: display %tdYND date(c(current_date), "DMY") 	
	
	
	*Output file
	global fileout "${base_charact}/${date}_Farmer and Cow characteristics.xlsx"

	
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

	
	
	//0. 
***************************************************************************************************************************************
	use "${baseline}.dta", clear
	
*************************************************************************************************************************************
	
	*Constructing the table as designed in the PAP
	putexcel set "${fileout}", sheet("Table 1_2a Cow charact") modify
	
	
	putexcel A1 = "Table 2_1 Characteristics of the cows and farm (at baseline)"
	putexcel D3 = "Overall sample"
	putexcel C4 = "Median"
	putexcel D4 = "IQR"
	putexcel E4 = "Mean or %"
	putexcel F4 = "Standard deviation"
	
	
	putexcel H3 = "Kenya"
	putexcel G4 = "Median"
	putexcel H4 = "IQR"
	putexcel I4 = "Mean or %"
	putexcel J4 = "Standard deviation"
	
	putexcel L3 = "Uganda"
	putexcel K4 = "Median"
	putexcel L4 = "IQR"
	putexcel M4 = "Mean or %"
	putexcel N4 = "Standard deviation"
	
	putexcel O3 = "Comparison by Nationality"
	putexcel O4 = "p-value (difference in means or test of independency)"
	putexcel P4 = "p-value (Median test)"
	
		
	*Summarizing the variables of interest
	
	putexcel B6 = "Gender of the farmer"
	putexcel B7 = "Male"
	putexcel B8 = "Female"
		
	putexcel B12 = "Cow demographics & medical history"
	putexcel B13 = "Total number of lactating dairy cows" 
	putexcel B14 = "Age (Months)"
	
	putexcel B15 = "Breed"
	putexcel B16 = "  Fresian"
	putexcel B17 = "  Ayshire"
	putexcel B18 = "  Jersey"
	putexcel B19 = "  Guernsey"
	putexcel B20 = "  Cross breed"
	putexcel B21 = "  Other breed"
	
	putexcel B22 = "Parity"
	putexcel B23 = "Received teat disinfection before calving"
	putexcel B24 = "History of Dry Cow Therapy (DCT) before end of last lactation*"
	putexcel B25 = "Received internal teat sealant before end of last lactation*"
	
	putexcel B26 = "Cow's status at enrollment"
	putexcel B27 = "  Age of youngest calf (days)"
	putexcel B28 = "  Days in milk"
	putexcel B29 = "  Body condition score"
	putexcel B30 = "  Had received mineral supplementation in the past 30 days"
	
	putexcel B31 = "Size of the cow's superficial lymph nodes"
	putexcel B32 = "  Normal"
	putexcel B33 = "  Slightly swollen"
	putexcel B34 = "  Swollen"
	
	putexcel B35 = "Cow's lameness score"
	putexcel B36 = "  Normal"
	putexcel B37 = "  Mild"
	putexcel B38 = "  Moderate"
	putexcel B39 = "  Lame"
	putexcel B40 = "  Severe"
	
	putexcel B41 = "Cow's current consistency"
	putexcel B42 = "  Hard"
	putexcel B43 = "  Soft"
	putexcel B44 = "  Watery"
	putexcel B45 = "  Watery with blood"
	
	putexcel B46 = "Cleanliness of the cow"
	putexcel B47 = "  Back"
	putexcel B48 = "  Flank"
	putexcel B49 = "  Tail"
	putexcel B50 = "  Lower hind leg"
	putexcel B51 = "  Udder"
	
	putexcel B52 = "Farm environment at enrollment"
	putexcel B53 = "Adequacy of zero-graze unit based on herd size ratio to number of cubicles" 
	putexcel B54 = "  Inadequate structure (>1.6 cows : 1 cubicle)"
	putexcel B55 = "  Adequate structure (<=1.6 cows:1cubicle)"
	putexcel B56 = "Drinking water is ad libitum (present all times)"
	putexcel B57 = "Forage is ad libitum (present at all times)"
	putexcel B58 = "Barn is free of manura or has scanty manure"
	putexcel B59 = "Cubicles are clean of manure or have scanty manure"
	putexcel B60 = "Cubicles include at least one form of bedding"
	putexcel B61 = "  Sand"
	putexcel B62 = "  Sawdust"
	putexcel B63 = "  Hay"
	putexcel B64 = "  Cow mattress"
	putexcel B65 = "  Tree leaves"
	putexcel B66 = "  Wood shavings"
	putexcel B67 = "  Straw mats"
	putexcel B68 = "  Other bedding type"
	

	
	cap matrix drop rtable
	mat rtable = J(70,18,.)
	
		
	*Computing the summary statistics
	cap tab resp_sex, gen(resp_sex)
	cap tab adeq_zero_gra_unit, gen(adeq_zero_gra_unit)
	
	
	//1. Respondent's gender
	*Overall
	
	local row 7
	foreach v of varlist resp_sex1 resp_sex2 {
	
	*Overall sample
	sum `v', detail
	putexcel E`row' = `r(mean)'
	
	*Among Kenyans
	sum `v' if region == 1, detail
	putexcel I`row' = `r(mean)'

	*Among Ugandans
	sum `v' if region == 2, detail
	putexcel M`row' = `r(mean)'

	local ++row
	}
	
	
	cap tab resp_age region, chi2 exact
		cap scalar pvalue = round((r(p)), 0.001)
		putexcel O7 = pvalue

	
	//Use cow_data only to summarize cow demographics, medical history and cow's status at enrollment
	preserve
	use "${base_charact}/temp_cowdata.dta", clear
	
	
	//2. Cow age in month
	
	*Overall sample
	sum enr_cow_age_ if enr_cow_age_ <400, detail
	putexcel C10 = `r(p50)'
	putexcel D10 = "`r(p25)' - `r(p75)'"
	putexcel E10 = `r(mean)'
	putexcel F10 = `r(sd)'

	
	*Among Kenyans
	sum enr_cow_age_ if region == 1 & enr_cow_age_ <400, detail
	putexcel G10 = `r(p50)'
	putexcel H10 = "`r(p25)' - `r(p75)'"
	putexcel I10 = `r(mean)'
	putexcel J10 = `r(sd)'

	
	*Among Ugandans
	sum enr_cow_age_ if region == 2 & enr_cow_age_ <400, detail
	putexcel K10 = `r(p50)'
	putexcel L10 = "`r(p25)' - `r(p75)'"
	putexcel M10 = `r(mean)'
	putexcel N10 = `r(sd)'
	
	
	*Comparing knowledge score by nationality
	cap ttest enr_cow_age_ if enr_cow_age_ <400, by(region)
	cap scalar pvalue = round((r(p)),0.001)
		putexcel O10 = pvalue
		
	*Comparing medians
	cap median enr_cow_age_ if enr_cow_age_ <400, by(region) medianties(below)
		cap scalar pvalue = round((r(p)),0.001)
		putexcel P10 = pvalue	
	
		
	
	//2. Breed, parity, teat disinfection, DCT history, internal teat sealant
	
	tab enr_cow_breed_, gen(breed)
	
	*Dropping the extreme value for cow parity (pending confirmation) inorder not to skew the distribution
	replace enr_cow_parity_ = . if enr_cow_parity_ == 998
	
	*Report percentage saying "yes"
	tab enr_cow_calv_disinf_, gen(enr_cow_calv_disinf_)
	tab enr_cow_dct_new, gen(enr_cow_dct_new)
	tab cow_lact_seal_new, gen(cow_lact_seal_new)
	
	
	local row 16
	foreach v of varlist breed2 breed3 {
	*Overall sample
	sum `v', detail
	putexcel E`row' = `r(mean)'

	
	*Among Kenyans
	sum `v' if region == 1, detail
	putexcel I`row' = `r(mean)'
	

	*Among Ugandans
	sum `v' if region == 2, detail
	putexcel M`row' = `r(mean)'

	
	cap tab `v' region, chi2 exact
		cap scalar pvalue = round((r(p)), 0.001)
		putexcel O`row' = pvalue
	local ++row
	}
	
	
	
	local row 20
	foreach v of varlist breed4 breed1 enr_cow_parity_ enr_cow_calv_disinf_2 enr_cow_dct_new3 cow_lact_seal_new3 {
	*Overall sample
	sum `v', detail
	putexcel E`row' = `r(mean)'
	
	*Among Kenyans
	sum `v' if region == 1, detail
	putexcel I`row' = `r(mean)'

	*Among Ugandans
	sum `v' if region == 2, detail
	putexcel M`row' = `r(mean)'

	
	cap tab `v' region, chi2 exact
		cap scalar pvalue = round((r(p)), 0.001)
		putexcel O`row' = pvalue
	local ++row
	}
	
	
	cap tab enr_cow_breed_ region, chi2 exact
		cap scalar pvalue = round((r(p)), 0.001)
		putexcel O15 = pvalue
	
	
	
	
	*Reporting medians and IQR stats for Parity
	
	*Overall sample
	sum enr_cow_parity_, detail
	putexcel C22 = `r(p50)'
	putexcel D22 = "`r(p25)' - `r(p75)'"
	putexcel E22 = `r(mean)'
	putexcel F22 = `r(sd)'

	
	*Among Kenyans
	sum enr_cow_parity_ if region == 1, detail
	putexcel G22 = `r(p50)'
	putexcel H22 = "`r(p25)' - `r(p75)'"
	putexcel I22 = `r(mean)'
	putexcel J22 = `r(sd)'

	
	*Among Ugandans
	sum enr_cow_parity_ if region == 2, detail
	putexcel K22 = `r(p50)'
	putexcel L22 = "`r(p25)' - `r(p75)'"
	putexcel M22 = `r(mean)'
	putexcel N22 = `r(sd)'
	
	
	*Comparing knowledge score by nationality
	cap ttest enr_cow_parity_, by(region)
	cap scalar pvalue = round((r(p)),0.001)
		putexcel O22 = pvalue
		
	*Comparing medians
	cap median enr_cow_parity_, by(region) medianties(below)
		cap scalar pvalue = round((r(p)),0.001)
		putexcel P22 = pvalue	
	
	
	
	
	local row 27
	foreach v of varlist young_calf_age enr_cow_milk_hist_ cow_bcs_ {
	*Overall sample
	sum `v', detail
	putexcel C`row' = `r(p50)'
	putexcel D`row' = "`r(p25)' - `r(p75)'"
	putexcel E`row' = `r(mean)'
	putexcel F`row' = `r(sd)'
	
	*Among Kenyans
	sum `v' if region == 1, detail
	putexcel G`row' = `r(p50)'
	putexcel H`row' = "`r(p25)' - `r(p75)'"
	putexcel I`row' = `r(mean)'
	putexcel J`row' = `r(sd)'

	*Among Ugandans
	sum `v' if region == 2, detail
	putexcel K`row' = `r(p50)'
	putexcel L`row' = "`r(p25)' - `r(p75)'"
	putexcel M`row' = `r(mean)'
	putexcel N`row' = `r(sd)'
	
	
	*Comparing means by nationality
	cap ttest `v', by(region)
	cap scalar pvalue = round((r(p)),0.001)
		putexcel O`row' = pvalue
		
	*Comparing medians
	cap median enr_cow_age_, by(region) medianties(below)
		cap scalar pvalue = round((r(p)),0.001)
		putexcel P`row' = pvalue	
		
	local ++row
	}
	
	
	
	//Mineral supplementation
	
	*Overall sample
	sum diet_mineral_yesno, detail
	putexcel E30 = `r(mean)'
	
	*Among Kenyans
	sum diet_mineral_yesno if region == 1, detail
	putexcel I30 = `r(mean)'
	
	
	*Among Ugandans
	sum diet_mineral_yesno if region == 2, detail
	putexcel M30 = `r(mean)'
	
		
	cap tab diet_mineral_yesno region, chi2 exact
		cap scalar pvalue = round((r(p)), 0.001)
		putexcel O30 = pvalue
	

	
	
	//Cow's superficial lymph nodes
	
	tab enr_cow_lymp_szie_, gen(enr_cow_lymp_szie_)
	
	local row 32
	foreach v of varlist enr_cow_lymp_szie_1 enr_cow_lymp_szie_2 {
	
	*Overall sample
	sum `v', detail
	putexcel E`row' = `r(mean)'
	
	*Among Kenyans
	sum `v' if region == 1, detail
	putexcel I`row' = `r(mean)'

	*Among Ugandans
	sum `v' if region == 2, detail
	putexcel M`row' = `r(mean)'

	local ++row
	}
	
	cap tab enr_cow_lymp_szie_ region, chi2 exact
		cap scalar pvalue = round((r(p)), 0.001)
		putexcel O31 = pvalue
	
	
	
	//Cow's lameness
	
	tab enr_cow_lameness_, gen(enr_cow_lameness_)
	
	local row 36
	foreach v of varlist enr_cow_lameness_1 enr_cow_lameness_2 {
	
	*Overall sample
	sum `v', detail
	putexcel E`row' = `r(mean)'
	
	*Among Kenyans
	sum `v' if region == 1, detail
	putexcel I`row' = `r(mean)'

	*Among Ugandans
	sum `v' if region == 2, detail
	putexcel M`row' = `r(mean)'


	local ++row
	}
	
	
	cap tab enr_cow_lameness_ region, chi2 exact
		cap scalar pvalue = round((r(p)), 0.001)
		putexcel O35 = pvalue
	
	
	
	//Cow's current consistency
	
	tab enr_cow_feces_, gen(enr_cow_feces_)
	
	local row 42
	foreach v of varlist enr_cow_feces_1 enr_cow_feces_2 enr_cow_feces_3 {
	
	*Overall sample
	sum `v', detail
	putexcel E`row' = `r(mean)'
	
	*Among Kenyans
	sum `v' if region == 1, detail
	putexcel I`row' = `r(mean)'

	*Among Ugandans
	sum `v' if region == 2, detail
	putexcel M`row' = `r(mean)'

	
	cap tab `v' region, chi2 exact
		cap scalar pvalue = round((r(p)), 0.001)
		putexcel O`row' = pvalue
	local ++row
	}
	
	cap tab enr_cow_feces_ region, chi2 exact
		cap scalar pvalue = round((r(p)), 0.001)
		putexcel O41 = pvalue
	
	
	
	
	//Cow's cleanliness
	
	tab1 cow_clean_back cow_clean_flank cow_clean_tail cow_clean_limb cow_clean_udder
	
	local row 47
	foreach v of varlist cow_clean_back cow_clean_flank cow_clean_tail cow_clean_limb cow_clean_udder {
	
	*Overall sample
	sum `v', detail
	putexcel E`row' = `r(mean)'
	
	*Among Kenyans
	sum `v' if region == 1, detail
	putexcel I`row' = `r(mean)'

	*Among Ugandans
	sum `v' if region == 2, detail
	putexcel M`row' = `r(mean)'

	
	cap tab `v' region, chi2 exact
		cap scalar pvalue = round((r(p)), 0.001)
		putexcel O`row' = pvalue
	local ++row
	}
	
	restore
	
	
	
	
	
	//Describing the farm environment
	foreach v of varlist adeq_zero_gra_unit diet_water diet_forage {
		cap tab `v', gen(`v')
		}
		
	sum adeq_zero_gra_unit1 adeq_zero_gra_unit2 diet_water1 diet_forage1 clean_barn clean_cubicles bedding_obs
	
	local row 54
	foreach v of varlist adeq_zero_gra_unit1 adeq_zero_gra_unit2 ///
						 diet_water1 diet_forage1 clean_barn clean_cubicles bedding_obs ///
						 obs_bed_type_1 obs_bed_type_2 obs_bed_type_3 obs_bed_type_4 ///
						 obs_bed_type_5 obs_bed_type_6 obs_bed_type_7 obs_bed_type__96 {
	
	*Overall sample
	sum `v', detail
	putexcel E`row' = `r(mean)'
	
	*Among Kenyans
	sum `v' if region == 1, detail
	putexcel I`row' = `r(mean)'

	*Among Ugandans
	sum `v' if region == 2, detail
	putexcel M`row' = `r(mean)'

	
	cap tab `v' region, chi2 exact
		cap scalar pvalue = round((r(p)), 0.001)
		putexcel O`row' = pvalue
	local ++row
	}
	
	
	
	*Save farmer characteristics data
	save "${tempdata}/farmer_characteristics_data.dta", replace
	
