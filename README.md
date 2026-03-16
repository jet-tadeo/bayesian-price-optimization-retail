# Bayesian Price Optimization for Retail Using MCMC

## Overview
This project implements a Bayesian pricing model using Markov Chain Monte Carlo (MCMC) to determine the optimal product price that maximizes expected revenue in retail and e-commerce environments.

The model estimates demand sensitivity to price, discounts, and contextual variables such as weather and promotions.

## Dataset
Retail inventory dataset containing:
- Price
- Units Sold
- Demand Forecast
- Discount
- Weather Condition
- Holiday / Promotion

Total observations: ~73,000 retail sales records.

## Methodology
The analysis includes:

1. Data preprocessing and feature scaling
2. Bayesian linear regression using Stan
3. MCMC sampling with NUTS
4. Posterior predictive simulation
5. Revenue optimization across price ranges

## Model
The Bayesian regression model:

log(Units_Sold + 1) =
β0 + β1 Price + β2 Discount + β3 Weather + β4 Promotion + ε

Priors:
- β ~ Normal(0,1)
- σ ~ Exponential(1)

## Diagnostics
The model includes:

- Trace plots
- R-hat convergence diagnostics
- Pairwise parameter correlation analysis

## Result
The optimal price maximizing expected revenue is:

**$100**

The revenue curve indicates diminishing returns beyond this price point.

## Tools
- R
- rstan
- bayesplot
- ggplot2
- dplyr

## Author
Vince Jefferson I. Tadeo
DAT004M Probability and Statistics
MS in Data Science
