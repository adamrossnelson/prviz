{smcl}

{title:Title}

{phang}
{bf:prviz} {hline 2} Stata package that visualizes proportion over an x axis.

{marker syntax}
{title:Syntax}

{p 8 17 2}
{cmdab:prviz} [{it:varlist}] [if] [in] [, options]

{p 8 17 2} Where the first variable in [{it:varlist}] is a binary. Second variables in [{it:varlist}] is a continous value. The program will calculate the proprtion of the y axis variable that is true at each value of the x axis variable. Those data get stored in a matrix, that matrix is converted to variables, which are then graphed. Most twoway graph options supported. For example:

{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt title(string)}}Displays string as graph title.{p_end}
{synopt:{opt ytitle(string)}}Displays string as y axis title.{p_end}
{synopt:{opt name}}Names the graph for later reference.{p_end}

{marker description}
{title:Description}

{pstd}
{cmd:prviz} Example output:

. prviz yvar xvar if xvar >= 45 xvar <= 55

             |     xvar_      pcty_      pctn_     count_       top_ 
-------------+-------------------------------------------------------
         r45 |        45         33        -32       1010        100 
         r46 |        46         33        -32       1016        100 
         r47 |        47         37        -36        991        100 
         r48 |        48         44        -43        986        100 
         r49 |        49         47        -46       1027        100 
         r50 |        50         49        -48       1021        100 
         r51 |        51         55        -54        988        100 
         r52 |        52         58        -57        974        100 
         r53 |        53         63        -62       1073        100 
         r54 |        54         66        -65       1002        100 
         r55 |        55         68        -67       1052        100 

Example visualizations available:
{browse "https://github.com/adamrossnelson/prviz/"}{p_end}

{marker example}
{title:Example}

{phang}{cmd:. set more off}{p_end}
{phang}{cmd:. clear all}{p_end}
{phang}{cmd:. set seed 1234}{p_end}
{phang}{cmd:. discard}{p_end}
{phang}{cmd:. set obs 100000}{p_end}

{phang}{cmd:. gen xvar = round(runiform(1,100))}{p_end}
{phang}{cmd:. gen yvar = round((xvar / 100) + rnormal(0,.1))}{p_end}
{phang}{cmd:. prviz yvar xvar, title(User written prviz test output) ///}{p_end}
{phang}{cmd:. subtitle(First test) name(prviz_test_1)}{p_end}

{marker author}
{title:Author}

{phang}     Adam Ross Nelson, JD PhD{p_end}
{phang}     {browse "https://github.com/adamrossnelson"}{p_end}