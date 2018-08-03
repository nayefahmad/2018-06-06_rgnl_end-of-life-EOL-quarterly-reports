

#*******************************************************
# IMPORT, CLEAN DEATHS DATA 
#*******************************************************


library("tidyverse")
library("here")
library("tidyr")
library("magrittr")
library("reshape2")


# rm(list = ls())

# todo: ----------------
# > fix x-axis of graphs p1, p2
# > fix order of labels in legend 
# > add data sources, key contacts 


# 1) read in data and functions: ----------------
source(here("src", 
            "extract_deaths_function.R"))
source(here("src", 
            "stl_function.R"))

# deaths data: 
df1.deaths.data <- 
      read_csv(here("results", 
                    "output from src", 
                    "2018-07-27_rgnl_deaths-and-acute-deaths-data-all-communities.csv"))  

# measure targets: 
df2.targets <- 
      read_csv(here("data", 
                    "2018-07-31_rgnl_eol-acute-deaths-percentage-targets.csv"))





# 2) Group by CommunityRegion2 and nest: ---------------
df1.deaths.data %<>% 
      set_names(tolower(names(.))) %>% 
      rename(area = communityregion2, 
             quarter = deathfiscalquarter) %>%
      inner_join(df2.targets) %>%  # join on area and quarter to get targets 
      
      # calculate measure: 
      mutate(measure = round(acutedeaths/deaths, 2)) %>% 
      group_by(area) %>% 
      nest()

# each entry of deaths.data$data is a dataframe, which is nested within the 
# deaths.data dataframe 

# examine data: 
df1.deaths.data$data  # all data
df1.deaths.data$data[[5]]  # Vancouver data 





# 3) run STL decompositions: --------------
df1.deaths.data %<>% 
      # extract ts objects: 
      mutate(deaths.ts = map2(data,  # arg1
                              "deaths", # arg2
                              extract_deaths),           # custom function for extracting deaths data as ts object 
             acutedeaths.ts = map2(data, 
                                   "acutedeaths", 
                                   extract_deaths)) %>%  # custom function for extracting deaths data as ts object 
      
      
      
      # run stl decompositions: 
      mutate(deaths.stl = map(deaths.ts, stl.fn),            # custom function for returning stl components as dataframe  
             acutedeaths.stl = map(acutedeaths.ts, stl.fn))  # custom function for returning stl components as dataframe 

# result: 
df1.deaths.data$deaths.stl[[5]]
df1.deaths.data$acutedeaths.stl[[5]]




# 4) Identify text for plots: ----------------------
# first identify breaks for x-axis (multiples of 4 until max num quarters): 
x.breaks <- 
      unnest(df1.deaths.data, acutedeaths.stl) %>% 
      select(timeperiod) %>%
      unique() %>%
      mutate(test = timeperiod %% 4) %>% 
      filter(test == 0) %>% 
      select(timeperiod) %>% 
      unname %>%
      unlist

# next find min and max quarter for subtitle: 
df3.quarters <- 
      unnest(df1.deaths.data, data) %>% select(quarter) %>% unique()

min.quarter <-  df3.quarters %>% filter(row_number() == 1) %>% as.character()
max.quarter <-  df3.quarters %>% filter(row_number() == nrow(df3.quarters)) %>% as.character()



# 5) plotting trend components: ---------------
p1.trends <- 
      unnest(df1.deaths.data, deaths.stl) %>% 
      as.data.frame() %>% 
      filter(!is.na(area)) %>% 
      
      # create plot: 
      ggplot() + 
      
      # deaths trend
      geom_line(aes(x = timeperiod, 
                    y = trend,
                    colour = "Deaths trend"), 
                size = 1) +  
      
      # deaths data: 
      geom_line(aes(x = timeperiod, 
                    y = data,
                    colour = "Deaths"), 
                size = 0.1) +
      
      
      # acute deaths trend
      geom_line(data = unnest(df1.deaths.data, acutedeaths.stl) %>% 
                      filter(!is.na(area)), 
                aes(x = timeperiod, 
                    y = trend,
                    colour = "Acute Deaths trend"), 
                size = 1.0) + 
      
      # acutedeaths data: 
      geom_line(data = unnest(df1.deaths.data, acutedeaths.stl) %>% 
                      filter(!is.na(area)), 
                aes(x = timeperiod, 
                    y = data,
                    colour = "Acute Deaths"), 
                size = 0.1) +
      
      facet_wrap(~area) + 
      
      
      scale_color_manual(values = c("lightpink", 
                                    "red", 
                                    "grey80", 
                                    "black")) + 
      scale_x_continuous(breaks = x.breaks) + 
      
      labs(title = "Deaths and acute deaths, by COC",
           subtitle = paste0(min.quarter, " to ", max.quarter), 
           y = "number of deaths", 
           x = "quarter") + 
      guides(colour = guide_legend("")) +  # remove legend title
      
      theme_classic(base_size = 12); p1.trends
      
 

# 6) plotting seasonal components: ---------------
p2.seasonal <- 
      unnest(df1.deaths.data, deaths.stl) %>% 
      as.data.frame() %>% 
      filter(!is.na(area)) %>% 
      
      # create plot: 
      ggplot(aes(x = timeperiod, 
                 y = seasonal)) + 
      
      # deaths 
      geom_line(aes(colour = "Deaths")) +  
      
      # acute deaths: 
      geom_line(data = unnest(df1.deaths.data, acutedeaths.stl) %>% 
                      filter(!is.na(area)), 
                aes(colour = "Acute Deaths")) + 
      
      geom_hline(yintercept = 0, 
                 colour = "grey70", 
                 size = 0.2) + 
      
      facet_wrap(~area) + 
      
      
      scale_color_manual(values = c("red", "black")) + 
      labs(title = "Seasonal components of deaths and acute deaths, by COC",
           subtitle = paste0(min.quarter, " to ", max.quarter),
           y = "number of deaths", 
           x = "quarter") + 
      scale_x_continuous(breaks = x.breaks) + 
      
      guides(colour = guide_legend("")) +  # remove legend title
      
      theme_classic(base_size = 12); p2.seasonal







# 7) plotting measure values: ----------------
p3.measures.and.targets <- 
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
      
      facet_wrap(~area) + 
      
      # scales: 
      scale_colour_manual(values = c("grey60",
                                     "dodgerblue")) + 
      scale_y_continuous(limits = c(0, 1.0), 
                         breaks = seq(0, 1, 0.1)) + 
      scale_x_discrete(breaks = c("14-Q1", 
                                  "15-Q1", 
                                  "16-Q1", 
                                  "17-Q1", 
                                  "18-Q1")) +
      
      # labs: 
      labs(title = "Regional End of Life Reporting \n% of overall hospital deaths for clients known to VCH Community \nprograms", 
           subtitle = paste0(min.quarter, " to ", max.quarter), 
           y = "proportion") + 
      
      guides(colour = guide_legend("")) +  # remove legend title
      
      
      theme_classic(base_size = 12); p3.measures.and.targets


#******************************************************************
# > VCH LEVEL GRAPH: ---------
#******************************************************************
p3.1.measures.and.targets.vch <- 
      unnest(df1.deaths.data, data) %>% 
      filter(!is.na(area)) %>%
      group_by(quarter) %>%
      summarize(deaths = sum(deaths), 
                acutedeaths = sum(acutedeaths)) %>% 
      mutate(measure = round(acutedeaths/deaths, 2), 
             area = "VCH") %>% 
      inner_join(df2.targets) %>%
      melt %>% 
      filter(variable %in% c("measure", "target")) %>% 
      
      # plot
      ggplot(aes(x = quarter, 
                 y = value, 
                 group = variable)) + 
      geom_line(aes(colour = variable), 
                size = 1) + 
      
      # scales: 
      scale_colour_manual(values = c("dodgerblue",
                                     "grey60")) + 
      scale_y_continuous(limits = c(0, 1.0), 
                         breaks = seq(0, 1, 0.1)) + 
      scale_x_discrete(breaks = c("14-Q1", 
                                  "15-Q1", 
                                  "16-Q1", 
                                  "17-Q1", 
                                  "18-Q1")) +
      
      # labs: 
      labs(title = "Regional End of Life Reporting \n% of overall hospital deaths for clients known to VCH Community \nprograms", 
           subtitle = paste0(min.quarter, " to ", max.quarter, " for VCH as a whole"), 
           y = "proportion") + 
      
      guides(colour = guide_legend("")) +  # remove legend title
      
      
      theme_classic(base_size = 12); p3.1.measures.and.targets.vch








#**************************************************************************
# 8) write outputs: -------------------------
#**************************************************************************

pdf(here("results", 
            "output from src", 
            "2018-08-02_rgnl_eol-reporting_percent-hospital-deaths.pdf"))
p3.1.measures.and.targets.vch
p3.measures.and.targets
p1.trends
p2.seasonal
dev.off()
   
      








# > alternative approach: use for loop to plot each COC: 
# plots <- list()
# 
# # names for plot titles: 
# coc.list <- unique(deaths.data$area)
# 
# # define plotting function: 
# plot.fn <- function(df){
#       df %>% 
#       mutate(data = seasonal + trend + remainder, 
#               timeperiod = seq_along(seasonal)) %>% 
#       ggplot(aes(x = timeperiod, 
#                  y = trend)) + 
#       geom_line(colour = "red") + 
#       scale_y_continuous(limits = c(0, 1000)) + 
#       labs(title = paste0(coc.list[i])) + 
#       theme_classic()
# }
# 
# 
# # apply fn in loop: 
# for (i in 1:5){
#       plots[[i]] <- 
#       deaths.data$stl.decomp[[i]] %>% 
#       as.data.frame() %>% 
#       plot.fn() 
#       
# }
# 
# # view plots: 
# print(plots)
# plots[[5]]
# 
# ggarrange(plots[[2]], 
#           plots[[3]], 
#           plots[[4]], 
#           plots[[5]])


