

#********************************************************
# SEASONAL DECOMPOSITION OF DEATHS KNOWN TO COMMUNITY
#********************************************************

library("tidyverse")
library("fpp")
library("here")
library("reshape2")

# rm(list = ls())

# 1) NOTES: ---------------

# THIS SCRIPT IS NO LONGER IN USE ------------------------

# see folder: \\vch.ca\departments\QUIST\Production\Pegah Mortazavi\EndOfLife\Regional EndOfLifeReporting\Quarterly
#       file: 2018-07-17_Q4_EndOfLifeReporting.xlsx

# graphs here are terrible becasue they try to do too much: show level, 
# identify trend and seasonaly, etc. 

# better to split graphs: one to show trend, one to identify seasonality, etc. 


# TODO: -------------


# 2) deaths data: --------------
# read data from excel sheet: 
deaths <- readClipboard() %>%  # read in e.g. Vancouver data 
      as.numeric() %>% 
      ts(start = c(2014, 1),
         frequency = 4)

str(deaths)

fit <- stl(deaths, 
           s.window = "periodic")

# examine result: 
str(fit)  # list of 8
df1.van.deaths <- fit[[1]] %>% 
      as.data.frame() %>% 
      mutate(data = seasonal + trend + remainder, 
             timeperiod = seq_along(seasonal)) 
str(df1.van.deaths)

# graph: 
p1.van.deaths <- plot(fit, main = "Vancouver deaths known to Community, 2014-Q1 to 2018-Q1")
p1.van.deaths


# graph only trend: 
p2.van.deaths.trend <- 
      df1.van.deaths %>% 
      ggplot(aes(x = timeperiod,
                 y = trend)) + 
      geom_line() + 
      theme_classic(base_size = 16) +
      labs(title = "Trend component of Vancouver deaths known \nto Community", 
           subtitle = "2014-Q1 to 2018-Q1"); p2.van.deaths.trend
# todo: fix x-axis labels       



# output results: ------------
pdf(here("results", 
         "output from src", 
         "2018-07-27_rgnl_vancouver-deaths-data.pdf"))
plot(fit, main = "Vancouver deaths known to Community, 2014-Q1 to 2018-Q1")
dev.off()



pdf(here("results", 
         "output from src", 
         "2018-07-27_rgnl_vancouver-deaths-data-trend-component-only.pdf"))
p2.van.deaths.trend
dev.off()
