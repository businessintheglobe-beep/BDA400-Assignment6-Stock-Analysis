
# BDA400 Assignment 6
# Technical Analysis Using R - Visualization Phase
# Interactive Stock Analysis Dashboard

library(shiny)
library(ggplot2)
library(quantmod)

# USER INTERFACE
ui <- fluidPage(
  
  titlePanel("Stock Market Technical Analysis Dashboard"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      selectInput(
        "stock",
        "Select Stock:",
        choices = c(
          "Apple (AAPL)" = "AAPL",
          "Microsoft (MSFT)" = "MSFT",
          "Tesla (TSLA)" = "TSLA"
        )
      ),
      
      dateRangeInput(
        "dates",
        "Select Date Range:",
        start = "2024-01-01",
        end = Sys.Date(),
        max = Sys.Date()
      )
      
    ),
    
    mainPanel(
      h3("Latest Trading Signal"),
      verbatimTextOutput("trading_signal"),
      h3("Stock Prices and Moving Averages"),
      plotOutput("stock_chart"),
      
      h3("Relative Strength Index (RSI)"),
      plotOutput("rsi_chart"),
      
      h3("MACD Technical Indicator"),
      plotOutput("macd_chart")
      
    )
  )
)

# SERVER
server <- function(input, output) {
  
  # Download and prepare stock data
  stock_data <- reactive({
    
    req(input$stock, input$dates)
    
    validate(
      need(input$dates[1] <= input$dates[2],
           "Please select a valid date range.")
    )
    
    # Download earlier data for indicator calculations
    download_start <- as.Date(input$dates[1]) - 120
    
    stock <- tryCatch(
      getSymbols(
        input$stock,
        src = "yahoo",
        from = download_start,
        to = as.Date(input$dates[2]) + 1,
        auto.assign = FALSE
      ),
      error = function(e) NULL
    )
    
    validate(
      need(!is.null(stock),
           "Unable to download stock data. Check your internet connection.")
    )
    
    data <- data.frame(
      Date = as.Date(index(stock)),
      Close = as.numeric(Cl(stock))
    )
    
    validate(
      need(nrow(data) >= 50,
           "Not enough historical data to calculate indicators.")
    )
    
    # Simple Moving Averages
    data$SMA20 <- SMA(data$Close, n = 20)
    data$SMA50 <- SMA(data$Close, n = 50)
    # Calculate Buy, Sell, and Hold signals
    
    data$TradingSignal <- "HOLD"
    
    # Compare today's moving averages with yesterday's
    previous_SMA20 <- c(NA, head(data$SMA20, -1))
    previous_SMA50 <- c(NA, head(data$SMA50, -1))
    
    # BUY when SMA20 crosses above SMA50
    buy_condition <- (
      previous_SMA20 <= previous_SMA50 &
        data$SMA20 > data$SMA50
    )
    
    # SELL when SMA20 crosses below SMA50
    sell_condition <- (
      previous_SMA20 >= previous_SMA50 &
        data$SMA20 < data$SMA50
    )
    
    # Replace missing conditions with FALSE
    buy_condition[is.na(buy_condition)] <- FALSE
    sell_condition[is.na(sell_condition)] <- FALSE
    
    # Assign signals
    data$TradingSignal[buy_condition] <- "BUY"
    data$TradingSignal[sell_condition] <- "SELL"    
    # Relative Strength Index
    data$RSI <- RSI(data$Close, n = 14)
    
    # MACD
    macd_values <- MACD(
      data$Close,
      nFast = 12,
      nSlow = 26,
      nSig = 9,
      maType = "EMA",
      percent = FALSE
    )
    
    data$MACD <- as.numeric(macd_values[, "macd"])
    data$Signal <- as.numeric(macd_values[, "signal"])
    
    # Filter to selected date range
    data <- data[
      data$Date >= input$dates[1] &
        data$Date <= input$dates[2],
    ]
    
    validate(
      need(nrow(data) > 0,
           "No trading data available for the selected dates.")
    )
    
    data
  })
  # LATEST TRADING SIGNAL SUMMARY
  output$trading_signal <- renderText({
    
    data <- stock_data()
    
    latest <- tail(data, 1)
    
    paste(
      "Stock:", input$stock,
      "\nDate:", as.character(latest$Date),
      "\nClosing Price: $", round(latest$Close, 2),
      "\nTrading Signal:", latest$TradingSignal
    )
    
  })
  
  # STOCK PRICE CHART
  output$stock_chart <- renderPlot({
    
    data <- stock_data()
    # Separate BUY and SELL signals
    buy_points <- data[data$TradingSignal == "BUY", ]
    sell_points <- data[data$TradingSignal == "SELL", ]
    
    ggplot(data, aes(x = Date)) +
      geom_line(
        aes(y = Close, color = "Closing Price"),
        linewidth = 0.8
      ) +
      geom_line(
        aes(y = SMA20, color = "SMA 20"),
        linewidth = 0.8,
        na.rm = TRUE
      ) +
      geom_line(
        aes(y = SMA50, color = "SMA 50"),
        linewidth = 0.8,
        na.rm = TRUE
      ) +
      # Green triangles indicate BUY signals
      geom_point(
        data = buy_points,
        aes(x = Date, y = Close),
        color = "darkgreen",
        shape = 24,
        fill = "limegreen",
        size = 3,
        stroke = 1
      ) +
      
      # Red triangles indicate SELL signals
      geom_point(
        data = sell_points,
        aes(x = Date, y = Close),
        color = "darkred",
        shape = 25,
        fill = "red",
        size = 3,
        stroke = 1
      ) +
      scale_color_manual(
        values = c(
          "Closing Price" = "blue",
          "SMA 20" = "red",
          "SMA 50" = "green"
        )
      ) +
      labs(
        title = paste(input$stock, "Stock Price Analysis"),
        x = "Date",
        y = "Price (USD)",
        color = "Indicator"
      ) +
      theme_minimal()
  })
  
  # RSI CHART
  output$rsi_chart <- renderPlot({
    
    data <- stock_data()
    
    ggplot(data, aes(x = Date, y = RSI)) +
      geom_line(
        color = "purple",
        linewidth = 0.8,
        na.rm = TRUE
      ) +
      geom_hline(
        yintercept = 70,
        color = "red",
        linetype = "dashed"
      ) +
      geom_hline(
        yintercept = 30,
        color = "green",
        linetype = "dashed"
      ) +
      coord_cartesian(ylim = c(0, 100)) +
      labs(
        title = paste(input$stock, "RSI (14)"),
        x = "Date",
        y = "RSI"
      ) +
      theme_minimal()
  })
  
  # MACD CHART
  output$macd_chart <- renderPlot({
    
    data <- stock_data()
    
    ggplot(data, aes(x = Date)) +
      geom_line(
        aes(y = MACD, color = "MACD"),
        linewidth = 0.8,
        na.rm = TRUE
      ) +
      geom_line(
        aes(y = Signal, color = "Signal"),
        linewidth = 0.8,
        na.rm = TRUE
      ) +
      geom_hline(
        yintercept = 0,
        linetype = "dashed"
      ) +
      scale_color_manual(
        values = c(
          "MACD" = "blue",
          "Signal" = "red"
        )
      ) +
      labs(
        title = paste(input$stock, "MACD (12, 26, 9)"),
        x = "Date",
        y = "MACD Value",
        color = "Indicator"
      ) +
      theme_minimal()
  })
  
}

# RUN DASHBOARD
shinyApp(ui = ui, server = server)
