

#*******************************************************
# IMPORT, CLEAN DEATHS DATA 
#*******************************************************


library("tidyverse")
library("here")
library("tidyr")
library("magrittr")
library("ggpubr")

# todo: ----------------
# > add acute.deaths lines in the graphs, by COC 
# > rename col stl.decomp to deaths.stl; add new col acutedeaths.stl 


# read in data: ----------------
source(here("src", 
            "extract_deaths_function.R"))


deaths.data <- 
      read_csv(here("results", 
                    "output from src", 
                    "2018-07-27_rgnl_deaths-and-acute-deaths-data-all-communities.csv"))  



# Group by CommunityRegion2 and nest: ---------------
deaths.data %<>% 
      set_names(tolower(names(.))) %>% 
      rename(area = communityregion2, 
             quarter = deathfiscalquarter) %>%
      group_by(area) %>% 
      nest()

# each entry of deaths.data$data is a dataframe, which is nested within the 
# deaths.data dataframe 

deaths.data$data  # all data
deaths.data$data[[5]]  # Vancouver data 





# add column with deaths as ts object: --------------
deaths.data %<>% 
      mutate(deaths.ts = map(data, extract_deaths)) %>% 
      mutate(stl.decomp = map(deaths.ts, function(x) {
                  stl <- stl(x, s.window = "periodic")
                  
                  stl.df <- stl[[1]] %>% as.data.frame() %>% 
                        mutate(data = seasonal + trend + remainder, 
                               timeperiod = seq_along(seasonal))
                  
                  return(stl.df)
                  }
            ))

# result: 
deaths.data$stl.decomp[[5]]




# plotting trend components: ---------------
# deaths.data$stl.decomp[[5]] %>% 
#       as.data.frame() %>% 
#       mutate(data = seasonal + trend + remainder, 
#              timeperiod = seq_along(seasonal)) %>% 
#       ggplot(aes(x = timeperiod, 
#                  y = trend)) + 
#             geom_line()
# 

unnest(deaths.data, stl.decomp) %>% 
      as.data.frame() %>% 
      filter(!is.na(area)) %>% 
      ggplot(aes(x = timeperiod, 
                 y = trend)) + 
      geom_line() + 
      facet_wrap(~area) + 
      theme_classic()
      
      
      





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


