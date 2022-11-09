# Setup
library(tidyverse)
setwd("C:/Users/David/Desktop/Bergland/data")

# Load in inference results under split_mig, split_no_mig, and split_mig_asym
# models, respectively
o1 <- read.table("op1_all_params_split_mig.txt", header=TRUE)
o2 <- read.table("op2_all_params_split_no_mig.txt", header=TRUE)
o3 <- read.table("op3_all_params_split_mig_asym.txt", header=TRUE)

# Get maximum of log-likelihood function for inference on each SFS size under 
# each model
o1_max <- o1 %>% 
  group_by(size) %>%
  summarize(split_mig_ll=max(ll))
o2_max <- o2 %>% 
  group_by(size) %>%
  summarize(split_no_mig_ll=max(ll))
o3_max <- o3 %>% 
  group_by(size) %>%
  summarize(split_mig_asym_ll=max(ll))

# Combine data frames to compare likelihoods across models
oa <- o1_max %>% 
  left_join(o2_max, by="size") %>%
  left_join(o3_max, by="size")

# Visualizations
ggplot(oa[-8, ] %>% pivot_longer(c(2:4)),
       aes(x=size, y=value, color=name)) +
  geom_point(size=2) + 
  xlab("SFS size") +
  ylab("Maximum log-likelihood") + 
  ggtitle("Size of SFS vs. maxima of log-likelihood functions under different models") +
  labs(color = "Model")
  
ggplot(oa %>% pivot_longer(c(2:4)),
       aes(x=size, y=value, color=name)) +
  geom_point() +
  geom_smooth(method="lm", formula=y~x, se=FALSE) +
  facet_grid(~ name) +
  xlab("Size of SFS") +
  ylab("Maximum of log-likelihood function") +
  labs(color="Model")

# Confirm linear relationships between log-likelihood maxima and SFS size with
# Wald test on OLS regression coefficient p-values
lm(data=o1_max, split_mig_ll ~ size + 0) %>% summary
lm(data=o2_max, split_no_mig_ll ~ size + 0) %>% summary
lm(data=o3_max, split_mig_asym_ll ~ size + 0) %>% summary

# Perform model selection between split_mig and split_no_mig with likelihood ratio-
# test (LRT)
oa %>%
  mutate(lr = -2 * (split_no_mig_ll - split_mig_ll)) %>%
  mutate(p = pchisq(lr, df=1, lower.tail=FALSE))
# Conclude that split_mig model is preferred to the split_no_mig model
# at all SFS sizes greater than 3, which is too small to ever be used in practice.
# LRT is likely invalid here because the constrained model is seen with a greater
# likelihood than the unconstrained model in the size=3 case.

# Convert estimates from optimal models at size=20 back into moments units
# for use in plotting in a Jupyter notebook
coeff <- 934.2784 / (4 * 5.69e-9 * 200000)
# 934.2784 is the value of theta for the optimal inference run under the split_mig
# model. 5.69e-9 is the mutation rate. 200,000 is the genome size.
o1 %>% select(2:8) %>%
  filter(size==20) %>%
  filter(ll == max(ll)) %>%
  mutate(NA_pop_est = NA_pop_est / coeff,
         EU_pop_est = EU_pop_est / coeff,
         t_est = t_est / (2 * coeff),
         m_est = m_est * 2 * coeff)

coeff <- 5161.235 / (4 * 5.69e-9 * 200000)
# 5161.235 is the value of theta for the optimal inference run under the split_no_mig
# model.
o2 %>% select(2:7) %>%
  filter(size==20) %>%
  filter(ll == max(ll)) %>%
  mutate(NA_pop_est = NA_pop_est / coeff,
         EU_pop_est = EU_pop_est / coeff,
         t_est = t_est / (2 * coeff))

# Convert estimates from optimal models at size=100 back into moments units
# for use in plotting in a Jupyter notebook
coeff <- 934.0159 / (4 * 5.69e-9 * 200000)
# 934.0159 is the value of theta for the optimal inference run under the split_mig
# model. 5.69e-9 is the mutation rate. 200,000 is the genome size.
o1 %>% select(2:8) %>%
  filter(size==100) %>%
  filter(ll == max(ll)) %>%
  mutate(NA_pop_est = NA_pop_est / coeff,
         EU_pop_est = EU_pop_est / coeff,
         t_est = t_est / (2 * coeff),
         m_est = m_est * 2 * coeff)

coeff <- 5343.133 / (4 * 5.69e-9 * 200000)
# 5343.133 is the value of theta for the optimal inference run under the split_no_mig
# model.
o2 %>% select(2:7) %>%
  filter(size==100) %>%
  filter(ll == max(ll)) %>%
  mutate(NA_pop_est = NA_pop_est / coeff,
         EU_pop_est = EU_pop_est / coeff,
         t_est = t_est / (2 * coeff))







