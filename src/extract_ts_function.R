

#*****************************************************
# FUNCTION TO EXTRACT DEATHS DATA FROM EACH COC AND CONVERT TO TIME SERIES       
#*****************************************************

# todo: add args to identify start datetime

# Function defn: -----------------
extract_ts <- 
      function(df, colname, startyear=2014, startquarter=1){
            # df is a single entry (row) of the "data" col of a nested dataframe
            # colname: either "deaths" or "acute deaths" 
            # startyear: eg. "2014"
            # startquarter: e.g. "1"
            
            # output: ts object with deaths data for specified area 
            
            library("glue")  # see dplyr vignette "Programming" 
            
            colname <- as.character(colname)
            
            deaths.ts <- df %>% 
                  select(glue("{colname}")) %>% 
                  unlist() %>% 
                  as.numeric() %>% 
                  ts(start = c(startyear, startquarter), 
                     frequency = 4)
            
            # str(deaths.ts)
            
            return(deaths.ts)
      }



# test fn: -----------
# extract_ts(df1.deaths.data$data[[1]], "deaths") 
# 
# # try different start period: 
# extract_ts(df1.deaths.data$data[[1]], 
#            "deaths", 
#            2015, 
#            4) 
# 
# extract_ts(df1.deaths.data$data[[1]], "deaths") %>%
#       stl(s.window = "periodic")
