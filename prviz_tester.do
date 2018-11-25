// Test script in support of user written Stata package - prviz -.
// More information at: https://github.com/adamrossnelson/prviz


// First test:
set more off
clear all
set seed 1234
discard
// Set 100,000 observations
set obs 100000
// Generate xvar uniform distribution between 0 and 100.
gen xvar = round(runiform(1,100))
// Generate y var that will be sometimes true and sometimes not.
// Divide xvar by 100 then add random normal with .1 std dev.
// Creates positively correlated relationship.
gen yvar = round((xvar / 100) + rnormal(0,.1))
// Test the visulization
prviz yvar xvar, title(prviz example output) ///
subtitle(first test) ///
name(prviz_test_1) ///
note("More information: github.com/adamrossnelson/prviz") ///
xtitle("Value along the x axis - conceptually an independant variable") ///
ytitle("Proportion of y variable that is true," "conceptually dependant variable")



// Second test:
// Test a visualization with negative correlation.
gen newy = (yvar - 1) * -1
// Test the visulization
prviz yvar xvar, title(prviz example output) ///
subtitle(second test) ///
name(prviz_test_2) ///
note("More information: github.com/adamrossnelson/prviz") ///
xtitle("Value along the x axis - conceptually an independant variable") ///
ytitle("Proportion of y variable that is true," "conceptually dependant variable")




// Third test:
// Test command with subset of data.
prviz yvar xvar if xvar >= 45 & xvar <= 55, title(prviz example output) ///
subtitle(third test) ///
name(prviz_test_3) ///
note("More information: github.com/adamrossnelson/prviz") ///
xtitle("Value along the x axis - conceptually an independant variable") ///
ytitle("Proportion of y variable that is true," "conceptually dependant variable")

