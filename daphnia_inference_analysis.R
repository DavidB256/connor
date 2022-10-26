# Setup
library(tidyverse)
setwd("C:/Users/David/Desktop/Bergland/data")

# Load in inference results
o1 <- read.table("op1_all_params_split_mig.txt")
o2 <- read.table("op2_all_params_split_no_mig.txt")
o3 <- read.table("op3_all_params_split_mig_asym.txt")

# Get maximum of log-likelihood function at each SFS size under each model
o1_max <- o1 %>% 
  group_by(nu=V2) %>%
  summarize(split_mig_ll=max(V4))
o2_max <- o2 %>% 
  group_by(nu=V2) %>%
  summarize(split_no_mig_ll=max(V4))
o3_max <- o3 %>% 
  group_by(nu=V2) %>%
  summarize(split_mig_asym_ll=max(V4))

# Prepare data for plotting
oa <- o1_max %>% 
  left_join(o2_max, by="nu") %>%
  left_join(o3_max, by="nu")

# Scatterplot showing optimal model at each SFS size
ggplot(oa[-8, ] %>% pivot_longer(c(2:4)),
       aes(x=nu, y=value, color=name)) +
  geom_point()

# Faceted scatterplots showing linear relationships between
# log-likelihood maxima and SFS size
ggplot(oa %>% pivot_longer(c(2:4)),
       aes(x=nu, y=value, color=name)) +
  geom_point() +
  geom_smooth(method="lm", formula=y~x, se=FALSE) +
  facet_grid(~ name)

# Create linear models to check linear relationships between
# log-likelihood maxima and SFS size
lm(data=o1_max, split_mig_ll ~ nu + 0) %>% summary
lm(data=o2_max, split_no_mig_ll ~ nu + 0) %>% summary
lm(data=o3_max, split_mig_asym_ll ~ nu + 0) %>% summary

# Perform model selection with LRT
oa %>%
  mutate(lr = -2 * (split_no_mig_ll - split_mig_ll)) %>%
  mutate(p = pchisq(lr, df=1, lower.tail=FALSE))
# Conclude that split_mig model is preferred to the split_no_mig model
# at all SFS sizes greater than 4x4.

# Convert estimates from optimal models at nu=20 back into moments units
# for use in plotting in a Jupyter notebook
coeff <- 934.2784 / (4 * 5.69e-9 * 200000)
o1 %>% select(2:8) %>%
  filter(V2==20) %>%
  filter(V4 == max(V4)) %>%
  mutate(V5 = V5 / coeff,
         V6 = V6 / coeff,
         V7 = V7 / (2 * coeff),
         V8 = V8 * 2 * coeff)

coeff <- 5161.235 / (4 * 5.69e-9 * 200000)
o2 %>% select(2:7) %>%
  filter(V2==20) %>%
  filter(V4 == max(V4)) %>%
  mutate(V5 = V5 / coeff,
         V6 = V6 / coeff,
         V7 = V7 / (2 * coeff))








