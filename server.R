#

library(shiny)
library(here)
library(jsonlite)
library(rmarkdown)
library(knitr)
library(tidyverse)
library(glue)


icon.df <- read_rds("icons.rds")

# Define server logic required to pull and process data
shinyServer(function(input, output) {
    
    report <- reactiveValues(filepath = NULL) #This creates a short-term storage location for a filepath
    
    observeEvent(input$generate, {
        

   #     param <- list(dist = 27661590000000)
        param <- list(dist = input$select)
 
  #      tmp_file <- paste0(tempfile(), ".html") #Creating the temp where the .pdf is going to be stored
        
# Working version but trying the tags$iframe        
   #      output$report <- renderUI({
   #          includeHTML(   
   #      render("LCAPmetricsReport.Rmd", 
   #             output_format = "all", 
   # #            output_file = tmp_file,
   #             params = param, 
   #             envir = new.env(parent = globalenv()) 
   #             )
   #          )
   #      })
        
        a <-  eventReactive(input$generate, {
            
            rmarkdown::render("LCAPmetricsReport.Rmd", 
                                          output_format = "all",
                              #            output_file = tmp_file,
                                          params = param,
                                          envir = new.env(parent = globalenv()) )
            
            tags$iframe(
                src = base64enc::dataURI(file="LCAPmetricsReport.html", mime="text/html; charset=UTF-8"),
                style="border:0; position:relative; top:0; left:0; right:0; bottom:0; width:100%; height:1800px"
                
            )
            
        })
        
        
        
        output$report <- renderUI({
            a()
        })
        
        
        
        
        
        
        
        
        output$icon <- renderUI(
            img( width = 300, 
                src = icon.df %>%
                                                filter(cds == param) %>% 
                                                select(path) %>%
                                                unlist()
            )
            )
        
  #      report$filepath <- tmp_file #Assigning in the temp file where the .pdf is located to the reactive file created above
        
    })
    
    # # Hide download button until report is generated
    # output$reportbuilt <- reactive({
    #     return(!is.null(report$filepath))
    # })
    # outputOptions(output, 'reportbuilt', suspendWhenHidden= FALSE)
    # 
    # #Download report  
    # output$download <- downloadHandler(
    #     
    #     # This function returns a string which tells the client
    #     # browser what name to use when saving the file.
    #     filename = function() {
    #         paste0(input$select, "_", Sys.Date(), ".html") %>%
    #             gsub(" ", "_", .)
    #     },
    #     
    #     # This function should write data to a file given to it by
    #     # the argument 'file'.
    #     content = function(file) {
    #         
    #         file.copy(report$filepath, file)
    #         
    #     }
    # )
    # 
})



