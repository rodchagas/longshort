library(shiny)
library(quantmod)
library(ggplot2)
library(gridExtra)

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
                   actionButton("runif", "Execute")
      ),
      
      # Show a plot of the generated distribution
      mainPanel("Analysis",
                plotOutput("graphs"),
                verbatimTextOutput("cordata"),
                verbatimTextOutput("step1")
                
      )   
)



