# Generalized linear regression analysis of agave size by treatment
# Jeffrey C. Oliver
# jcoliver@email.arizona.edu
# 2020-07-20

rm(list = ls())

################################################################################
# Use mixed-effects generalized linear regression to test for an effect of 
# treatment on agave size (number of leaves). All comparisons are relative to 
# control, so no post-hoc tests are necessary. 

# Corresponds to 1.2.a in report

library(lmerTest)    # lmer mixed effects model
library(dplyr)       # data wrangling and the %>%
library(car)         # Levene test of homoscedasticity
library(broom.mixed) # tidy up output from statistical output
library(stringr)     # clean up statistical output

live_agave_data <- read.csv(file = "data/agave-size-data.csv", 
                            stringsAsFactors = TRUE)

# Random intercept groups are determined by unique plot/row combination, create
# variable with that information; the approach of nesting row within plot 
# results in a singular fit model, so we don't do that
live_agave_data <- live_agave_data %>%
  mutate(plotrow = paste0(plot, "-", Row))

# Run model where counts are treated as Poisson distributed
size_model <- lme4::glmer(formula = live_leaf_number ~ Treatment + (1|plotrow),
                          data = live_agave_data,
                          family = "poisson")

# Levene's test for homoscedasticity
leveneTest(residuals(size_model) ~ live_agave_data$Treatment)
# Levene's Test for Homogeneity of Variance (center = median)
#       Df F value Pr(>F)
# group  9  0.4629  0.894
#       64 

# Tidy the output so we can write to file
size_model_out <- broom.mixed::tidy(size_model)

# Drop random effects row and columns group and effect
size_model_out <- size_model_out %>%
  filter(effect == "fixed") %>%
  select(-effect, - group)

# Remove the word "Treatment"
size_model_out <- size_model_out %>%
  mutate(term = stringr::str_replace(string = term, 
                                     pattern = "Treatment", 
                                     replacement = ""))

# Change "statistic" column to z.value and "term" to coefficient
size_model_out <- size_model_out %>%
  rename(z.value = statistic,
         coefficient = term)

# Write output to file
write.csv(x = size_model_out, 
          file = "output/agave-size-analysis-out.csv",
          row.names = FALSE)
