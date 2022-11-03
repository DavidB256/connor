# Setup
library(tidyverse)
setwd("C:/Users/David/Desktop/Bergland/data")

plot_fs <- function(fs, resolution) {
  # Mask absent allele corner
  fs[1, 1] <- 0
  
  # Get size of SFS. Thus currently only supports square SFSs.
  size <- fs %>% count %>% as.numeric
  
  # "Pivot" data frame from CSV into data frame that can be plotted 
  fs_pivoted <- fs %>%
    pivot_longer(1:size, names_to="row", values_to="count") %>% 
    mutate(col = rep(1:size, each=size))
  
  # Reorder factor levels so that the columns of the SFS get plotted in the correct
  # order.
  fs_pivoted$row <- factor(as.factor(fs_pivoted$row),
                           paste0("V", seq(size)))
  
  ggplot(fs_pivoted, aes(x=row, y=col, 
                         fill= floor(log10(count) * resolution))) +
    geom_tile() +
    xlab("Daphnia.pulex.Europe") +
    ylab("Daphnia.pulex.NorthAmerica") +
    ggtitle("Site frequency spectrum of Daphnix pulex populations")
}

# Load SFSs 
fs_data <- read.csv("fs_data.csv", header=FALSE)
fs_split_mig_model <- read.csv("fs_split_mig_model.csv", header=FALSE)
fs_split_no_mig_model <- read.csv("fs_split_no_mig_model.csv", header=FALSE)

plot_fs(fs_data, 4)
plot_fs(fs_split_mig_model, 4)
plot_fs(fs_split_no_mig_model, 4)

