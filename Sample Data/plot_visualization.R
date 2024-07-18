library(shiny)
library(ggplot2)
library(gganimate)
library(tidyr)
library(stringr)
library(tools)
library(tidyverse)
library(jsonlite)
library(readxl)
library(readODS)
library(hunspell)
library(lubridate)

ui <- fluidPage(
    titlePanel("Plot Visualization"), 
    
    sidebarLayout(
        sidebarPanel(
            fileInput("file", "Input your File (CSV, JSON, XLS, XLSX, ODS):", 
                      accept = c(".csv", ".json", ".xls", ".xlsx", ".ods")), 
            checkboxGroupInput("x_value", "X Values:", choices = NULL), 
            selectInput("y_value", "Y Value:", choices = NULL), 
            sliderInput("xrange", "X Range:", min = 0, max = 1, value = c(0,1)), 
            sliderInput("yrange", "Y Range:", min = 0, max = 1, value = c(0,1)),
            radioButtons("plot_type", "Plot Type:", choices = list("Bar Plot" = "bar",
                                                                   "Scatter Plot" = "scatter",
                                                                   "Pie Chart" = "pie")), 
            selectInput("animated", "Toggle Animated:", choices = c("Yes", "No"))), 
        
        mainPanel(
            uiOutput("plot_vis"))))

server <- function(input, output, session) {
    dt <- reactive({
        req(input$file)
        file_ext <- file_ext(input$file$datapath)
        
        if (file_ext == "csv") {
            read.csv(input$file$datapath)}
        
        else if (file_ext == "json") {
            fromJSON(input$file$datapath)}
        
        else if (file_ext %in% c("xls", "xlsx")) {
            read_xlsx(input$file$datapath)}
        
        else if (file_ext == "ods") {
            read_ods(input$file$datapath)}
        
        else {
            stop("Unsupported file type. Please stick to the file requirements: CSV, JSON, XLS, XLSX, or ODS")}})
    
    clean_dt <- reactive({
        req(dt())
        
        if (!is.null(dt()) && nrow(dt()) > 0 && ncol(dt()) > 0) {
            dt() %>%
                na.omit() %>%
                mutate_if(is.character, function(x) str_to_lower(hunspell_suggest(trimws(x)))) %>%
                unique() %>%
                mutate_if(is.character, function(x) str_replace_all(x, ",", ""))}
        else {
            stop("Empty Dataframe unable to visualize, please upload different file.")}})
    
    observe({
        req(clean_dt())
        
        updateCheckboxGroupInput(session, "x_value", choices = colnames(clean_dt()), selected = colnames(clean_dt())[1])
        updateSelectInput(session, "y_value", choices = colnames(clean_dt()), selected = colnames(clean_dt())[2])
        
        numeric_data <- clean_dt() %>%
            select(where(is.numeric))

        if (ncol(numeric_data) > 0) {
        
        updateSliderInput(session, "xrange", min = min(numeric_data), max = max(numeric_data), 
                          value = c(min(numeric_data), max(numeric_data)))
        updateSliderInput(session, "yrange", min = min(numeric_data), max = max(numeric_data), 
                          value = c(min(numeric_data), max(numeric_data)))}})

    output$plot_ui <- renderUI({
        req(filtered_dt())
        
        if (input$animated == "No") {plotOutput("plot_vis")} 
        else {imageOutput("animated_plot")}})
    
    output$static_plot <- renderPlot({
        req(filtered_dt(), input$animated == "No")
        
        plot_dt <- clean_dt() %>%
            select(all_of(c(input$x_value, input$y_value)))
        
        if (input$plot_type == "bar") {
            ggplot(plot_dt, aes_string(x = input$x_value, y = input$y_value, fill = input$x_value)) +
                geom_bar(stat = "identity", position = "dodge", linewidth = 1, color = "black") +
                coord_flip() + 
                labs(title = paste(paste(input$x_value, sep = ", "), "by", input$y_value), x = paste(input$x_value, sep = ","), y = input$y_value) +
                
                theme_minimal() +
                theme(panel.grid = element_line(linewidth = .5, color = "black"),
                      axis.text.x = element_text(size = 15, face = "bold", color = "black", 
                                                 margin = margin(b = 10)),
                      axis.text.y = element_text(size = 15, face = "bold", color = "black", 
                                                 margin = margin(l = 10)),
                      plot.title = element_text(size = 25, hjust = -.5),
                      axis.title = element_text(size = 20),
                      legend.text = element_text(size = 15),
                      legend.title = element_text(size = 18))}
        
        else if (input$plot_type == "scatter") {
            ggplot(plot_dt, aes_string(x = input$x_value, y = input$y_value, fill = input$x_value)) +
                geom_point(size = 6, alpha = .8) +
                coord_flip() + 
                labs(title = paste(paste(input$x_value, sep = ", "), "by", input$y_value), x = paste(input$x_value, sep = ","), y = input$y_value) +
                
                scale_color_gradient(low = "blue", high = "red") +
                
                theme_minimal() +
                theme(panel.grid = element_line(linewidth = .5, color = "black"),
                      axis.text.x = element_text(size = 15, face = "bold", color = "black", 
                                                 margin = margin(b = 10)),
                      axis.text.y = element_text(size = 15, face = "bold", color = "black", 
                                                 margin = margin(l = 10)),
                      plot.title = element_text(size = 25, hjust = -.5),
                      axis.title = element_text(size = 20),
                      legend.text = element_text(size = 15),
                      legend.title = element_text(size = 18))}
        
        else if (input$plot_type == "pie") {
            ggplot(plot_dt, aes_string(x = "", y = input$y_value, fill = input$x_value)) +
                geom_bar(stat = "identity", linewidth = 2, color = "white") +
                coord_polar(theta = "y") +
            labs(title = paste(input$y_value, "Pie Chart"), y = input$y_value, fill = input$x_value) +
                
                theme_minimal() +
                theme(plot.title = element_text(size = 25, hjust = -.5),
                      legend.text = element_text(size = 15),
                      legend.title = element_text(size = 18))}})
    
    output$anim_plot <- renderImage({
        req(filtered_dt, input$animated == "Yes")
        
        plot_dt <- filtered_dt %>%
            select(all_of(input$x_value, input$y_value))

        if (input$plot_type == "bar") {
            bar_plot <- ggplot(plot_dt, aes_string(x = input$x_value, y = input$y_value, fill = input$x_value)) +
                geom_bar(stat = "identity", position = "dodge", linewidth = 1, color = "black") +
                coord_flip() + 
                labs(title = paste(paste(input$x_value, sep = ", "), "by", input$y_value), x = paste(input$x_value, sep = ","), y = input$y_value) +
                
                theme_minimal() +
                theme(panel.grid = element_line(linewidth = .5, color = "black"),
                      axis.text.x = element_text(size = 15, face = "bold", color = "black", 
                                                 margin = margin(b = 10)),
                      axis.text.y = element_text(size = 15, face = "bold", color = "black", 
                                                 margin = margin(l = 10)),
                      plot.title = element_text(size = 25, hjust = -.5),
                      axis.title = element_text(size = 20),
                      legend.text = element_text(size = 15),
                      legend.title = element_text(size = 18))
            
            bp_animated <- bar_plot + transition_states(input$x_value, transition_length = 1, state_length = 1) + 
            enter_grow() + exit_shrink()
            
            animate(bp_animated, nframes = 100, fps = 20, renderer = gifski_renderer())}

        else if (input$plot_type == "scatter") {
            scatter_plot <- ggplot(plot_dt, aes_string(x = input$x_value, y = input$y_value, fill = input$x_value)) +
                geom_point(size = 6, alpha = .8) +
                coord_flip() + 
                labs(title = paste(paste(input$x_value, sep = ", "), "by", input$y_value), x = paste(input$x_value, sep = ","), y = input$y_value) +
                
                scale_color_gradient(low = "blue", high = "red") +
                
                theme_minimal() +
                theme(panel.grid = element_line(linewidth = .5, color = "black"),
                      axis.text.x = element_text(size = 15, face = "bold", color = "black", 
                                                 margin = margin(b = 10)),
                      axis.text.y = element_text(size = 15, face = "bold", color = "black", 
                                                 margin = margin(l = 10)),
                      plot.title = element_text(size = 25, hjust = -.5),
                      axis.title = element_text(size = 20),
                      legend.text = element_text(size = 15),
                      legend.title = element_text(size = 18))
            
            sp_animated + transition_states(input$x_value, transition_length = 1, state_length = 1) + 
            enter_grow() + exit_shrink()
            
            animate(sp_animated, nframes = 100, fps = 20, renderer = gifski_renderer())}

        else if (input$plot_type == "pie") {
            pie_plot <- ggplot(plot_dt, aes_string(x = "", y = input$y_value, fill = input$x_value)) +
                geom_bar(stat = "identity", linewidth = 2, color = "white") +
                coord_polar(theta = "y") +
            labs(title = paste(input$y_value, "Pie Chart"), y = input$y_value, fill = input$x_value) +
                
                theme_minimal() +
                theme(plot.title = element_text(size = 25, hjust = -.5),
                      legend.text = element_text(size = 15),
                      legend.title = element_text(size = 18))
            
            pp_animated + transition_states(input$x_value, transition_length = 1, state_length = 1) + 
            enter_grow() + exit_shrink()
            
            animate(pp_animated, nframes = 100, fps = 20, renderer = gifski_renderer())}})}

shinyApp(ui = ui, server = server)
