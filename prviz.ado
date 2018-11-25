*! 1.0.0 Adam Ross Nelson November2018 // Original version
*! Author          : Adam Ross Nelson
*! Description     : Stata package that visualizes proportion over an x axis.
*! Maintained at   : https://github.com/adamrossnelson/prviz

capture program drop prviz
program define prviz, rclass
	version 15
	syntax varlist(min=2 max=2) [if] [in] [, *]

	// TODO: Test that y axis variable is a binary.
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
	
	// TODO: Figure out why using local/scalar causes conformability error
	// di `matlength'
	// di "matrix tograph = J(`matlength', 5,.)""
	// Declare matrix that will store graph data.
	matrix tograph = J(`matlength', 5,.)
	// matrix tograph = J(round(r(max)), 5,.)
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

	twoway (area top_ xvar_, fcolor(dkgreen%80) lwidth(vvthin)) ///
	       (area pcty_ xvar_, fcolor(white%40) lwidth(vvthin)), ///
		   legend(off) ylabel(0(10)100) ///
		   text(95 `false_note' "Dark area charts percent false", place(e)) ///
		   text(5 `true_note' "Faded area charts percent true", place(w)) ///
		   `options'
		   
	restore
	
end
