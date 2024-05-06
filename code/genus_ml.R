source('code/genus_process.R')
library(mikropml)

srn_genus_data <- composite %>% 
  select(group, taxonomy, rel_abund, srn) %>% 
  pivot_wider(names_from=taxonomy, values_from=rel_abund) %>% 
  select(-group) %>% 
  mutate(srn=if_else(srn, "srn", "healthy")) %>% 
  select(srn, everything())

srn_genus_preprocessed <- preprocess_data(srn_genus_data, outcome_colname='srn')$dat_transformed

srn_genus_results <- run_ml(srn_genus_preprocessed,
       method='glmnet',
       outcome_colname='srn',
       kfold=5, # default
       cv_times=100, # default
       training_frac=0.2, # default
       seed=19971016)

