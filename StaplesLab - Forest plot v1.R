###############################################################################
# This work is licensed under CC BY-NC-SA 4.0. To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/4.0/
# Suggested citation: Staples JA. Staples lab forest plot template. 2023 Apr 4. Retrieved from: ***LINK***
# Filename: "StaplesLab - Forest plot v1.R"
# Staples Lab R code for forest / tornado plots
# Author: John A Staples
# Date: 2023-04-04
# Updated: 2023-04-04
###############################################################################
# Load packages, working directory, Staples Lab ggplot theme
# source("~/Documents/2016 - UBC projects/ ... ")



###############################################################################
# The following assumes you have a tibble "results.subgroups" with the following column names:
## subgroup_name
## strata_name
## Case 
## Control 
## estimate 
## conf.low 
## conf.high      
## p.value 
## std.error




###############################################################################
# Set up labels for the tornado plot

# This can be used to export your groups, modify the names, indenting, bolding etc in Excel, then re-import (this is easier than coding it in R)
# results.subgroups %>%
#  select(subgroup_name, strata_name) %>%
#  export("../data/Project - Subgroups tornado plot labels v1.xlsx")

label_data <- import("../data/Project - Subgroups tornado plot labels v1 (modified).xlsx") %>%
  tibble() %>%
  mutate(label = if_else(indent_nobold == 1, paste0("     ", strata_name), strata_name),
         fontface = ifelse(indent_nobold == 0, "bold", "plain"))

subgroup_tornado_data <- left_join(label_data %>%
                                     select(-subgroup_name),
                                   results.subgroups,
                                   by = "strata_name") %>%
  mutate(label = factor(label, levels = rev(label_data$label))) 




###############################################################################
# Create main tornado plot
subgroup_tornado_data_main <- subgroup_tornado_data %>% 
  filter(main_forest == 1)

ggplot(dat = subgroup_tornado_data_main) +
  geom_hline(yintercept=1, lty=2) + 
  geom_linerange(aes(x = label, ymin = conf.low, ymax = conf.high, colour = subgroup_name)) + 
  geom_point(aes(x = label, y = estimate, colour = subgroup_name, size = 1/std.error), shape = 15) + 
  coord_flip() + 
  labs(x = "", y = "Odds ratio") +
  scale_y_continuous(trans="log",
                     breaks=c(0.2,0.25,0.33,0.5,1.0,2.0,3.0,4.0,5.0),
                     limits=c(0.33,3)) +
  scale_colour_viridis_d(direction = -1, begin = 0, end = 0.8) +
  theme_stapleslab + 
  theme(axis.ticks.y = element_blank(),
        axis.text.y = element_text(face = if_else(rev(subgroup_tornado_data_main$fontface) == "bold", "bold", "plain"),
                                   colour = if_else(rev(subgroup_tornado_data_main$space) == 0, "black", "white"),
                                   margin = margin(0,0,0,0),
                                   hjust = 0)) + 
  guides(size = "none",
         colour = "none") 
ggsave(paste0("Project - Subgroup forest plot - ", today(), ".pdf"), width=10, height = nrow(subgroup_tornado_data_main)*0.20 + 2.5, units="in", dpi = 300)







