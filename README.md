# Instant Payment Adoption and Bank Behavior

##  Project Overview

This project empirically analyzes how the adoption of instant payment systems in the U.S. banking sector affects liquidity management, deposit composition, and risk-taking behavior among banks. It uses staggered difference-in-differences (DiD) and event study methods to estimate the causal effects of adoption.

---

## Files

- Empirical_Writing_Sample.pdf           # Core write-up using Stata-based DiD/event study
- instant_payment_code.do                # Main empirical code
- Policy_Brief_Bank_Instant_Payment_System.pdf              # Policy summary of findings
- README.md                              # Project description and documentation

---

##  Empirical Strategy

- **Data**: Panel data on U.S. commercial banks’ balance sheets and payment system adoption timelines
- **Methods**: (Through Stata 17)
  - Panel fixed effects regressions (`xtreg` with clustered SEs)
  - Event study designs with dynamic treatment effects
  - Tests for parallel trends via `coefplot`
- **Key Variables**:
  - `liquidity_ratio = (cash + govbond) / asset`
  - `checking/saving/time deposit ratios`
  - `high_risk_loans` vs `low_risk_loans`

---

##  Key Results

1. **Liquidity increases post-adoption** – Banks raise their liquidity buffers, likely to accommodate real-time withdrawal needs.
2. **Deposit composition shifts** – Slight reallocation between checking, saving, and time deposits.
3. **Reduced risky lending** – Banks reduce exposure to high-risk loan portfolios.

Graphs and tables exported using `outreg2` and `coefplot` can be found in `/figures`.

---

##  Policy Insight Summary

> **Title:** How Instant Payment Adoption Shapes Bank Behavior: Liquidity, Deposits, and Risk-Taking

**Overview:** This empirical project analyzes the effect of instant payment system adoption on the behavior of commercial banks in the U.S. Using a staggered difference-in-differences framework and panel data on bank balance sheets, the study reveals how real-time payment capabilities can influence bank liquidity management, deposit structure, and portfolio risk.

### Key Policy Insights:

- **Improved Liquidity Buffers**
- **Shift in Deposit Composition**
- **Risk-Taking Adjustments**

**Implication for Policymakers:** As countries around the world adopt or expand real-time payment systems, these findings highlight the importance of accompanying regulatory frameworks that anticipate changes in liquidity needs, funding models, and bank risk profiles.

---

##  Contact

- Yuqi Shi ([yshi103@alumni.jh.edu](mailto\:yshi103@alumni.jh.edu))
- [LinkedIn](https://www.linkedin.com/in/yuqi-shi-3728a5200/)

---

> This repository is intended to showcase empirical skills for pre-doctoral RA applications. The methods and findings are illustrative of the kind of work I aim to do in macro-finance and policy research.

