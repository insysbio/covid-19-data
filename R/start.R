#!/usr/bin/env Rscript

args = commandArgs(trailingOnly = TRUE)

build_date <- args[1]

if(!require(tidyr, warn.conflicts = FALSE)){
    install.packages("tidyr", repos = 'https://cran.rstudio.com/')
    library(tidyr, warn.conflicts = FALSE)
}
if(!require(dplyr, warn.conflicts = FALSE)){
    install.packages("dplyr", repos = 'https://cran.rstudio.com/')
    library(dplyr, warn.conflicts = FALSE)
}
if(!require(jsonlite, warn.conflicts = FALSE)){
    install.packages("jsonlite", repos = 'https://cran.rstudio.com/')
    library(jsonlite, warn.conflicts = FALSE)
}
if(!require(ISOcodes, warn.conflicts = FALSE)){
    install.packages("ISOcodes", repos = 'https://cran.rstudio.com/')
    library(ISOcodes, warn.conflicts = FALSE)
}
if(!require(knitr, warn.conflicts = FALSE)){
    install.packages("knitr", repos = 'https://cran.rstudio.com/')
    library(knitr, warn.conflicts = FALSE)
}
if(!require(highr, warn.conflicts = FALSE)){
    install.packages("highr", repos = 'https://cran.rstudio.com/')
    library(highr, warn.conflicts = FALSE)
}

res <- try({
  source('./R/transform-hopkins-data.R')
})
if(inherits(res, "try-error")) q(status=1) else message("Hopkins done.")
res <- try({
  source('./R/transform-russian-data.R')
})
if(inherits(res, "try-error")) q(status=1) else message("Russian done.")
res <- try({
  source('./R/transform-us-data.R')
})
if(inherits(res, "try-error")) q(status=1) else message("US done.")

quit(save = 'no')
