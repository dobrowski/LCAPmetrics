

library(knitr)
library(rmarkdown)


### One district at a time ------


# 27662250000000 - Spreckels 
# 27660680000000 - SoMoCo


dist <- "27662250000000"

render("LCAPmetricsReport.Rmd", 
       output_file = dist,
       output_dir = here("output"),
       params = list(
    dist = dist
))

### Everybody ------

walk2(indicators$cds, indicators$DistrictName , ~ rmarkdown::render("LCAPmetricsReport.Rmd", 
                                    output_file = {.y},
                                    output_dir = here("output"),
                                    params = list(
                                        dist = .x
                                    )))
