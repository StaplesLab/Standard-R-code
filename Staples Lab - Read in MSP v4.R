###########################################################
# This work is licensed under CC BY-NC-SA 4.0. To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/4.0/
# Suggested citation: Erdelyi S, Daly-Grafstein D, Yu Y, Staples JA. R code to read in MSP. 2023 Apr 14. Retrieved from: ***LINK***
# Filename: "Staples Lab - Read in MSP v4.R"
# Read Medical Services Plan (MSP), obtained from PopDataBC, Canada
# Authors: Shannon Erdelyi, Daniel Daly-Grafstein, Ying (Daisy) Yu, John Staples
# Date: 2022-02-16
# Updated: 2023-04-14

##########################################################

# Specify file information for your project in the project-specific code that calls this source file. For example:
## Get the number of records in each file from the data release txt file
# msp_dd_path <- ""   # file path for data dictionary
# msp_dir <- ""       # file path for the folder of data files
# fileNames <- c(list.files(msp_dir))      
# file.sizes <- c(          # add here the number of records in each file (sorted by year in this dataset)
#   # 2001-2010
#   23299740,80734341,66913187,55012559,57131658,82774099,142137663,103139946, 67009790,67694021,
#   # 2011-2016
#   68927629,89883596,81069453,105703477,83875479,71585816) 
# # Read in data dictionary
# msp_dd <- read_xlsx(msp_dd_path, sheet = "msp.C") %>%
#   filter(!Name %in% "Line Feed") %>%
#   select(col_width = Length, col_name = `Name Abbrev`)


# Read in data in chunks (otherwise it's too large)
readRow <- 10000000  ## read 10 million rows at a time
# create chunks to read in file
file.cuts <- lapply(file.sizes, function(x) seq(0, x, by = readRow))

# use for loops - map functions caused memory error
msp_lst <- list()

for(i in 1:length(fileNames)){
  fileName <- fileNames[i]
  file.cut <- file.cuts[[i]]
  print(paste(fileName, "with", file.sizes[i], "records"))
  
  msp_file_lst <- list()
  index <- 1
  getF <- paste0(msp_dir, fileName)
  
  for(j in 1:length(file.cut)){
    print(paste("reading chunk", j, "out of", length(file.cut)))
    
    msp_chunk <- tryCatch({
      # read data
      read_fwf(getF, fwf_widths(widths=msp_dd$col_width, col_names=msp_dd$col_name),
               col_types=cols(.default="c"),
               n_max=readRow, skip=file.cut[j]) %>% 
        as_tibble() %>%
        
        select(STUDYID, servdate, servloc, "pracnum*", spec, contains("icd9")) %>%     #feeitem
        unite("icd_all", contains("icd9"), na.rm = TRUE, sep = "_, _") %>% 
        mutate(icd_all = paste0("_", icd_all, "_")) %>% 
        mutate(servdate = ymd(servdate)) %>%
        filter(STUDYID %in% coh_id_temp$STUDYID) %>% 
        distinct() # discard duplicate rows with same studyid, servicedate, and icd codes
    }, error=function(e){
      NULL
    })
    
    if(!is.null(msp_chunk)){
      msp_file_lst[[index]] <- msp_chunk
      index <- index + 1
    } 
    
  }
  
  msp_file <- as_tibble(do.call("rbind", msp_file_lst)) %>% distinct()
  msp_lst[[i]] <- msp_file
}


# bind all years of visits together
msp <- as_tibble(do.call("rbind", msp_lst)) %>% distinct() 






