# Logistic regression analysis of agave survival by treatment
# Jeffrey C. Oliver
# jcoliver@email.arizona.edu
# 2020-07-20

rm(list = ls())

################################################################################
# Use mixed-effects logistic regression to test for an effect of treatment on 
# agave survival. All comparisons are relative to control, so no post-hoc tests
# are necessary. 

# Roughly corresponds to 1.1.a in deprecated agave-lovegrass-report

# Status ~ Treatment
# Binomial ~ Categorical

library(lme4)        # glmer logistic models
library(dplyr)       # data wrangling
library(broom.mixed) # tidy up output from statistical output
library(stringr)     # clean up statistical output

agave_data <- read.csv(file = "data/agave-data.csv", stringsAsFactors = FALSE)

# Random intercept groups are determined by unique plot/row combination, create
# variable with that information;
agave_data <- agave_data %>%
  mutate(plotrow = paste0(plot, "-", Row))

# Run glm with plotrow as random effect
surv_init <- lme4::glmer(formula = Status ~ Treatment + (1|plotrow),
                         data = agave_data,
                         family = binomial(link = "logit"))

# Convergence issues, so run again from starting point of end of last model
surv_params <- lme4::getME(surv_init, c("theta", "fixef"))
surv_single <- update(surv_init, 
                      start = surv_params,
                      control = lme4::glmerControl(optCtrl = list(maxfun = 2e4)))

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

# Also output observed and predicted survival
# Calculate observed survival
agave_surv <- agave_data %>%
  group_by(Treatment) %>%
  summarize(Live = sum(Status == 1),
            Total = n()) %>%
  mutate(Survival = Live/Total) %>%
  select(-Live, -Total) %>%
  ungroup()

# Predicted values, ignoring random effect of plotrow
# Use coefficients stored in surv_single_out; pull out treatment & estimate 
# info and replace "(Intercept)" with "C", as it represents control treatment
agave_surv_coeff <- surv_single_out %>%
  rename(Treatment = coefficient) %>%
  select(Treatment, estimate) %>%
  mutate(Treatment = str_replace(string = Treatment,
                                 pattern = "\\(Intercept\\)",
                                 replacement = "C"))

# Calculate probabilities for each of the treatments, b_1 is the vector of 
# coefficient estimates for each non-control treatment; first element of the 
# vector corresponds to the control treatment, and is thus 0; b_0 is intercept
b_0 <- agave_surv_coeff$estimate[1]
b_1 <- c(0, agave_surv_coeff$estimate[2:nrow(agave_surv_coeff)])
# Start by calculating e^(b_0 + b_1)
beta_exp <- exp(b_0 + b_1)
# Probability is e^(b_0 + b_1) / (1 + e^(b_0 + b_1))
agave_surv_coeff$probs <- beta_exp / (1 + beta_exp)

# Join the predictions to the observed survival info
agave_surv <- agave_surv %>%
  inner_join(agave_surv_coeff) %>%
  select(-estimate) %>%
  rename(`Survival Probability` = probs)

# Write output to file
write.csv(x = agave_surv,
          file = "output/agave-survival-values.csv",
          row.names = FALSE)
