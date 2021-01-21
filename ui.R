

library(shiny)
library(rmarkdown)


library(shiny)
library(here)
library(jsonlite)
library(rmarkdown)
library(knitr)
library(tidyverse)
library(glue)


indicators <- read_rds("indicators.rds")
series_ids <- indicators$cds
names(series_ids) <- indicators$DistrictName


# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Monterey County LCAP Metrics for LEAs"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            selectInput("select", label = h3("Select box"),
                        choices = series_ids[order(names(series_ids))],
                #        choices = list( "Alisal" = "27659610000000","Big Sur" = "27751500000000" ,"Bradley" = "27659790000000", "Chualar" = "27659950000000", "North Monterey County" = "27738250000000", "Salinas Union" = "27661590000000", "South Monterey" = "27660680000000", "Washington" = "27662330000000"), 
                        selected = 1),
     #       sliderInput("slider", "Slider", 27661590000000, 27661590000000, 1),
            actionButton("generate", "Generate Report", icon = icon("file"), # This is the only button that shows up when the app is loaded
                  style = "color: #fff; background-color: #337ab7; border-color: #2e6da4"),
     br(),
     br(),
     conditionalPanel(condition = "output.reportbuilt",
                      downloadButton("download", "Download LCAP Report", 
                                     style = "color: #fff; background-color: #337ab7; border-color: #2e6da4"))
        ),

        # Show a plot of the generated distribution
        mainPanel(
       #     "Holding area"
            includeMarkdown("Instructions.Rmd"),
            img(src='logo.png', height="30%", width="30%", align = "right")
        )
    )
))
