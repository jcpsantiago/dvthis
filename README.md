
# dvcru

<!-- badges: start -->
[![R-CMD-check](https://github.com/jcpsantiago/dvcru/workflows/R-CMD-check/badge.svg)](https://github.com/jcpsantiago/dvcru/actions)
<!-- badges: end -->

The goal of `dvcru` is to provide utility functions for [DVC](https://dvc.org) 
pipelines using R scripts.
An additional goal is to document the usual workflows they enable, and provide
a template for projects using DVC and R.

## Installation

You can install the current development version of `dvcru` with

``` r
remotes::install_github("jcpsantiago/dvcru")
```

No version available in CRAN yet.

## Using dvcru

You can use DVC by itself by running `dvc init` within a git repo dir
(read their docs [here](https://dvc.org/doc)) and then use the utility functions
to make your life easier.
Or, you can use `dvcru` to setup the scaffolding for you.

* Create a new R project based on the `dvcru` template. `<WIP>`
It will have the following folder structure and initiate DVC for you 
(if it is installed, otherwise it shows you a warning):

```sh
.
├── data                   # all data that's not a model, metrics or plots goes here
│  ├── intermediate        # outputs of each stage to be used in future stages
│  └── raw                 # original data; should never be overwritten; saved in remote storage with DVC
├── metrics                # metrics of interest in JSON; DVC can track these over time
├── models                 # final output of your pipeline, in case it's a model
├── plots                  # any plots produced, including CSVs with data for plots (see DVC docs)
├── queries                # .sql files or other format so that queries are also tracked
├── R                      # additional R functions needed for this project and not in a pkg yet
├── reports                # more complete reports or model cards
└── stages                 # scripts for each stage; doesn't need to be only in R!
```

This structure assumes a DVC pipeline for Machine Learning made out of multiple `stages/*.R` which will 

* take some data e.g. from a database using `queries/*.sql`
* save that data as `data/raw/*.csv`
* do something with it and save the intermediate steps as `data/intermediate/*.qs`
* finally output `models/*`, some `metrics/*.json` and `plots/*.png`

You are free, of course, to use your own naming conventions, stages, etc.
E.g. maybe you don't have data coming from a database -- just delete the `queries` dir,
and instead place your data in `data/raw`. Bam!

### Stages

Stages should be small and focused, just like you would write your normal R functions.
For example you could have stages (separate, independent scripts) for:

* Fetching data
* Cleaning data
* Feature transformation
* Train-test split
* Hyperparameter tuning
* Train final model
* Produce metrics
* Produce plots

This way it's possible to experiment and make changes to a smaller amount of code 
each time.
It also enables an interactive workflow e.g. if you want to experiment with a new transformation

* Open the feature transformation script
* Run the `read_intermediate_data()` lines to load cached data the stage depends on
* Add a new transformation to e.g. a `mutate()`
* Run the modified chunk of code and see the result in the R REPL/Console
* Save the script and run `dvc repro` in the terminal to run the pipeline starting at the modified feature transformation script all the way downstream
* Rinse and repeat!

A stage script could look something like this:
```r
#!/usr/bin/env Rscript

# you may not need command line arguments, but they're helpful in parameterised pipelines
n_of_dragons <- commandArgs(trailingOnly = TRUE)[1]

# assigning it to this_stage by convention will allow stage_footer() to be called without args
this_stage <- dvcru::stage_header("Choosing dragons")

dvcru::log_stage_step("Loading dragon data")
dragons_raw <- readr::read_csv(here::here("data/raw/dragons.csv"))

dvcru::log_stage_step("Loading clean kingdom data")
kingdoms <- dvcru::read_intermediate_result("kingdoms")

dvcru::log_stage_step("Keeping only {n_of_dragons} dragons")
dragons_clean <- head(dragons_raw, n_of_dragons)
dragons_and_kingdoms <- dplyr::inner_join(dragons_clean, kingdoms)

# you don't have to save every single intermediate result, but here I want to 
# be extensive for documentation sake
dvcru::log_stage_step("Saving intermediate dragons_clean")
dvcru::save_intermediate_result(dragons_clean)

dvcru::log_stage_step("Saving intermediate dragons_clean")
dvcru::save_intermediate_result(dragons_and_kingdoms)

dvcru::stage_footer()
```


