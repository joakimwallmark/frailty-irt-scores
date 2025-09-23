#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(readr)
  source("R/score_frailty.R")
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  cat("Usage: Rscript R/score_frailty_cli.R <input.csv> <output.csv> [model.rds] [--all]\n")
  quit(status = 1)
}

in_csv  <- args[1]
out_csv <- args[2]

# Defaults
model_path <- "model/frailty_bifactor_model.rds"
return_all_factors <- FALSE

# Optional 3rd arg = model path unless it's a flag
if (length(args) >= 3) {
  a3 <- args[3]
  if (tolower(a3) %in% c("--all","-a","true","t","1","yes","y")) {
    return_all_factors <- TRUE
  } else {
    model_path <- a3
  }
}
# Optional 4th arg = flag
if (length(args) >= 4) {
  a4 <- args[4]
  if (tolower(a4) %in% c("--all","-a","true","t","1","yes","y")) {
    return_all_factors <- TRUE
  }
}

df <- readr::read_csv(in_csv, show_col_types = FALSE)

sc <- score_frailty(
  df,
  model_path          = model_path,
  return_all_factors  = return_all_factors
)

readr::write_csv(cbind(df, sc), out_csv)
cat(sprintf("Wrote %s\n", out_csv))
