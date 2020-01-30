# README for data

## Summary of data and design
There are 6 plots (reps). In each large plot, ten rows of agave were planted 
(20 plants per row) in a lehmann lovegrass (invasive plant) dominated field. 
Each row is a different treatment. Treatment codes are:

+ J = javelina protection with chicken wire
+ S = shade cloth
+ W = lehmanns control via weed eating
+ H = lehmanns control via hand pulling
+ J+S = javelin protection with chicken wire AND shade cloth
+ J+W = javelin protection with chicken wire AND lahmanns control via weed eating
+ S+W = Shade cloth AND lehmanns control via weed eating
+ W+H = lehmanns control via weed eating AND lehmanns control via hand pulling
+ C = control (no treatment applied)

Agave seedlings were planted in the spring and last month. Measurements are:

1. On each agave, if the plant was predated upon (was munched by 
javelina), was dead or was alive and not predated upon.
2. On THREE agave per row (out of ten), amy measured the number of live leaves. 
If there were not enough live plants (as is the case mostly, most of our agaves 
died or were really badly chewed), then no leaves were measured.
3. On each agave planting (ten per row), amy assessed the amount of lehmanns 
aerial cover in a meter squared quadrat (with the quadrat centered on the agave)

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



