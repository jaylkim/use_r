*! version 0.0.0.9000 Jay Kim 04feb2021

/***

_version 0.0.0.9000_


use_r
=====


Description
-----------

This command does the following:

1. Detects an R code chunk right after its call and creates an __.R__ file.

2. Saves the data on memory so that the R file can use it.

3. Runs the R file.

4. Prints any side effects other than figures and tables.

5. Saves figures tables.

6. Returns one _data.frame_-like object (e.g. _tibble_). 


Syntax
------

> use_r, _do(path/to/do.do)_ _**r**path(path/to/r)_


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
        
        disp as err "Chunk title not provided."
        
        local current_d = subinstr(c(current_date), " ", "", .)
        local current_t = subinstr(c(current_time), ":", "", .) 

        local chunk_title = ("`current_d'" + "_" + "`current_t'")
        local chunk_title = ("`chunk_title'" + char(runiformint(97, 122)))
        local chunk_title = ("`chunk_title'" + char(runiformint(97, 122)))
        local chunk_title = ("`chunk_title'" + char(runiformint(97, 122)))

        disp as txt "Chunk title created based on the current date-time"

      }
      
      disp `"R code chunk (`chunk_title') Detected."'


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

      disp `"Data for the chunk saved in `datafilepath'."'

      // Extract the R chunk

      local rfilename = "st_`dofilenosuffix'_`chunk_title'.R" 
      mata: st_local("rfilepath", pathjoin("`rparent'", "`rfilename'"))

      qui file open rfile using "`rfilepath'", write replace
      
      file write rfile "## This file was written by running `do'." _n
      file write rfile "" _n 
      file write rfile `"data <- haven::read_dta("`datafilepath'")"' _n

      file read dofile line

      while `"`line'"' != "~~~" {
      
        file write rfile `"`line'"' _n

        file read dofile line

      }

      qui file close rfile

      disp `"`rfilepath' written."'
      
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

  disp "`rfilepath'"

  file open rtmp using "`r_temppath'", write replace

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

  disp "New dataset from the R code retrieved"

end
