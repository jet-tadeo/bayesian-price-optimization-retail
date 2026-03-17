# Bayesian Price Optimization for Retail Using MCMC

## Overview
This project implements a Bayesian pricing model using Markov Chain Monte Carlo (MCMC) to determine the optimal product price that maximizes expected revenue in retail and e-commerce environments.

The model estimates demand sensitivity to price, discounts, and contextual variables such as weather and promotions.

## Project Structure

```text
bayesian-price-optimization-retail/
│
├── data
│   └── retail_store_inventory.csv
│
├── scripts
│   └── bayesian_price_model.R
│
├── outputs
│   ├── traceplot.png
│   ├── rhat_plot.png
│   ├── revenue_curve.png
│   ├── posterior_estimates.png
│   └── pairwise_correlations.png
│
├── docs
│   └── case_study.pdf
│
├── README.md
├── requirements.txt
└── .gitignore
```

## Dataset

This project uses the **Retail Store Inventory Forecasting Dataset** available on Kaggle.

Author: Anirudh Chauhan  
Source: https://www.kaggle.com/datasets/anirudhchauhan/retail-store-inventory-forecasting-dataset

The dataset contains approximately **73,100 retail transaction records** with variables related to pricing, demand, promotions, inventory levels, and external factors such as weather conditions. :contentReference[oaicite:1]{index=1}

Key variables include:
- Price
- Units Sold
- Demand Forecast
- Discount
- Weather Condition
- Holiday/Promotion
- Competitor Pricing
- Inventory Level

## Data Disclaimer

The dataset used in this project is publicly available on Kaggle and is used for educational and research purposes only.

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

## Reproducing the Project

1. Download the dataset from Kaggle:
https://www.kaggle.com/datasets/anirudhchauhan/retail-store-inventory-forecasting-dataset

2. Place the file inside the project directory:

data/retail_store_inventory.csv

3. Run the R script:

scripts/bayesian_price_optimization_model.R

## Author
Vince Jefferson I. Tadeo

DAT004M Probability and Statistics

MS in Data Science
