# Boxplot of agave size by treatment
# Jeffrey C. Oliver
# jcoliver@email.arizona.edu
# 2020-07-20

rm(list = ls())

################################################################################
# Boxplot of the size of agave plants in each treatment. Only considering a 
# maximum of three agaves in a unique plot/row/treatment combination

# Corresponds to plot shown in 1.2.a (although some of the data wrangling work 
# is done in 1.1)

library(dplyr)      # data wrangling
library(ggplot2)    # plotting
library(extrafont)  # for Times New Roman font
# font_import()     # import system fonts for use by R
# loadfonts()       # only have to do this once

source(file = "functions/boxplot_customization.R") # custom whisker placement

live_agave_data <- read.csv(file = "data/agave-size-data.csv", 
                            stringsAsFactors = TRUE)

