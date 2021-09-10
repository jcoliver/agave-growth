# Linear regression of Lehmann lovegrass cover by treatment and agave p/a
# Jeffrey C. Oliver
# jcoliver@email.arizona.edu
# 2021-09-09

rm(list = ls())

################################################################################
# Corresponds to 2.2 in report, but may need to adjust based on assumptions
library(car)         # Levine test for homogeneity
library(dplyr)       # data wrangling
library(lmerTest)    # mixed model
library(merDeriv)    # robust estimates of standard errors
# library(lme4)        # mixed model

# Cover ~ Treatment + Agave present/absent
# Binomial ~ Categorical + Categorical(Binary)

cover_data <- read.csv(file = "data/agave-data.csv", 
                       stringsAsFactors = FALSE)

# Restrict data to only control and hand-pulling
cover_data <- cover_data %>%
  filter(Treatment %in% c("C", "H", "W"))

# Create unique combinations of plot & Row for random effects
cover_data <- cover_data %>%
  mutate(plotrow = paste0(plot, "-", Row))

# Treat predictors as a factors
cover_data$Treatment <- factor(cover_data$Treatment)
cover_data$Status <- factor(cover_data$Status)

# Since cover ranges from 0 to 100 percent, should be treated as binomial 
# response variable; recode to 0-1 scale
# cover_data <- cover_data %>%
#   mutate(aerial_cover = aerial_cover/100)

# Run linear model with plot as random effect
cover_model_pa <- lme4::lmer(formula = aerial_cover ~ Treatment + Status + (1|plotrow),
                                 data = cover_data)
# cover_model_pa <- lme4::glmer(formula = aerial_cover ~ Treatment + Status + (1|plotrow),
#                                  data = cover_data,
#                               family = "binomial")

# Check assumptions of linear regression
# Look at fitted vs. residuals
plot(cover_model_pa, which = 1)

# Q-Q plot for normality of residuals
qqnorm(resid(cover_model_pa))
qqline(resid(cover_model_pa))

# Levene test for homogeneity
car::leveneTest(resid(cover_model_pa) ~ cover_data$Treatment)
# Levene's Test for Homogeneity of Variance (center = median)
#       Df F value    Pr(>F)    
# group  2  26.154 5.804e-09 ***
#       62  
# Quite heteroscetastic

# Consider adding weights to model
# https://stackoverflow.com/questions/45788123/general-linear-mixed-effect-glmer-heteroscedasticity-modelling


# Attempts at using sandwich & lmtest::coeftest did not work

# Want to use sandwich estimator, but need to manually get "meat" and "bread" 
# objects
cover_meat <- sandwich::meat(x = cover_model_pa)
cover_bread <- merDeriv::bread.lmerMod(x = cover_model_pa, 
                                       full = TRUE,
                                       information = "expected", 
                                       ranpar = "var")
cover_sandwich <- sandwich(x = cover_model_pa,
                           bread. = cover_bread,
                           meat. = cover_meat)
# Pass to lmtest::coeftest, but chronic "long vectors not supported" error
cover_vcovHC <- lmtest::coeftest(x = cover_model_pa,
                                 vcov. = cover_sandwich)
# Homoscedasticity violated, so need better standard error estimates
# use a heteroscedasticity constant model of variance with White's estimator
cover_vcovHC <- lmtest::coeftest(x = cover_model_pa,
                                 vcov = merDeriv::bread.lmerMod(x = cover_model_pa))


# Doesn't work (sandwich package doesn't work with lmer)
cover_vcovHC <- lmtest::coeftest(x = cover_model_pa,
                                 vcov = sandwich::vcovHC(x = cover_model_pa,
                                                         type = "HC0"))


cover_pa_summary <- summary(cover_model_pa)

# Extract coefficients
cover_pa_coeffs <- cover_pa_summary$coefficients

# Coerce to a data frame
cover_pa_coeffs <- as.data.frame(cover_pa_coeffs)

# Add rownames as first column
cover_pa_coeffs <- cbind(Predictor = rownames(cover_pa_coeffs),
                         cover_pa_coeffs)
rownames(cover_pa_coeffs) <- NULL

# Update column names
colnames(cover_pa_coeffs) <- c("Predictor", "Estimate", "Std.Error", "df", 
                               "t.value", "p.value")

# Replace "Treatment" values
cover_pa_coeffs$Predictor <- gsub(pattern = "TreatmentH",
                                  replacement = "Hand-pulling",
                                  x = cover_pa_coeffs$Predictor)
cover_pa_coeffs$Predictor <- gsub(pattern = "TreatmentW",
                                  replacement = "Weed-eating",
                                  x = cover_pa_coeffs$Predictor)

# Replace Status1 with human-readable version
cover_pa_coeffs$Predictor <- gsub(pattern = "Status",
                                  replacement = "Agave presence",
                                  x = cover_pa_coeffs$Predictor)

# Ensure small p-values are not shown as zero
cover_pa_coeffs$p.value <- as.character(ifelse(
  test = cover_pa_coeffs$p.value < 1e-5,
  yes = signif(x = cover_pa_coeffs$p.value, digits = 5),
  no = round(x = cover_pa_coeffs$p.value, digits = 5)))

write.csv(x = cover_pa_coeffs, 
          file = "output/lovegrass-cover-pa-analysis-out.csv",
          row.names = FALSE)
