# Setup
library(tidyverse)
setwd("C:/Users/David/Desktop/Bergland/data")

filt <- read.table("filtered_DI_output.txt", header=TRUE)
filt %>% 
  filter(model == "split_mig") %>%
  filter(ll == max(ll))
filt %>% 
  filter(model == "split_no_mig") %>%
  filter(ll == max(ll))

mlg <- read.table("mlg_DI_output.txt", header=TRUE)
mlg %>% 
  filter(model == "split_mig") %>%
  filter(ll == max(ll))
mlg %>% 
  filter(model == "split_no_mig") %>%
  filter(ll == max(ll))
