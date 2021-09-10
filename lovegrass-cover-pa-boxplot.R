# Boxplot of lovegrass cover by treatment and agave presence/absence
# Jeffrey C. Oliver
# jcoliver@email.arizona.edu
# 2020-07-20

rm(list = ls())

################################################################################




# Create new column indicating presence or absence of agave
cover_data$agave <- "Present"
cover_data$agave[cover_data$Status == 0] <- "Absent"
cover_data$agave <- factor(x = cover_data$agave)

