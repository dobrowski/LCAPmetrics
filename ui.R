#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Old Faithful Geyser Data"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            selectInput("select", label = h3("Select box"), 
                        choices = list("Salinas Union" = 27661590000000, "Alisal" = 27659610000000, "Bradley" = 27659790000000), 
                        selected = 1),
     #       sliderInput("slider", "Slider", 27661590000000, 27661590000000, 1),
            downloadButton("report", "Generate report")
        ),

        # Show a plot of the generated distribution
        mainPanel(
            "Holding area"
     #       includeMarkdown("LCAPmetricsReport.Rmd")
        )
    )
))
