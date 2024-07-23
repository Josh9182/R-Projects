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
                selectInput("cleaner", "Clean the data?", choices = c("Yes", "No"), selected = "No"),
                uiOutput("cleaner_dyn"),
                
                selectInput("visualizer", "Visualize the data?", choices = c("Yes", "No"), selected = "No"),
                uiOutput("vis_dyn"), 
                
                selectInput("table_view", "View table?", choices = c("Yes", "No"), selected = "No"),
                uiOutput("tb_dyn"), 
                
                selectInput("plot_view", "View plot?", choices = c("Yes", "No"), selected = "No"),
                uiOutput("pv_dyn"))}})
    
    output$cleaner_dyn <- renderUI({
          
            
        if (input$cleaner == "Yes") {
            tagList(
                selectInput("white", "Trim white space?", choices = c("Yes", "No"), selected = "No"),
                selectInput("dupl", "Remove duplicate values?", choices = c("Yes", "No"), selected = "No"),
                selectInput("null", "Remove NULL values?", choices = c("Yes", "No"), selected = "No"),
                selectInput("case", "Change text case?", choices = c("Yes", "No"), selected = "No"),
                selectInput("cols", "Remove certain columns?", choices = c("Yes", "No"), selected = "No"),
                selectInput("rows", "Remove certain rows?", choices = c("Yes", "No"), selected = "No"))}
        else {
            NULL}})  
    }

shinyApp(ui = ui, server = server)
