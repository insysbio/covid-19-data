#!/usr/bin/env Rscript

args = commandArgs(trailingOnly = TRUE)

res <- try({
  source('./R/transform-hopkins-data.R')
})
if(inherits(res, "try-error")) q(status=1) else message("All done.")

quit(save = 'no')
