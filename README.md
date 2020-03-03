LCAP Metrics
================

## Purpose

The purpose of this project is to provide all districts with as many of
the required LCAP metrics as possible. It draws on public datasources
including the California Dashboard and CDE’s downloadable data files
(<https://www.cde.ca.gov/ds/sd/sd/>).

## Files

1.  LCAPmetrics.R - this script compiles all the indicators together in
    a single dataframe
2.  renderfiles.R - this script instructs the rmarkdown files (see
    below) to execute for a single district or all districts
3.  LCAPmetricsReport.Rmd - this file transforms the dataframe into an
    html report and csv file for each district with narrative, context
    and source information
4.  child.Rmd - generates sections for the above rmarkdown report

## Reports

All reports will be put in the output folder
