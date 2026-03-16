# Load required libraries
library(readr)
library(rstan)
library(dplyr)
library(ggplot2)
library(bayesplot) # For enhanced MCMC diagnostics

# Set rstan options
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# Load the dataset (prompt user to choose file if needed)
data <- read_csv("data/retail_store_inventory.csv")

# Inspect column names
print(colnames(data))

# Data preprocessing: select relevant columns
df <- data %>%
  select(
    Price,
    `Units Sold`,
    `Demand Forecast`,
    Discount,
    `Weather Condition`,
    `Holiday/Promotion`
  ) %>%
  na.omit()

# Convert categorical variables to factors
df <- df %>%
  mutate(
    `Weather Condition` = as.factor(`Weather Condition`),
    `Holiday/Promotion` = as.factor(`Holiday/Promotion`)
  )

# Save means and SDs for scaling
price_mean <- mean(df$Price)
price_sd <- sd(df$Price)
discount_mean <- mean(df$Discount)
discount_sd <- sd(df$Discount)

# Standardize variables
df <- df %>%
  mutate(
    Price_scaled = (Price - price_mean) / price_sd,
    Discount_scaled = (Discount - discount_mean) / discount_sd,
    log_Units_Sold = log1p(`Units Sold`)  # more numerically stable
  )

# Create design matrix
X <- model.matrix(~ Price_scaled + Discount_scaled + `Weather Condition` + `Holiday/Promotion`, data = df)

# Stan model definition
stan_code <- "
data {
  int<lower=0> N;
  int<lower=0> K;
  vector[N] log_units_sold;
  matrix[N, K] X;
}
parameters {
  vector[K] beta;
  real<lower=0> sigma;
}
model {
  beta ~ normal(0, 1);
  sigma ~ exponential(1);
  log_units_sold ~ normal(X * beta, sigma);
}
generated quantities {
  vector[N] y_rep;
  for (n in 1:N) {
    y_rep[n] = normal_rng(dot_product(X[n], beta), sigma);
  }
}
"

# Prepare data for Stan
stan_data <- list(
  N = nrow(df),
  K = ncol(X),
  log_units_sold = df$log_Units_Sold,
  X = X
)

# Compile and sample
model <- stan_model(model_code = stan_code)
fit <- sampling(model, data = stan_data, chains = 4, iter = 2000, warmup = 1000, seed = 123)

# ====================
# DIAGNOSTIC PLOTS
# ====================

# 1. Trace plots for key parameters
trace_plot <- rstan::traceplot(fit, 
                               pars = c("beta[1]", "beta[2]", "sigma"),
                               inc_warmup = FALSE,
                               ncol = 1) +
  ggtitle("Trace Plots of Key Parameters") +
  theme_minimal()

print(trace_plot)

# 2. Pairwise parameter correlations
pairs_plot <- pairs(fit, pars = c("beta[1]", "beta[2]", "sigma"))
print(pairs_plot)

# 3. Rhat and neff summary (bayesplot)
color_scheme_set("brightblue")
diagnostic_plot <- mcmc_rhat(rhat(fit)) + 
  ggtitle("R-hat Diagnostic") +
  ylab("Parameter") +
  xlab("R-hat Value")

print(diagnostic_plot)

# ====================
# ANALYSIS CONTINUES
# ====================

# Summarize posterior estimates
print(fit, pars = c("beta", "sigma"))

# Extract posterior samples
posterior <- extract(fit)

# Revenue prediction function
compute_revenue <- function(price, discount = 0, posterior_samples) {
  price_scaled <- (price - price_mean) / price_sd
  discount_scaled <- (discount - discount_mean) / discount_sd
  
  # Create new data with simplified column names
  new_data <- data.frame(
    Price_scaled = price_scaled,
    Discount_scaled = discount_scaled,
    Weather_Condition = factor(levels(df$`Weather Condition`)[1], levels = levels(df$`Weather Condition`)),
    Holiday_Promotion = factor(levels(df$`Holiday/Promotion`)[1], levels = levels(df$`Holiday/Promotion`))
  )
  
  # Rename columns to match original formula (with backticks)
  names(new_data) <- c("Price_scaled", "Discount_scaled", "Weather Condition", "Holiday/Promotion")
  
  new_X <- model.matrix(
    ~ Price_scaled + Discount_scaled + `Weather Condition` + `Holiday/Promotion`,
    data = new_data
  )
  
  log_units_pred <- posterior_samples$beta %*% t(new_X)
  units_pred <- exp(log_units_pred) - 1
  revenue <- units_pred * price
  return(mean(revenue))
}

# Simulate revenue across price range
price_range <- seq(min(df$Price), max(df$Price), length.out = 50)
revenue_estimates <- sapply(price_range, function(p) compute_revenue(p, posterior_samples = posterior))

# Determine optimal price
optimal_price <- price_range[which.max(revenue_estimates)]
cat("Optimal price:", round(optimal_price, 2), "\n")

# Plot revenue curve
ggplot(data.frame(Price = price_range, Revenue = revenue_estimates), aes(x = Price, y = Revenue)) +
  geom_line(color = "steelblue", size = 1) +
  geom_vline(xintercept = optimal_price, linetype = "dashed", color = "red") +
  labs(title = "Expected Revenue vs. Price", x = "Price", y = "Expected Revenue") +
  theme_minimal()
