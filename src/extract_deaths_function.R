

#*****************************************************
# FUNCTION TO EXTRACT DEATHS DATA FROM EACH COC AND CONVERT TO TIME SERIES       
#*****************************************************

# Function defn: -----------------
extract_deaths <- 
      function(df){
            # df is a single entry (row) of the "data" col of a nested dataframe
            # output: ts object with deaths data for specified area 
            
            deaths.ts <- df %>% 
                  select(deaths) %>% 
                  unlist() %>% 
                  as.numeric() %>% 
                  ts(start = c(2014, 1), 
                     frequency = 4)
            
            # str(deaths.ts)
            
            return(deaths.ts)
      }



# test fn: 
extract_deaths(deaths.data$data[[1]]) %>% stl(s.window = "periodic")
# todo: "Error in stl(.) : only univariate series are allowed" 
