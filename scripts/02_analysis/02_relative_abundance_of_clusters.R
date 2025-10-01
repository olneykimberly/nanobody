library(ggplot2)
library(dplyr)
library(scales) # For percentages and commas

# ----------------------------------------------------------------------
# 1. LOAD AND PREPARE THE DATA
# ----------------------------------------------------------------------

# Load the CSV file created by the shell script
data_raw <- read.csv("/tgen_labs/jfryer/kolney/nanobody/vsearch/cluster_relative_abundance.csv") 
Abeta1 <- subset(data_for_plot, Sample == "Abeta1")
# Define the exact order of samples for plotting
ordered_samples_clean <- c(
  "Abeta1", "Abeta2", "Abeta3", "Abeta4", 
  "ApoE1", "ApoE2", "ApoE3", 
  "Clu1", "Clu2"
)

# Enforce the plotting order using factor levels
data_raw$Sample <- factor(data_raw$Sample, levels = ordered_samples_clean)

# 2. CALCULATE RELATIVE ABUNDANCE
data_for_plot <- data_raw %>%
  group_by(Sample) %>%
  mutate(
    Total_Reads = sum(Read_Count), # Calculate total reads per sample
    Relative_Abundance = Read_Count / Total_Reads # Calculate relative abundance
  ) %>%
  ungroup() %>%
  # Optional: Filter for the top clusters if needed, but for relative abundance plot, 
  # we usually keep all records to show total diversity.
  arrange(Sample) 

# ----------------------------------------------------------------------
# 3. GENERATE THE STACKED BAR CHART
# ----------------------------------------------------------------------

# NOTE: The 'Cluster_ID' is treated as a factor for coloring. 
# Since there are thousands, the legend is suppressed.

relative_abundance_plot <- ggplot(
  data_for_plot, 
  aes(
    x = Sample, 
    y = Relative_Abundance, 
    fill = factor(Cluster_ID)# Use Cluster_ID for coloring
  )
) +
  # Create the stacked bar geometry. Each bar represents 100% of the reads for that sample.
  #geom_bar(stat = "identity", width = 0.8, colour = NA, linewidth = 0.0)  +
  geom_bar(stat = "identity", width = 0.8, color = "black") + 
  # Set axis and plot titles
  labs(
    title = "Relative Abundance of Nanobody Cluster Records Across Samples",
    x = "Sample ID",
    y = "Relative Read Abundance (Total Reads per Sample)"
  ) +
  
  # Format the y-axis to show percentages
  scale_y_continuous(
    labels = percent,
    expand = expansion(mult = c(0, 0)) # Start the bar right at the x-axis
  ) +
  
  # Apply a color scheme (using a broad color palette for high number of clusters)
  # The default ggplot hue scale is sufficient here, but if you need thousands of distinct
  # colors, you may need a custom Viridis or similar scale.
  # scale_fill_viridis_d(guide = "none") # Example of a common high-contrast palette
  
  # Hide the legend as requested (since there are too many clusters)
  guides(fill = "none") +
  
  # Apply a clean theme
  theme_minimal() +
  
  # Customize theme elements for better readability
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10, face = "bold"),
    axis.text.y = element_text(size = 10),
    axis.title = element_text(face = "bold"),
    panel.grid.major.x = element_blank() # Remove vertical grid lines
  )

# Display the plot
print(relative_abundance_plot)
