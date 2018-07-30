

#*******************************************************
# IMPORT, CLEAN DEATHS DATA 
#*******************************************************


library("tidyverse")
library("here")
library("tidyr")
library("magrittr")

# todo: ----------------
# > use nest( ) and pmap() to apply fn over each community, get list-columns 
#      with the required data 


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
      
deaths.data$data  # all data
deaths.data$data[[5]]  # Vancouver data 


