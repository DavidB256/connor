# Setup
library(tidyverse)
setwd("C:/Users/David/Desktop/Bergland/data")

sl1 <- 130000000
sl2 <- 200000

ci <- read.table("connor_inference_output.txt", header=TRUE,
                 col.names = c("n1", "n2", "n_na", "n_eu", "t", "m",
                               "n_na_sd", "n_eu_sd", "t_sd", "m_sd", "theta_sd",
                               "ll"))
ci
ci %>% mutate(n_na = n_na * (sl1 / sl2),
              n_eu = n_eu * (sl1 / sl2),
              t = t * (sl1 / sl2),
              m = m / (sl1 / sl2)) %>%
  filter(ll > -2975)
