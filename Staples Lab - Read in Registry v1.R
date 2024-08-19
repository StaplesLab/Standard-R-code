###########################################################
# This work is licensed under CC BY-NC-SA 4.0. To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/4.0/
# Suggested citation: Erdelyi S, Daly-Grafstein D, Yu Y, Staples JA. R code to read in registry. 2023 Apr 12. Retrieved from: ***LINK***
# Filename: "Staples Lab - Read in Registry v1.R"
# Read in registry
# Author: Shannon Erdelyi, Daniel Daly-Grafstein, Ying (Daisy) Yu, John Staples
# Date: 2022-02-16
# Updated: 2023-04-12

##########################################################
# You need to ensure you've got the correct libraries and that you state which types of census geodata are available for the project. For example:
# library("tidyverse")
# library("readxl")
# reg_dd_path <- ""   # file path for data dictionary
# reg_dir <- ""       # file path for the folder of data files
# These should be specified in the code file that calls this code file using a source command


# get data dictionary
(reg_dd <- read_xlsx(reg_dd_path, 
                 sheet = "registry.C") %>%
    filter(!Name %in% "Line Feed") %>%
    select(col_width = Length, col_name = `Name Abbrev`))


# for all files
(files <- paste0(reg_dir,
                     list.files(reg_dir, pattern=".C")))
(reg <- map_dfr(files, function(f){
  
  read_fwf(f, 
           col_positions = fwf_widths(widths = reg_dd$col_width, 
                                      col_names = reg_dd$col_name),
           col_types = cols(.default = "c"))
  
}))

