*! version 0.0.0.9000 Jay Kim 04feb2021

/***

_version 0.0.0.9000_


use_r
=====


Description
-----------

This command does the following:

1. Detects an R code chunk before its call and creates an __.R__ file.

2. Saves the data on memory so that the R file can use it.

3. Runs the R file.

4. Prints any side effects other than figures.

5. Saves figures.

6. Returns one _data.frame_-like object (e.g. _tibble_). 

7. Loads the data on Stata memory.

You have to embed this command right before an R code chunk.
An R code chunk is not supposed to be run by Stata, so you have to
comment it out with /* */.

This command detects any R code chunks in order.
Thus, you may not skip this command after any R code chunk.

An R code chunk have to look like this:

{col 10}~~~r chunk-title
{col 14}Any R code lines
{col 10}~~~

The leading part should include a chunk title.
If not provided, it assigns one based on the current date time
followed by three random letters.


Syntax
------

Put this command right after an R code chunk.

{col 10}use_r, do(path/to/do.do) {ul:r}path(path/to/r)

Options
-------

1. do: The path to the currently running do file. A relative path is supported.

2. **r**path: The path to the Rscript command path.
    
{col 10}- You can get the full path
{col 14}- {bf:Terminal} (Unix): which Rscript
{col 14}- {bf:Cmd} (Win): where Rscript


Author
------

Jay (Jongyeon) Kim

Johns Hopkins University

jay.luke.kim@gmail.com

[https://github.com/jaylkim](https://github.com/jaylkim)

[https://jaylkim.rbind.io](https://jaylkim.rbind.io)


License
-------

MIT License

Copyright (c) 2021 Jongyeon Kim


_This help file was created by the_ __markdoc__ _package written by Haghish_

***/



program define use_r

  syntax , do(str) Rpath(str)
  
  // Path manipulations

  mata: st_local("dopath", pathjoin(pwd(), "`do'")) 
  mata: pathsplit("`dopath'", path = "", file = ""); st_local("dofilename", file)
  mata: st_local("dofilenosuffix", pathrmsuffix("`dofilename'"))
  mata: st_local("datapath", pathjoin(pwd(), "data"))
  mata: st_local("srcpath", pathjoin(pwd(), "src"))
  mata: st_local("rparent", pathjoin(pwd(), pathjoin("src", "R")))
  mata: st_local("outpath", pathjoin(pwd(), "output"))
  mata: st_local("figpath", pathjoin("`outpath'", "figures"))

  // Detects an R code chunk

  cap file open dofile using "`dopath'", read
  file read dofile line

  while r(eof) == 0 {
  
    local line = strtrim(`"`line'"')

    if regexm(`"`line'"', "^~~~r") {
      
      local chunk_title = word(regexr(`"`line'"', "~~~r", ""), 1)
      
      if "`chunk_title'" == "" {
        
        disp as txt "Chunk title not provided"
        
        local current_d = subinstr(c(current_date), " ", "", .)
        local current_t = subinstr(c(current_time), ":", "", .) 

        local chunk_title = ("`current_d'" + "_" + "`current_t'")
        local chunk_title = ("`chunk_title'" + char(runiformint(97, 122)))
        local chunk_title = ("`chunk_title'" + char(runiformint(97, 122)))
        local chunk_title = ("`chunk_title'" + char(runiformint(97, 122)))

        disp as txt "Chunk title created based on the current date-time"

      }
      
      disp as txt `"R code chunk (`chunk_title') detected"'


      // Create dirs if not exist
      
      qui cap mkdir "`srcpath'"
      qui cap mkdir "`rparent'"
      qui cap mkdir "`datapath'"
      qui cap mkdir "`outpath'"
      qui cap mkdir "`figpath'"

      // Save the data on memory
      
      local datafilename = "st_`dofilenosuffix'_`chunk_title'.dta"
      mata: st_local("datafilepath", pathjoin("`datapath'", "`datafilename'"))
      qui save "`datafilepath'", replace 

      disp as txt `"Data for the chunk saved in `datafilepath'"'

      // Extract the R chunk

      local rfilename = "st_`dofilenosuffix'_`chunk_title'.R" 
      mata: st_local("rfilepath", pathjoin("`rparent'", "`rfilename'"))

      qui file open rfile using "`rfilepath'", write replace
      
      file write rfile "## This file was written by running `do'." _n
      file write rfile "" _n(2)
      file write rfile "## Read the data from Stata" _n
      file write rfile `"data <-"' _n
      file write rfile _col(2) `"haven::read_dta("' _n
      file write rfile _col(4) `""`datafilepath'""' _n
      file write rfile _col(2) ")" _n
      file write rfile "" _n(3)

      file read dofile line

      while `"`line'"' != "~~~" {
      
        file write rfile `"`line'"' _n

        file read dofile line

      }

      qui file close rfile

      disp as txt `"`rfilepath' written"'
      
      continue, break

    }
    
    file read dofile line 

  }

  if r(eof) != 0 {
    file close dofile
  }


  // Create a temp R file to run the R file above

  tempname rtemp

  mata: st_local("r_temppath", pathjoin(pwd(), "`rtemp'.R"))

  qui file open rtmp using "`r_temppath'", write replace

  file write rtmp `"source("`rfilepath'", echo = TRUE)"' _n
  file write rtmp _n
  file write rtmp "obj_data <-" _n
  file write rtmp "ls()[" _n
  file write rtmp "sapply(" _n
  file write rtmp "lapply(" _n
  file write rtmp "lapply(" _n
  file write rtmp "lapply(" _n
  file write rtmp "ls(), as.symbol" _n
  file write rtmp ")," _n
  file write rtmp "eval)," _n
  file write rtmp "class)," _n
  file write rtmp `"function(x) "data.frame" %in% x)]"' _n
  file write rtmp `"haven::write_dta(eval(as.symbol(obj_data)), "`datafilepath'")"'
  
  file close rtmp
 
  // Run the R code
  // Any side effects will be printed or saved
  // One data frame should be returned
  // The returned data frame will be loaded on Stata memory

  shell `rpath' `r_temppath'

  erase "`r_temppath'"

  qui use "`datafilepath'", clear

  disp as txt "New dataset from the R code retrieved"

end
