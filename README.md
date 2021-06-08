
# dvcru

<!-- badges: start -->
[![R-CMD-check](https://github.com/jcpsantiago/dvcru/workflows/R-CMD-check/badge.svg)](https://github.com/jcpsantiago/dvcru/actions)
<!-- badges: end -->

The goal of `dvcru` is to provide utility functions to pipelines using R scripts
within [DVC](https://dvc.org) pipelines.
An additional goal is to document the usual workflows they enable, and provide
a template for projects using DVC.

## Installation

You can install the current development version of `dvcru` with

``` r
remotes::install_github("jcpsantiago/dvcru")
```

## Using DVC

Nothing beats reading their [docs](https://dvc.org/doc), but here's how to start:

* Create a new R project based on the `dvcru` template.
It will have the following folder structure and initiate DVC for you 
(if it is installed, otherwise it shows you a warning):

```sh
.
├── data
│  ├── intermediate
│  └── raw
├── metrics
├── models
├── plots
├── queries
├── R
├── reports
└── stages
```

This structure assumes a DVC pipeline for Machine Learning made out of `stages/*.R` which will 

* take some data e.g. from a database using `queries/*.sql`
* save that data as `data/raw/*.csv`
* do something with it and save the intermediate steps as `data/intermediate/*.qs`
* finally output a `model/*`, some `metrics/*.json` and `plots/*.png`

You are free, of course, to use your own naming conventions, stages, etc.
E.g. maybe you don't have data coming from a database -- just delete the `queries` dir,
and instead place your data in `data/raw`. Bam!

* 

