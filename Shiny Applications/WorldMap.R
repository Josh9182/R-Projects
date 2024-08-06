library(tidyverse)
library(shiny)
library(shinyjs)
library(leaflet)

ui <- fluidPage(
    titlePanel("Map Viewer"), 
    
    sidebarLayout(
        sidebarPanel(
            selectInput("view_type", "View Type:", choices = c("--No Selection","Worldwide", "Specific Location"), selected = "--No Selection"), 
            uiOutput("view_sidebar"), 
            uiOutput("download")), 
        mainPanel(
            leafletOutput("leaf", height = "900px", width = "1200px"))))

server <- function(input, output) {
    output$leaf <- renderLeaflet({
        leaflet() %>%
            addTiles()})}

shinyApp(ui, server)
