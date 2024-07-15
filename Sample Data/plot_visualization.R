library(shiny)
library(ggplot2)
library(gganimate)
library(tidyr)
library(tidyverse)
library(JSONlite)
library(readxl)
library(readODS)

ui <- fluidPage(
    titlePanel("Plot Visualization"), 
    
    sidebarLayout(
        sidebarPanel(
            fileInput("file", "Input your File (CSV, JSON, XLS, XLSX, ODS):", accept = c(".csv", ".json", ".xls", ".xlsx", ".ods")), 
            checkboxGroupInput("x_value", "X Values:", choices = NULL), 
            selectInput("y_value", "Y Value:", choices = NULL), 
            sliderInput("xrange", "X Range:", min = 0, max = 1, value = c(0,1)), 
            sliderInput("yrange", "Y Range:", min = 0, max = 1, value = c(0,1)),
            radioButtons("plot_type", "Plot Type", choices = list("Bar Plot" = "bar",
                                                                  "Scatter Plot" = "scatter",
                                                                  "Pie Chart" = "pie")), 
            selectInput("animated", "Animated?", choices = c("Yes", "No"))), 
        
        mainPanel(
            plotOutput("plot_vis"))))
