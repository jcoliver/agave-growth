# Boxplot of agave size by treatment
# Jeffrey C. Oliver
# jcoliver@email.arizona.edu
# 2020-07-20

rm(list = ls())

################################################################################
# Boxplot of the size of agave plants in each treatment. Only considering a 
# maximum of three agaves in a unique plot/row/treatment combination

# Corresponds to plot shown in 1.2.a of deprecated agave-lovegrass-report

library(dplyr)      # data wrangling
library(ggplot2)    # plotting
library(extrafont)  # for Times New Roman font
# font_import()     # import system fonts for use by R
# loadfonts()       # only have to do this once

source(file = "functions/boxplot_customization.R") # custom whisker placement

live_agave_data <- read.csv(file = "data/agave-size-data.csv", 
                            stringsAsFactors = TRUE)

# Relevel to ensure proper order on plot
live_agave_data$Treatment <- factor(live_agave_data$Treatment,
                                    levels = c("C", "J", "J+S", "J+H", "J+W",
                                               "S", "S+H", "S+W", "H", "W"))

agave_size_plot <- ggplot(data = live_agave_data, 
                          mapping = aes(x = Treatment,
                                        y = live_leaf_number)) +
  stat_summary(fun.data = boxplot_quantiles, geom = "boxplot") +
  labs(title = "Agave size by treatment",
       x = "Treatment",
       y = "Number of leaves") +
  theme_bw() +
  theme(text = element_text(family = "Times New Roman"))

# Only add asterisks if the analysis file was found *and* there are significant
# differences from the control
analysis_results_file <- "output/agave-size-analysis-out.csv"

if (file.exists(analysis_results_file)) {
  analysis_results <- read.csv(file = analysis_results_file)
  
  # Retain only significant results and drop control row
  significant_results <- analysis_results %>%
    filter(coefficient != "(Intercept)") %>%
    filter(p.value <= 0.05)

  # Only proceed if there was at least one significant effect
  if (nrow(significant_results) > 0) {
    # The "text" column will be used by ggplot to add the text to the plot 
    # (here, it is just the asterisk character). Rename "coefficient" to 
    # Treatment so it is recognized as the same variable being plotted on the 
    # x-axis
    significant_results <- significant_results %>%
      mutate(text = "*") %>%
      select(coefficient, text) %>%
      rename(Treatment = coefficient)

    # Need to know where to place the asterisk on the y-axis. We want to put the 
    # label at end of upper whisker, which is the 95% quantile of counts, so for 
    # each treatment, figure out where the 95% quantile is
    size_whisker <- live_agave_data %>%
      group_by(Treatment) %>%
      summarize(upper_whisker = quantile(x = live_leaf_number, prob = 0.95))

    # Merge text for plot with whisker values for positioning text on the plot
    significant_text <- merge(x = significant_results,
                              y = size_whisker,
                              by = "Treatment")
    
    # Add those asterisks to the plot, 
    agave_size_plot <- agave_size_plot +
      geom_text(data = significant_text,
                label = significant_text$text,
                nudge_y = 0.1,
                nudge_x = 0.1,
                mapping = aes(x = Treatment, y = upper_whisker),
                size = 5,
                family = "Times New Roman")
  } else {
    message("No treatments were significantly different from Control treatment")
  }
} else {
  message("No analysis results file found; asterisks will not be added to plot.")
  message("Run script 'agave-size-analysis.R' to create results file.")
}

# Write to file, with or without asterisks
ggsave(filename = "output/agave-size-boxplot.pdf", 
       plot = agave_size_plot,
       width = 6.5,
       height = 3,
       units = "in",
       device = cairo_pdf) # To deal with font issues

ggsave(filename = "output/agave-size-boxplot.png", 
       plot = agave_size_plot,
       width = 6.5,
       height = 3,
       units = "in")
