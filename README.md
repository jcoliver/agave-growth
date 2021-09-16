# Analyses of _Agave palmeri_ growth and survivorship

This repository holds code and data for analyses of a variety of treatments 
investigating the relationship between Lehmann lovegrass, _Eragrostis 
lehmanniana_, and Palmer's agave, _Agave palmeri_.

The primary questions are:

1. How do various treatments affect agave survival and growth, where:
    a. **agave-survival**: survival is measured by whether an individual plant 
    survived the experiment, and
    b. **agave-growth**: growth is measured by the number of leaves from three 
    plants in a row
2. How do a subset of treatments affect percent cover of Lehman lovegrass, 
considering also:
    a. **lovegrass-cover-pa**: presence or absence of an agave
    b. **lovegrass-cover-size**: size of agave, when present

Bold text above indicates the file-naming strategy used for this project. 
Scripts and output files use the bolded font as the prefix and descriptor of 
script / output contents as the suffix. i.e. the script 
agave-survival-analysis.R runs the analyses for 1a, above, and outputs the 
results of statistical tests to output/agave-survival-analysis-out.csv. The 
script agave-survival-boxplot.R creates an accompanying boxplot for 1a and 
saves the PNG file to output/agave-survival-boxplot.png.

## Dependencies

+ broom.mixed, formatting of statistical output
+ car, Levene test of homoscedasticity
+ dplyr, data wrangling
+ emmeans, post-hoc, pairwise comparisons
+ extrafont, data visualization
    + to avoid errors with `ggsave` will need to run `extrafont::font_import()`
+ ggplot2, data visualization
+ lme4, glmer logistic models
+ stringr, formatting of statistical output

## Organization

+ Scripts for running analyses and saving results to files, as well as scripts 
for creating data visualizations are in the top-level directory. Also in the 
top-level directory is the data cleaning script (data-preparation.R), which 
standardized variable names and values. Early development on this work was done 
in an RMarkdown file, agave-lovegrass-report.Rmd; the file remains, but much of 
the analyses are deprecated, corresponding to appropriate files in this 
top-level directory.
+ **data**: raw and tidied data
+ **functions**: custom functions for assistance with data visualization
+ **output**: results of statistical analyses and data visualization files