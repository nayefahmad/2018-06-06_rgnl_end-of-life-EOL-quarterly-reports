

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

source(here("src", 
            "extract_deaths_function.R"))


deaths.data <- 
      read_csv(here("results", 
                    "output from src", 
                    "2018-07-27_rgnl_deaths-and-acute-deaths-data-all-communities.csv"))  



# > Group by CommunityRegion2 and nest: ---------------
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





# > add column with deaths as ts object: --------------
deaths.data %<>% 
      mutate(deaths.ts = map(data, extract_deaths)) %>% 
      mutate(stl.decomp = map(deaths.ts, function(x) {
                  stl <- stl(x, s.window = "periodic")
                  return(stl[[1]])
                  }
            ))

# result: 
deaths.data$stl.decomp[[1]]


# try plotting: 
deaths.data$stl.decomp[[5]] %>% 
      as.data.frame() %>% 
      mutate(data = seasonal + trend + remainder, 
             timeperiod = seq_along(seasonal)) %>% 
      ggplot(aes(x = timeperiod, 
                 y = trend)) + 
            geom_line()




# use for loop to plot each COC: 
coc.list <- unique(deaths.data$area)


lapply(deaths.data$stl.decomp, 
       function(x){
             x %>% as.data.frame() %>% 
                   mutate(data = seasonal + trend + remainder, 
                          timeperiod = seq_along(seasonal)) %>% 
                   ggplot(aes(x = timeperiod, 
                              y = trend)) + 
                   geom_line() + 
                   labs(title = paste0())
       })










# unnest(deaths.data, deaths.ts) 
# deaths.data$deaths.ts[[1]]


# create a list with all time series: 
# death.time.series <- list()
# for (i in seq_along(deaths.data)){
#       death.time.series[[i]] <- deaths.data$deaths.ts[[i]]
# }
# 
# death.time.series
# death.time.series[[1]] %>% str
# death.time.series[[1]] %>% plot()
# 
# 
# lapply(deaths.data$deaths.ts, function(x) {stl(x)})
# 
# deaths.data$deaths.ts[[1]] %>% str  # todo: why is this not a univariate time series? 

