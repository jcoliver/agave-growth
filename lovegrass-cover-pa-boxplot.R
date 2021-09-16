# Boxplot of lovegrass cover by treatment and agave presence/absence
# Jeffrey C. Oliver
# jcoliver@email.arizona.edu
# 2021-09-10

rm(list = ls())

################################################################################
# Boxplot of percent cover of Lehmann lovegrass for control, hand-pulling, and 
# weed-eating treatments, with presence / absence of agave shown separately.

# Corresponds to Figure 2.2 in deprecated agave-lovegrass-report

library(ggplot2)  # plotting
library(dplyr)    # data wrangling
library(extrafont)   # Times New Roman font

source(file = "functions/boxplot_customization.R") # custom whisker placement

cover_data <- read.csv(file = "data/agave-data.csv", 
                       stringsAsFactors = FALSE)

# Restrict data to only control and hand-pulling
cover_data <- cover_data %>%
  filter(Treatment %in% c("C", "H", "W"))

# Create new column indicating presence or absence of agave
cover_data$agave <- "Present"
cover_data$agave[cover_data$Status == 0] <- "Absent"
cover_data$agave <- factor(x = cover_data$agave)

cover_pa_plot <- ggplot(data = cover_data, 
                        mapping = aes(x = agave, y = aerial_cover,
                                      fill = Treatment)) +
  stat_summary(fun.data = boxplot_quantiles, 
               geom = "boxplot",
               position = position_dodge(width = 0.7),
               width = 0.5) +
  scale_fill_manual(values = c("#787878", "#D8B365", "#5AB4AC"),
                    labels = c("Control", "Hand-pulling", "Weed-eating")) +
  labs(x = "Agave",
       y = "Percent cover") +
  theme_bw() +
  theme(text = element_text(family = "Times New Roman"))
print(cover_pa_plot)

# Print to file
ggsave(filename = "output/lovegrass-cover-pa-plot.pdf",
       plot = cover_pa_plot,
       width = 6.5,
       height = 3,
       units = "in",
       device = cairo_pdf)

ggsave(filename = "output/lovegrass-cover-pa-plot.png",
       plot = cover_pa_plot,
       width = 6.5,
       height = 3,
       units = "in")
