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
            selectInput("row_choice", "Remove certain rows?", choices = c("yes" = "Yes", "no" = "No"))), 
        mainPanel(
            uiOutput("ui"),
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
    }
