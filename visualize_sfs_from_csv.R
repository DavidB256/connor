# Setup
library(tidyverse)
setwd("C:/Users/David/Desktop/Bergland/data/")

plot_fs <- function(fs) {
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
  
  # Plot
  base_plot <- ggplot(fs_pivoted, aes(x=row, y=col, fill=log10(count)))
  
  base_plot +
    geom_tile() +
    xlab("pop0") +
    ylab("pop1") +
    ggtitle("") +
    theme_classic() +
    theme(axis.text.x=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks=element_blank()) +
    scale_fill_continuous(na.value="white") +
    geom_segment(x=0, y=0, xend=size, yend=size,
                 size=1) +
    scale_y_continuous(expand=c(0, 0)) +
    xlab(expression(paste("European", italic(" D. pulex")))) +
    ylab(expression(paste("North American", italic(" D. pulex")))) +
    labs(fill=bquote(log[10](count)))
}
trim_fs <- function(fs, min=1) {
  for (col in 1:ncol(fs)) {
    fs[, col] <- ifelse(fs[, col] < min, 0, fs[, col])
  }
  
  fs
}


# Load SFSs 
fs_data <- read.csv("fs_data.csv", header=FALSE)
fs_split_mig_model <- read.csv("fs_split_mig_model.csv", header=FALSE)
fs_split_no_mig_model <- read.csv("fs_split_no_mig_model.csv", header=FALSE)

plot_fs(trim_fs(fs_data))
plot_fs(trim_fs(fs_split_mig_model))
plot_fs(trim_fs(fs_split_no_mig_model))

