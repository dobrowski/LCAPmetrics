

library(knitr)
library(rmarkdown)


dist <- "27662250000000"

render("LCAPmetricsReport.Rmd", 
       output_file = dist,
       output_dir = here("output"),
       params = list(
    dist = dist
))



# 27662250000000 - Spreckels 
# 27660680000000 - SoMoCo
