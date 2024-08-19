#####################################################################################
# This work is licensed under CC BY-NC-SA 4.0. To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/4.0/
# Suggested citation: Staples JA. Staples lab theme. 2022 May 4. Retrieved from: ***LINK***
# Filename: "Staples Lab - ggplot theme - 2022-04-29.R"
# ggplot: theme_stapleslab
# Authors: John A Staples
# Created: 2022-04-29
# Revised: 2022-05-04
#####################################################################################

library(tidyverse)

theme_stapleslab <- theme_bw() +
  theme(
    legend.background = element_blank(),
    legend.box.background = element_rect(colour = "grey30"),
    panel.border = element_rect(size = 1.25, colour = "grey30", fill = NA),
    axis.text = element_text(size = 16),
    axis.title = element_text(size = 18, face = "bold"),
    panel.grid = element_blank(),
    axis.line = element_line(size = 0.5, colour = "grey30"),
    axis.ticks = element_line(size = 0.5, colour = "grey30"),
    axis.title.x = element_text(vjust= -0.5),
    axis.title.y = element_text(vjust= +1.75),
    plot.margin = margin(t=20,r=20,b=20,l=20))
