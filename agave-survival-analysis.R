# Logistic regression analysis of agave survival by treatment
# Jeffrey C. Oliver
# jcoliver@email.arizona.edu
# 2020-07-20

rm(list = ls())

################################################################################
# Use mixed-effects logistic regression to test for an effect of treatment on 
# agave survival. All comparisons are relative to control, so no post-hoc tests
# are necessary. 

# Roughly corresponds to 1.1.a in agave-lovegrass-report.Rmd

library(lme4)        # glmer logistic models
library(dplyr)       # data wrangling
library(broom.mixed) # tidy up output from statistical output
library(stringr)     # clean up statistical output

agave_data <- read.csv(file = "data/agave-data.csv", stringsAsFactors = TRUE)

# Logistic regression, predicting Status (0, 1) from Treatment, with a random
# intercept of plot
surv_single <- lme4::glmer(formula = Status ~ Treatment + (1|plot),
                           data = agave_data,
                           family = binomial(link = "logit"))

# Tidy the output so we can write to file
surv_single_out <- broom.mixed::tidy(surv_single)

# Drop random effects row and columns group and effect
surv_single_out <- surv_single_out %>%
  filter(effect == "fixed") %>%
  select(-effect, - group)

# Remove the word "Treatment"
surv_single_out <- surv_single_out %>%
  mutate(term = stringr::str_replace(string = term, 
                                     pattern = "Treatment", 
                                     replacement = ""))

# Change "statistic" column to z.value and "term" to coefficient
surv_single_out <- surv_single_out %>%
  rename(z.value = statistic,
         coefficient = term)

# Write output to file
write.csv(x = surv_single_out, 
          file = "output/agave-survival-analysis-out.csv",
          row.names = FALSE)
