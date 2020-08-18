# Linear regression of Lehmann lovegrass cover by treatment and agave size
# Jeffrey C. Oliver
# jcoliver@email.arizona.edu
# 2020-07-20

rm(list = ls())

################################################################################
# Use linear regression to predict percent cover of Lehmann lovegrass from 
# treatment, number of agave leaves, and interaction. Only considering control 
# and hand-pulling treatments

# Roughly corresponds to 2.1.b in report but results here accommodate 
# heteroscedasticity

library(car)         # Levene test of homogeneity of variance
library(MASS)        # studentized residuals
library(lmtest)      # accommodate heteroscedasticity in standard error estimate
library(sandwich)    # White's estimator for standard errors
library(dplyr)       # data wrangling
library(broom)       # tidy up output from statistical output
library(stringr)     # clean up statistical output

# Cover ~ Treatment + Leaves + Treatment x Leaves
# Continuous ~ Categorical + Continuous

cover_data <- read.csv(file = "data/agave-size-data.csv", 
                       stringsAsFactors = FALSE)

# Restrict data to only control and hand-pulling
cover_data <- cover_data %>%
  filter(Treatment %in% c("C", "H"))

cover_model <- lm(formula = aerial_cover ~ Treatment * live_leaf_number,
                  data = cover_data)

# Check assumptions of linear regression
# Look at fitted vs. residuals
plot(cover_model, which = 1)
# Flagged 5, 6, 13 as having "large" residuals

# Q-Q plot for normality of residuals
plot(cover_model, which = 2)
# Flagged 6, 12, 13 as deviations from expectations. Plot the distribution 
# of residuals
cover_sresids <- MASS::studres(cover_model)
hist(cover_sresids, freq = FALSE)
xfit <- seq(min(cover_sresids), max(cover_sresids), length = 50)
yfit <- dnorm(xfit)
lines(xfit, yfit)
# Meh. Small sample size, but not terrible.

# Heteroscedasticity
plot(cover_model, which = 3)
# 6, 12, 13 a bit high, and line may have positive slope. Do test
car::ncvTest(model = cover_model)
# Non-constant Variance Score Test 
# Variance formula: ~ fitted.values 
# Chisquare = 7.946772, Df = 1, p = 0.0048173
# Looks heteroscedastic. Quite.

# Influential outliers
plot(cover_model, which = 5)
# Some observations close to 0.5 Cook's distance. Do an outlier test
outlierTest(model = cover_model)
# No Studentized residuals with Bonferroni p < 0.05
# Largest |rstudent|:
#   rstudent unadjusted p-value Bonferroni p
# 6 3.367927          0.0055916     0.095057
# Looks fine.

# Homoscedasticity violated, so need better standard error estimates
# use a heteroscedasticity constant model of variance with White's estimator
cover_vcovHC <- lmtest::coeftest(x = cover_model,
                                 vcov = sandwich::vcovHC(x = cover_model,
                                                         type = "HC0"))

# Tidy the output so we can write to file
cover_out <- broom::tidy(cover_vcovHC)

# Remove the word "Treatment"
cover_out <- cover_out %>%
  mutate(term = stringr::str_replace(string = term,
                                     pattern = "Treatment",
                                     replacement = ""))

# Change "statistic" column to z.value and "term" to coefficient
cover_out <- cover_out %>%
  rename(z.value = statistic,
         coefficient = term)

# Write output to file
write.csv(x = cover_out, 
          file = "output/lovegrass-cover-size-analysis-out.csv",
          row.names = FALSE)