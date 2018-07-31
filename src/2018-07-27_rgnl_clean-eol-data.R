

#*******************************************************
# IMPORT, CLEAN DEATHS DATA 
#*******************************************************


library("tidyverse")
library("here")
library("tidyr")
library("magrittr")
library("ggpubr")

# rm(list = ls())

# todo: ----------------
# > add acute.deaths lines in the graphs, by COC 
# > rename col stl.decomp to deaths.stl; add new col acutedeaths.stl 
# > fix x-axis of graphs 
# > assign plot names 


# 1) read in data: ----------------
source(here("src", 
            "extract_deaths_function.R"))
source(here("src", 
            "stl_function.R"))


df1.deaths.data <- 
      read_csv(here("results", 
                    "output from src", 
                    "2018-07-27_rgnl_deaths-and-acute-deaths-data-all-communities.csv"))  



# 2) Group by CommunityRegion2 and nest: ---------------
df1.deaths.data %<>% 
      set_names(tolower(names(.))) %>% 
      rename(area = communityregion2, 
             quarter = deathfiscalquarter) %>%
      group_by(area) %>% 
      nest()

# each entry of deaths.data$data is a dataframe, which is nested within the 
# deaths.data dataframe 

df1.deaths.data$data  # all data
df1.deaths.data$data[[5]]  # Vancouver data 





# 3) run STL decompositions: --------------
df1.deaths.data %<>% 
      # extract ts objects: 
      mutate(deaths.ts = map2(data,  # arg1
                              "deaths", # arg2
                              extract_deaths), 
             acutedeaths.ts = map2(data, 
                                   "acutedeaths", 
                                   extract_deaths)) %>% 
      
      
      
      # run stl decompositions: 
      mutate(deaths.stl = map(deaths.ts, stl.fn), 
             acutedeaths.stl = map(acutedeaths.ts, stl.fn))

# result: 
df1.deaths.data$deaths.stl[[5]]
df1.deaths.data$acutedeaths.stl[[5]]



# 4) plotting trend components: ---------------

# first identify breaks for x-axis: 
x.breaks <- 
      unnest(df1.deaths.data, acutedeaths.stl) %>% 
      select(timeperiod) %>%
      unique() %>%
      mutate(test = timeperiod %% 4) %>% 
      filter(test == 0) %>% 
      select(timeperiod) %>% 
      unname %>%
      unlist



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
      
      labs(title = "Trend components of deaths and acute deaths, by COC",
           subtitle = "2014-Q1 to 2018-Q1", 
           y = "number of deaths", 
           x = "quarter") + 
      guides(colour = guide_legend("")) +  # remove legend title
      
      theme_classic(base_size = 12); p1.trends
      
 

# 5) plotting seasonal components: ---------------
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
           subtitle = "2014-Q1 to 2018-Q1",
           y = "number of deaths", 
           x = "quarter") + 
      scale_x_continuous(breaks = x.breaks) + 
      
      guides(colour = guide_legend("")) +  # remove legend title
      
      theme_classic(base_size = 12); p2.seasonal









#**************************************************************************
# 5) write outputs: -------------------------
#**************************************************************************

pdf(here("results", 
            "output from src", 
            "2018-07-31_rgnl_eol-deaths-trend-and-seasonal-components.pdf"))
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


