# Setup
library(tidyverse)
library(viridis)
setwd("C:/Users/David/Desktop/Bergland/data/sfs_csvs/")

load_sfs <- function(name, min=2, scale=1) {
  # Read in SFS from CSV file
  sfs <- read.csv(name, header=FALSE)
  # Mask absent allele corner
  sfs[1, 1] <- 0
  # Get size of SFS. This currently only supports square SFSs.
  size <- sfs %>% count %>% as.numeric
  # "Pivot" data frame from CSV into data frame that can be plotted 
  sfs_pivoted <- sfs %>%
    pivot_longer(1:size, names_to="row", values_to="count") %>% 
    mutate(col = rep(1:size, each=size))
  # Reorder factor levels so that the columns of the SFS get plotted in the correct
  # order.
  sfs_pivoted$row <- factor(as.factor(sfs_pivoted$row),
                           paste0("V", seq(size)))
  # Scale counts in SFS
  sfs_pivoted <- sfs_pivoted %>%
    mutate(count = count * scale)
  # Round values less min down to 0
  sfs_pivoted <- sfs_pivoted %>%
    mutate(count = ifelse(count < min, 0, count))
  # Return
  sfs_pivoted
}

# Load SFSs 
# Scale is ratio of number of non-absent SNPs in VCFs, as measured by summing elements
# of respective 100x100 empirical SFSs in NumPy and rounding to the nearest integer
# (moments creates SFSs with non-integer entries via rounding errors as it constructs 
# SFSs on a log scale, then exponentiates, for computational efficiency)
scale <- 40060 / 588371
busco_sfs_empirical <- load_sfs("busco/sfs_empirical_20.csv")
busco_sfs_from_ests <- load_sfs("busco/sfs_from_ests_20.csv")
busco_sfs_split_mig_model <- load_sfs("busco/sfs_split_mig_model_20.csv")
busco_sfs_split_no_mig_model <- load_sfs("busco/sfs_split_no_mig_model_20.csv")
filt_sfs_empirical <- load_sfs("filt/sfs_empirical_20.csv", scale=scale)
filt_sfs_from_ests <- load_sfs("filt/sfs_from_ests_20.csv", scale=scale)
filt_sfs_split_mig_model <- load_sfs("filt/sfs_split_mig_model_20.csv", scale=scale)
filt_sfs_split_no_mig_model <- load_sfs("filt/sfs_split_no_mig_model_20.csv", scale=scale)

sfs_all <- rbind(busco_sfs_empirical %>% mutate(sfs="empirical", vcf="BUSCO", BIC=NA, SAP=0.0143),
                 busco_sfs_from_ests %>% mutate(sfs="from_ests", vcf="BUSCO", BIC=16516, SAP=0.0042),
                 busco_sfs_split_mig_model %>% mutate(sfs="split_mig_model", vcf="BUSCO", BIC=1393, SAP=0.0104),
                 busco_sfs_split_no_mig_model %>% mutate(sfs="split_no_mig_model", vcf="BUSCO", BIC=2862, SAP=0.0043),
                 filt_sfs_empirical %>% mutate(sfs="empirical", vcf="Filtered", BIC=NA, SAP=0.0160),
                 filt_sfs_from_ests %>% mutate(sfs="from_ests", vcf="Filtered", BIC=257384, SAP=0.0042),
                 filt_sfs_split_mig_model %>% mutate(sfs="split_mig_model", vcf="Filtered", BIC=11293, SAP=0.0127),
                 filt_sfs_split_no_mig_model %>% mutate(sfs="split_no_mig_model", vcf="Filtered", BIC=33216, SAP=0.0063))

ggplot(sfs_all, aes(x=row, y=col, fill=log10(count))) +
  geom_tile() + 
  geom_text(aes(x=9, y=18, label=paste0("SAP=",SAP*100,"%")), hjust=0) +
  geom_text(aes(x=9, y=20, label=paste0("BIC=",BIC)), hjust=0) +
  facet_grid(vcf ~ sfs,
             labeller = labeller(sfs = c("empirical"="Empirical",
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
  scale_fill_viridis(na.value="white", option="D") +
  geom_segment(x=0, y=0, xend=22, yend=22,
               size=1) +
  scale_y_continuous(expand=c(0, 0)) +
  xlab(expression(paste("European", italic(" D. pulex")))) +
  ylab(expression(paste("North American", italic(" D. pulex")))) +
  labs(fill=bquote(log[10](count)))






