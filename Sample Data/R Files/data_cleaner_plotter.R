library(readODS)
library(readxl)
library(jsonlite)
library(xml2)
library(tools)
library(stringr)
library(DT)
library(tidyverse)
library(shiny)

ui <- fluidPage(
    titlePanel("Data Cleaner & Visualizer"), 
    
    sidebarLayout(
        sidebarPanel(
            fileInput("file", "Import your file (CSV, JSON, XML, XLSX, ODS):"),
            uiOutput("file_sidebar"),
            downloadButton("download", "Download file:")), 
        
        mainPanel(
            uiOutput("uio"), 
            dataTableOutput("table"), 
            plotOutput("plot"))))

server = function(input, output, session) {
    
    data <- reactive({
        req(input$file)
        
        file_ext <- file_ext(input$file$datapath)
        
        dt <- switch(file_ext, 
                     csv = read_csv(input$file$datapath), 
                     json = fromJSON(input$file$datapath), 
                     xml = read_xml(input$file$datapath), 
                     xlsx = read_xlsx(input$file$datapath), 
                     ods = read_ods(input$file$datapath), 
                     stop("Unsupported file type, please retry."))
        print(dt)})
    
    
    output$file_sidebar <- renderUI({
        
        if (!is.null(input$file)) {
            tagList(
                selectInput("table_view", "Table Customization:", choices = c("Yes", "No"), selected = "No"),
                uiOutput("tb_dyn"), 
                
                selectInput("plot_view", "Plot Customization:", choices = c("Yes", "No"), selected = "No"),
                uiOutput("pv_dyn"))}})
    
    output$tb_dyn <- renderUI({
        
        if (input$table_view == "Yes") {
            tagList(
                selectInput("white", "Trim white space?", choices = c("Yes", "No"), selected = "No"),
                selectInput("dupl", "Remove duplicate values?", choices = c("Yes", "No"), selected = "No"),
                selectInput("null", "Remove NULL values?", choices = c("Yes", "No"), selected = "No"),
                selectInput("case", "Change text case?", choices = c("Yes", "No"), selected = "No"),
                selectInput("cols", "Remove certain columns?", choices = c("Yes", "No"), selected = "No"),
                selectInput("rows", "Remove certain rows?", choices = c("Yes", "No"), selected = "No"))}
        else {
            NULL}})
    
    output$pv_dyn <- renderUI({
        
        if (input$plot_view == "Yes") {
            tagList(
                radioButtons("plot_type", "Choose Visualization Type:", choices = c("Pie", "Bar", "Scatter", "Jitter", "Histogram", "Lolipop")))}
        else {
            NULL}})
    
}

shinyApp(ui = ui, server = server)
