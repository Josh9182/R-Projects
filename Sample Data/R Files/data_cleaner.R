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
            selectInput("white", "Trim white space?", choices = c("Yes", "No"), selected = "No"), 
            selectInput("null", "Remove NULL values?", choices = c("Yes", "No"), selected = "No"), 
            selectInput("cols", "Remove certain columns?", choices = c("Yes", "No"), selected = "No"),
            selectInput("rows", "Remove certain rows?", choices = c("Yes", "No"), selected = "No")),
        
        mainPanel(
            uiOutput("uio"),
            dataTableOutput("table"))))

server <- function(input, output, session) {
    data <- reactive({
        req(input$file)
        file_ext <- tools::file_ext(input$file$datapath)
        
        df <- switch(file_ext, 
                     csv = read_csv(input$file$datapath),
                     json = fromJSON(input$file$datapath),
                     xml = read_xml(input$file$datapath),
                     xls = read_xlsx(input$file$datapath),
                     ods = read_ods(input$file$datapath), 
                     stop("Incorrect file type, please restart."))
        
        print("Data loaded:")
        print(head(df))
        
        df})
    
    observe({
        req(data())
        df <- data()
        
        output$uio <- renderUI({
            ui_cols <- list()
            ui_rows <- list()
            
            if (input$cols == "Yes") {
                ui_cols <- c(ui_cols, 
                             list(selectInput("col_choice", "Select Columns to Remove:", choices = colnames(df), multiple = TRUE)))}
            
            if (input$rows == "Yes") {
                ui_rows <- c(ui_rows, 
                             list(sliderInput("row_choice", "Select Rows to Remove:", min = 1, max = floor(nrow(df)), value = c(1, floor(nrow(df))))))}
            
            ui_elements <- c(ui_cols, ui_rows)
            do.call(tagList, ui_elements)})})
    
    filtered_dt <- reactive({
        req(data())
        dt <- data()
        
        print("Initial data:")
        print(head(dt))
        
        if (!is.null(input$col_choice) && length(input$col_choice) > 0) {
            dt <- dt %>%
                select(-all_of(input$col_choice))
            print("After column removal:")
            print(head(dt))}
        
        if (!is.null(input$row_choice)) {
            row_range <- input$row_choice
            dt <- dt[-seq(row_range[1], row_range[2]), ]
            print("After row removal:")
            print(head(dt))}
        
        if (input$white == "Yes") {
            dt <- dt %>%
                mutate(across(where(is.character), ~ trimws(.)))
            print("After trimming white space:")
            print(head(dt))}
        
        if (input$null == "Yes") {
            dt <- dt %>%
                na.omit()
            print("After removing NULL values:")
            print(head(dt))}
        dt})
    
    output$table <- renderDataTable({
        df <- filtered_dt()
        req(df)
        if (floor(nrow(df)) == 0) {
            return(NULL)}
        datatable(df)})}

shinyApp(ui = ui, server = server)
