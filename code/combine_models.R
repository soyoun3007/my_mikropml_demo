#!/usr/bin/env Rscript

library(mikropml)
library(tidyverse)

rds_files <- commandArgs(trailingOnly=TRUE)
rds_files <- c('processed_data/l2_genus_1.Rds', 'processed_data/l2_genus_2.Rds')

iterative_run_ml_results <- map(rds_files, readRDS)

iterative_run_ml_results %>%
  map(pluck, 'trained_model') %>%
  combine_hp_performance() %>% 
  pluck('dat') %>% 
  write_tsv('processed_data/l2_genus_pooled_hp.tsv')

iterative_run_ml_results %>%
  map_dfr(pluck, 'performance') %>%
  write_tsv('processed_data/l2_genus_pooled_performance.tsv')
