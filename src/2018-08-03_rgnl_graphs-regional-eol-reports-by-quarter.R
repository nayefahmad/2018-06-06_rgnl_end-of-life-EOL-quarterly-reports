


#*******************************************************
# GRAPHS FOR REGIONAL EOL REPORT
#*******************************************************

library("here")
library("ggpubr")

# rm(list = ls())

# read in data: 
source(here("src", 
            "2018-07-27_rgnl_eol-deaths-and-acute-deaths-by-quarter.R"))


# todo: ---------
# > captions, fix axis of p2, onwards, capitalize axis title


#******************************************************
# 1) plotting trend components of acute deaths : ---------------
#******************************************************
p1.trends <- 
      # prep data: 
      unnest(df1.deaths.data, deaths.stl) %>% 
      as.data.frame() %>% 
      filter(!is.na(area)) %>% 
      
      # join to get quarter numbers: 
      inner_join(unnest(df1.deaths.data, data)) %>% 
      
      # create plot: 
      ggplot() + 
      
      # deaths trend
      geom_line(aes(x = quarter, 
                    y = trend,
                    colour = "Deaths trend", 
                    group = 1), 
                size = 1) +  
      
      facet_wrap(~area) + 
      
      # deaths data: 
      geom_line(aes(x = quarter, 
                    y = data,
                    colour = "Deaths", 
                    group = 1), 
                size = 0.1) +
      
      
      # acute deaths trend
      geom_line(data = unnest(df1.deaths.data, acutedeaths.stl) %>% 
                      filter(!is.na(area)) %>% 
                      inner_join(unnest(df1.deaths.data, data)), 
                aes(x = quarter, 
                    y = trend,
                    colour = "Acute Deaths trend", 
                    group = 1), 
                size = 1.0) + 
      
      # acutedeaths data: 
      geom_line(data = unnest(df1.deaths.data, acutedeaths.stl) %>% 
                      filter(!is.na(area)) %>% 
                      inner_join(unnest(df1.deaths.data, data)),  
                aes(x = quarter, 
                    y = data,
                    colour = "Acute Deaths",
                    group = 1), 
                size = 0.1) +
      
      
      # scaless:
      scale_color_manual(values = c("lightpink", 
                                    "red", 
                                    "grey70", 
                                    "black")) + 
      scale_x_discrete(breaks = quarter.labels) + 
      
      labs(title = "Deaths and acute deaths, by COC",
           subtitle = paste0(min.quarter, " to ", max.quarter), 
           y = "Number of deaths", 
           x = "Quarter", 
           caption = paste0("Data Sources: VCH Decision Support DAD (ADRMart), ED (EDMart), PARIS (CommunityMart) Data Views\n", "Extracted ", Sys.Date(), "\nReport Contact: kenneth.hawkins@vch.ca")) + 
      guides(colour = guide_legend("")) +  # remove legend title
      
      theme_classic(base_size = 12) + 
      theme(plot.caption = element_text(size = 8),
            axis.text.x = element_text(angle = 90)); p1.trends



# 2) plotting seasonal components: ---------------
p2.seasonal <- 
      # prep data: 
      unnest(df1.deaths.data, deaths.stl) %>% 
      as.data.frame() %>% 
      filter(!is.na(area)) %>% 
      
      # join to get quarter numbers: 
      inner_join(unnest(df1.deaths.data, data)) %>% 
      
      # create plot: 
      ggplot(aes(x = quarter, 
                 y = seasonal)) + 
      
      # deaths 
      geom_line(aes(colour = "Deaths", 
                    group = 1)) +  
      
      # acute deaths: 
      geom_line(data = unnest(df1.deaths.data, acutedeaths.stl) %>% 
                      filter(!is.na(area)) %>% 
                      inner_join(unnest(df1.deaths.data, data)), 
                aes(colour = "Acute Deaths", 
                    group = 1)) + 
      
      geom_hline(yintercept = 0, 
                 colour = "grey70", 
                 size = 0.2) + 
      
      facet_wrap(~area) + 
      
      scale_x_discrete(breaks = quarter.labels) + 
      scale_color_manual(values = c("red", "black")) + 
      labs(title = "Seasonal components of deaths and acute deaths, by COC",
           subtitle = paste0(min.quarter, " to ", max.quarter),
           y = "number of deaths", 
           x = "quarter") + 
      
      guides(colour = guide_legend("")) +  # remove legend title
      
      theme_classic(base_size = 12); p2.seasonal







# 3) plotting measure values: % acute deaths ----------------
p3.measures.and.targets <- 
      # prep data: 
      unnest(df1.deaths.data, data) %>% 
      filter(!is.na(area)) %>% 
      melt %>% 
      filter(variable %in% c("measure", "target")) %>% 
      
      # plot data: 
      ggplot(aes(x = quarter, 
                 y = value, 
                 group = variable)) + 
      geom_line(aes(colour = variable), 
                size = 1) + 
      
      facet_wrap(~area, 
                 nrow = 1) + 
      
      # scales: 
      scale_colour_manual(values = c("grey60",
                                     "dodgerblue")) + 
      scale_y_continuous(limits = c(0, 1.0), 
                         breaks = seq(0, 1, 0.2)) + 
      scale_x_discrete(breaks = quarter.labels) +
      
      # labs: 
      labs(# title = "Regional End of Life Reporting \n% of overall hospital deaths for clients known to VCH Community \nprograms", 
           # subtitle = paste0(min.quarter, " to ", max.quarter), 
           y = "Proportion", 
           x = "Quarter") + 
      
      guides(colour = guide_legend("")) +  # remove legend title
      
      
      theme_classic(base_size = 12) + 
      theme(plot.caption = element_text(size = 8),
            axis.text.x = element_text(angle = 90)); p3.measures.and.targets


#******************************************************************
# > VCH LEVEL GRAPH: ---------
#******************************************************************
p3.1.measures.and.targets.vch <- 
      # prep data: 
      unnest(df1.deaths.data, data) %>% 
      filter(!is.na(area)) %>%
      group_by(quarter) %>%
      summarize(deaths = sum(deaths), 
                acutedeaths = sum(acutedeaths)) %>% 
      mutate(measure = round(acutedeaths/deaths, 2), 
             area = "VCH") %>% 
      inner_join(df2.targets) %>%
      melt %>% 
      mutate(variable = factor(variable, 
                               levels = c("target", "measure"))) %>% 
      filter(variable %in% c("measure", "target")) %>% 
      
      # plot
      ggplot(aes(x = quarter, 
                 y = value, 
                 group = variable)) + 
      geom_line(aes(colour = variable), 
                size = 1) + 
      
      # scales: 
      scale_colour_manual(values = c("grey60", 
                                     "dodgerblue")) + 
      scale_y_continuous(limits = c(0, 1.0), 
                         breaks = seq(0, 1, 0.2)) + 
      scale_x_discrete(breaks = quarter.labels) + 
      
      # labs: 
      labs(title = "Percentage of overall hospital deaths for clients known to VCH Community \nprograms \n\nVCH Overall", 
           subtitle = paste0(min.quarter, " to ", max.quarter), 
           y = "Proportion", 
           x = "Quarter") + 
      
      guides(colour = guide_legend("")) +  # remove legend title
      
      
      theme_classic(base_size = 12); p3.1.measures.and.targets.vch





#**************************************************************************
# 4) plotting measure values: Avg LOS days  : -------------------------
#**************************************************************************

p4.acute.losdays.measure.and.target <- 
      # prep data: 
      unnest(df1.deaths.data, data) %>% 
      select(-c(measure, target)) %>%  # remove "measure" and "target" cols for indicator "%acute deaths"
      filter(!is.na(area)) %>% 
      mutate(measure = round(adjlosdays/deaths, 2)) %>% 
      inner_join(df3.los.targets) %>% 
      melt() %>% 
      filter(variable %in% c("measure", "target")) %>% 
      
      # plot data: 
      ggplot(aes(x = quarter, 
                 y = value, 
                 group = variable)) + 
      geom_line(aes(colour = variable), 
                size = 1) + 
      facet_wrap(~area, 
                 nrow = 1) + 
      
      # scales: 
      scale_colour_manual(values = c("firebrick",
                                     "grey60")) + 
      
      expand_limits(y = 0) +  # display y-axis starting at 0, without specifying max
      
      scale_x_discrete(breaks = quarter.labels) +
      
      # labs: 
      labs(# title = "Regional End of Life Reporting \nAverage hospital days in the last 6 months of life for clients known to \nVCH Community Programs", 
           # subtitle = paste0(min.quarter, " to ", max.quarter), 
           y = "Proportion", 
           x = "Quarter") + 
      
      guides(colour = guide_legend("")) +  # remove legend title
      
      theme_classic(base_size = 12) + 
      theme(plot.caption = element_text(size = 8),
            axis.text.x = element_text(angle = 90)); p4.acute.losdays.measure.and.target



# > VCH-LEVEL GRAPH: ----------
p4.1.acute.losdays.measure.and.target.vch <- 
      # prep data: 
      unnest(df1.deaths.data, data) %>% 
      filter(!is.na(area)) %>%
      group_by(quarter) %>%
      summarize(deaths = sum(deaths), 
                losdays = sum(adjlosdays)) %>% 
      mutate(measure = round(losdays/deaths, 2), 
             area = "VCH") %>% 
      inner_join(df3.los.targets) %>%
      melt %>% 
      filter(variable %in% c("measure", "target")) %>% 
      
      # plot
      ggplot(aes(x = quarter, 
                 y = value, 
                 group = variable)) + 
      geom_line(aes(colour = variable), 
                size = 1) + 
      
      # scales: 
      scale_colour_manual(values = c("firebrick",
                                     "grey60")) + 
      expand_limits(y = 0) +  # display y-axis starting at 0, without specifying max
      
      scale_x_discrete(breaks = quarter.labels) +
      
      # labs: 
      labs(title = "Average hospital days in the last 6 months of life for clients known to \nVCH Community Programs \n\nVCH Overall", 
           subtitle = paste0(min.quarter, " to ", max.quarter), 
           y = "proportion") + 
      
      guides(colour = guide_legend("")) +  # remove legend title
      
      
      theme_classic(base_size = 12); p4.1.acute.losdays.measure.and.target.vch




#**************************************************************************
# 5) trend of LOSdays: -------------------------
#**************************************************************************

p5.losdays.trend <- 
      # prep data: 
      unnest(df1.deaths.data, losdays.stl) %>% 
      as.data.frame() %>% 
      filter(!is.na(area)) %>% 
      
      # join to get quarter numbers: 
      inner_join(unnest(df1.deaths.data, data)) %>% 
      
      # plot data: 
      ggplot() + 
      
      # los trend
      geom_line(aes(x = quarter, 
                    y = trend, 
                    colour = "LOS days trend", 
                    group = 1), 
                size = 1) +
      
      # los data: 
      geom_line(aes(x = quarter, 
                    y = data, 
                    colour = "LOS days", 
                    group = 1), 
                size = 0.1) +
      
      facet_wrap(~area) + 
      
      
      scale_color_manual(values = c("grey80", 
                                    "black")) + 
      scale_x_discrete(breaks = quarter.labels) + 
      
      labs(title = "Total hospital days in last 6 months of life, for clients known to \nVCH Community Programs",
           subtitle = paste0(min.quarter, " to ", max.quarter), 
           y = "number of days", 
           x = "quarter") + 
      guides(colour = guide_legend("")) +  # remove legend title
      
      theme_classic(base_size = 12); p5.losdays.trend




# 6) seasonality of losdays: ---------
p6.losdays.seasonal <- 
      # prep data: 
      unnest(df1.deaths.data, losdays.stl) %>% 
      as.data.frame() %>% 
      filter(!is.na(area)) %>% 
      
      # join to get quarter numbers: 
      inner_join(unnest(df1.deaths.data, data)) %>%
      
      # plot data: 
      ggplot() + 
      
      # los trend
      geom_line(aes(x = quarter, 
                    y = seasonal, 
                    colour = "LOS days trend",
                    group = 1)) +
      
      facet_wrap(~area) + 
      
      scale_color_manual(values = c("black")) + 
      scale_x_discrete(breaks = quarter.labels) + 
      geom_hline(yintercept = 0, 
                 colour = "grey70", 
                 size = 0.2) + 
      
      
      labs(title = "Seasonal component of total hospital days in last 6 months of life \nfor clients known to VCH Community Programs",
           subtitle = paste0(min.quarter, " to ", max.quarter), 
           y = "number of days", 
           x = "quarter") + 
      guides(colour = guide_legend("")) +  # remove legend title
      
      theme_classic(base_size = 12); p6.losdays.seasonal









#**************************************************************************
# 7) write outputs: -------------------------
#**************************************************************************

pdf(here("results", 
         "output from src", 
         "2018-08-09_rgnl_eol-reporting_percent-hospital-deaths.pdf"))
ggarrange(p3.1.measures.and.targets.vch, 
          p3.measures.and.targets + theme(plot.margin = unit(c(2,0.5,0.5,0.5), "cm")), 
          nrow = 2)
p1.trends
p2.seasonal
dev.off()



pdf(here("results", 
         "output from src", 
         "2018-08-09_rgnl_eol-reporting_los-days-in-acute-last-six-months.pdf"))
p4.1.acute.losdays.measure.and.target.vch
p4.acute.losdays.measure.and.target
p5.losdays.trend
p6.losdays.seasonal
dev.off()



