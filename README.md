## Frailty Score (Riksstroke PROMs) — Scoring Guide

This repo lets you compute **frailty scores** for new respondents using the bifactor IRT model from the corresponding article (published later). Scores can be computed from within R or from the command line with R installed.

### Installation

- Clone/download this repository
- A local R installation is required. If you don’t already have R installed, you can download it here:  
👉 [https://cran.r-project.org/](https://cran.r-project.org/)
- Optionally, you may also want RStudio Desktop if you plan to use R more in the future (a popular IDE for R):  
👉 [https://posit.co/download/rstudio-desktop/](https://posit.co/download/rstudio-desktop/)
- Install the `mirt` R package
    ```r
    install.packages("mirt")
    ```

### Input data
See `templates/input_template.csv` for an example CSV in the expected format.

Items, names, and coding (you must use these column names):

| Column name      | Questionnaire item (abbrev. from article)             | Allowed codes                                                            |
| ---------------- | ----------------------------------------------------- | ------------------------------------------------------------------------ |
| `return_to_life` | Return to life/activities                             | 1–3 (1=Yes completely, 2=Yes not quite, 3=No)                            |
| `mobility`       | Mobility                                              | 1–3 (1=indoor+outdoor alone, 2=indoor alone only, 3=help indoor+outdoor) |
| `toilet_help`    | Toilet help                                           | 1–2 (1=no help, 2=needs help)                                            |
| `dressing_help`  | Dressing help                                         | 1–2 (1=no help, 2=needs help)                                            |
| `dependent_sup`  | Dependent on support/help                             | 1–3 (1=No, 2=Yes partly, 3=Yes completely)                               |
| `depressed_anx`  | Down/depressed/anxious since stroke                   | 1–2 (1=No, 2=Yes)                                                        |
| `general_health` | General health status                                 | 1–4 (1=Very good, 2=Fairly good, 3=Fairly poor, 4=Very poor)             |
| `fatigue`        | Increased tiredness affecting activities since stroke | 1–2 (1=No, 2=Yes)                                                        |
| `new_pain`       | New types of pain since stroke                        | 1–2 (1=No, 2=Yes)                                                        |

* **Missing/“Don’t know”:** encode as `NA` (leave the cell empty or write `NA` in CSV).
* **Ranges must be respected** (e.g., `general_health` must be 1, 2, 3 or 4). The scorer will error if any value is out of range.

### Scale and interpretation

* Scores are on the **reference metric** from the 2021–2022 Riksstroke cohort: mean 0, SD 1.
* **Higher θ̂ = more frailty** (worse recovery/well-being).

---

## Command-line scoring

Run from the terminal (bash) from the cloned repo directory:
```bash
Rscript R/score_frailty_cli.R templates/input_template.csv out.csv
```
All factors from the terminal:
```bash
Rscript R/score_frailty_cli.R templates/input_template.csv out.csv --all
```

This reads `input_template.csv` and writes scores to `out.csv`.

---

## R scoring
Open R or RStudio and set the working directory to the cloned repo (e.g., by opening the R project file `frailty-irt-model.Rproj` or by using the `setwd()` R function), then run:

```r
# Load the scoring function
source("R/score_frailty.R")

# Example: read a CSV with the 9 columns above (integers + NA)
df <- read.csv("templates/input_template.csv")

# Score using the model
res <- score_frailty(df)
head(res)
```

To return **all factors** (general + specifics) with SEs:

```r
res_all <- score_frailty(df, return_all_factors = TRUE)
head(res_all)
```

---

## mirt package users

Users familiar with `mirt` can use the `mirt` package directly. The model is stored in `model/frailty_bifactor_model.rds` and can be loaded with:

```r
library(mirt)
model <- readRDS("model/frailty_bifactor_model.rds")
```
 
