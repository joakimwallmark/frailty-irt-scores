suppressPackageStartupMessages({
  library(mirt)
})

# Helper: pick the general factor column name automatically.
.detect_general_factor <- function(mod, fs_mat) {
  # Try common names first
  cand <- intersect(c("G","General","GeneralFactor","general"), colnames(fs_mat))
  if (length(cand) >= 1) return(cand[1])
  # Fall back to the first factor column
  colnames(fs_mat)[1]
}

# Main function: score a data.frame of coded responses (integers, NA for missing)
# - df must have exactly the 9 expected columns in the expected order/coding
# - model_path: path to frailty_bifactor_model.rds
# - return_all_factors: if TRUE, return all three factor scores and SEs
score_frailty <- function(df,
                          model_path = "model/frailty_bifactor_model.rds",
                          return_all_factors = FALSE) {
  
  stopifnot(is.data.frame(df))
  mod <- readRDS(model_path)
  
  # Basic validation: ensure columns exist
  expected_cols <- c(
    "return_to_life",  # 1..3
    "mobility",        # 1..3
    "toilet_help",     # 1..2
    "dressing_help",   # 1..2
    "dependent_sup",   # 1..3
    "depressed_anx",   # 1..2
    "general_health",  # 1..4
    "fatigue",         # 1..2
    "new_pain"         # 1..2
  )
  if (!all(expected_cols %in% names(df))) {
    stop("Input data.frame is missing expected columns: ",
         paste(setdiff(expected_cols, names(df)), collapse = ", "))
  }
  
  # NEW: strict range validation (errors on any out-of-range scores)
  allowed <- list(
    return_to_life = 1:3,
    mobility       = 1:3,
    toilet_help    = 1:2,
    dressing_help  = 1:2,
    dependent_sup  = 1:3,
    depressed_anx  = 1:2,
    general_health = 1:4,
    fatigue        = 1:2,
    new_pain       = 1:2
  )
  bad_msgs <- character(0)
  for (nm in names(allowed)) {
    x <- df[[nm]]
    bad_idx <- which(!is.na(x) & !(x %in% allowed[[nm]]))
    if (length(bad_idx) > 0) {
      rng <- paste(range(allowed[[nm]]), collapse = "–")
      # Show up to first 10 offending row indices to keep error concise
      show_idx <- paste(utils::head(bad_idx, 10), collapse = ", ")
      extra <- if (length(bad_idx) > 10) sprintf(" (+%d more)", length(bad_idx) - 10) else ""
      bad_msgs <- c(bad_msgs,
                    sprintf("%s: values must be in %s; offending rows: %s%s",
                            nm, paste(allowed[[nm]], collapse = ","), show_idx, extra))
    }
  }
  if (length(bad_msgs) > 0) {
    stop(paste(c("Out-of-range scores detected:", bad_msgs), collapse = "\n"))
  }
  
  # Compute fscores on provided patterns (EAP)
  fs <- fscores(mod, response.pattern = df, method = "EAP", full.scores.SE = TRUE)
  
  if (return_all_factors) {
    out <- as.data.frame(fs[, 1:3])
    se_df <- as.data.frame(fs[, 4:6])
    res <- cbind(out, se_df)
  } else {
    res <- data.frame(
      theta_hat = fs[, "G"],
      theta_se  = fs[, "SE_G"]
    )
  }
  
  res
}
