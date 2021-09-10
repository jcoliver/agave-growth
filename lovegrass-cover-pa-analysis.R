# Linear regression of Lehmann lovegrass cover by treatment and agave p/a
# Jeffrey C. Oliver
# jcoliver@email.arizona.edu
# 2021-09-09

rm(list = ls())

################################################################################
library(car)         # Levine test for homogeneity
library(dplyr)       # data wrangling
library(lme4)        # mixed model

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
# response variable; recode to 0-1 scale (in model) and add 100 as weights
cover_data <- cover_data %>%
  mutate(weights = 100)

# Run glm with plotrow as random effect
cover_model_pa <- lme4::glmer(formula = aerial_cover/weights ~ Treatment + Status + (1|plotrow),
                                  data = cover_data,
                                  family = "binomial",
                                  weights = weights)

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
# group  2  17.639 8.623e-07 ***
#       62                      
# Quite heteroscetastic

# But does this matter?
# https://doi.org/10.1111/2041-210X.13434
# Maybe not too much, but inferences should be interpreted with caution and 
# future work with larger sample sizes and/or different experimental design
# should be encouraged
# Attempts at using sandwich & lmtest::coeftest did not work

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
colnames(cover_pa_coeffs) <- c("Predictor", "Estimate", "Std.Error", 
                               "z.value", "p.value")

# Replace "Treatment" values
cover_pa_coeffs$Predictor <- gsub(pattern = "TreatmentH",
                                  replacement = "Hand-pulling",
                                  x = cover_pa_coeffs$Predictor)
cover_pa_coeffs$Predictor <- gsub(pattern = "TreatmentW",
                                  replacement = "Weed-eating",
                                  x = cover_pa_coeffs$Predictor)

# Replace Status1 with human-readable version
cover_pa_coeffs$Predictor <- gsub(pattern = "Status1",
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
