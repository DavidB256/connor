# Setup
library(tidyverse)
setwd("C:/Users/David/Desktop/Bergland/data")

# Genetic parameters for VCF filtered for SNPs in BUSCO genes
mu <- 5.69e-9
L_BUSCO <- 2e5
L_filt <- 12e7
L_BUSCO_new <- 1603681
L_filt_new <- 26610786

# Load demographic inference results
busco <- read.table("busco_DI_output.txt", header=TRUE) %>%
  mutate(vcf = "BUSCO")
filt <- read.table("filt_DI_output.txt", header=TRUE) %>%
  mutate(vcf = "filt")

# Get optimal estimate values
inf_output <- rbind(busco, filt)
opt_inf_output <- inf_output %>%
  filter(size == 20) %>%
  group_by(model, vcf) %>%
  filter(ll == max(ll)) %>%
  select(vcf, model, NA_pop_est, EU_pop_est, t_est, m_est, theta) %>%
  arrange(vcf, model)
opt_inf_output

# Get optimal estimate values, converted back into raw moments' units
opt_inf_op_raw <- opt_inf_output %>%
  mutate(coeff = ifelse(vcf == "BUSCO", 
                        theta / (4 * mu * L_BUSCO), 
                        theta / (4 * mu * L_filt)),
         NA_pop_est = NA_pop_est / coeff,
         EU_pop_est = EU_pop_est / coeff,
         t_est = t_est / (2 * coeff),
         m_est = m_est * 2 * coeff)
opt_inf_op_raw

# Convert output to values corresponding to "new" genome length estimates
opt_inf_output %>%
  mutate(new_coeff = ifelse(vcf == "BUSCO", 
                        L_BUSCO / L_BUSCO_new, 
                        L_filt / L_filt_new),
         NA_pop_est = NA_pop_est * new_coeff,
         EU_pop_est = EU_pop_est * new_coeff,
         t_est = t_est * new_coeff,
         m_est = m_est * new_coeff)

# Convert output without genome length inference by fixing NA_pop_est to 700,000
opt_inf_op_raw %>% 
  mutate(coeff = 700000 / NA_pop_est,
         NA_pop_est = NA_pop_est * coeff,
         EU_pop_est = EU_pop_est * coeff,
         t_est = t_est * 2 * coeff,
         m_est = m_est / (2 * coeff)) %>%
  select(vcf, model, NA_pop_est, EU_pop_est, t_est, m_est, theta) %>%
  arrange(vcf, model)

# Convert output using McCoy et al. 2014's ancestral population-based method.
# This is what we ultimately used in the paper.
opt_inf_op_raw %>% 
  mutate(N_anc_est = 200000 / EU_pop_est,
         NA_pop_est = NA_pop_est * N_anc_est,
         EU_pop_est = EU_pop_est * N_anc_est,
         t_est = t_est * 2 * N_anc_est,
         m_est = m_est / (2 * N_anc_est)) %>%
  select(vcf, model, NA_pop_est, EU_pop_est, t_est, m_est, theta) %>%
  arrange(vcf, model) %>% pull(t_est)







