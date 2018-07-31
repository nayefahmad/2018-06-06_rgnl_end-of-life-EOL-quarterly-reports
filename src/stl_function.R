

#************************************************
# FUNCTION TO RUN STL DECOMPOSITION AND SAVE RESULTS AS DF
#************************************************

# define function: 
stl.fn <- function(x){
      # x is a ts object 
      
      stl <- stl(x, s.window = "periodic")
      
      stl.df <- stl[[1]] %>% as.data.frame() %>% 
            mutate(data = seasonal + trend + remainder, 
                   timeperiod = seq_along(seasonal))
      
      return(stl.df)
}

# test function: 
# stl.fn(df1.deaths.data$deaths.ts[[5]])
