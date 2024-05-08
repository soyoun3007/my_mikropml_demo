source('code/genus_process.R')
library(mikropml)
library(tictoc)
library(furrr)

#plan('sequential') # serial processing, not parallel!
#plan('multicore') # doesn;t work with windows or Rstudio
#plan('multisession', workers=8)
plan('multisession')

srn_genus_data <- composite %>% 
  select(group, taxonomy, rel_abund, srn) %>% 
  pivot_wider(names_from=taxonomy, values_from=rel_abund) %>% 
  select(-group) %>% 
  mutate(srn=if_else(srn, "srn", "healthy")) %>% 
  select(srn, everything())

srn_genus_preprocessed <- preprocess_data(srn_genus_data, outcome_colname='srn')$dat_transformed

test_hp <- list(alpha=0,
                lambda=c(0.1, 1, 2, 3, 4, 5, 10))

seed=19971016

get_srn_genus_results <- function(seed){
  
  run_ml(srn_genus_preprocessed,
       method='glmnet',
       outcome_colname='srn',
       kfold=5, # default
       cv_times=100, # default
       training_frac=0.2, # default
       hyperparameters=test_hp,
       seed=seed)
  
}

tic()
iterative_run_ml_results <- map(1:100, get_srn_genus_results)
toc()

performance <- iterative_run_ml_results %>%
  map(pluck, 'trained_model') %>%
  combine_hp_performance()

plot_hp_performance(performance$dat, lambda, AUC)

performance$dat %>% 
  group_by(alpha, lambda) %>% 
  summarize(mean_AUC=mean(AUC), .groups='drop') %>% 
  top_n(n=3, mean_AUC)
#  ggplot(aes(x=lambda, y=mean_AUC, color=as.character(alpha))) +
#  geom_line()

get_hyperparams_list(srn_genus_preprocessed, 'glmnet')

plan("sequential") # set back to single processor at the end of the run
