# Data preparation
# Jeffrey C. Oliver
# jcoliver@email.arizona.edu
# 2020-07-20

rm(list = ls())

################################################################################
library(dplyr)    # Renaming columns, filtering, selecting

coronado_data <- read.csv(file = "data/coronado-data-clean.csv",
                          stringsAsFactors = FALSE)

# Apply consistent treatment names
# Treatments are sometimes referred to in different ways, i.e. J+S and S+J are 
# both present in data set, but mean the same thing.
coronado_data$Treatment[coronado_data$Treatment == "S+J"] <- "J+S"
coronado_data$Treatment[coronado_data$Treatment == "H+J"] <- "J+H"
coronado_data$Treatment[coronado_data$Treatment == "W+J"] <- "J+W"
coronado_data$Treatment[coronado_data$Treatment == "W+S"] <- "S+W"

# Create 'status' column indicating live or dead agave
coronado_data$Status <- NA
coronado_data$Status[coronado_data$Species == "agave"] <- 1
coronado_data$Status[coronado_data$live_leaf_number %in% c("D", "D/P", "P")] <- 0

# Rename areial_cover column to aerial_cover
coronado_data <- coronado_data %>%
  rename(aerial_cover = areial_cover)

# Replace "Lehmann lovegarss" values in Species column with Lehmann lovegrass
coronado_data$Species <- gsub(x = coronado_data$Species,
                              pattern = "Lehmann lovegarss",
                              replacement = "Lehmann lovegrass")

# Subset agave data only and drop aerial_cover column
agave_data <- coronado_data %>%
  filter(Species == "agave") %>%
  select(-aerial_cover)

# Subset lovegrass data only and retain aerial_cover and columns necessary for 
# merge
lovegrass_data <- coronado_data %>%
  filter(Species == "Lehmann lovegrass") %>%
  select(plot, Row, plant.num, aerial_cover)

# Merge agave & lovegrass data aerial cover column
agave_data <- inner_join(x = agave_data,
                         y = lovegrass_data)

# Save to data file
write.csv(x = agave_data, 
          file = "data/agave-data.csv", 
          row.names = FALSE)

# Create a agave_size data frame, which includes a maximum of 3 (live) agaves 
# per row with size measurements

# Start by filtering out dead plants (Status = 0)
agave_size_data <- agave_data %>% 
  filter(Status == 1)

# Convert live_leaf_number to numeric
agave_size_data$live_leaf_number <- as.integer(agave_size_data$live_leaf_number)

# Drop any remaining rows with NA for leaf count
agave_size_data <- agave_size_data[!is.na(agave_size_data$live_leaf_number), ]

# Only consider a maximum of 3 agaves for any plot/row/treatment combination 
max_agaves <- 3
agave_size_data <- agave_size_data %>%
  group_by(plot, Row) %>%
  arrange(plant.num) %>%
  slice(1:max_agaves) %>%
  ungroup()

# Save agave_size data frame to file
write.csv(x = agave_size_data, 
          file = "data/agave-size-data.csv", 
          row.names = FALSE)
