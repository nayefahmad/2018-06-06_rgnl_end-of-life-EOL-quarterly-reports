

#*******************************************************
# IMPORT, CLEAN DEATHS DATA 
#*******************************************************


library("tidyverse")
library("here")
library("magrittr")

# todo: ----------------
# > use nest( ) and pmap() to apply fn over each community, get list-columns 
#      with the required data 


deaths.data <- 
      read_csv(here("results", 
                    "output from src", 
                    "2018-07-27_rgnl_deaths-and-acute-deaths-data-all-communities.csv"))  


# Vancouver data: ---------------
van.deaths <- 
      deaths.data %>% 
      set_names(tolower(names(.))) %>% 
      filter(communityregion2 == "Vancouver") %>% 
      select(deaths) %>% 
      ts(start = c(2014, 1),
          frequency = 4) %>% print


van.acutedeaths <- 
      deaths.data %>% 
      set_names(tolower(names(.))) %>% 
      filter(communityregion2 == "Vancouver") %>% 
      select(acutedeaths) %>% 
      ts(start = c(2014, 1),
         frequency = 4) %>% print




# Richmond data: ---------------
van.deaths <- 
      deaths.data %>% 
      set_names(tolower(names(.))) %>% 
      filter(communityregion2 == "Richmond") %>% 
      select(deaths) %>% 
      ts(start = c(2014, 1),
         frequency = 4) %>% print


van.acutedeaths <- 
      deaths.data %>% 
      set_names(tolower(names(.))) %>% 
      filter(communityregion2 == "Richmond") %>% 
      select(acutedeaths) %>% 
      ts(start = c(2014, 1),
         frequency = 4) %>% print

      





