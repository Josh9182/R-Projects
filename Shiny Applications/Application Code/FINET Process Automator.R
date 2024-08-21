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
    
    filtered_data <- reactive({
        req(data)
        fdt <- data()
        
        if(!is.null(fdt) && nrow(fdt) > 0) {
            fdt <- fdt %>%
                distinct() %>%
                mutate(across(where(is.character), ~ str_trim(.)))
            
        data.frame(fdt)}})
    
    output$file_sidebar <- renderUI({
        req(input$file)
        
        if(!is.null(input$file)) {
            tagList(
                selectInput("table_view", "Table Customization:", choices = c("Yes", "No"), selected = "No"), 
                uiOutput("tb_dyn"),
                
                actionButton("cancel_button", "Begin Cancellation Process"))}
        else {
            stop("Unable to render, please do not import empty file.")}})
    
    output$tb_dyn <- renderUI({
        req(input$table_view)
        req(filtered_data)
        fdt <- filtered_data()
        
        
        if (input$table_view == "Yes") {
            tagList(
                selectInput("cols", "Remove Columns:", choices = colnames(fdt), multiple = TRUE), 
                sliderInput("rows", "Select Rows:", min = 0, max = nrow(fdt), value = c(0,nrow(fdt)), step = 1))}})
    
    filtered_dt <- reactive({
        req(filtered_data)
        fdt <- filtered_data()
        
        if (!is.null(fdt) && nrow(fdt) > 0) {
            if (!is.null(input$cols)) {
                fdt <- fdt %>%
                    select(-all_of(input$cols))}
            
            if (!is.null(input$rows)) {
                fdt <- fdt %>%
                    slice(input$rows[1]:input$rows[2])}  

        data.frame(fdt)}})
    
    output$table <- renderDT({
        fdt <- filtered_dt()
        req(fdt)
        
        if (nrow(fdt) == 0) {
            return(NULL)}
        datatable(fdt)})}
