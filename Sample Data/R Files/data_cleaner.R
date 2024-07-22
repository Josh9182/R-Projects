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
            selectInput("dupl", "Remove duplicate values?", choices = c("Yes", "No"), selected = "No"),
            selectInput("null", "Remove NULL values?", choices = c("Yes", "No"), selected = "No"),
            selectInput("case", "Change text case?", choices = c("Yes", "No"), selected = "No"),
            selectInput("cols", "Remove certain columns?", choices = c("Yes", "No"), selected = "No"),
            selectInput("rows", "Remove certain rows?", choices = c("Yes", "No"), selected = "No"), 
            downloadButton("download", "Download File:")),
        
        mainPanel(
            uiOutput("uio"),
            dataTableOutput("table"))))

server <- function(input, output, session) {
    data <- reactive({
        req(input$file)
        file_ext <- file_ext(input$file$datapath)
        
        dt <- switch(file_ext, 
                     csv = read_csv(input$file$datapath),
                     json = fromJSON(input$file$datapath),
                     xml = read_xml(input$file$datapath),
                     xlsx = read_xlsx(input$file$datapath),
                     ods = read_ods(input$file$datapath), 
                     stop("Incorrect file type, please restart."))
        dt})
    
    observe({
        req(data())
        dt <- data()
        
        output$uio <- renderUI({
            ui_cols <- list()
            ui_rows <- list()
            ui_case <- list()
            
            if (input$cols == "Yes") {
                ui_cols <- c(ui_cols, 
                             list(selectInput("col_choice", "Select Columns to Remove:", choices = colnames(dt), multiple = TRUE)))}
            
            if (input$rows == "Yes") {
                ui_rows <- c(ui_rows, 
                             list(numericInput("row_choice", "Select Rows to Remove:", min = 0, max = nrow(dt), value = 0, step = 1)))}
                             
            if (input$case == "Yes") {
                ui_case <- c(ui_case, 
                             list(radioButtons("case_choice", "Select Case Change:", choices = c("Upper" = "Upper", "Lower" = "Lower"))))}
            
            ui_elements <- c(ui_cols, ui_rows, ui_case)
            do.call(tagList, ui_elements)})})
    
    filtered_dt <- reactive({
        req(data())
        dt <- data()
        
        if (!is.null(input$col_choice) && length(input$col_choice) > 0) {
            dt <- dt %>%
                select(-all_of(input$col_choice))}
        
        if (!is.null(input$row_choice) && input$row_choice > 0) {
            dt <- dt %>%
                slice(-(1:input$row_choice))}
        
        if (!is.null(input$case_choice)) {
            if (input$case_choice == "Upper") {
                dt <- dt %>%
                    mutate(across(where(is.character), ~ str_to_upper(.)))}
                
            else if (input$case_choice == "Lower") {
                dt <- dt %>%
                    mutate(across(where(is.character), ~ str_to_lower(.)))}}
        
        if (input$white == "Yes") {
            dt <- dt %>%
                mutate(across(where(is.character), ~ str_trim(.)))}

        if (input$dupl == "Yes") {
            dt <- dt %>%
                distinct()}
        
        if (input$null == "Yes") {
            dt <- dt %>%
                drop_na()}
            dt})
    
    output$table <- renderDataTable({
        dt <- filtered_dt()
        req(dt)
        if (nrow(dt) == 0) {
            return(NULL)}
        datatable(dt)})
    
    output$download <- downloadHandler(
        filename = function() {
            paste0("cleaned_data.", file_ext(input$file$name))},
        
        content = function(file) {
            dt <- filtered_dt()
            req(dt)
            file_ext <- file_ext(input$file$name)
            
            switch(file_ext, 
                   csv = write_csv(dt, file),
                   json = write_json(dt, file),
                   xml = write_xml(dt, file),
                   xlsx = write_xlsx(dt, file),
                   ods = write_ods(dt, file), 
                   stop("Incorrect file type, please restart."))})}

shinyApp(ui = ui, server = server)
