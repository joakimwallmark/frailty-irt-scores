# Frailty Score (Riksstroke PROMs) — Scoring Guide

Compute **frailty scores** for new respondents using the bifactor IRT model from the article (to be published later). **R is not required**: Clone/Download this repository and use the offline HTML tool.

## What’s in this repo

* `frailty_scoring_local.html` — offline scoring tool (runs offline in your browser).
* `lookup.csv` — precomputed lookup table (key → factor scores + SEs).
* `input_template.csv` — example input file with the required columns/coding.
* `frailty_bifactor_model.rds` — (optional) the fitted `mirt` model for advanced R users.
* `build_lookup_table.R` — (maintainer) script to regenerate `lookup.csv` from the model.

---

## Quick start (HTML — no R required)

1. Open `frailty_scoring_local.html` in a browser (Chrome/Edge/Firefox/Safari).
2. Click **Load the lookup table** and choose `lookup.csv`.
3. Click **Load your responses** and upload your CSV (see format below).
4. Click **Score and download CSV** → you’ll get `frailty_scores.csv` with scores appended. The `frailty` and `se_frailty` columns are contain the frailty scores and their respective standard errors. The subsequent columns contain the scores and SEs for the two specific factors (see article). 

### Output columns appended

* `theta_g`, `se_g` — general frailty factor + SE
* `theta_s1`, `se_s1` — specific factor 1 (Physical Functioning) + SE
* `theta_s2`, `se_s2` — specific factor 2 (Well-being/Mental Health) + SE

> Rows that don’t match any pattern in the lookup will have empty score cells. See Troubleshooting.

---

## Input data format

Use the 9 columns **exactly** as named below (order doesn’t matter).
See `templates/input_template.csv` for an example.

| Column name         | Questionnaire item (abbrev. from article)             | Allowed codes                                                            |
| ------------------- | ----------------------------------------------------- | ------------------------------------------------------------------------ |
| `return_to_life`    | Return to life/activities                             | 1–3 (1=Yes completely, 2=Yes not quite as before, 3=No)                            |
| `mobility`          | Mobility                                              | 1–3 (1=indoor+outdoor alone, 2=indoor alone only, 3=help indoor+outdoor) |
| `toilet_help`       | Toilet help                                           | 1–2 (1=no help, 2=needs help)                                            |
| `dressing_help`     | Dressing help                                         | 1–2 (1=no help, 2=needs help)                                            |
| `dependent_support` | Dependent on support                             | 1–3 (1=No, 2=Yes partly, 3=Yes completely)                               |
| `depressed_anxious` | Down/depressed/anxious                   | 1–2 (1=No, 2=Yes)                                                        |
| `general_health`    | General health status                                 | 1–4 (1=Very good, 2=Fairly good, 3=Fairly poor, 4=Very poor)             |
| `increased_fatigue` | Increased fatigue | 1–2 (1=No, 2=Yes)                                                        |
| `new_pain`          | New pain                        | 1–2 (1=No, 2=Yes)                                                        |


**Missing / “Don’t know”**: leave the cell empty or write `NA` (both are treated as missing).
**Ranges must be respected**: values outside the allowed codes won’t match the lookup.

---

## Scale and interpretation

* Scores are on the **reference metric** (2021–2022 Riksstroke cohort): mean 0, SD 1.
* **Higher score $(\hat{\theta})$ = higher frailty** (worse recovery/well-being).

---

## Troubleshooting

* **Blank scores in output**
  Most common causes:

  * A column name is misspelled (must match the table above exactly).
  * A value is out of range (e.g., `general_health=5`).
  * Extra whitespace or non-numeric strings in numeric columns.
* **Large files**
  The lookup join is instant for typical CSV sizes. If you’re scoring millions of rows, consider splitting the input CSV into chunks.

---

## R / `mirt` users (optional)

You don’t need R to score with the HTML tool, but the model is made available for R users:

```r
# Minimal example: load model and score new data with mirt
library(mirt)
# Load the fitted bifactor model
mod <- readRDS("frailty_bifactor_model.rds")  # 3 factors: g, s1, s2
# Read your data frame with the 9 columns listed above (integers + NA)
df <- read.csv("input_template.csv")
# EAP scores for all three factors
scores <- fscores(mod, response.pattern = df)
head(scores)
```
