###########################################################
# This work is licensed under CC BY-NC-SA 4.0. To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/4.0/
# Suggested citation: Erdelyi S, Daly-Grafstein D, Yu Y, Staples JA. R code to read in MSP practitioner data. 2022 Nov 18. Retrieved from: ***LINK***
# FIlename: "StaplesLab - read-msp-pract.R"
# Read MSP - Practitioner obtained from PopDataBC, Canada
# Author: Shannon Erdelyi, DDG, YY
# Date: 2022-02-16
# Updated: 2022-11-18

##########################################################

# libraries
library(tidyverse)
library(readxl)


# list versions
types <- c(".A", ".B")

# read data by version
 (msp_p <- map_dfr(types, function(t){
  
  #### (t <- types[1])  ### FOR TESTING
  
  # get data dictionary (the variable names varied between sheets in the original)
  # use dd with same variable names in both sheets
 (dd <- read_xlsx("",            # enter file path for data dictionary 
                 sheet = paste0("mspprac", t)) %>%
    filter(!Name %in% "Line Feed") %>%
    select(col_width = Length, col_name = `Name Abbrev`))


  # list all data files for version of interest
  (file_dirs <- paste0("R:/DATA/2018-07-10/msp-prac/", 
                     list.files("R:/DATA/2018-07-10/msp-prac", pattern = paste0("\\", t), ignore.case = F )))

  # read files 
  map_df(file_dirs, function(fd){
  
  #### (fd <- file_dirs[1])  ### FOR TESTING
  
  read_fwf(fd, col_positions = fwf_widths(widths = dd$col_width, 
                                          col_names = dd$col_name),
           col_types = cols(.default = "c"))
  
})

}))


data <- msp_p


##########################################################
# Return data
##########################################################

# set all other objects to NULL
#type <- msp_p <- NULL

# output data at end of code for reading from source
data

msp_p <- data

write.csv(msp_p, "FILENAME.csv", row.names = FALSE)  # enter file path for final saved file; format .csv



