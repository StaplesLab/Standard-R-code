###########################################################
# This work is licensed under CC BY-NC-SA 4.0. To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/4.0/
# Suggested citation: Erdelyi S, Daly-Grafstein D, Yu Y, Staples JA. R code to read in demographics. 2023 Apr 10. Retrieved from: ***LINK***
# Filename: "Staples Lab - Read in demographics v2.R"
# Read demographics data obtained from PopDataBC, Canada
# Author: Shannon Erdelyi, Daniel Daly-Grafstein, Ying (Daisy) Yu, John Staples
# Date: 2022-02-16
# Updated: 2023-04-10

##########################################################

# get data dictionary
(dd <- read_xlsx(demo_dd_path, 
                 sheet = "demographics.B") %>%
    filter(!Name %in% "Line Feed") %>%
    select(col_width = Length, col_name = `Name Abbrev`))

(demo <- read_fwf(demo_file_path, 
                     col_positions = fwf_widths(widths = dd$col_width, 
                                                col_names = dd$col_name),
                     col_types = cols(.default = "c")))

