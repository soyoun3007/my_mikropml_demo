#!/usr/bin/env Rscript

source('code/genus_process.R')
library(mikropml)
library(glue)

seed <- as.numeric(commandArgs(trailingOnly=TRUE))

srn_genus_data <- composite %>% 
  select(group, taxonomy, rel_abund, srn) %>% 
  pivot_wider(names_from=taxonomy, values_from=rel_abund) %>% 
  select(-group) %>% 
  mutate(srn=if_else(srn, "srn", "healthy")) %>% 
  select(srn, everything())

srn_genus_preprocessed <- preprocess_data(srn_genus_data,
                                          outcome_colname='srn')$dat_transformed

test_hp <- list(alpha=0,
                lambda=c(0.1, 1, 2, 3, 4, 5))
  
model <- run_ml(srn_genus_preprocessed,
       method='glmnet',
       outcome_colname='srn',
       kfold=5, # default
       cv_times=100, # default
       training_frac=0.2, # default
       hyperparameters=test_hp,
       seed=seed)

saveRDS(model, file=glue('processed_data/l2_genus_{seed}.Rds'))
