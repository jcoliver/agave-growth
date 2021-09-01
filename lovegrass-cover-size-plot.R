# Scatterplot of lovegrass cover by treatment and agave size
# Jeffrey C. Oliver
# jcoliver@email.arizona.edu
# 2020-07-20

rm(list = ls())

################################################################################
# Corresponds to Figure 2.1.b in report

library(dplyr)       # data wrangling
library(ggplot2)     # plotting
library(extrafont)   # Times New Roman font

cover_data <- read.csv(file = "data/agave-size-data.csv", 
                       stringsAsFactors = FALSE)

# Restrict data to only control and hand-pulling
cover_data <- cover_data %>%
  filter(Treatment %in% c("C", "H"))

# Run regression model for parameter estimates
cover_model <- lm(formula = aerial_cover ~ Treatment * live_leaf_number,
                  data = cover_data)

# Plot the model results
# Predict lines of relationships
control_limits <- c(min(cover_data$live_leaf_number[cover_data$Treatment == "C"]),
                    max(cover_data$live_leaf_number[cover_data$Treatment == "C"]))
control_line <- data.frame(Treatment = "C",
                           live_leaf_number = control_limits)
control_line$aerial_cover <- predict(cover_model, 
                                     newdata = control_line)

hand_pulling_limits <- c(min(cover_data$live_leaf_number[cover_data$Treatment == "H"]),
                         max(cover_data$live_leaf_number[cover_data$Treatment == "H"]))
hand_pulling_line <- data.frame(Treatment = "H",
                                live_leaf_number = hand_pulling_limits)
hand_pulling_line$aerial_cover <- predict(cover_model, 
                                          newdata = hand_pulling_line)

# Plot the data
cover_plot <- ggplot(data = cover_data, 
                                 mapping = aes(x = live_leaf_number, 
                                               y = aerial_cover,
                                               group = Treatment, 
                                               fill = Treatment,
                                               shape = Treatment)) +
  geom_line(data = control_line, color = "#787878") +
  geom_line(data = hand_pulling_line, color = "#D8B365") +
  geom_point(size = 2.0, alpha = 0.75) +
  scale_fill_manual(values = c("#787878", "#D8B365"),
                    labels = c("Control", "Hand-pulling")) +
  scale_shape_manual(values = c(21, 22), # Circle, square
                     labels = c("Control", "Hand-pulling")) +
  xlab(label = "Number of leaves") +
  ylab(label = "Percent cover") +
  ggtitle(label = "Figure 2.1.b. Percent Lehmann cover by agave size") +
  theme_bw() +
  theme(text = element_text(family = "Times New Roman"))
# print(cover_plot)

# Print to file
ggsave(filename = "output/lovegrass-cover-size-plot.pdf", 
       plot = cover_plot,
       width = 6.5,
       height = 3,
       units = "in",
       device = cairo_pdf)

ggsave(filename = "output/lovegrass-cover-size-plot.png", 
       plot = cover_plot,
       width = 6.5,
       height = 3,
       units = "in")
