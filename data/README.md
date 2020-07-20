# README for data

## Files included
+ coronado-data-original.xlsx: Original Excel data file
+ coronado-data-clean.csv: Updated data file, with manual edits (see below) of original Excel data file, coronado-data-original.xlsx
+ agave-data.csv: Data for all agaves, created by data-preparation.R. Has consistent treatment names and 'Status' column indicating whether plant was alive (1) or dead (0) at end of treatment; note some agaves have a NA in live_leaf_number column. These plants _were_ alive at the end of the experiment; their size was not measured. Thus they can be included in analyses of agave survivorship (response) or presence/absence (predictor), but not of agave size (either response or predictor)
+ agave-size-data.csv: Data for live agaves with size (leaf count) data, created by data-preparation.R; includes a maximum of three agaves per plot/row combination.

## Summary of data and design
There are 6 plots (reps). In each large plot, ten rows of agave were planted (20 plants per row) in a Lehmann lovegrass-dominated field. Each row is a different treatment. Treatment codes are:

+ J = javelina protection with chicken wire
+ S = shade cloth
+ W = Lehmann lovegrass control via weed eating
+ H = Lehmann lovegrass control via hand pulling
+ J+S = javelin protection with chicken wire AND shade cloth
+ J+W = javelin protection with chicken wire AND Lehmann lovegrass control via weed eating
+ S+W = Shade cloth AND Lehmann lovegrass control via weed eating
+ W+H = Lehmann lovegrass control via weed eating AND hand pulling
+ C = control (no treatment applied)

## Changes from original data file
Several alterations to the original Excel file, coronado-data-original.xlsx, 
were made to create the computable data file, coronado-data-clean.csv:

+ Cells for plot 2, row 1 for live_leaf_cover of Lehmann lovegrass rows were 
empty; changed to NA in coronado-data-clean
+ Plot 1, row 3, plant 20 Lehmann lovegrass was incorrectly labeled as J+H 
treatment; changed to W coronado-data-clean
+ One observation (plot 1, row 1, plant 8) had a value of "L" in the 
live_leaf_number column; changed to NA
+ In live_leaf_number, some cells were coded "L8" and such; in such cases the 
leading "L" was removed
+ Column name "areial_cover(%" changed to "areial_cover" [sic]
+ Plot 4, row 1, plant 12 and plot 4, row 2, plant 12 had D/10 and D/D 6, 
respectively in areial_cover [sic] column. Changed to 10 and 6, respectively
+ Plot 5, row 1, no treatment was assigned (NA) in original Excel file; changed 
to S+W following consultation with A. Gill 2019-11-01
