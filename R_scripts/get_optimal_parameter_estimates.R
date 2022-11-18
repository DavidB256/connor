# Setup
library(tidyverse)
setwd("C:/Users/David/Desktop/Bergland/data")

# Load in inference results under split_mig, split_no_mig, and split_mig_asym
# models, respectively
o1 <- read.table("op1_all_params_split_mig.txt",
                 col.names = c("model", "size", "theta", "ll",
                               "NA_pop_est", "EU_pop_est", "t_est", "m_est",
                               "NA_pop_sd", "EU_pop_sd", "t_sd", "m_sd", "theta_sd"))
o2 <- read.table("op2_all_params_split_no_mig.txt",
                 col.names = c("model", "size", "theta", "ll",
                               "NA_pop_est", "EU_pop_est", "t_est",
                               "NA_pop_sd", "EU_pop_sd", "t_sd", "theta_sd"))
o3 <- read.table("op3_all_params_split_mig_asym.txt",
                 col.names = c("model", "size", "theta", "ll",
                               "NA_pop_est", "EU_pop_est", "t_est", "m1_est", "m2_est",
                               "NA_pop_sd", "EU_pop_sd", "t_sd", "m1_sd", "m2_sd", "theta_sd"))

# Optimal parameter estimates under split_mig model with ns=[20, 20] are
# [1305050, 211901.2, 4100767, 1.882456e-08] with log-likelihood -685.71.
o1 %>% select(2:8) %>%
  filter(size==20) %>%
  filter(ll == max(ll))
# Optimal parameter estimates under split_no_mig model with ns=[20, 20] are
# [1208659, 250920.2, 1872263] with log-likelihood -1422.65.
o2 %>% select(2:7) %>%
  filter(size==20) %>%
  filter(ll == max(ll))
# Optimal parameter estimates under split_mig_asym model with ns=[20, 20] are
# [1317303, 199626.5, 4117019, 2.997558e-08, 1.410001e-08] with log-likelihood -1422.65.
o3 %>% select(2:9) %>%
  filter(size==20) %>%
  filter(ll == max(ll))


