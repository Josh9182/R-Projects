library(shiny)
library(ggplot2)
library(gganimate)
library(tidyr)
library(tools)
library(tidyverse)
library(jsonlite)
library(readxl)
library(readODS)
library(hunspell)
library(lubridate)

ui <- fluidPage(
    titlePanel("Plot Visualization"), 
    
    sidebarLayout(
        sidebarPanel(
            fileInput("file", "Input your File (CSV, JSON, XLS, XLSX, ODS):", accept = c(".csv", ".json", ".xls", ".xlsx", ".ods")), 
            checkboxGroupInput("x_value", "X Values:", choices = NULL), 
            selectInput("y_value", "Y Value:", choices = NULL), 
            sliderInput("xrange", "X Range:", min = 0, max = 1, value = c(0,1)), 
            sliderInput("yrange", "Y Range:", min = 0, max = 1, value = c(0,1)),
            radioButtons("plot_type", "Plot Type:", choices = list("Bar Plot" = "bar",
                                                                  "Scatter Plot" = "scatter",
                                                                  "Pie Chart" = "pie")), 
            selectInput("animated", "Toggle Animated:", choices = c("Yes", "No"))), 
        
        mainPanel(
            plotOutput("plot_vis"))))

server <- function(input, output, session) {
    dt <- reactive({
        req(input$file)
        file_ext <- file_ext(input$file$datapath)
        
        if (file_ext == "csv") {
            read.csv(input$file$datapath)}
        
        else if (file_ext == "json") {
            fromJSON(input$file$datapath)}
        
        else if (file_ext %in% c("xls", "xlsx")) {
            read_xlsx(input$file$datapath)}
        
        else if (file_ext == "ods") {
            read_ods(input$file$datapath)}
        
        else {
            stop("Unsupported file type. Please stick to the file requirements: CSV, JSON, XLS, XLSX, or ODS")}})
            
            clean_dt <- reactive({
                req(dt())
                
                if (!is.null(dt()) && nrow(dt()) > 0 && ncol(dt()) > 0) {
                dt() %>%
                    na.omit() %>%
                    mutate_if(is.character, function(x) str_to_lower(hunspell_suggest(trimws(x)))) %>%
                    unique() %>%
                    mutate_if(is.character, function(x) str_replace_all(x, ",", ""))}
                else {
                    stop("Empty Dataframe unable to visualize, please upload different file.")}})
            
            
    output$cleaned_data <- renderPlot({
        clean_dt()})}

    observe({
        req(clean_dt())
        
        updateCheckboxGroupInput(session, "x_value", choices = colnames(clean_dt()), selected = colnames(clean_dt())[1])
        updateSelectInput(session, "y_value", choices = colnames(clean_dt()), selected = colnames(clean_dt())[2])
        
        numeric_data <- clean_dt() %>%
            select(where(is.numeric))
        
        updateSliderInput(session, "xrange", min = min(numeric_data), max = max(numeric_data), value = c(min(numeric_data), max(numeric_data)))
        updateSliderInput(session, "yrange", min = min(numeric_data), max = max(numeric_data), value = c(min(numeric_data), max(numeric_data)))
    })
