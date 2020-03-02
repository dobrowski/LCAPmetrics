

library(knitr)
library(rmarkdown)


render("LCAPmetricsReport.Rmd", 
       output_file = "27662250000000",
       output_dir = here("output"),
       params = list(
    dist = "27662250000000"
))
