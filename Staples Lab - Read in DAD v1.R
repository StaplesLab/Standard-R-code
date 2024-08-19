###########################################################
# This work is licensed under CC BY-NC-SA 4.0. To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/4.0/
# Suggested citation: Erdelyi S, Daly-Grafstein D, Yu Y, Staples JA. R code to read in discharge abstract database. 2023 Apr 10. Retrieved from: ***LINK***
# Filename: "Staples Lab - Read in DAD v1.R"
# Read Discharge Abstract Database (DAD), obtained from PopDataBC, Canada.
# Authors: Shannon Erdelyi, Daniel Daly-Grafstein, John Staples
# Date: 2022-02-16
# Updated: 2023-04-10
##########################################################

# For this function you need to specify the following items (I've given examples here)
## types <- c(".A", ".G", ".H", ".O")
## dad_dd_path <- ""                  # file path for data dictionary
## dad_dir <- ""                      # file path for the folder of data files


# read data by version
(hosp <- map_dfr(types, function(t){
  
  #### (t <- types[1])  ### FOR TESTING
  
  # get data dictionary
  (dad_dd <- read_xlsx(dad_dd_path, 
                   sheet = paste0("hospital", t)) %>%
     filter(!Name %in% "Line Feed") %>%
     select(col_width = Length, col_name = `Name Abbrev`))
  
  # list all data files for version of interest
  (file_dirs <- paste0(dad_dir, 
                       list.files(dad_dir, pattern = paste0("\\", t), ignore.case = F )))
  
  # read files 
  map_df(file_dirs, function(fd){
    
    #### (fd <- file_dirs[1])  ### FOR TESTING
    
    read_fwf(fd, col_positions = fwf_widths(widths = dad_dd$col_width, 
                                            col_names = dad_dd$col_name),
             col_types = cols(.default = "c"))
    
  })
  
}))

