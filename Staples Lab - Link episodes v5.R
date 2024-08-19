#############################################
# This work is licensed under CC BY-NC-SA 4.0. To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/4.0/
# Suggested citation: Erdelyi S,  Daly-Grafstein D, Yu Y, Staples JA. Link episodes of care. 2023 Jul 11. Retrieved from: ***LINK***
# Filename: "Staples Lab - Link episodes v5.R"
# Link episodes of care
# Author: Shannon Erdelyi, Daniel Daly-Grafstein, Ying (Daisy) Yu, John Staples
# Date: 2022-12-08
# Updated: 2023-07-11
#############################################

# Mandatory inputs to read DAD function:
#   - DAD data table: this table should include columns STUDYID, ADDATE, SEPDATE,
#     SEPDISP, HOSPTO*, HOSPFROM*
#         - note SEPDISP is only needed for DT_1day_transfer and DT_1day_transfer_hosp
#         - HOSPTO* and HOSPFROM* only needed for DT_1day_transfer_hosp


# Optional inputs to read DAD function:
#   - filter_record_num: Flag, if TRUE, filter out duplicates using RECRDNUM flag in DAD data
#                       Note if set to TRUE but no RECRDNUM column in DAD data, will throw an error
#                       Default is FALSE. If FALSE, filters duplicates by removing duplicates of
#                       STUDYID, ADDATE, SEPDATE
#   - episodes_of_care: parameter to decide how to create episodes of care. If episodes_of_care = "DT_1day", 
#     an episode of care is created by combining
#     records for a individual if less than or equal to 1 day between admission and prior discharge date.
#     If episodes_of_care = "DT_1day_transfer, criteria as previous + need a transfer flag in the SEPDISP
#     column (SEPDISP == "01" | SEPDISP == "10" | SEPDISP == "20). 
#     If episodes_of_care = "DT_1day_transfer_hosp", criteria as previous +
#     need the HOSPTO* and HOSPFROM* ID columns to match between transfers. If episodes_of_care = "all"
#     create episodes according to all 3 criteria.
#     Default is episodes_of_care = "DT_1day"

#dd_path <- "R:/DATA/2018-06-20/docs/data_dictionary_discharge-abstracts-database.xlsx"
#types <- c("G", "H", "N")
#dad_dir <- "R:/DATA/2018-06-20/hospital/"

#date_start <- as.Date("2002-03-01")
#date_end <- as.Date("2017-01-31")
#study_ids <- c([study IDs here])
#study_ids <- NULL
#cols_select <- c("fileName", "STUDYID", "ADDATE", "SEPDATE", 
#                 "HOSPTO*", "HOSPFROM*",
#                 "TDAYS", "SEPDISP", paste0("DIAGX", 1:25))
#filter_record_num <- FALSE
#episodes_of_care <- "DT_1day"

create_episodes <- function(data, filter_record_num = F,
                          episodes_of_care = "DT_1day"){
  
  # filter out duplicates
  if(filter_record_num == TRUE){
    if(!"RECRDNUM" %in% names(data)){
      stop("Cannot filter by RECRDNUM because column isn't present in data
       Either include RECRDNUM in selected cols, or set 'filter_record_num = F'")
    }
    data <- data[!duplicated(data$RECRDNUM),]
  } else{
    # remove duplicates of studyid, admission date, discharge date
    data <- data[!duplicated(data[,c("STUDYID", "ADDATE", "SEPDATE")]),]
    
    #data <- data %>% 
    #  group_by(STUDYID, ADDATE, SEPDATE) %>% 
    #  summarise(across(everything(), function(x) ifelse(all(is.na(x)), NA, (na.omit(x)[1])))) %>% 
    #  ungroup()
  }
  
  # coerce ADDATE, SEPDATE to DATE 
  tryCatch({
    data <- data %>% mutate(ADDATE = as.Date(ADDATE),
                            SEPDATE = as.Date(SEPDATE)) 
    }, error = function(x){ stop("ADDATE or SEPDATE cannot be coerced to date values")})
  
  # create episodes of care
  if(!episodes_of_care %in% c("DT_1day", "DT_1day_transfer", "DT_1day_transfer_hosp", "all")) {
    stop("episodes_of_care parameter not set to one of DT_1day, DT_1day_transfer, DT_1day_transfer_hosp, all")
  } else if(episodes_of_care == "DT_1day") {
    # nested/overlapping hospital admissions by >1 day
    # OR up to 1-day diff between admit vs prior discharge date
    data <- data %>% 
      group_by(STUDYID) %>% 
      arrange(STUDYID, SEPDATE, .by_group=TRUE) %>%
      mutate(DT_1day = replace_na(as.numeric(as.Date(ADDATE) > (lag(as.Date(SEPDATE)) + 1)), 1)) %>% 
      ungroup() %>% 
      mutate(episode_of_care = cumsum(DT_1day)) %>% 
      select(-DT_1day)
  } else if(episodes_of_care == "DT_1day_transfer"){
    # nested/overlapping hospital admissions by >1 day
    # OR up to 1-day diff between admit vs prior discharge date
    # AND transfer flag present
    data <- data %>% 
      group_by(STUDYID) %>% 
      arrange(STUDYID, SEPDATE, .by_group=TRUE) %>%
      mutate(DT_1day_transfer = replace_na(as.numeric((ADDATE > (lag(SEPDATE) + 1)) |
                                                        (!lag(SEPDISP) %in% c("01","10","20"))), 1)) %>% 
      ungroup() %>% 
      mutate(episode_of_care = cumsum(DT_1day_transfer)) %>% 
      select(-DT_1day_transfer)
  } else if(episodes_of_care == "DT_1day_transfer_hosp"){
    # nested/overlapping hospital admissions by >1 day
    # OR up to 1-day diff between admit vs prior discharge date
    # AND transfer flag present
    # AND HOSPTO* ID in record transferring patient 
    # equals HOSPFROM* ID in record receiving transferred patient
    data <- data %>% 
      group_by(STUDYID) %>% 
      arrange(STUDYID, SEPDATE, .by_group=TRUE) %>%
      mutate(DT_1day_transfer_hosp = replace_na(as.numeric((ADDATE > (lag(SEPDATE) + 1)) |
                                                             (!lag(SEPDISP) %in% c("01","10","20")) |
                                                             (lag(`HOSPTO*`) != `HOSPFROM*`)), 1)) %>% 
      ungroup() %>% 
      mutate(episode_of_care = cumsum(DT_1day_transfer_hosp)) %>% 
      select(-DT_1day_transfer_hosp)
  } else{
    #create using all three criteria
    data <- data %>% 
      group_by(STUDYID) %>% 
      arrange(STUDYID, SEPDATE, .by_group=TRUE) %>%
      mutate(DT_1day = replace_na(as.numeric(ADDATE > (lag(SEPDATE) + 1)), 1),
             DT_1day_transfer = replace_na(as.numeric((ADDATE > (lag(SEPDATE) + 1)) |
                                                        (!lag(SEPDISP) %in% c("01","10","20"))), 1),
             DT_1day_transfer_hosp = replace_na(as.numeric((ADDATE > (lag(SEPDATE) + 1)) |
                                                             (!lag(SEPDISP) %in% c("01","10","20")) |
                                                             (lag(`HOSPTO*`) != `HOSPFROM*`)), 1)) %>% 
      ungroup() %>% 
      mutate(episode_care_DT_1day = cumsum(DT_1day),
             episode_care_DT_1day_transfer = cumsum(DT_1day_transfer),
             episode_care_DT_1day_transfer_hosp = cumsum(DT_1day_transfer_hosp)) %>% 
      select(-c(DT_1day, DT_1day_transfer, DT_1day_transfer_hosp))
    
  }
  
  return(data)
  
}




