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
    output$view_sidebar <- renderUI({
        req(input$view_type)
        
        if (input$view_type != "--No Selection" && input$view_type == "Specific Location") {
            tagList(
               textInput("location", "Location:"))}})
    
    output$leaf <- renderLeaflet({
        req(input$view_type)
        req(input$view_sidebar)
        
        if (input$view_type == "--No Selection") {
            leaflet()}
        else if (input$view_type != "--No Selection" && input$view_type == "Worldwide") {
            leaflet() %>%
                addTiles() %>%
                setView(lng = 43.66253690456744, lat = -10.029940624081375, zoom = 10)}
        else if (input$view_type != "--No Selection" && input$location != "") {
            location <- input$location
            
            location_result <- geocode_OSM(location)
            
            if (!is.null(location_result$coords)) {
                leafletProxy("map") %>%
                    setView(lng = location_result$coords[1], lat = location_result$coords[2], zoom = 5)
            }
            
            
        }
    })
}

shinyApp(ui, server)
