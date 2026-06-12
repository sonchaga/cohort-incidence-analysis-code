*******************************************************************************
* Author: Sylvia Onchaga
* Purpose: To describe farmer characteristics at baseline
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
*A: Read data
*===============================================================================


	do "${manuscript_2}/0.0_Farmer Baseline Characteristics data prep.do"
	
	*Keep baseline data only
	keep if survey_round == 0
	count

*===============================================================================
* B: Define programs to summarize the characteristics
*===============================================================================

	 *1. For continuous variables report mean and sd - as per our PAP
		*prog: write_mean_sd
	 
	cap program drop write_mean_sd
	program define write_mean_sd
		args var cond cell
		if "`cond'" == "all" {
			qui sum `var', detail
		}
		else {
			qui sum `var' if `cond', detail
		}
		if `r(N)' == 0 {
			putexcel set "${fileout}", sheet("Table 1_2 Farmers charact") modify
			putexcel `cell' = (".")
			exit
		}
		local mn  = string(round(`r(mean)', 0.1), "%9.1f")
		local sd  = string(round(`r(sd)',   0.1), "%9.1f")
		putexcel set "${fileout}", sheet("Table 1_2 Farmers charact") modify
		putexcel `cell' = ("`mn' (`sd')")
	end


	
	 *2. For proportion variables such as propotion of land used for dairy farming: prog: write_mean_sd_pct
		 * Program appends "%" to mean and SD or median and IQR.

	cap program drop write_mean_sd_pct
	program define write_mean_sd_pct
		args var cond cell
		if "`cond'" == "all" {
			qui sum `var', detail
		}
		else {
			qui sum `var' if `cond', detail
		}
		if `r(N)' == 0 {
			putexcel set "${fileout}", sheet("Table 1_2 Farmers charact") modify
			putexcel `cell' = (".")
			exit
		}
		local mn  = string(round(`r(mean)', 0.1), "%9.1f")
		local sd  = string(round(`r(sd)',   0.1), "%9.1f")
		putexcel set "${fileout}", sheet("Table 1_2 Farmers charact") modify
		putexcel `cell' = ("`mn'% (`sd'%)")
	end


	  *3. Continous variables - Report Median and IQR as per Peter/Zoetis request
	     *prog: write_median_iqr
	     *Writes "median (p25, p75)" 
	
	cap program drop write_median_iqr
	program define write_median_iqr
		args var cond cell
		if "`cond'" == "all" {
			qui sum `var', detail
		}
		else {
			qui sum `var' if `cond', detail
		}
		if `r(N)' == 0 {
			putexcel set "${fileout}", sheet("Table 1_2 Farmers charact") modify
			putexcel `cell' = (".")
			exit
		}
		local med = string(round(`r(p50)', 0.1), "%9.1f")
		local p25 = string(round(`r(p25)', 0.1), "%9.1f")
		local p75 = string(round(`r(p75)', 0.1), "%9.1f")
		putexcel set "${fileout}", sheet("Table 1_2 Farmers charact") modify
		putexcel `cell' = ("`med' (`p25', `p75')")
	end


	
	  *5. Append % to median and IQR for proportion variables
	   *prog: write_median_iqr_pct
	cap program drop write_median_iqr_pct
	program define write_median_iqr_pct
		args var cond cell
		if "`cond'" == "all" {
			qui sum `var', detail
		}
		else {
			qui sum `var' if `cond', detail
		}
		if `r(N)' == 0 {
			putexcel set "${fileout}", sheet("Table 1_2 Farmers charact") modify
			putexcel `cell' = (".")
			exit
		}
		local med = string(round(`r(p50)', 0.1), "%9.1f")
		local p25 = string(round(`r(p25)', 0.1), "%9.1f")
		local p75 = string(round(`r(p75)', 0.1), "%9.1f")
		putexcel set "${fileout}", sheet("Table 1_2 Farmers charact") modify
		putexcel `cell' = ("`med'% (`p25'%, `p75'%)")
	end

	

	 *6. For categorical variables, report percentages and 95% confidence intervals
	 *prog: write_prop_ci
	 *Writes "N (pct%, lb%, ub%)" using Wilson confidence intervals to handle extreme proportion values
	cap program drop write_prop_ci
	program define write_prop_ci
		args var cond cell
		if "`cond'" == "all" {
			qui ci proportions `var', wilson
		}
		else {
			qui ci proportions `var' if `cond', wilson
		}
		local n   = `r(N)'
		if `n' == 0 {
			putexcel set "${fileout}", sheet("Table 1_2 Farmers charact") modify
			putexcel `cell' = (".")
			exit
		}
		local pct = string(round(`r(mean)'*100, 0.1), "%9.1f")
		local lb  = string(round(`r(lb)'*100,   0.1), "%9.1f")
		local ub  = string(round(`r(ub)'*100,   0.1), "%9.1f")
		putexcel set "${fileout}", sheet("Table 1_2 Farmers charact") modify
		putexcel `cell' = ("`pct'% (`lb'%–`ub'%)")
	end


	  *7. To write formatted p-value ("<0.001" or rounded to 3dp)
	  *prog: write_pvalue
	cap program drop write_pvalue
	program define write_pvalue
		args pval cell
		putexcel set "${fileout}", sheet("Table 1_2 Farmers charact") modify
		if `pval' < 0.001 {
			putexcel `cell' = ("<0.001")
		}
		else {
			local fmtp = string(round(`pval', 0.001), "%9.3f")
			putexcel `cell' = ("`fmtp'")
		}
	end


	list hhid if resp_education == .
	
	
	
	
	
*===============================================================================
* C: Summarize indicators
* TABLE 1.2: Farmer Characteristics
*===============================================================================
	
	putexcel set "${fileout}", sheet("Table 1_2 Farmers charact") modify

	putexcel A1 = "Table 1_2 Farmer characteristics at baseline, by country"
	
	*Column labels
	putexcel B3 = "Overall"
	putexcel C3 = "Kenya"
	putexcel D3 = "Uganda"
	putexcel E3 = "p-value"

	putexcel B4 = "N=207"
	putexcel C4 = "N=101"
	putexcel D4 = "N=106"
	putexcel E4 = "(Kenya vs Uganda)"


	*Row labels
	putexcel A6  = "Age (Years)"
	putexcel A7  = "    Mean (SD)"
	putexcel A8  = "    Median (IQR)"

	putexcel A10 = "Wealth index (Equity Tool)"
	putexcel A11 = "    Quintile 1"
	putexcel A12 = "    Quintile 2"
	putexcel A13 = "    Quintile 3"
	putexcel A14 = "    Quintile 4"
	putexcel A15 = "    Quintile 5"

	putexcel A17 = "Highest education level completed - % (95% CI)"
	putexcel A18 = "    No formal education"
	putexcel A19 = "    Primary"
	putexcel A20 = "    Secondary"
	putexcel A21 = "    Tertiary (University / Vocational)"

	putexcel A23 = "Household's sources of income - % (95% CI)"
	putexcel A24 = "    Dairy farming (Sale of dairy milk and other dairy products)"
	putexcel A25 = "    Other agricultural activities"
	putexcel A26 = "    Non-agricultural activities and sources"

	putexcel A28 = "Proportion of household income from dairy farming"
	putexcel A29 = "    Mean (SD)"
	putexcel A30 = "    Median (IQR)"

	putexcel A32 = "Proportion of household income from other agricultural activities"
	putexcel A33 = "    Mean (SD)"
	putexcel A34 = "    Median (IQR)"

	putexcel A36 = "Proportion of household income from non-agricultural activities"
	putexcel A37 = "    Mean (SD)"
	putexcel A38 = "    Median (IQR)"

	putexcel A40 = "Farm size in square metres"
	putexcel A41 = "    Mean (SD)"
	putexcel A42 = "    Median (IQR)"

	putexcel A44 = "Proportion of farm used for the dairy structure"
	putexcel A45 = "    Mean (SD)"
	putexcel A46 = "    Median (IQR)"

	putexcel A48 = "Proportion of farm used to cultivate fodder"
	putexcel A49 = "    Mean (SD)"
	putexcel A50 = "    Median (IQR)"

	putexcel A52 = "Household's total herd size"
	putexcel A53 = "    Mean (SD)"
	putexcel A54 = "    Median (IQR)"

	putexcel A56 = "Household's dairy herd size"
	putexcel A57 = "    Mean (SD)"
	putexcel A58 = "    Median (IQR)"

	putexcel A60 = "Total number of lactating dairy cows"
	putexcel A61 = "    Mean (SD)"
	putexcel A62 = "    Median (IQR)"

	putexcel A64 = "Family members supporting dairy farming"
	putexcel A65 = "    Mean (SD)"
	putexcel A66 = "    Median (IQR)"

	putexcel A68 = "Farmers with paid/hired workers - % (95% CI)"
	putexcel A69 = "Farmers who milk by machine - % (95% CI)"

	putexcel A71 = "Bovine mastitis knowledge score"
	putexcel A72 = "    Mean (SD)"
	putexcel A73 = "    Median (IQR)"

	putexcel A75 = "Farm hygiene practices score"
	putexcel A76 = "    Mean (SD)"
	putexcel A77 = "    Median (IQR)"

	putexcel A79 = "Self-reported milking practices score"
	putexcel A80 = "    Mean (SD)"
	putexcel A81 = "    Median (IQR)"
	
	putexcel A83 = "Gender of the farmer"
	putexcel A84 = "    Male"
	putexcel A85 = "    Female"

	putexcel A86 = "*Household could have multiple income sources / multiple-choice allowed"
	putexcel A87 = "Note: Proportions shown as % (95% CI Wilson). Means shown as Mean (SD). Medians shown as Median (IQR: P25, P75). P-values: t-test (means), Wilcoxon rank-sum (medians), chi2/Fisher exact (proportions/categorical)."
	
	
	
*===============================================================================
* B: Computing and exporting results
*===============================================================================
	*0. Subgroup conditions and their stat columns
	local cond1 all
	local cond2 region==1
	local cond3 region==2
	local sg_cols B C D
	local n_sg = 3

	
	*1. Farmer's Age (continuous: Mean SD + Median IQR)
	forvalues s = 1/3 {
		local col : word `s' of `sg_cols'
		write_mean_sd resp_age "`cond`s''" `col'7
	}
	forvalues s = 1/3 {
		local col : word `s' of `sg_cols'
		write_median_iqr resp_age "`cond`s''" `col'8
	}
	qui ttest resp_age, by(region)
	local pv = `r(p)'
	write_pvalue `pv' E7
	qui ranksum resp_age, by(region)
	local pv = 2*normprob(-abs(`r(z)'))
	write_pvalue `pv' E8


	
	
	*2. Wealth Index (Categorical: Report quintile proportions and 95% CI)
	tab wealth_index, gen(wq_)

	* Quintile proportions rows 11-15
	local row 11
	forvalues q = 1/5 {
		forvalues s = 1/3 {
			local col : word `s' of `sg_cols'
			write_prop_ci wq_`q' "`cond`s''" `col'`row'
		}
		local ++row
	}
	qui tab wealth_index region, chi2 exact
	local pv = `r(p)'
	write_pvalue `pv' E11

	
	

	*3. Education Level (categorical: Report proportions with CI)
	tab edu_level, gen(educ_)

	local row 18
	forvalues e = 1/4 {
		forvalues s = 1/3 {
			local col : word `s' of `sg_cols'
			write_prop_ci educ_`e' "`cond`s''" `col'`row'
		}
		local ++row
	}
	qui tab edu_level region, chi2 exact
	local pv = `r(p)'
	write_pvalue `pv' E18



	*5.Livelihood Sources (Binary: Report proportions with CI)
	* Note a farmer can have multiple livelihood sources
	local row 24
	foreach var in liveli_dairy liveli_agri liveli_oth {
		forvalues s = 1/3 {
			local col : word `s' of `sg_cols'
			write_prop_ci `var' "`cond`s''" `col'`row'
		}
		qui tab `var' region, chi2 exact
		local pv = `r(p)'
		write_pvalue `pv' E`row'
		local ++row
	}


	
	
	*6.Income Proportions (Proportion variables: Report Mean SD + Median IQR; and append "%")
	local mean_row 29
	local med_row  30
	foreach var in hh_income_dairy hh_inc_agric_act hh_inc_nonagri {
		forvalues s = 1/3 {
			local col : word `s' of `sg_cols'
			write_mean_sd_pct    `var' "`cond`s''" `col'`mean_row'
			write_median_iqr_pct `var' "`cond`s''" `col'`med_row'
		}
		qui ttest `var', by(region)
		local pv = `r(p)'
		write_pvalue `pv' E`mean_row'
		qui ranksum `var', by(region)
		local pv = 2*normprob(-abs(`r(z)'))
		write_pvalue `pv' E`med_row'
		local mean_row = `mean_row' + 4
		local med_row  = `med_row'  + 4
	}


	*7.Farm Size and Allocation (Mean SD + Median IQR)
	* Farm total size - plain (metres, not a proportion)
	* Farm allocation is a proportion variable (Report Mean SD + Median IQR; and append "%")
	
	local mean_row 41
	local med_row  42
	forvalues s = 1/3 {
		local col : word `s' of `sg_cols'
		write_mean_sd    farm_size_tot_calc "`cond`s''" `col'`mean_row'
		write_median_iqr farm_size_tot_calc "`cond`s''" `col'`med_row'
	}
	qui ttest farm_size_tot_calc, by(region)
	local pv = `r(p)'
	write_pvalue `pv' E`mean_row'
	qui ranksum farm_size_tot_calc, by(region)
	local pv = 2*normprob(-abs(`r(z)'))
	write_pvalue `pv' E`med_row'
	local mean_row = `mean_row' + 4
	local med_row  = `med_row'  + 4

	
	* Farm allocation proportions – append %
	foreach var in prop_farm_dairy prop_farm_fodder {
		forvalues s = 1/3 {
			local col : word `s' of `sg_cols'
			write_mean_sd_pct    `var' "`cond`s''" `col'`mean_row'
			write_median_iqr_pct `var' "`cond`s''" `col'`med_row'
		}
		qui ttest `var', by(region)
		local pv = `r(p)'
		write_pvalue `pv' E`mean_row'
		qui ranksum `var', by(region)
		local pv = 2*normprob(-abs(`r(z)'))
		write_pvalue `pv' E`med_row'
		local mean_row = `mean_row' + 4
		local med_row  = `med_row'  + 4
	}


	

	*8.Herd Size (Continuous vairbale: Report Mean SD + Median IQR)
	local mean_row 53
	local med_row  54
	foreach var in tot_herd_size tot_dairy_herd herd_lact_cows {
		forvalues s = 1/3 {
			local col : word `s' of `sg_cols'
			write_mean_sd    `var' "`cond`s''" `col'`mean_row'
			write_median_iqr `var' "`cond`s''" `col'`med_row'
		}
		qui ttest `var', by(region)
		local pv = `r(p)'
		write_pvalue `pv' E`mean_row'
		qui ranksum `var', by(region)
		local pv = 2*normprob(-abs(`r(z)'))
		write_pvalue `pv' E`med_row'
		local mean_row = `mean_row' + 4
		local med_row  = `med_row'  + 4
	}



	*9.Farm Labour
	   *Family workers: (Mean (SD) + Median (IQR))
	   *Paid workers: (Percentage, 95% CI)
	   *Milking machine: (Percentage, 95% CI)


	forvalues s = 1/3 {
		local col : word `s' of `sg_cols'
		write_mean_sd    workers_dairy_fam "`cond`s''" `col'65
		write_median_iqr workers_dairy_fam "`cond`s''" `col'66
	}
	qui ttest workers_dairy_fam, by(region)
	local pv = `r(p)'
	write_pvalue `pv' E65
	qui ranksum workers_dairy_fam, by(region)
	local pv = 2*normprob(-abs(`r(z)'))
	write_pvalue `pv' E66

	local row 68
	foreach var in prop_paid_labor prop_milk_by_mach {
		forvalues s = 1/3 {
			local col : word `s' of `sg_cols'
			write_prop_ci `var' "`cond`s''" `col'`row'
		}
		qui tab `var' region, chi2 exact
		local pv = `r(p)'
		write_pvalue `pv' E`row'
		local ++row
	}


	
*10. Baseline KAPs Scores (continuous: Mean SD + Median IQR)

	local mean_row 72
	local med_row  73
	foreach var in bov_know_score farm_hyg_prac_score self_rep_milk_prac_score {
		forvalues s = 1/3 {
			local col : word `s' of `sg_cols'
			write_mean_sd    `var' "`cond`s''" `col'`mean_row'
			write_median_iqr `var' "`cond`s''" `col'`med_row'
		}
		qui ttest `var', by(region)
		local pv = `r(p)'
		write_pvalue `pv' E`mean_row'
		qui ranksum `var', by(region)
		local pv = 2*normprob(-abs(`r(z)'))
		write_pvalue `pv' E`med_row'
		local mean_row = `mean_row' + 4
		local med_row  = `med_row'  + 4
	}
	
	
	
*11. Gender of the farmer (Binary: Report proportions with CI)
	tab resp_sex, gen(resp_sex)
	local row 84
	forvalues e = 1/2 {
		forvalues s = 1/3 {
			local col : word `s' of `sg_cols'
			write_prop_ci resp_sex`e' "`cond`s''" `col'`row'
		}
		local ++row
	}
	qui tab resp_sex region, chi2 exact
	local pv = `r(p)'
	write_pvalue `pv' E18

	
	

