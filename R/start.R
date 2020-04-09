#!/usr/bin/env Rscript

args = commandArgs(trailingOnly = TRUE)

if(!require(tidyr, warn.conflicts = FALSE)){
    install.packages("tidyr", repos = 'https://cran.rstudio.com/', lib = 'r_libs')
    library(tidyr, warn.conflicts = FALSE, lib.loc = 'r_libs')
}
if(!require(dplyr, warn.conflicts = FALSE)){
    install.packages("dplyr", repos = 'https://cran.rstudio.com/', lib = 'r_libs')
    library(dplyr, warn.conflicts = FALSE, lib.loc = 'r_libs')
}
if(!require(jsonlite, warn.conflicts = FALSE)){
    install.packages("jsonlite", repos = 'https://cran.rstudio.com/', lib = 'r_libs')
    library(jsonlite, warn.conflicts = FALSE, lib.loc = 'r_libs')
}
if(!require(ISOcodes, warn.conflicts = FALSE)){
    install.packages("ISOcodes", repos = 'https://cran.rstudio.com/', lib = 'r_libs')
    library(ISOcodes, warn.conflicts = FALSE, lib.loc = 'r_libs')
}
if(!require(knitr, warn.conflicts = FALSE)){
    install.packages("knitr", repos = 'https://cran.rstudio.com/', lib = 'r_libs')
    library(knitr, warn.conflicts = FALSE, lib.loc = 'r_libs')
}
library(highr)

res <- try({
  source('./R/transform-hopkins-data.R')
})
if(inherits(res, "try-error")) q(status=1) else message("All done.")

quit(save = 'no')
