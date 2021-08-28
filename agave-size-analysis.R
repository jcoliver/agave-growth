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

################################################################################
# This first model is not appropriate, as data are count data and might 
# suffer from pseudoreplication. See summed analysis, below.

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

################################################################################
# Run model where size is *sum* of all plant leaves in a unique row/plot
# Start by summing values
summed_row <- live_agave_data %>%
  group_by(plot, Row, Treatment) %>%
  summarize(sum_leaf_number = sum(live_leaf_number)) %>%
  ungroup()

# Include plot as random effect  
size_summed <- lme4::glmer(formula = sum_leaf_number ~ Treatment + (1|plot),
                              data = summed_row,
                              family = "poisson")

# Levene's test for homoscedasticity
leveneTest(residuals(size_summed) ~ summed_row$Treatment)
# Levene's Test for Homogeneity of Variance (center = median)
#       Df F value Pr(>F)
# group  9  1.1334 0.3818
#       22               

# Tidy the output so we can write to file
size_summed_out <- broom.mixed::tidy(size_summed)

# Drop random effects row and columns group and effect
size_summed_out <- size_summed_out %>%
  filter(effect == "fixed") %>%
  select(-effect, - group)

# Remove the word "Treatment"
size_summed_out <- size_summed_out %>%
  mutate(term = stringr::str_replace(string = term, 
                                     pattern = "Treatment", 
                                     replacement = ""))

# Change "statistic" column to z.value and "term" to coefficient
size_summed_out <- size_summed_out %>%
  rename(z.value = statistic,
         coefficient = term)

# Write output to file
write.csv(x = size_summed_out, 
          file = "output/summed-agave-size-analysis-out.csv",
          row.names = FALSE)
