#


library(shiny)

shinyServer(function(input, output) {
# Define server logic required to draw a histogram
output$report <- downloadHandler(
    filename = "LCAP_Metrics_report.html",
    content = function(file) {
        # Copy the report file to a temporary directory before processing it, in
        # case we don't have write permissions to the current working dir (which
        # can happen when deployed).
    #    tempReport <- file.path(tempdir(), "LCAPmetricsReport.Rmd")
   #     file.copy("LCAPmetricsReport.Rmd", tempReport, overwrite = TRUE)
        
        # Set up parameters to pass to Rmd document
        params <- list(dist = input$select)
        
        # Knit the document, passing in the `params` list, and eval it in a
        # child of the global environment (this isolates the code in the document
        # from the code in this app).
        rmarkdown::render("LCAPmetricsReport.Rmd",  output_file = file,
                          params = params
                          ,envir = new.env(parent = globalenv())
                                          )
        
    }
)
})

