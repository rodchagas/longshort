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
ui <- fluidPage(
      
      # Application title
      titlePanel("Long & Short Viability"),
      
      #
      sidebarPanel("Set Parameters",
                   dateInput('dateFrom', 
                             label = "Date from:",
                             value = Sys.Date()-100,
                             format = "yyyy-mm-dd"
                   ),
                   dateInput('dateTo', 
                             label = "Date to:",
                             value = Sys.Date(), 
                             format = "yyyy-mm-dd"
                   ),
                   textInput('Ticker1', label = "Ticker Symbol 01:"
                   ),
                   textInput('Ticker2', label = "Ticker Symbol 02:"
                   ),
                   actionButton("runif", "Execute"),
                   actionButton("reset","Clear")
      ),
      
      # Show a plot of the generated distribution
      mainPanel("Analysis",
                plotOutput("graphs"),
                #plotOutput("analise2"),
                verbatimTextOutput("cordata"),
                verbatimTextOutput("step1"),
                verbatimTextOutput("step2")
                
      )   
)

# Run the application 
App <- shinyApp(ui = ui.R, server = server.R)
