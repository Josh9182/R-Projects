library(readODS)
library(readxl)
library(jsonlite)
library(xml2)
library(tools)
library(DT)
library(tidyverse)
library(shiny)

ui <- fluidPage(
    titlePanel("Data Cleaner"),
    
    sidebarLayout(
        sidebarPanel(
            fileInput("file", "Import your CSV, JSON, XML, XLSX, or ODS file below:"), 
            selectInput("white", "Trim white space?", choices = c("yes" = "Yes", "no" = "No")), 
            selectInput("null", "Remove NULL values?", choices = c("yes" = "Yes", "no" = "No")), 
            selectInput("cols", "Remove certain columns?", choices = c("yes" = "Yes", "no" = "No")),
            selectInput("rows", "Remove certain rows?", choices = c("yes" = "Yes", "no" = "No"))), 
        mainPanel(
            uiOutput("uio"),
            dataTableOutput("table"))))

server <- function(input, output, session) {
    data <- reactive({
        req(input$file)
        file_ext <- file_ext(input$file$datapath)
        
        switch(file_ext, 
               csv <- read_csv(input$file$datapath),
               json <- fromJSON(input$file$datapath),
               xml <- read_xml(input$file$datapath),
               xls <- read_xlsx(input$file$datapath),
               ods <- read_ods(input$file$datapath), 
               stop("Incorrect file type, please restart."))})

server <- function(input, output, session) {
    data <- reactive({
        req(input$file)
        file_ext <- file_ext(input$file$datapath)
        
        switch(file_ext, 
               csv <- read_csv(input$file$datapath),
               json <- fromJSON(input$file$datapath),
               xml <- read_xml(input$file$datapath),
               xls <- read_xlsx(input$file$datapath),
               ods <- read_ods(input$file$datapath), 
               stop("Incorrect file type, please restart."))})
    
    output$uio <- renderUI({
        req(input$cols, input$rows)
        
        ui_cols <- list()
        ui_rows <- list()
        
        if (input$cols == "yes") {
            ui_cols <- c(ui_cols, list(selectInput("col_choice", "Select Columns to Remove:", choices = colnames(data()))))}
        
        else {NULL}
        
        if (input$rows == "yes") {
            ui_rows <- c(ui_rows, list(sliderInput("row_choice", "Select Rows to Remove:", min = 1, max = nrow(data()))))}
        
        else {NULL}
        
        
        ui_elements = c(ui_cols, ui_rows)
        do.call(tagList, ui_elements)})

    filtered_dt <- reactive({
        req(data())
        dt <- data()

        if (!is.null(input$col_choice)) {
            dt <- dt %>%
            select(-all_of(input$col_choice))}
    })
        
    }
