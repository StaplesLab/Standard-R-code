###########################################################
# This work is licensed under CC BY-NC-SA 4.0. To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/4.0/
# Suggested citation: Erdelyi S, Daly-Grafstein D, Yu Y, Staples JA. R code to read in PharmaNet (medication dispensed). 2023 Apr 14. Retrieved from: ***LINK***
# Filename: "Staples Lab - Read in PNet (meds dispensed) v2.R"
# Read PharmaNet (medications dispensed)
## Note there is separate read in code for PNet (health product info)
# Authors: Shannon Erdelyi, Daniel Daly-Granfstein, Ying (Daisy) Yu, John Staples
# Date: 2022-02-16
# Updated: 2023-04-14

##########################################################


# Specify file path to data dictionary and the data file directory in the main code file that calls this source file, eg.
## pnet_dd_path <- ""
## file.dir <- paste0('R:/DATA/2023-02-27_110931/pharmanet/dsp_rpt.dat_0',c(1:7),'.dat.gz')  # file path for the folder of data files; file format: .dat.gz 
## cohort_studyids <- unique(coh_ids$STUDYID)


##########################################################
# Medications dispensed

# get data dictionary
(pnet_dd <- read_xlsx(pnet_dd_path, 
                 sheet = "dsp_rpt.A") %>%
   filter(!Name %in% "Line Feed") %>%
   select(col_width = Length, col_name = `Name Abbrev`))


# use for loops - map functions caused memory error
pnet_lst <- list()

for(i in 1:length(file.dir)){
  print(paste("reading chunk", i, "out of", length(file.dir)))
  
  pnet_chunk <- tryCatch({
    # read data
    read_fwf(file.dir[i], fwf_widths(widths=pnet_dd$col_width, col_names=pnet_dd$col_name),
             col_types=cols(.default="c")) %>% 
      as_tibble() %>% 
      select(-DE_PR_PRAC.PRSCR_PRAC_LIC_BODY_IDNT, -DE_PR_INFO.PRSCR_SPTY_FLG,           #-DE.CLNT_GENDER_LABEL,
             -DE_PR_INFO.RCNT_CLG_SPTY_1_LABEL, -DE_PR_INFO.RCNT_CLG_SPTY_2_LABEL) %>%
      filter(DE.STUDYID %in% cohort_studyids) %>%
      distinct() 
  }, error=function(e){
    NULL
  })
  pnet_lst[[i]] <- pnet_chunk
  pnet_chunk <- NULL
}


pnet <- as_tibble(do.call("rbind", pnet_lst)) %>% distinct()
beep()

variable.names(pnet)
pnet <- pnet %>% select(DE.STUDYID, DE.HLTH_PROD_LABEL, DE.SRV_DATE, DE.DSPD_DAYS_SPLY)

now() 



