###########################################################
# This work is licensed under CC BY-NC-SA 4.0. To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/4.0/
# Suggested citation: Erdelyi S, Daly-Grafstein D, Yu Y, Staples JA. R code to read in PharmaNet. 2024 Apr 14. Retrieved from: ***LINK***
# Filename: "Staples Lab - Read in PNet (health prod) v1.R"
# Read PharmaNet (health product info; maps dinpin to drug brand, dose, etc.)
## Note there is separate read in code for PNet (medications dispensed)
# Authors: Shannon Erdelyi, Daniel Daly-Grafstein, Ying (Daisy) Yu, John Staples
# Date: 2022-02-16
# Updated: 2023-04-14

##########################################################


# Specify file path to data dictionary and the data file directory in the main code file that calls this source file, eg.
## pnet_hp_dd_path <- ""     # file path for data dictionary
## pnet_hp_file <- ""        # data file format: .dat.gz ; file path for the folder of data files



##########################################################
# Health product information

(dd_hp <- read_xlsx(pnet_hp_dd_path,
                    sheet = "hlth_rpt.A") %>%
   filter(!Name %in% "Line Feed") %>%
   select(col_width = Length, col_name = `Name Abbrev`))


(pnet_hp <- read_fwf(pnet_hp_file,
                         col_positions = fwf_widths(widths = dd_hp$col_width,
                                                    col_names = dd_hp$col_name),
                         col_types = cols(.default = "c")))




