###########################################################
# This work is licensed under CC BY-NC-SA 4.0. To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/4.0/
# Suggested citation: Erdelyi S, Daly-Grafstein D, Yu Y, Khan M, Staples JA. R code to read in census geodata. 2023 Apr 12. Retrieved from: ***LINK***
# Filename: "Staples Lab - Read in census geodata v1.R"
# Read in census geodata obtained from PopDataBC, Canada
# Author: Shannon Erdelyi, Mayesha Khan, Daniel Daly-Grafstein, Ying (Daisy) Yu, John Staples
# Date: 2022-02-16
# Updated: 2023-04-12
##########################################################
# You need to ensure you've got the correct libraries, and that you set the types of census geodata and the files paths for the project. For example:
# library("tidyverse")
# library("readxl")
# types <- c(".B", ".C", ".D", ".G", ".H", ".I")     # each filename has a letter suffix
# cen_dd_path <- ""                                  # file path for the folder of data files
# cen_dir <- ""                                      # file path for the folder of data files
# These should be specified in the code file that calls this code file using a source command (because they will change with each project)


# read data by version
(census <- map_dfr(types, function(t){
  
  #### (t <- types[1])  ### FOR TESTING
  
  # get data dictionary
  (cen_dd <- read_xlsx(cen_dd_path, 
                   sheet = paste0("censusgeodata", t)) %>%
     filter(!Name %in% "Line Feed") %>%
     select(col_width = Length, col_name = `Name Abbrev`))
  
  # list all data files for version of interest
  (file_dirs <- paste0(cen_dir, 
                       list.files(cen_dir, pattern = t)))
  
  # read files 
  map_df(file_dirs, function(fd){
    
    #### (fd <- file_dirs[1])  ### FOR TESTING
    
    read_fwf(fd, col_positions = fwf_widths(widths = cen_dd$col_width, 
                                            col_names = cen_dd$col_name),
             col_types = cols(.default = "c"))
    
  })
  
}))
