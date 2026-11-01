# BDA400 Assignment 6 – Stock Market Technical Analysis Dashboard

## Project Overview

This project is an interactive stock market technical analysis dashboard developed using R and Shiny as part of BDA400 – Data Science Tools and Techniques at CDI College.

The dashboard allows users to analyze historical stock prices, visualize technical indicators, and identify potential trading signals.

## Features

- Interactive stock selection: Apple (AAPL), Microsoft (MSFT), and Tesla (TSLA)
- Customizable date range
- Historical stock data retrieved from Yahoo Finance
- Stock closing price visualization
- 20-day and 50-day Simple Moving Averages (SMA)
- Relative Strength Index (RSI – 14 periods)
- Moving Average Convergence Divergence (MACD – 12, 26, 9)
- BUY, SELL, and HOLD trading signals
- Visual BUY and SELL markers on the stock price chart
- Latest trading signal summary

## Technical Indicators

### Simple Moving Averages (SMA)

The dashboard calculates 20-day and 50-day moving averages to identify price trends.

### Relative Strength Index (RSI)

RSI measures price momentum on a scale from 0 to 100. Levels of 70 and 30 are displayed as reference thresholds.

### MACD

MACD is used to analyze changes in price momentum through the MACD line and signal line.

## Trading Signal Logic

- **BUY:** The 20-day SMA crosses above the 50-day SMA.
- **SELL:** The 20-day SMA crosses below the 50-day SMA.
- **HOLD:** No crossover occurs on the trading day.

These signals are educational indicators and do not constitute financial advice.

## Technologies Used

- R
- RStudio
- Shiny
- ggplot2
- quantmod
- Yahoo Finance historical market data

## How to Run the Dashboard

1. Install R and RStudio.
2. Download the `app.R` file from this repository.
3. Install the required packages in R:

```r
install.packages(c("shiny", "ggplot2", "quantmod"))
```

4. Open `app.R` in RStudio.
5. Click **Run App**.
6. Select a stock and date range to explore the technical analysis charts and trading signals.

An internet connection is required to retrieve stock data.

## Author

Mustafa Shinnar

CDI College – BDA400 Assignment 6
