library(shiny)
library(here)
library(jsonlite)
library(rmarkdown)
library(knitr)
library(tidyverse)
library(glue)
library(markdown)



indicators <- read_rds("indicators.rds")
series_ids <- indicators$cds
names(series_ids) <- indicators$districtname


# icon.df <- read_rds("icons.rds")



# Define UI for application that draws a histogram
shinyUI(fluidPage(
    #Google analytics
    tags$head(includeHTML("google-analytics.html")),
    
    # Application title
    titlePanel("Monterey County LCAP Metrics"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            selectInput("select", label = h3("Select box"),
                        choices = series_ids[order(names(series_ids))],
                        selected = 1),
            actionButton("generate", "Generate Report", icon = icon("file"), # This is the only button that shows up when the app is loaded
                  style = "color: #fff; background-color: #337ab7; border-color: #2e6da4"),
     br(),
     br(),
     # conditionalPanel(condition = "output.reportbuilt",
     #                  downloadButton("download", "Download LCAP Metrics", 
     #                                 style = "color: #fff; background-color: #337ab7; border-color: #2e6da4"))
        
     uiOutput("icon")
     
     ),

        # Show a plot of the generated distribution
        mainPanel(
       #     "Holding area"
            
            htmlOutput("report"),
            
            
   #         includeMarkdown("Instructions.Rmd"),
            img(src='logo.png', height="30%", width="30%", align = "right")
        )
    )
))
