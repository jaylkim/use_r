{smcl}

{p 4 4 2}
{it:version 0.0.0.9000}



{title:use_r}



{title:Description}

{p 4 4 2}
This command does the following:

{break}    1. Detects an R code chunk before its call and creates an {bf:.R} file.

{break}    2. Saves the data on memory so that the R file can use it.

{break}    3. Runs the R file.

{break}    4. Prints any side effects other than figures.

{break}    5. Saves figures.

{break}    6. Returns one {it:data.frame_-like object (e.g. {it:tibble}). 

{break}    7. Loads the data on Stata memory.

{p 4 4 2}
You have to embed this command right before an R code chunk.
An R code chunk is not supposed to be run by Stata, so you have to
comment it out with /* */.

{p 4 4 2}
This command detects any R code chunks in order.
Thus, you may not skip this command after any R code chunk.

{p 4 4 2}
An R code chunk have to look like this:

{col 10}~~~r chunk-title
{col 14}Any R code lines
{col 10}~~~

{p 4 4 2}
The leading part should include a chunk title.
If not provided, it assigns one based on the current date time
followed by three random letters.



{title:Syntax}

{p 4 4 2}
Put this command right after an R code chunk.

{col 10}use_r, do(path/to/do.do) {ul:r}path(path/to/r)


{title:Options}

{break}    1. do: The path to the currently running do file. A relative path is supported.

{break}    2. {ul:r}path: The path to the Rscript command path.

{col 10}- You can get the full path
{col 14}- {bf:Terminal} (Unix): which Rscript
{col 14}- {bf:Cmd} (Win): where Rscript



{title:Author}

{p 4 4 2}
Jay (Jongyeon) Kim

{p 4 4 2}
Johns Hopkins University

{p 4 4 2}
jay.luke.kim@gmail.com

{p 4 4 2}
{browse "https://github.com/jaylkim":https://github.com/jaylkim}

{p 4 4 2}
{browse "https://jaylkim.rbind.io":https://jaylkim.rbind.io}



{title:License}

{p 4 4 2}
MIT License

{p 4 4 2}
Copyright (c) 2021 Jongyeon Kim


{p 4 4 2}
{it:This help file was created by the} {bf:markdoc} {it:package written by Haghish}



