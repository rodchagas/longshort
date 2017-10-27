library(shiny)
library(quantmod)
library(ggplot2)
library(gridExtra)

server <- function(input, output) {
      
      v <- reactiveValues(data = NULL)
      
      observeEvent(input$runif,{
            v$title <- paste("Stocks prices:",input$Ticker1," x ", input$Ticker2)
            v$title_ratio <- paste("Ratio:",input$Ticker1,"/", input$Ticker2)
            
            
            v$teste01 <- as.Date(input$dateFrom)
            
            v$Ticker1 <- input$Ticker1
            v$Ticker2 <- input$Ticker2
            v$dateTo  <- input$dateTo
            v$dateFrom <- input$dateFrom
            
            if( (v$Ticker1 != "") & (v$Ticker2 != "") &
                (!is.null(v$dateTo))  & (!is.null(v$dateFrom )) ){
                  
                  data.stock1 <- getSymbols(as.character(input$Ticker1),
                                            src="google", 
                                            from = input$dateFrom, 
                                            to   = input$dateTo,
                                            warnings = FALSE,
                                            env=environment())
                  
                  data.stock2 <- getSymbols(as.character(input$Ticker2),
                                            src="google", 
                                            from = input$dateFrom, 
                                            to   = input$dateTo,
                                            warnings = FALSE,
                                            env=environment())
                  
                  stock1.xts <- get(data.stock1)[,1:4]
                  stock2.xts <- get(data.stock2)[,1:4]  
                  
                   m.stock1 <- to.monthly(stock1.xts)
                   m.stock2 <- to.monthly(stock2.xts)
                  
                  o.stock1 <- Op(m.stock1)
                  o.stock2 <- Op(m.stock2)
                  
                  ts1.stock1 <- ts(o.stock1, frequency = 12)
                  ts1.stock2 <- ts(o.stock2, frequency = 12)
                  
                  #Store data into global variable
                  v$df.stock1 <- data.frame(value=coredata(m.stock1),timestamp=index(m.stock1))
                  v$df.stock2 <- data.frame(value=coredata(m.stock2),timestamp=index(m.stock2))
                  
                  df.stock1 <- data.frame(value=coredata(m.stock1),timestamp=index(m.stock1))
                  df.stock2 <- data.frame(value=coredata(m.stock2),timestamp=index(m.stock2))
                  
                  v$long.short.cond1 <- cor(df.stock1$value.stock1.xts.Open, 
                                            df.stock2$value.stock2.xts.Open)
                  
                  v$p1 <- ggplot() + 
                        geom_line(data = df.stock1, aes(x=timestamp, y=value.stock1.xts.Open, color = "Ticker1" )) +
                        geom_line(data = df.stock2, aes(x=timestamp, y=value.stock2.xts.Open, color = "Ticker2")) +
                        scale_color_manual(name = "Colors", 
                                           values = c("Ticker1" ="red", "Ticker2"="blue")) +
                        labs( x = "Period - Month",
                              y = "Stock Open Price") + 
                        ggtitle(v$title) + 
                        theme(plot.title = element_text(hjust = 0.5))
                  
                  dif.data <- abs(df.stock1 - df.stock2)
                  rel.data <-    df.stock1 /df.stock2  
                  rel.data$timestamp <- df.stock1$timestamp 
                  v$p2 <- ggplot() + 
                        geom_line(data = rel.data, aes(timestamp, value.stock1.xts.Open), color = "purple") +
                        geom_hline(yintercept = mean(rel.data$value.stock1.xts.Open), color = alpha("green")) +
                        geom_hline(yintercept = quantile(rel.data$value.stock1.xts.Open)[2], color = alpha("blue"))+
                        geom_hline(yintercept = quantile(rel.data$value.stock1.xts.Open)[4], color = alpha("red")) +
                        labs( x = "Period - Month",
                              y = "Ratio Ticker 01 / Ticker 02") + 
                        scale_color_manual(values = c("purple", "green", "blue", "red")) +
                        ggtitle(v$title_ratio) + 
                        theme(plot.title = element_text(hjust = 0.5)) 
                  
                  v$long.short.cond1 <- cor(df.stock1$value.stock1.xts.Open, 
                                            df.stock2$value.stock2.xts.Open)                  
                  
            } else {
                  v$df.stock1 <- NULL
                  v$df.stock2 <- NULL
                  df.stock1   <- NULL
                  df.stock2   <- NULL
                  v$long.short.cond1  <- NULL
                  v$p1 <- ggplot() + 
                        labs( x = "Period - Month",
                              y = "Stock Open Price") + 
                        scale_color_discrete(name = "Stock Tickers", 
                                             labels = c("Ticker 1" ,"Ticker2")) +
                        ggtitle("Please insert all parameters") + 
                        theme(plot.title = element_text(hjust = 0.5))
                  v$p2 <- ggplot() + 
                        labs( x = "Period - Month",
                              y = "Ratio Ticker 01 / Ticker 02") + 
                        scale_color_discrete(name = "Stock Tickers", 
                                             labels = c("Ticker 1" ,"Ticker2")) +
                        ggtitle("Please insert all parameters") + 
                        theme(plot.title = element_text(hjust = 0.5))
                  
                  
            }
      })
      
      output$step1 <- renderText({
            
            if (is.null(v$df.stock1)) return()
            df.stock1 <- v$df.stock1 
            df.stock2 <- v$df.stock2 
            
            dif.data <- abs(df.stock1 - df.stock2)
            rel.data <-    df.stock1 /df.stock2  
            rel.data$timestamp <- df.stock1$timestamp 
            dim(rel.data)[1]
            
            if(abs(v$long.short.cond1 > 0.8)) {
                  if(rel.data[dim(rel.data)[1],1]>quantile(rel.data$value.stock1.xts.Open)[2] && 
                     rel.data[dim(rel.data)[1],1]<quantile(rel.data$value.stock1.xts.Open)[4]){
                        paste("Step 2: Not Ok - Long&Short not recomendable. Ratio between first and third quantile")               
                  } else if(rel.data[dim(rel.data)[1],1]<quantile(rel.data$value.stock1.xts.Open)[2] ) {
                        paste("Step 2: Ok - Long&Short recomendation - Short:", v$Ticker2,  " Long: " , v$Ticker1)
                  } else {
                        paste("Step 2: Ok - Long&Short recomended - Short:", v$Ticker1,  " Long: " , v$Ticker2)
                  }
            }
            
      })
      
      output$cordata <- renderText({
            if ( is.null(v$long.short.cond1) ){long.short.cond1 <- 0 }else{
                  long.short.cond1 <- v$long.short.cond1}
            
            if(abs(long.short.cond1 > 0.8)) {
                  paste("Step 1: OK - Stocks are high correlated:", round(long.short.cond1,2) )
            } else {
                  paste("Step 1: Not OK - Stocks are not high correlated:", round(long.short.cond1,2))
            }
      })
      output$graphs <- renderPlot({
            p1 <- v$p1
            p2 <- v$p2
            if (is.null(p1)) {
                  v$p1 <- ggplot() + 
                        labs( x = "Period - Month",
                              y = "Stock Open Price") + 
                        scale_color_discrete(name = "Stock Tickers", 
                                             labels = c("Ticker 1" ,"Ticker2")) +
                        ggtitle("Please insert all parameters") + 
                        theme(plot.title = element_text(hjust = 0.5))
                  v$p2 <- ggplot() + 
                        labs( x = "Period - Month",
                              y = "Stock Open Price") + 
                        scale_color_discrete(name = "Stock Tickers", 
                                             labels = c("Ticker 1" ,"Ticker2")) +
                        ggtitle("Please insert all parameters") + 
                        theme(plot.title = element_text(hjust = 0.5))               
            }
            grid.arrange(p1,p2, ncol=2, top = "Long & Short")
      })
      
}



