###########################################################
# This work is licensed under CC BY-NC-SA 4.0. To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/4.0/
# Suggested citation: Erdelyi S, Daly-Grafstein D, Yu Y, Khan M, Staples JA. R code to read in vital statistics deaths. 2023 Apr 13. Retrieved from: ***LINK***
# Filename: "Staples Lab - Read in Vital Statistics-deaths v1.R"
# Read deaths (vital statistics) obtained from PopDataBC, Canada
# Authors: Shannon Erdelyi, Daniel Daly-Grafstein, Ying (Daisy) Yu, John Staples
# Date: 2022-02-16
# Updated: 2023-04-13
##########################################################

# For this function you need to specify the following items (I've given examples here):
## deaths_dd_path <- ""                 # file path for data dictionary
## deaths_dir <- " "                    # file path for the folder of data files
# Because 2017 seems to be in a separate folder and perhaps has a separate data dictionary, 
# you need to run this source file twice, the second time with these updated file paths/directories:
## deaths_dd_path_2017 <- "FILEPATH/data_dictionary_vital-statistics-deaths.xlsx"
## deaths_dir_2017 <- "FILEPATH/deaths2017.B.dat.gz"
## ... you then need to bind_rows( the two death files



##########################################################
# deaths data dictionary
(deaths_dd <- read_xlsx(deaths_dd_path, 
                 sheet = "deaths.B") %>%
   filter(!Name %in% "Line Feed") %>%
   select(col_width = Length, col_name = `Name Abbrev`))


(files <- paste0(deaths_dir,
                 list.files(deaths_dir, pattern=".B")))
(death <- map_dfr(files, function(f){
  
  read_fwf(f, 
           col_positions = fwf_widths(widths = deaths_dd$col_width, 
                                      col_names = deaths_dd$col_name),
           col_types = cols(.default = "c"))
  
}))



