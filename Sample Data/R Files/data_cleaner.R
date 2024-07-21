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
            selectInput("white", "Trim white space?", choices = NULL), 
            selectInput("null", "Remove NULL values?", choices = NULL), 
            checkboxGroupInput("cols", "Remove certain columns?", choices = NULL),
            selectInput("row_choice", "Remove certain rows?", choices = NULL)), 
        mainPanel(
            dataTableOutput("table"))))

server <- function(input, output, session) {
    data <- reactive({
        req(input$file)
        file_ext <- file_ext(input$file$datapath)
        
        switch(file_ext, 
               )
    })
}
