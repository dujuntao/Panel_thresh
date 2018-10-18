panel_thresh_endogenous.m extends the MATLAB proccedure IVTAR.M written by Bruce E. Hansen as described in Kremer, Bick and Nautz "Inflation and Growth: New Evidence From a Dynamic Panel Threshold Analysis" (Empirical Economics,44(2), April 2013, 861-878) to estimate a Dynamic Panel Threshold Model. 

-----------------------------

CG_transformed_data.xls contains the 5-year averages of all regressors for the two country groups considered in our paper (CG=Develop,industrial). 

CG_transformed_data.txt contains the same information as CG_transformed_data.xls and is read in by panel_thresh_endogenous.m

CG_instrumentsall.txt contains the instruments used in the estimation and is read in by panel_thresh_endogenous.m

-----------------------------

The current code generates table 5 for industrialized countries. To generate table 1 include all instruments in the brackets in row 53. To generate the results for developed countries uncomment rows 15 to 18 and put lines 20 to 23 into a comment.

-----------------------------

Remarks: 

1. Note that the exact coefficient estimates may vary with the Matlab version used. 
2. The paper actually reports 90% confidence intervals rather than 95% confidence intervals.
3. The coefficient for dtot in table 6 is actually positive rather than negative.