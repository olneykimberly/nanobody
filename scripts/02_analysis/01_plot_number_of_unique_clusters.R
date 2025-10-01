library(ggplot2)
library(dplyr)
library(stringr)
library(scales) # Needed for the comma formatting

# ----------------------------------------------------------------------
# 1. LOAD AND PREPARE THE DATA
# ----------------------------------------------------------------------

# NOTE: The absolute path has been removed for portability. 
# Ensure 'unique_counts.csv' is in your current working directory when running this.
data_for_plot <- read.csv("/tgen_labs/jfryer/kolney/nanobody/vsearch/unique_counts.csv") 

# Check the data structure
print(head(data_for_plot))

# Ensure the count column is numeric
data_for_plot$Unique_Read_Count <- as.numeric(data_for_plot$Unique_Read_Count)

# --- Custom Ordering and Coloring Setup ---

# Define the exact order of samples (must match the cleaned names from the shell script)
ordered_samples <- c(
  "Abeta1", "Abeta2", "Abeta3", "Abeta4", 
  "ApoE1", "ApoE2", "ApoE3", 
  "Clu1", "Clu2"
)

# 1. Enforce the plotting order using factor levels
data_for_plot$Sample <- factor(data_for_plot$Sample, levels = ordered_samples)

# 2. Define the custom color palette (Dark to Light for each group)
# Abeta (4): Dark Blue to Light Blue
abeta_colors <- c("#1f77b4", "#4c97c3", "#79b7d2", "#a6d7e2") 
# ApoE (3): Red to Pink
apoe_colors <- c("#d62728", "#ff9896", "#ffc8c6") 
# Clu (2): Dark Grey to Light Grey
clu_colors <- c("#393939", "#8c8c8c")

custom_colors <- c(abeta_colors, apoe_colors, clu_colors)

# ----------------------------------------------------------------------
# 2. GENERATE THE BAR CHART
# ----------------------------------------------------------------------

# Create the bar chart, using the Sample column for both x-axis position and color fill
unique_read_plot <- ggplot(
  data_for_plot, 
  aes(
    x = Sample, # Uses the factor level order defined above
    y = Unique_Read_Count,
    fill = Sample # Maps color fill to each sample
  )
) +
  # Add the bar geometry
  geom_bar(stat = "identity", width = 0.8) + 
  
  # Apply the custom color palette to the bars
  scale_fill_manual(values = custom_colors) +
  
  # Add the count labels above each bar
  geom_text(
    aes(label = format(Unique_Read_Count, big.mark = ",")), 
    vjust = -0.5, 
    size = 3.5,
    color = "black" # Ensure labels are black for readability
  ) +
  
  # Set axis and plot titles
  labs(
    title = "Number of Unique Clusters",
    x = "Sample",
    y = "Number of Unique Clusters",
    fill = "Sample" # Title for the legend
  ) +
  
  # Improve the y-axis scaling and formatting (use commas for large numbers)
  scale_y_continuous(
    labels = scales::comma,
    expand = expansion(mult = c(0, 0.15)) # Increased space above bars for labels
  ) +
  
  # Apply a clean, theme_minimal style
  theme_minimal() +
  
  # Customize theme elements for better readability
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10, face = "bold"), # Keep X labels bold
    axis.text.y = element_text(size = 10),
    axis.title = element_text(face = "bold"),
    legend.position = "none" # Hide legend since colors are self-explanatory and axis labels are provided
  )

# Display the plot
print(unique_read_plot)