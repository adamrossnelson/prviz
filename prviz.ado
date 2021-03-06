*! 1.0.0 Adam Ross Nelson November2018 // Original version
*! 1.1.1 Adam Ross Nelson December2018 // Added bar option
*! Author          : Adam Ross Nelson
*! Description     : Stata package that visualizes proportion over an x axis.
*! Maintained at   : https://github.com/adamrossnelson/prviz

capture program drop prviz
program define prviz, rclass
	version 15
	syntax varlist(min=2 max=2) [if] [in] [, * fcolor(string)]

	// TODO: Test that x axis variable is integer continous.
	//       OR - convert x axis to integer continious.

	// This program takes two variables, the first is an y axis variable, and
	// the secnd is the x axis variable. The y axis variable must be a binary where
	// 0 = false and 1 = true. The x axis variable must be a continous, count,
	// ordinal, or nominal that consists of whole integers.

	// The program will calculate the proprtion of the y axis variable that is true
	// at each value of the x axis variable. Those data get stored in a matrix,
	// that matrix is converted to variables, which are then graphed.
	
	tokenize "`varlist'"
	
	local make_bar = 0
	if strpos("`options'","bar") > 0 {
		local make_bar = 1
		local options = subinstr("`options'","bar","", .)
	}

	// Test to make sure y, outcome variable is binary.
	capture assert `1' == 1 | `1' == 0 `if' `in'
	if _rc != 0 {
		display as err "ERROR. Y, outcome variable is not binary."
		error 450
	}
	
	// Check if color had been specified. If not, set to default.
	if "`fcolor'" == "" {
		local fcolor = "dkgreen%80"
	}
	
	// Determine a sensible min and max value for the x axis.
	// Take the rounded value of the min and max x axis value.
	qui sum `2' `if' `in'
	local min = round(r(min))
	local max = round(r(max))

	// Determine the length of the matrix needed.
	local matlength = `max' - `min' + 1
	
	// Preserve data set before keeping/removing observations.
	preserve
	capture keep `if' `in'
	
	// Declare matrix that will store graph data.
	matrix tograph = J(`matlength', 5,.)
	// Name matrix columns.   
	//    xvar_  = x axis values
	//    pcty_  = percent true (y axis)   pctn_ = percent not true (y axis)
	//    count_ = N of obs at x axis      top_  = Helper variable used in graph
	matrix colnames tograph = xvar_ pcty_ pctn_ count_ top_
	
	// Use local to iterate through row when first x axis value is not 1.
	local matrow = 1
	// Loop through x axis values. Calculate graph data and populate matrix.
	forvalues i = `min'/`max' {
		qui sum `1' if `2' == `i'
		// Store x axis value.
		matrix tograph[`matrow', 1] = `i'
		// Store percent true (y axis)
		matrix tograph[`matrow', 2] = r(mean) * 100
		// Store percent not true (y axis)
		matrix tograph[`matrow', 3] = (1 - r(mean) * 100)
		// Store number of observations available at each x axis value.
		matrix tograph[`matrow', 4] = r(N)
		// Store helper variable used in graph.
		matrix tograph[`matrow', 5] = 100
		local matrow = `matrow' + 1
	}
	
	// TODO: Add an option/argument that can suppress this output.
	// Display and output matrix with formatting rules.
	matlist tograph, format(%9.2g)
	
	// Convert matrix to variables which can be graphed.
	svmat tograph, names(col)
	
	// Apply variable labels
	label variable top_ "Proportion Not True"
	label variable pcty_ "Proportion True"
	
	// Calculate position for legend text inside chart area.
	qui sum xvar_
	// False note position on x axis is minimum x axis value 
	// plus 1% of the x axis length.
	local false_note = r(min) + (`matlength' * .01)
	// True note position on x axis is the 99th% position
	// along the x axis length.
	local true_note = r(max) * .99

	if `make_bar' {
		qui tab xvar_
		if r(r) > 20 {
			di as result ""
			di as result "WARNING. X axis contains 20 more than categories."
			di as result "         This visuzlization optimized for 20 or fewer."
		}
		graph bar (mean) yvar (mean) yvar_inv, over(xvar) ///
		stack legend(rows(1) position(6)) ///
		`options'
	}
	else {
		twoway (area top_ xvar_, fcolor("`fcolor'") lwidth(vvthin)) ///
			(area pcty_ xvar_, fcolor(white%40) lwidth(vvthin)), ///
			legend(off) ylabel(0(10)100) ///
			text(95 `false_note' "Dark area charts percent false", place(e)) ///
			text(5 `true_note' "Faded area charts percent true", place(w)) ///
			`options'
	}
	
	// gen yvar_inv = 1 - yvar
	   
	restore
	
end
