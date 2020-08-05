# Linear regression analysis of agave size by treatment
# Jeffrey C. Oliver
# jcoliver@email.arizona.edu
# 2020-07-20

rm(list = ls())

################################################################################
# Use mixed-effects linear regression to test for an effect of treatment on 
# agave size (number of leaves). All comparisons are relative to control, so no 
# post-hoc tests are necessary. 

# Corresponds to 1.2.a in report

library(lmerTest)    # lmer mixed effects model
library(dplyr)       # data wrangling and the %>%
library(car)         # Levene test of homoscedasticity
library(broom.mixed) # tidy up output from statistical output
library(stringr)     # clean up statistical output

live_agave_data <- read.csv(file = "data/agave-size-data.csv", 
                            stringsAsFactors = TRUE)

# Run model with plot as a random effect
size_single <- lmerTest::lmer(formula = live_leaf_number ~ Treatment + (1|plot),
                                    data = live_agave_data)

# Levene's test for homoscedasticity
leveneTest(residuals(size_single) ~ live_agave_data$Treatment)

# Tidy the output so we can write to file
size_single_out <- broom.mixed::tidy(size_single)

# Drop random effects row and columns group and effect
size_single_out <- size_single_out %>%
  filter(effect == "fixed") %>%
  select(-effect, - group)

# Remove the word "Treatment"
size_single_out <- size_single_out %>%
  mutate(term = stringr::str_replace(string = term, 
                                     pattern = "Treatment", 
                                     replacement = ""))

# Change "statistic" column to z.value and "term" to coefficient
size_single_out <- size_single_out %>%
  rename(z.value = statistic,
         coefficient = term)

# Write output to file
write.csv(x = size_single_out, 
          file = "output/agave-size-analysis-out.csv",
          row.names = FALSE)
