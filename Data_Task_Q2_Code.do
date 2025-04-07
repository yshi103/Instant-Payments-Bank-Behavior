cd "C:\Users\shiyq\Desktop\PreDoc\UPenn Predoc Data Analysis\Data_Task_Q2"
import excel "C:\Users\shiyq\Desktop\PreDoc\UPenn Predoc Data Analysis\Data_Task_Q2\Q2_Bank_Data.xlsx", sheet("in") firstrow
* Format the data into millions
foreach var in asset cash govbond deposit deposit_checking deposit_saving deposit_time loan_total loan_AA loan_A loan_B loan_C loan_D loan_E loan_F loan_G loan_H corecapital {
    replace `var' = `var' / 1000000
}
format time_id %td
format instant_time %td
describe time_id instant_time
* Generate post-treatment indicator (1 if bank has adopted in or before current period)
gen post = (time_id >= instant_time) if if_instant == 1
replace post = 0 if if_instant == 0
* Event time is the time relative to adoption
gen event_time = time_id - instant_time  
replace event_time = . if if_instant == 0
* turn the event time into months format
replace event_time = floor((time_id - instant_time) / 30)
******************************************************************************************
***** 1. Liquidity Ratio
******************************************************************************************
gen liquidity_ratio = (cash + govbond) / asset
xtset bank_id time_id
* The Standard DiD equation:
xtreg liquidity_ratio post i.time_id, fe cluster(bank_id)
* Create event-time dummies for key months (the months used in the regression)
gen event_neg10 = (event_time == -10) // this means 10 months before the adoption
gen event_neg5  = (event_time == -5)
gen event_neg2  = (event_time == -2)
gen event_0     = (event_time == 0) // Date when the payment system adopted
gen event_2     = (event_time == 2)
gen event_5     = (event_time == 5)
gen event_10    = (event_time == 10) // 10 months after
* Run Staggered DiD regression (excluding event_time == -1)
xtreg liquidity_ratio event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 i.time_id, fe cluster(bank_id)
* Create an indicator for 20 months after adoption
gen event_20 = (event_time == 20)
* Run the event-study regression with `event_20`
xtreg liquidity_ratio event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 i.time_id, fe cluster(bank_id)
* Plot the coefficients to check the Parallel Trends Assumption hold or not
coefplot, keep(event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 ) vertical xlabel(, angle(45)) yline(0, lcolor(red) lpattern(dash)) title("Event Study: Impact on Liquidity Ratio") xtitle("Months to Adoption") ytitle("Coefficient Estimate") mlabposition(12) mlabgap(0.2) ciopts(lwidth(thin)) msymbol(O) mcolor(blue)
graph export "C:\Users\shiyq\Desktop\PreDoc\UPenn Predoc Data Analysis\Data_Task_Q2\EventStudy for Liquidity Ratio.png", as(png) name("Graph") replace
* Now we could generate the control variables
gen log_assets = log(asset) // Bank Size
gen capital_ratio = corecapital / asset
gen loan_deposit_ratio = loan_total / deposit
* Staggered DiD with Controls:
xtreg liquidity_ratio event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 log_assets capital_ratio loan_deposit_ratio cash govbond loan_total i.time_id, fe cluster(bank_id)
* Store both baseline and controls regression results
eststo baseline: xtreg liquidity_ratio event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 i.time_id, fe cluster(bank_id)
eststo controls: xtreg liquidity_ratio event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 log_assets capital_ratio loan_deposit_ratio cash govbond loan_total i.time_id, fe cluster(bank_id)
* Export to Word
outreg2 [baseline controls] using liquidity_results.doc, replace label ctitle("Baseline", "With Controls") keep(event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 log_assets capital_ratio loan_deposit_ratio cash govbond loan_total) 
shellout using `"liquidity_results.doc"'
***********************************************************************************************
***** 2. Bank Deposit Ratios
************************************************************************************************
* Firstyl we need to define the variables
gen checking_ratio = deposit_checking / (deposit + 0.001) // Avoid getting 0
gen saving_ratio   = deposit_saving / (deposit + 0.001)
gen time_ratio     = deposit_time / (deposit + 0.001)
gen log_checking_ratio = log(checking_ratio + 0.001)
gen log_saving_ratio   = log(saving_ratio + 0.001)
gen log_time_ratio     = log(time_ratio + 0.001)
* Standard DiD regression equation: stored separtely
eststo check: xtreg log_checking_ratio post i.time_id, fe cluster(bank_id)
eststo save: xtreg log_saving_ratio post i.time_id, fe cluster(bank_id)
eststo time: xtreg log_time_ratio post i.time_id, fe cluster(bank_id)
* Export table
esttab check save time using deposit_results.doc, replace b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) label title("Effect of Instant Payments on Deposit Ratios") mtitles("Checking" "Saving" "Time") keep(post) compress
test event_neg10 event_neg5 event_neg2
* Generate the plot for Parallel Trends Assumption each by each:
xtreg log_checking_ratio event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 i.time_id, fe cluster(bank_id)
coefplot, keep(event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 ) vertical xlabel(, angle(45)) yline(0, lcolor(red) lpattern(dash)) title("Event Study: Impact on Checking Ratios") xtitle("Months to Adoption") ytitle("Coefficient Estimate") mlabposition(12) mlabgap(0.2) ciopts(lwidth(thin)) msymbol(O) mcolor(blue)
graph export "C:\Users\shiyq\Desktop\PreDoc\UPenn Predoc Data Analysis\Data_Task_Q2\Checking Ratios.png", as(png) name("Graph")
* For Saving Ratio:
xtreg log_saving_ratio event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 i.time_id, fe cluster(bank_id)
coefplot, keep(event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 ) vertical xlabel(, angle(45)) yline(0, lcolor(red) lpattern(dash)) title("Event Study: Impact on Saving Ratios") xtitle("Months to Adoption") ytitle("Coefficient Estimate") mlabposition(12) mlabgap(0.2) ciopts(lwidth(thin)) msymbol(O) mcolor(blue)
graph export "C:\Users\shiyq\Desktop\PreDoc\UPenn Predoc Data Analysis\Data_Task_Q2\Saving Ratios.png", as(png) name("Graph")
*For Time Ratio:
xtreg log_time_ratio event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 i.time_id, fe cluster(bank_id)
coefplot, keep(event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 ) vertical xlabel(, angle(45)) yline(0, lcolor(red) lpattern(dash)) title("Event Study: Impact on Time Ratios") xtitle("Months to Adoption") ytitle("Coefficient Estimate") mlabposition(12) mlabgap(0.2) ciopts(lwidth(thin)) msymbol(O) mcolor(blue)
graph export "C:\Users\shiyq\Desktop\PreDoc\UPenn Predoc Data Analysis\Data_Task_Q2\Time Ratios.png", as(png) name("Graph")
*\ Since the parallel assumption of saving deposit does not hold, then I just generate the regression table for checking and time ratios with baseline and controls results:

eststo baseline_1: xtreg log_checking_ratio event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 i.time_id, fe cluster(bank_id)
eststo controls_1: xtreg log_checking_ratio event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 log_assets capital_ratio loan_deposit_ratio cash govbond loan_total i.time_id, fe cluster(bank_id)
eststo baseline_2: xtreg log_time_ratio event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 i.time_id, fe cluster(bank_id)
eststo controls_2: xtreg log_time_ratio event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 log_assets capital_ratio loan_deposit_ratio cash govbond loan_total i.time_id, fe cluster(bank_id)
* Then outreg2 the table:
outreg2 [baseline_1 controls_1 baseline_2 controls_2] using ratios_results.doc, replace label ctitle("Baseline", "With Controls", "Baseline", "With Controls") keep(event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 log_assets capital_ratio loan_deposit_ratio cash govbond loan_total) 
shellout using `"ratios_results.doc"'
*************************************************************************************************
***** 3. Risky Loans
*************************************************************************************************
drop _est_check _est_save _est_time _est_controls_1 _est_baseline_2 _est_controls_2 _est_baseline_1 
* I decided to divide the loan categories into two groups, low risk and high risk to do the research
gen low_risk_ratio = (loan_AA + loan_A + loan_B + loan_C) / loan_total
gen high_risk_ratio = (loan_D + loan_E + loan_F + loan_G + loan_H) / loan_total
gen log_low_risk = log(low_risk_ratio + 0.001)
gen log_high_risk = log(high_risk_ratio + 0.001)
* Still run the Standard DiD first
xtreg log_low_risk post i.time_id, fe cluster(bank_id)
xtreg log_high_risk post i.time_id, fe cluster(bank_id)
* After, the plot of parallel trends of Low Risk is generated
xtreg log_low_risk event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 i.time_id, fe cluster(bank_id)
coefplot, keep(event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 ) vertical xlabel(, angle(45)) yline(0, lcolor(red) lpattern(dash)) title("Event Study: Impact on Low Risk Loan") xtitle("Months to Adoption") ytitle("Coefficient Estimate") mlabposition(12) mlabgap(0.2) ciopts(lwidth(thin)) msymbol(O) mcolor(blue)
graph export "C:\Users\shiyq\Desktop\PreDoc\UPenn Predoc Data Analysis\Data_Task_Q2\low risk loan.png", as(png) name("Graph")
* The Plot of High Risk
xtreg log_high_risk event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 i.time_id, fe cluster(bank_id)
coefplot, keep(event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 ) vertical xlabel(, angle(45)) yline(0, lcolor(red) lpattern(dash)) title("Event Study: Impact on High Risk Loan") xtitle("Months to Adoption") ytitle("Coefficient Estimate") mlabposition(12) mlabgap(0.2) ciopts(lwidth(thin)) msymbol(O) mcolor(blue)
graph export "C:\Users\shiyq\Desktop\PreDoc\UPenn Predoc Data Analysis\Data_Task_Q2\high risk loan.png", as(png) name("Graph")
* Want to see the joint significance
test event_neg10 event_neg5 event_neg2
* Kind of re-order the dataset to make it clean
sort bank_id time_id
list bank_id time_id, sepby(bank_id)
eststo clear
* Starting to run the Staggered DiD regressions with controls:
eststo baseline_low: xtreg log_low_risk event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 i.time_id, fe cluster(bank_id)
eststo controls_low: xtreg log_low_risk event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 log_assets capital_ratio loan_deposit_ratio cash govbond loan_total i.time_id, fe cluster(bank_id)
eststo baseline_high: xtreg log_high_risk event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 i.time_id, fe cluster(bank_id)
eststo controls_high: xtreg log_high_risk event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 log_assets capital_ratio loan_deposit_ratio cash govbond loan_total i.time_id, fe cluster(bank_id)
outreg2 [baseline_low controls_low baseline_high controls_high] using risk_ratios_results.doc, replace label ctitle("Baseline", "With Controls", "Baseline", "With Controls") keep(event_neg10 event_neg5 event_neg2 event_0 event_2 event_5 event_10 event_20 log_assets capital_ratio loan_deposit_ratio cash govbond loan_total)
shellout using `"risk_ratios_results.doc"'
*****************************************************************************************
********************************************************************************************$



