library(readODS)
library(readxl)
library(jsonlite)
library(xml2)
library(tools)
library(tidyverse)
library(shiny)
library(shinyjs)
library(heatmaply)
library(plotly)

ui <- fluidPage(
    titlePanel("Heat Map Visualizer"), 
    
    sidebarLayout(
        sidebarPanel(
            fileInput("file", 
                      HTML('<div style="text-align: center;">
                   Import your file:<br>(CSV, JSON, XML, XLSX, ODS)
                 </div>')), 
            uiOutput("file_sidebar")),
        
        mainPanel(
            plotlyOutput("heatmap", height = "1000px", width = "1000px"))))

server <- function(input, output, session) {
    data <- reactive({
        req(input$file)
        
        file_ext <- file_ext(input$file$datapath)
        
        fe <- switch(file_ext, 
                     csv = read_csv(input$file$datapath), 
                     json = fromJSON(input$file$datapath), 
                     xml = read_xml(input$file$datapath), 
                     xlsx = read_xlsx(input$file$datapath), 
                     ods = read_ods(input$file$datapath), 
                     stop("Unsupported file type, please retry."))
        
        print(fe)})
    
    output$file_sidebar <- renderUI({
        req(input$file)
        req(data)
        
        tagList(
            selectInput("cols", "Select Columns:", choices = numeric_cols, multiple = TRUE),
            sliderInput("rows", "Select Row Amount:", min = 1, max = nrow(data()), value = nrow(data()), step = 1),
            selectInput("gradient", "Colors for gradient:", 
                        choices = c("Blue", "Purple", "Green", "Yellow", "Orange", "Red"), 
                        multiple = TRUE))})
    
    observeEvent(input$cols, {
        
        if (!is.null(input$cols)) {
            numeric_cols <- colnames(data())[sapply(data(), is.numeric)]
            
            updateSelectInput(session, "cols", choices = numeric_cols, selected = input$cols)}})
    
    observe({
        req(input$cols)
        req(input$gradient)
        
        if (length(input$cols) > 2) {
            updateSelectInput(session, "cols", selected = input$cols[1:2])}
        
        if (length(input$gradient) > 2) {
            updateSelectInput(session, "gradient", selected = input$gradient[1:2])}})
    
    output$heatmap <- renderPlotly({
        req(input$cols)
        req(input$rows)
        
        df <- data()
        
        if (length(input$cols) < 2) {
            return(NULL)}
        else {
            df <- df[1:input$rows, input$cols, drop = FALSE]
            
            heatmaply(df, colors = input$gradient, xlab = "Columns", ylab = "Rows", main = paste("Heatmap of", input$cols[1], "Vs.", input$cols[2]))}})}


shinyApp(ui, server)
