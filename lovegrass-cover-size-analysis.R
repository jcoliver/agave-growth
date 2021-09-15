# Linear regression of Lehmann lovegrass cover by treatment and agave size
# Jeffrey C. Oliver
# jcoliver@email.arizona.edu
# 2020-07-20

rm(list = ls())

################################################################################
# Use generalized linear regression to predict percent cover of Lehmann 
# lovegrass from treatment, number of agave leaves, and interaction. Only 
# considering control and hand-pulling treatments

# Roughly corresponds to 2.1.b in report but results here better model the 
# response variable

library(lme4)        # generalized linear model
library(dplyr)       # data wrangling
library(broom)       # tidy up output from statistical output
library(stringr)     # clean up statistical output

# Cover ~ Treatment + Leaves + Treatment x Leaves
# Binomial ~ Categorical + Continuous + Categorical x Continuous

cover_data <- read.csv(file = "data/agave-size-data.csv", 
                       stringsAsFactors = FALSE)

# Restrict data to only control and hand-pulling
cover_data <- cover_data %>%
  filter(Treatment %in% c("C", "H"))

# Create unique combinations of plot & Row for random effects
cover_data <- cover_data %>%
  mutate(plotrow = paste0(plot, "-", Row))

# Since cover ranges from 0 to 100 percent, should be treated as binomial 
# response variable; recode to 0-1 scale (in model) and add 100 as weights
cover_data <- cover_data %>%
  mutate(weights = 100)

# Run glm with plotrow as random effect
cover_model <- lme4::glmer(formula = aerial_cover/weights ~ Treatment * live_leaf_number + (1|plotrow),
                           data = cover_data,
                           family = "binomial",
                           weights = weights)

# Check assumptions of linear regression
# Look at fitted vs. residuals
plot(cover_model, which = 1)

# Q-Q plot for normality of residuals
qqnorm(resid(cover_model))
qqline(resid(cover_model))

# Levene test for homogeneity
car::leveneTest(resid(cover_model) ~ cover_data$Treatment)
# Levene's Test for Homogeneity of Variance (center = median)
#       Df F value  Pr(>F)  
# group  1   8.345 0.01125 *
#       15   
# Heteroskedastic, but will interpret with caution

# Extract results for output
cover_summary <- summary(cover_model)
cover_coeffs <- cover_summary$coefficients

# Coerce to a data frame
cover_coeffs <- as.data.frame(cover_coeffs)

# Add rownames as first column
cover_coeffs <- cbind(Predictor = rownames(cover_coeffs),
                         cover_coeffs)
rownames(cover_coeffs) <- NULL

# Update column names
colnames(cover_coeffs) <- c("Predictor", "Estimate", "Std.Error", 
                            "z.value", "p.value")

# Replace "Treatment" values
cover_coeffs$Predictor <- gsub(pattern = "TreatmentH",
                               replacement = "Hand-pulling",
                               x = cover_coeffs$Predictor)

# Replace live_leaf_number with human-readable version
cover_coeffs$Predictor <- gsub(pattern = "live_leaf_number",
                               replacement = "Agave size",
                               x = cover_coeffs$Predictor)

# Ensure small p-values are not shown as zero
cover_coeffs$p.value <- as.character(ifelse(
  test = cover_coeffs$p.value < 1e-5,
  yes = signif(x = cover_coeffs$p.value, digits = 5),
  no = round(x = cover_coeffs$p.value, digits = 5)))

write.csv(x = cover_coeffs, 
          file = "output/lovegrass-cover-size-analysis-out.csv",
          row.names = FALSE)