# Setup
library(tidyverse)
setwd("C:/Users/David/Desktop/Bergland/data/")

load_fs <- function(name, min=1) {
  # Read in FS from CSV file
  fs <- read.csv(name, header=FALSE)
  # Mask absent allele corner
  fs[1, 1] <- 0
  # Get size of SFS. This currently only supports square SFSs.
  size <- fs %>% count %>% as.numeric
  # "Pivot" data frame from CSV into data frame that can be plotted 
  fs_pivoted <- fs %>%
    pivot_longer(1:size, names_to="row", values_to="count") %>% 
    mutate(col = rep(1:size, each=size))
  # Reorder factor levels so that the columns of the SFS get plotted in the correct
  # order.
  fs_pivoted$row <- factor(as.factor(fs_pivoted$row),
                           paste0("V", seq(size)))
  # Round values less min down to 0
  fs_pivoted <- fs_pivoted %>%
    mutate(count = ifelse(count < min, 0, count))
  # Return
  fs_pivoted
}

# Load FSs 
fs_empirical <- load_fs("fs_empirical.csv")
fs_from_ests <- load_fs("fs_from_ests.csv")
fs_split_mig_model <- load_fs("fs_split_mig_model.csv")
fs_split_no_mig_model <- load_fs("fs_split_no_mig_model.csv")

fs_all <- rbind(fs_empirical %>% mutate(source="empirical"),
                fs_from_ests %>% mutate(source="from_ests"),
                fs_split_mig_model %>% mutate(source="split_mig_model"),
                fs_split_no_mig_model %>% mutate(source="split_no_mig_model"))

ggplot(fs_all, aes(x=row, y=col, fill=log10(count))) +
  geom_tile() + 
  facet_wrap(~ source, nrow=1,
             labeller = labeller(source = c("empirical"="Empirical",
                                            "from_ests"="From parameter estimates",
                                            "split_mig_model"="Split-with-migration model",
                                            "split_no_mig_model"="Split-without-migration model"))) +
  xlab("pop0") +
  ylab("pop1") +
  ggtitle("") +
  theme_classic() +
  theme(axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank()) +
  scale_fill_continuous(na.value="white") +
  geom_segment(x=0, y=0, xend=22, yend=22,
               size=1) +
  scale_y_continuous(expand=c(0, 0)) +
  xlab(expression(paste("European", italic(" D. pulex")))) +
  ylab(expression(paste("North American", italic(" D. pulex")))) +
  labs(fill=bquote(log[10](count)))






