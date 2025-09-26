#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(dplyr)
  library(purrr)
  library(readr)
  library(tidyr)
  library(mirt)
})

# Item names (must match the mirt model item order/labels)
items <- c('return_to_life','mobility','toilet_help','dressing_help',
           'dependent_support','depressed_anxious','general_health',
           'increased_fatigue','new_pain')

# Valid codes per item (NA included as a state to cover missing)
# Note: DK is treated as NA, so we do not include DK codes here.
levels_list <- list(
  return_to_life    = c(1L,2L,3L,NA_integer_),
  mobility          = c(1L,2L,3L,NA_integer_),
  toilet_help       = c(1L,2L,NA_integer_),
  dressing_help     = c(1L,2L,NA_integer_),
  dependent_support = c(1L,2L,3L,NA_integer_),
  depressed_anxious = c(1L,2L,NA_integer_),
  general_health    = c(1L,2L,3L,4L,NA_integer_),
  increased_fatigue = c(1L,2L,NA_integer_),
  new_pain          = c(1L,2L,NA_integer_)
)

stopifnot(setequal(names(levels_list), items))

message('Enumerating response space...')
all_combos <- tidyr::crossing(!!!levels_list) |>
  select(all_of(items))

nrow_all <- nrow(all_combos)
message('Total combinations kept: ', nrow_all)

# --- Load model and compute EAP scores (all 3 factors + SEs) ---
mod <- readRDS('frailty_bifactor_model.rds')

message('Scoring combinations with mirt::fscores ...')
scores <- fscores(
  mod,
  response.pattern = all_combos,
  method = 'EAP',
  full.scores = FALSE,
)

# Assume first factor is the general factor, then s1, s2
scores_tbl <- tibble(
  frailty  = as.numeric(scores[, 1]),
  se_frailty     = as.numeric(scores[, 4]),
  theta_s1 = as.numeric(scores[, 2]),
  se_s1    = as.numeric(scores[, 5]),
  theta_s2 = as.numeric(scores[, 3]),
  se_s2    = as.numeric(scores[, 6])
)

# Build key: stable string based on item=value with NA literal for missing
key_df <- all_combos |> mutate(across(everything(), ~ ifelse(is.na(.x), 'NA', as.character(.x)))) |>
  unite('key', all_of(items), sep = '|', remove = FALSE)

lookup <- bind_cols(key_df['key'], all_combos, scores_tbl)

# Write CSVs
readr::write_csv(lookup |> select(key, starts_with('frailty'), starts_with('theta_'), starts_with('se_')), 'lookup.csv')
message('Wrote lookup to: lookup.csv')
