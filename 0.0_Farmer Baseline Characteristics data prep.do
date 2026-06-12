*******************************************************************************
* Author: Sylvia Onchaga, onchagasylvia@gmail.com
* Purpose: To describe farmer characteristics at baseline
* Date of creation: 28/07/2025
* Updated: Dropped treatment/control split; Overall + Country columns only.
*           Continuous variables: Mean(SD) row + Median(IQR) row.
*           P-value = Kenya vs Uganda comparison.
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
	global manuscript_2 "2_Manuscript_2"
	
	
	*Output date	
	global date: display %tdYND date(c(current_date), "DMY") 	
	
	
	*Output file
	global fileout "${manuscript_2}/${date}_Manuscript_2_Results.xlsx"

	
	*Data
	global baseline "${root}/1_Baseline/4_Clean_data/baseline_combined_clean"
	global alldata "${root}/2_Monthly_followup/4_Clean_data/alldata_clean_long"



*===============================================================================
* A. Prepare Farmer characteristics variables
*===============================================================================

	use "${alldata}.dta", clear
	
	list hhid if resp_education == .
	
	tab resp_sex
	label define gender 1 "Male" 2 "Female", replace
	label values resp_sex gender
	
	
	*1a. Wealth index: Kenya
	tab hh_eq_fuel
	gen hh_eq_fuel_ke = 1 if hh_eq_fuel == 3
	replace hh_eq_fuel_ke = 2 if hh_eq_fuel == 1
	replace hh_eq_fuel_ke = 3 if hh_eq_fuel_ke == .
	lab define hh_eq_fuel_ke 1 "LPG" 2 "Wood" 3 "Other", replace
	lab values hh_eq_fuel_ke hh_eq_fuel_ke
	
	tab hh_eq_floor
	gen hh_eq_floor_ke = 1 if hh_eq_floor == 2
	replace hh_eq_floor_ke = 2 if hh_eq_floor == 3
	lab define hh_eq_floor_ke 1 "Earth/sand" 2 "Other material", replace
	lab values hh_eq_floor_ke hh_eq_floor_ke
	
	global hhvars_ke hh_eq_electric hh_eq_dvd hh_eq_fridge hh_eq_cupboard hh_eq_clock hh_eq_sofa ///
					 hh_eq_watch hh_eq_bank hh_eq_fuel_ke hh_eq_floor_ke
					 
	foreach v of varlist $hhvars_ke {
		replace `v' = 2 if `v' == 0
	}
	
	rename ($hhvars_ke) (Q1 Q2 Q3 Q4 Q5 Q6 Q7 Q8 Q9 Q10)

	recode Q1  (1=0.0901723696984575)  (2=-0.0809206114139582)   (else=.) if region==1, gen(Q1_KE)
	recode Q2  (1=0.163508095826312)   (2=-0.0234657865451049)   (else=.) if region==1, gen(Q2_KE)
	recode Q3  (1=0.210731711224477)   (2=-0.0170120462717232)   (else=.) if region==1, gen(Q3_KE)
	recode Q4  (1=0.0622579569060288)  (2=-0.0485715199949654)   (else=.) if region==1, gen(Q4_KE)
	recode Q5  (1=0.126779546121326)   (2=-0.0242769343636582)   (else=.) if region==1, gen(Q5_KE)
	recode Q6  (1=0.0520518495259003)  (2=-0.0690471286572358)   (else=.) if region==1, gen(Q6_KE)
	recode Q7  (1=0.10446133591088)    (2=-0.0324784173306824)   (else=.) if region==1, gen(Q7_KE)
	recode Q8  (1=0.0821517087173338)  (2=-0.0606084284592917)   (else=.) if region==1, gen(Q8_KE)
	recode Q9  (1=0.24896345883716)    (2=-0.108088617065368)    (3=0.0603583719444778) (else=.) if region==1, gen(Q9_KE)
	recode Q10 (1=-0.100278973790337)  (2=0.0550723606302278)    (else=.) if region==1, gen(Q10_KE)

	gen double wealth_score_ke = Q1_KE + Q2_KE + Q3_KE + Q4_KE + Q5_KE + ///
	                              Q6_KE + Q7_KE + Q8_KE + Q9_KE + Q10_KE

	gen wealth_index_ke = .
	replace wealth_index_ke = 1 if wealth_score_ke >  -100            & wealth_score_ke < -0.396301480011
	replace wealth_index_ke = 2 if wealth_score_ke >= -0.396301480011
	replace wealth_index_ke = 3 if wealth_score_ke >= -0.174219099805
	replace wealth_index_ke = 4 if wealth_score_ke >=  0.117116728797
	replace wealth_index_ke = 5 if wealth_score_ke >=  0.501732861623
	replace wealth_index_ke = . if wealth_score_ke == .

	rename (Q1 Q2 Q3 Q4 Q5 Q6 Q7 Q8 Q9 Q10) ($hhvars_ke)
	

	
	
	*1b. Wealth index: Uganda
	gen hh_eq_fuel_ug = 1 if hh_eq_fuel == 1
	replace hh_eq_fuel_ug = 2 if hh_eq_fuel == 2
	replace hh_eq_fuel_ug = 3 if hh_eq_fuel == 4
	lab define hh_eq_fuel_ug 1 "Wood" 2 "Charcoal" 3 "Other", replace
	lab values hh_eq_fuel_ug hh_eq_fuel_ug
	
	gen hh_eq_floor_ug = 1 if hh_eq_floor == 1
	replace hh_eq_floor_ug = 2 if hh_eq_floor == 3
	lab define hh_eq_floor_ug 1 "Cement" 2 "Other material", replace
	lab values hh_eq_floor_ug hh_eq_floor_ug

	global hhvars_ug hh_eq_electric hh_eq_cd hh_eq_radio hh_eq_tv hh_eq_cupboard hh_eq_sofa ///
					 hh_eq_watch hh_eq_bank hh_eq_fuel_ug hh_eq_floor_ug hh_eq_roof hh_eq_wall
					 
	foreach v of varlist $hhvars_ug {
		replace `v' = 2 if `v' == 0
	}
	
	rename ($hhvars_ug) (Q1 Q2 Q3 Q4 Q5 Q6 Q7 Q8 Q9 Q10 Q11 Q12)

	recode Q1  (1=0.275603085756302)  (2=-0.175683453679085)  (else=.) if region==2, gen(Q1_UG)
	recode Q2  (1=0.577200591564178)  (2=-0.066351093351841)  (else=.) if region==2, gen(Q2_UG)
	recode Q3  (1=0.11636459082365)   (2=-0.140172019600868)  (else=.) if region==2, gen(Q3_UG)
	recode Q4  (1=0.553622901439667)  (2=-0.113039664924145)  (else=.) if region==2, gen(Q4_UG)
	recode Q5  (1=0.377477169036865)  (2=-0.101961888372898)  (else=.) if region==2, gen(Q5_UG)
	recode Q6  (1=0.389080584049225)  (2=-0.111183002591133)  (else=.) if region==2, gen(Q6_UG)
	recode Q7  (1=0.336532533168793)  (2=-0.0987134352326393) (else=.) if region==2, gen(Q7_UG)
	recode Q8  (1=0.257304966449738)  (2=-0.123342290520668)  (else=.) if region==2, gen(Q8_UG)
	recode Q9  (1=-0.240691840648651) (2=0.814900994300842)   (3=0.291707694530487) (else=.) if region==2, gen(Q9_UG)
	recode Q10 (1=0.356949418783188)  (2=-0.144967511296272)  (else=.) if region==2, gen(Q10_UG)
	recode Q11 (1=-0.302963495254517) (2=0.139120757579803)   (else=.) if region==2, gen(Q11_UG)
	recode Q12 (1=0.319381326436996)  (2=-0.142463430762291)  (else=.) if region==2, gen(Q12_UG)

	gen double wealth_score_ug = Q1_UG + Q2_UG + Q3_UG + Q4_UG + Q5_UG + Q6_UG + ///
	                              Q7_UG + Q8_UG + Q9_UG + Q10_UG + Q11_UG + Q12_UG

	gen wealth_index_ug = .
	replace wealth_index_ug = 1 if wealth_score_ug >  -100           & wealth_score_ug < -1.3102465868
	replace wealth_index_ug = 2 if wealth_score_ug >= -1.3102465868
	replace wealth_index_ug = 3 if wealth_score_ug >= -0.601067505777
	replace wealth_index_ug = 4 if wealth_score_ug >=  0.231222607195
	replace wealth_index_ug = 5 if wealth_score_ug >=  1.696585081517
	replace wealth_index_ug = . if wealth_score_ug == .

	rename (Q1 Q2 Q3 Q4 Q5 Q6 Q7 Q8 Q9 Q10 Q11 Q12) ($hhvars_ug)


	
	*1c. Combined wealth index
	cap drop wealth_index
	gen wealth_index = .
	forvalues q = 1/5 {
		replace wealth_index = `q' if (wealth_index_ke == `q' & region == 1) | ///
		                              (wealth_index_ug == `q' & region == 2)
	}
	lab var wealth_index "Wealth index"
	lab define wealth_index 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" ///
	                        4 "Quintile 4" 5 "Quintile 5", replace
	lab values wealth_index wealth_index


	
	
	*2. Education level
	cap drop edu_level
	recode resp_education (0     = 0 "No formal education") ///
	                      (1/2   = 1 "Primary") ///
	                      (3/4   = 2 "Secondary") ///
	                      (5/8   = 3 "Tertiary"), gen(edu_level)

						  

	*3. Livelihood sources
	cap drop liveli_dairy
	gen liveli_dairy = (livelihood_act_3 == 1)
	lab var liveli_dairy "Dairy farming (sale of dairy milk and dairy products)"
	
	cap drop liveli_agri
	gen liveli_agri = (livelihood_act_4 == 1 | livelihood_act_5 == 1)
	lab var liveli_agri "Other agricultural activities"
	
	cap drop liveli_oth
	gen liveli_oth = (livelihood_act_1 == 1 | livelihood_act_2 == 1 | ///
	                  livelihood_act_6 == 1 | livelihood_act_7 == 1 | ///
	                  livelihood_act_8 == 1 | livelihood_act__96 == 1)
	lab var liveli_oth "Non-agricultural activities and sources"

	

	*4. Income proportions
	replace hh_income_dairy = 10 if hh_income_dairy == .
	
	cap drop hh_inc_agric_act
	gen hh_inc_agric_act = hh_income_livest + hh_income_crops
	lab var hh_inc_agric_act "Income from other agricultural activities"
	replace hh_inc_agric_act = 10 if hh_inc_agric_act == .
	
	cap drop hh_inc_nonagri
	egen hh_inc_nonagri = rowtotal(hh_income_formal hh_income_informal hh_income_remit ///
	                                hh_income_pension hh_income_selfempl hh_income_other)
	lab var hh_inc_nonagri "Income from non agricultural activities"
	replace hh_inc_nonagri = 10 if hh_inc_nonagri == .


	
	*5. Farm size and allocation
	cap drop prop_farm_dairy
	gen prop_farm_dairy = round(100 * (farm_size_dairy_unit_calc / farm_size_tot_calc), 0.1)
	lab var prop_farm_dairy "Proportion of the farm used for the dairy structure"
	
	cap drop prop_farm_fodder
	gen prop_farm_fodder = round(100 * (farm_size_fodder_unit_calc / farm_size_tot_calc), 0.1)
	lab var prop_farm_fodder "Proportion of the farm used to grow fodder"


	*6. Dairy herd size
	cap drop tot_dairy_herd
	egen tot_dairy_herd = rowtotal(herd_dry_cows herd_lact_cows)
	lab var tot_dairy_herd "Household's dairy herd size"


	
	
	*7. Paid labour indicator
	cap drop prop_paid_labor
	recode workers_dairy_paid (0 = 0 "No paid workers") (1/8 = 1 "Has paid workers"), ///
	                           gen(prop_paid_labor)
	lab var prop_paid_labor "Proportion of dairy farmers with paid or hired workers"

	
	

	*8. Milking by machine
	cap drop prop_milk_by_mach
	recode tech_type (1 = 0 "No") (2/3 = 1 "Yes"), gen(prop_milk_by_mach)
	lab var prop_milk_by_mach "Proportion of farmers that milk using a machine"


	
*===============================================================================
*2. FARMER KAPs INDICATORS
*===============================================================================
	
	*1. Farmer's bovine mastitis knowledge score at baseline
	*Start by creating composite knowledge variables
	*If mastitis_aware is "No", mastitis cause is missing. Recode missing to "0"
	
	sum mastitis_aware mastitis_cause_1 mastitis_cause_2 mastitis_cause_3 mastitis_cause_4 mastitis_cause__96 mastitis_cause__98
	
	foreach v of varlist mastitis_cause_1 mastitis_cause_2 mastitis_cause_3 mastitis_cause_4 mastitis_cause__96 mastitis_cause__98 {
		replace `v' = 0 if mastitis_aware == 0 & `v' == .
		}
	
	gen bov_know_ind1 = 0
	replace bov_know_ind1 = 1 if mastitis_cause_1 == 1 | mastitis_cause_2 == 1 | mastitis_cause_3 == 1 | mastitis_cause_4 == 1 
	lab var bov_know_ind1 "Know mastitis cause"
	
		*Creating a second version of bov_know_ind1 to account for responses to True/False statements
		gen bov_know_ind1b = 0
		replace bov_know_ind1b = 1 if mastitis_cause_1 == 1 | mastitis_cause_2 == 1 | mastitis_cause_3 == 1 | mastitis_cause_4 == 1 | mastitis_general_1 == 1
		lab var bov_know_ind1b "Know mastitis cause"

					
	gen bov_know_ind2 = 0
	replace bov_know_ind2 = 1 if mastitis_detect_1 == 1 | mastitis_detect_2 == 1 | mastitis_detect_3 == 1 | mastitis_detect_4 == 1 
	replace bov_know_ind2 = 0 if mastitis_aware == 0
	lab var bov_know_ind2 "Know mastitis detection methods"
	
	
	gen bov_know_ind3 = 0
	replace bov_know_ind3 = 1 if mastitis_detect_freq == 1
	replace bov_know_ind3 = 0 if mastitis_aware == 0
	lab var bov_know_ind3 "Know mastitis should be checked daily"
	
	
	gen bov_know_ind4 = 0
	replace bov_know_ind4 = 1 if mastitis_impact_1 == 1 | mastitis_impact_2 == 1 | mastitis_impact_3 == 1 | mastitis_impact_4 == 1 | mastitis_impact_5 == 1
	replace bov_know_ind4 = 0 if mastitis_aware == 0
	lab var bov_know_ind4 "Know at least one impact of mastitis"
	tab bov_know_ind4
	
	
	gen mastitis_prevent_4b = 0
	replace mastitis_prevent_4b = 1 if mastitis_prevent_4==1 | mastitis_general_6==1
	egen ind5_total = rowtotal(mastitis_prevent_1 mastitis_prevent_2 mastitis_prevent_3 mastitis_prevent_4b mastitis_prevent_5 mastitis_prevent_6 mastitis_prevent_7)
	
	gen bov_know_ind5 = 0
	replace bov_know_ind5 = 1 if ind5_total>=4
	replace bov_know_ind5 = 0 if mastitis_aware == 0
	lab var bov_know_ind5 "Know how to prevent mastitis"
	
	
	gen bov_know_ind6 = 0
	replace bov_know_ind6 = 1 if mastitis_general_1 == 1
	lab var bov_know_ind6 "Know mastitis is a condition that affect the udder"
	tab bov_know_ind6
	
		
		*Creating a second version of bov_know_ind6 to account for responses to impact of mastitis
		
		cap drop bov_know_ind6b
		gen bov_know_ind6b = 0
		replace bov_know_ind6b = 1 if (mastitis_impact_1 == 1 | mastitis_impact_2 == 1) | mastitis_general_1 == 1
		lab var bov_know_ind6b "Know mastitis is a condition that affect the udder"
		tab bov_know_ind6b
		
	
	gen bov_know_ind7 = 0
	replace bov_know_ind7 = 1 if mastitis_general_2 == 0
	lab var bov_know_ind7 "Know mastitis is not only detected by changes in milk"
	tab bov_know_ind7
	
	
	gen bov_know_ind8 = 0
	replace bov_know_ind8 = 1 if mastitis_general_3 == 1
	lab var bov_know_ind8 "Know cows with mastitis should always be milked last"
	
	
	gen bov_know_ind9 = 0
	replace bov_know_ind9 = 1 if mastitis_general_4 == 1
	lab var bov_know_ind9 "Know milking should be done by squeezing the udder"
	

	gen bov_know_ind10 = 0
	replace bov_know_ind10 = 1 if mastitis_general_5 == 0
	lab var bov_know_ind10 "Know that one towel should not be ued to clean all animals"
	
	
	gen bov_know_ind11 = 0
	replace bov_know_ind11 = 1 if mastitis_general_6 == 1
	lab var bov_know_ind11 "Know mastitis teat dips help in prevention of mastitis"
	tab bov_know_ind11
		
		
		*Creating a second version of bov_know_ind11 to account for responses to mastitis prevention
		
		cap drop bov_know_ind11b
		gen bov_know_ind11b = 0
		replace bov_know_ind11b = 1 if (mastitis_prevent_3 == 1 | mastitis_prevent_4 == 1) ///
									  | mastitis_general_6 == 1
		lab var bov_know_ind11b "Know mastitis teat dips help in prevention of mastitis"
		tab bov_know_ind11b
	
	
	
	gen bov_know_ind12 = 0
	replace bov_know_ind12 = 1 if mastitis_general_7 == 0
	lab var bov_know_ind12 "Know hygeine in sleeping cubicles is essential in preventing mastitis"
	tab bov_know_ind12
	
		*Creating a second version of bov_know_ind12 to account for responses to mastitis prevention
		
		cap drop bov_know_ind12b
		gen bov_know_ind12b = 0
		replace bov_know_ind12b = 1 if mastitis_prevent_7 == 1 | mastitis_general_7 == 1
		lab var bov_know_ind12b "Know hygiene in sleeping cubicles is essential in preventing mastitis"
		tab bov_know_ind12b
	
	
	gen bov_know_ind13 = 0
	replace bov_know_ind13 = 1 if mastitis_general_8 == 1
	lab var bov_know_ind13 "Know most infection during lactation originate from infections during dry period"
	
	
	gen bov_know_ind14 = 0
	replace bov_know_ind14 = 1 if mastitis_general_9 == 1
	lab var bov_know_ind14 "Know mastitis can be controlled by vaccination"
	tab bov_know_ind14
		
		*Creating a second version of bov_know_ind14 to account for responses to mastitis prevention
		
		cap drop bov_know_ind14b
		gen bov_know_ind14b = 0
		replace bov_know_ind14b = 1 if mastitis_prevent_5 == 1 | mastitis_general_9 == 1
		lab var bov_know_ind14b "Know mastitis can be controlled by vaccination"
		tab bov_know_ind14b
	
	
	egen bov_know_score = rowtotal(bov_know_ind1 bov_know_ind2 bov_know_ind3 bov_know_ind4 bov_know_ind5 bov_know_ind6 ///
								  bov_know_ind7 bov_know_ind8 bov_know_ind9 bov_know_ind10 bov_know_ind11 ///
								  bov_know_ind12 bov_know_ind13 bov_know_ind14)
	lab var bov_know_score "Bovine mastitis knowledge score"
	sum bov_know_score
	
	
	
	
	//Alternative approach to computing bovine mastitis knowledge score based following Laura's feedback
	
	
	egen bov_know_score_v2 = rowtotal(bov_know_ind1 bov_know_ind2 bov_know_ind3 ///
									  bov_know_ind4 bov_know_ind5 bov_know_ind6b ///
									  bov_know_ind7 bov_know_ind8 bov_know_ind9 ///
									  bov_know_ind10 bov_know_ind11b ///
									  bov_know_ind12b bov_know_ind13 bov_know_ind14b)
	lab var bov_know_score_v2 "Bovine mastitis knowledge score_version 2"
	sum bov_know_score_v2
		
	
	mean bov_know_score bov_know_score_v2
	
	
	
	*2. Self-reported farm hygiene practices
	
	cap drop farm_hyg_prac1
	gen farm_hyg_prac1 = 0
	replace farm_hyg_prac1 = 1 if hyg_rem_manure == 1
	lab var farm_hyg_prac1 "Farmer removes manure from the dairy structure daily"
	
	
	/*Hygiene practice 2: Number of farmers that adhere to the minimum intervals for removing and replacing or cleaning sleeping pens, depending on the type of beddings:

		1) Wet and soiled straw or dust beddings removed DAILY
		2) bedding should be spread/turned DAILY and completely changed every 6 months
		3) Cow mattress should be washed DAILY
	
	*/
	
	
	cap drop farm_hyg_prac2
	gen farm_hyg_prac2 = 0
	replace farm_hyg_prac2 = 1 if (hyg_bedding_freq == 1 & (obs_bed_type_7 == 1 | obs_bed_type_2 == 1 | obs_bed_type_4 == 1 | obs_bed_type_3 == 1 | obs_bed_type_5 ==1 | obs_bed_type_6 == 1)) | ///
								  (hyg_bedding_freq != 99 & obs_bed_type_1 == 1)
	lab var farm_hyg_prac2 "Farmer adheres to minimum interval for removing and replacing or cleaning pens"
	tab farm_hyg_prac2															 
	
	
	cap drop farm_hyg_prac3
	gen farm_hyg_prac3 = 1
	replace farm_hyg_prac3 = 0 if hyg_disinf_freq == 99
	lab var farm_hyg_prac3 "Farmer disinfects cubicles at least once every 21 days"					
	tab farm_hyg_prac3
	
	
	cap drop farm_hyg_prac_score
	egen farm_hyg_prac_score = rowtotal(farm_hyg_prac1 farm_hyg_prac2 farm_hyg_prac3)
	label var farm_hyg_prac_score "Farmer hygiene practices score"
	tab farm_hyg_prac_score
	
	
	
	
	*3. Farmer's self-reported milking practices at baseline					//Already generated by Judy
	*Noticed all farmers milk by hand; only one farmer milks by hand and using a machine; does it make sense to generate one score combining general and hand milking practices?
	
	*Response to LB's comments: These were generated in the survey as calculate fields
	mean gen_milking_prac1 gen_milking_prac2 gen_milking_prac3 gen_milking_prac4 gen_milking_prac5 gen_milking_prac6
	mean gen_milk_prac_score																
	mean gen_hand_milk_score
	
	*Confirming if they are accurately computed
	*Practice 1
	cap drop gen_milking_prac1b
	gen gen_milking_prac1b = 0
	replace gen_milking_prac1b = 1 if ((tech_type == 1 | tech_type == 3) & tech_clean_teat == 1) | ///
									   (tech_type == 3 & tech_mach_clean == 1 & tech_clean_teat == 1)
	lab var gen_milking_prac1b "Farmer cleans teat with warm water before milking"
	tab gen_milking_prac1b gen_milking_prac1

	
	*Practice 2 >> These almost tally, gen_milking_prac2b is the correct one
	cap drop gen_milking_prac2b
	gen gen_milking_prac2b = 0
	replace gen_milking_prac2b = 1 if ( (tech_type == 1 | tech_type == 3) & ///
									((tech_paper_towel == 1 | tech_paper_towel == 2) | ///
									 tech_cloth_towel == 1)) | ///		
									(tech_type == 3 & ///
									((tech_mach_paper_towel == 1 | tech_mach_paper_towel == 2) | ///
									tech_mach_cloth_towel == 1))
	
	lab var gen_milking_prac2b "Farmer dries teats using a clean towel and do so using either one cloth towel per cow or one disposable paper towel per teat or per cow"
	tab gen_milking_prac2b 
	tab gen_milking_prac2
		
	
	*Practice 3 >> These tally
	cap drop gen_milking_prac3b
	gen gen_milking_prac3b = 0
	replace gen_milking_prac3b = 1 if ((tech_type == 1 | tech_type == 3) & ///
									  (tech_check_obs == 1 | tech_check_cup == 1 | tech_check_cmt == 1)) | ///
									  (tech_type == 3 & (tech_mach_obs == 1 | tech_mach_cup == 1 | tech_mach_cmt == 1))
	
	lab var gen_milking_prac3b "Farmer check for mastitis by observation, or using CMT or using strip cup"
	tab gen_milking_prac3b
	tab gen_milking_prac3

	
	*Practice 4 >> These tally
	cap drop gen_milking_prac4b
	gen gen_milking_prac4b = 0
	replace gen_milking_prac4b = 1 if ((tech_type == 1 | tech_type == 3) & ///
									  (tech_dip_teats == 1)) | ///
									  (tech_type == 3 & (tech_mach_postdip == 1))
	
	lab var gen_milking_prac4b "Farmer dips each teat in a post-dipping solution or coat teat with post milking disinfectant immediately after milking"
	tab gen_milking_prac4b
	tab gen_milking_prac4	
	
	
	*Practice 5 >> These tally
	cap drop gen_milking_prac5b
	gen gen_milking_prac5b = 0
	replace gen_milking_prac5b = 1 if hyg_disinf_parlor_freq == 1
	lab var gen_milking_prac5b "Number of farmers that disinfect the milking area on a daily basis"
	
	tab gen_milking_prac5
	tab gen_milking_prac5b
	
	
	*Practice 6 >> These tally
	cap drop gen_milking_prac6b
	gen gen_milking_prac6b = 0
	replace gen_milking_prac6b = 1 if hyg_disinf_equip_freq == 1
	replace gen_milking_prac6b = 0 if tech_type == 3 & hyg_disinf_machine_freq != 1
	lab var gen_milking_prac6b "Farmer disinfects the milking equipment on a daily basis"
	
	tab gen_milking_prac6 gen_milking_prac6b

	
	*Computing the general milking practices score using the updated variables
	cap drop gen_milk_prac_score_v2
	egen gen_milk_prac_score_v2 = rowtotal(gen_milking_prac1b gen_milking_prac2b ///
										   gen_milking_prac3b gen_milking_prac4b ///
										   gen_milking_prac5b gen_milking_prac6b)
	
	lab var gen_milk_prac_score_v2 "Number of the best practices the dairy farmer adheres to at each followup_version 2"
	sum gen_milk_prac_score_v2
	
	
	
	//Verifying hand milking practices
	
	*Hand milking practice 1 >> The two variables tally
	cap drop hand_milking_prac1b
	gen hand_milking_prac1b = 0 
	replace hand_milking_prac1b = 1 if tech_wash_hands == 1
	replace hand_milking_prac1b = . if tech_type == 2
	lab var hand_milking_prac1b "Farmer washes their hands during milking"
	tab hand_milking_prac1 hand_milking_prac1b
	
	
	*Hand milking practice 2 >> The two variables tally
	cap drop hand_milking_prac2b
	gen hand_milking_prac2b = 0 
	replace hand_milking_prac2b = 1 if tech_salve == 1
	replace hand_milking_prac2b = . if tech_type == 2
	lab var hand_milking_prac2b "Farmer applies milking salve"
	tab hand_milking_prac2 hand_milking_prac2b
	
	
	*Hand milking practice 3 >> There two variables do not tally
	cap drop hand_milking_prac3b
	gen hand_milking_prac3b = 0 
	replace hand_milking_prac3b = 1 if tech_squeeze == 1 & tech_pull == 0
	replace hand_milking_prac3b = . if tech_type == 2
	lab var hand_milking_prac3b "Farmer milks by squeezing and does not mention pulling the udder"
	tab hand_milking_prac3 hand_milking_prac3b
	
	
	*Computing the updated hand milking practices score using the updated variables
	
	cap drop hand_milk_pass
	gen hand_milk_pass = 0
	replace hand_milk_pass = 1 if hand_milking_prac1b == hand_milking_prac2b == hand_milking_prac3b == 1
	replace hand_milk_pass = . if tech_type == 2
	lab var hand_milk_pass "Farmers that adhere to all three best hand milking practices"
	tab hand_milk_pass
	
	
	
	*Computing self-reported milking practices - restricting to hand milking
	sum gen_milking_prac1b gen_milking_prac2b gen_milking_prac3b gen_milking_prac4b gen_milking_prac5b gen_milking_prac6b hand_milking_prac1b hand_milking_prac2b hand_milking_prac3b
	
	cap drop self_rep_milk_prac_score
		egen self_rep_milk_prac_score = rowtotal(gen_milking_prac1b gen_milking_prac2b gen_milking_prac3b gen_milking_prac4b gen_milking_prac5b gen_milking_prac6b hand_milking_prac1b hand_milking_prac2b hand_milking_prac3b)
		sum self_rep_milk_prac_score
		lab var self_rep_milk_prac_score "Self-reported milking practices (sum of all best practices reported)"
		
	
	*9. SAVE DATA
	save "${manuscript_2}/0_Tempdata/Farmer_Baseline_characteristics.dta", replace
	

