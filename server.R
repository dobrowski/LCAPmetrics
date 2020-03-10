#


library(shiny)
library(here)


# Define server logic required to pull and process data
shinyServer(function(input, output) {
    
    report <- reactiveValues(filepath = NULL) #This creates a short-term storage location for a filepath
    
    observeEvent(input$generate, {
        
        # progress <- shiny::Progress$new()
        # # Make sure it closes when we exit this reactive, even if there's an error
        # on.exit(progress$close())
        # progress$set(message = "Gathering data and building report.", 
        #              detail = "This may take a while. This window will disappear  
        #              when the report is ready.", value = 1)
        
       
        params <- list(dist = input$select)
 
        tmp_file <- paste0(tempfile(), ".html") #Creating the temp where the .pdf is going to be stored
        
        render("LCAPmetricsReport.Rmd", 
               output_format = "all", 
               output_file = tmp_file,
               params = params, 
               envir = new.env(parent = globalenv()) )
        
        report$filepath <- tmp_file #Assigning in the temp file where the .pdf is located to the reactive file created above
        
    })
    
    # Hide download button until report is generated
    output$reportbuilt <- reactive({
        return(!is.null(report$filepath))
    })
    outputOptions(output, 'reportbuilt', suspendWhenHidden= FALSE)
    
    #Download report  
    output$download <- downloadHandler(
        
        # This function returns a string which tells the client
        # browser what name to use when saving the file.
        filename = function() {
            paste0(input$select, "_", Sys.Date(), ".html") %>%
                gsub(" ", "_", .)
        },
        
        # This function should write data to a file given to it by
        # the argument 'file'.
        content = function(file) {
            
            file.copy(report$filepath, file)
            
        }
    )
    
})




# 
# shinyServer(function(input, output) {
# # Define server logic required to draw a histogram
# output$report <- downloadHandler(
#     filename = "LCAP_Metrics_report.html",
#     contentType =  'text/html',
#     content = function(file) {
#         # Copy the report file to a temporary directory before processing it, in
#         # case we don't have write permissions to the current working dir (which
#         # can happen when deployed).
# 
# 
# 
#         td <- file.path(tempdir())
# 
#         file.copy('LCAPmetricsReport.Rmd', file.path(tempdir(), "LCAPmetricsReport.Rmd") , overwrite = TRUE)
#         # file.copy('indicators.rds', file.path(tempdir(), "indicators.rds") , overwrite = TRUE)
#         # file.copy('metrics.rds', file.path(tempdir(), "metrics.rds") , overwrite = TRUE)
#         # file.copy('dashboard_mry.rds', file.path(tempdir(), "dashboard_mry.rds") , overwrite = TRUE)
#         file.copy('child.Rmd', file.path(tempdir(), "child.Rmd") , overwrite = TRUE)
#         # file.copy('csi_mry.rds', file.path(tempdir(), "csi_mry.rds") , overwrite = TRUE)
# 
#         # tempReport <- file.path(tempdir(), "LCAPmetricsReport.Rmd")
#         # file.copy("LCAPmetricsReport.Rmd", tempReport, overwrite = TRUE)
# 
# 
# 
#         # Set up parameters to pass to Rmd document
#         params <- list(dist = input$select)
# 
#         # Knit the document, passing in the `params` list, and eval it in a
#         # child of the global environment (this isolates the code in the document
#         # from the code in this app).
#         rmarkdown::render(file.path(tempdir(),"LCAPmetricsReport.Rmd"), # output_file = file,
#                           params = params
#                           ,envir = new.env(parent = globalenv())
#                                           )
# 
#     }
# )
# })
# 
