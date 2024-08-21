library(readODS)
library(readxl)
library(jsonlite)
library(xml2)
library(tools)
library(stringr)
library(DT)
library(tidyverse)
library(shiny)
library(shinyjs)

ui <- fluidPage(
    useShinyjs(), 
    titlePanel("Warrant Cancellation Automation"),
    
    sidebarLayout(
        sidebarPanel(
            fileInput("file", "Import your file:"), 
            uiOutput("file_sidebar")),
        mainPanel(
            DTOutput("table"))))

server <- function(input, output, session) {
    data <- reactive({
        req(input$file)
        
        file_ext <- file_ext(input$file$datapath)
        
        fp <- switch(file_ext, 
                     csv = read_csv(input$file$datapath), 
                     json = fromJSON(input$file$datapath), 
                     xml = read_xml(input$file$datapath), 
                     xlsx = read_xlsx(input$file$datapath), 
                     ods = read_ods(input$file$datapath), 
                     stop("Unsupported file type, please retry."))
        return(fp)})
    
    output$file_sidebar <- renderUI({
        req(input$file)
        
        if(!is.null(input$file)) {
            tagList(
                selectInput("table_view", "Table Customization:", choices = c("Yes", "No"), selected = "No"), 
                uiOutput("tb_dyn"),
                
                actionButton("cancel_button", "Begin Cancellation Process"))}})
    
    output$table <- renderDT({
        fdt <- data()
        req(fdt)
        
        if (nrow(fdt) == 0) {
            return(NULL)}
        datatable(fdt)})}
