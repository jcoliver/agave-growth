# Boxplot of agave survival by treatment
# Jeffrey C. Oliver
# jcoliver@email.arizona.edu
# 2020-07-20

rm(list = ls())

################################################################################
# Boxplot of the number of agave plants surviving in each treatment. Will add 
# numbers that show the proportion of plants surviving in each treatment as 
# well as asterisks to the plot indicating those treatments with significantly 
# different survival probability from Control treatment. These asterisks are 
# drawn from the output of logistic mixed-models of agave-survival-analysis.R.

# Corresponds to plot shown in 1.1.a (although some of the data wrangling work 
# is done in 1.1)

library(dplyr)      # data wrangling
library(ggplot2)    # plotting
library(extrafont)  # for Times New Roman font
# font_import()     # import system fonts for use by R
# loadfonts()       # because that's what the web says to do

source(file = "functions/boxplot_customization.R") # custom whisker placement

agave_data <- read.csv(file = "data/agave-data.csv", stringsAsFactors = TRUE)

# The positioning of the text labels (right above the upper whisker) requires 
# calculating where the upper whisker will end.

# Start by calculating mean survivorship for each treatment; this is going to be
# the text labels we add to the plot
survivorship <- agave_data %>%
  group_by(Treatment) %>%
  summarize(mean_survivorship = round(x = mean(sum(Status)/n()), digits = 2))

# Because the text will be on the graph of agave _counts_, we are looking at the 
# counts of live agave to determine positioning of text.
agave_counts <- agave_data %>%
  group_by(plot, Treatment) %>%
  summarize(num_alive = sum(Status))

# We want to put the text label at end of upper whisker, which is the 95% 
# quantile of counts, so for each treatment, figure out where the 95% quantile 
# is
count_whisker <- agave_counts %>%
  ungroup() %>%
  group_by(Treatment) %>%
  summarize(upper_whisker = quantile(x = num_alive, prob = 0.95))

# Merge survivorship values (text for plot) with whisker values (for 
# positioning) text on the plot
survive_text_counts <- merge(x = survivorship,
                             y = count_whisker,
                             by = "Treatment")

# Re-level so Control (C) is reference and treatments are plotted in desired 
# order
agave_counts$Treatment <- factor(agave_counts$Treatment,
                                 levels = c("C", "J", "J+S", "J+H", "J+W",
                                            "S", "S+H", "S+W", "H", "W"))

# Create the boxplot with text for agave survival probability; will add 
# asterisks later, if the stats output is available in 
# output/agave-survival-analysis-out.csv
agave_count_plot <- ggplot(data = agave_counts, mapping = aes(x = Treatment, y = num_alive)) +
  stat_summary(fun.data = boxplot_quantiles, geom = "boxplot") +
  labs(title = "Figure 1.1. Agave survival by treatment",
       x = "Treatment",
       y = "Number of live agaves") +
  geom_text(data = survive_text_counts,
            # referring to bare column won't work for label
            label = survive_text_counts$mean_survivorship, 
            nudge_y = 0.6, # move labels above upper whisker
            mapping = aes(x = Treatment, y = upper_whisker),
            size = 4,
            family = "Times New Roman") +
  theme_bw() +
  theme(text = element_text(family = "Times New Roman"))

# See if we can get the output of logistic mixed-effects models to determine 
# which treatments were significantly different from the Control treatment

analysis_results_file <- "output/agave-survival-analysis-out.csv"
if (file.exists(analysis_results_file)) {
  analysis_results <- read.csv(file = analysis_results_file, stringsAsFactors = TRUE)
  
  # Select only those rows that had significant effects, and drop the intercept
  # row
  significant_results <- analysis_results %>%
    filter(coefficient != "(Intercept)") %>%
    filter(p.value < 0.05)
  
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
    
    # Need to merge with survive_text_counts so we know where on the y-axis to 
    # place the asterisks
    significant_results <- merge(x = significant_results,
                            y = survive_text_counts[, c("Treatment", "upper_whisker")])
    
    
    # Add those asterisks to the plot, 
    agave_count_plot <- agave_count_plot +
      geom_text(data = significant_results,
                label = significant_results$text,
                nudge_y = 0.1,
                nudge_x = 0.1,
                mapping = aes(x = Treatment, y = upper_whisker),
                size = 5,
                family = "Times New Roman")
  } else {
    message("No treatments were significantly different from Control treatment")
  }
} else {
  message("Could not find results of logistic mixed-effect models; perhaps agave-survival-analysis.R still needs to be run?")
}

# Write to file, with or without asterisks
ggsave(filename = "output/agave-survival-boxplot.pdf", 
       plot = agave_count_plot,
       width = 6.5,
       height = 3,
       units = "in",
       device = cairo_pdf)

ggsave(filename = "output/agave-survival-boxplot.png", 
       plot = agave_count_plot,
       width = 6.5,
       height = 3,
       units = "in")
