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
library(ggplot2)

ui <- fluidPage(
    useShinyjs(),  # Make sure shinyjs is used
    titlePanel("Data Cleaner & Visualizer"),
    
    sidebarLayout(
        sidebarPanel(
            fileInput("file", "Import your file (CSV, JSON, XML, XLSX, ODS):"),
            uiOutput("file_sidebar"),
            downloadButton("download", "Download file:")
        ),
        
        mainPanel(
            uiOutput("uio"),
            dataTableOutput("table"),
            plotOutput("plot", height = 800, width = 1000))))

server = function(input, output, session) {
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
        print(fp)})
    
    output$file_sidebar <- renderUI({
        req(input$file)
        
        if (!is.null(input$file)) {
            tagList(
                selectInput("table_view", "Table Customization:", choices = c("Yes", "No"), selected = "No"),
                uiOutput("tb_dyn"), 
                
                selectInput("plot_view", "Plot Customization:", choices = c("Yes", "No"), selected = "No"),
                uiOutput("pv_dyn"))}})
    
    output$tb_dyn <- renderUI({
        req(input$table_view)
        
        if (input$table_view == "Yes") {
            tagList(
                selectInput("white", "Trim white space?", choices = c("Yes", "No"), selected = "No"),
                selectInput("dupl", "Remove duplicate rows?", choices = c("Yes", "No"), selected = "No"),
                selectInput("null", "Remove NULL rows?", choices = c("Yes", "No"), selected = "No"),
                
                selectInput("case", "Change text case?", choices = c("Yes", "No"), selected = "No"),
                uiOutput("case_choice"),
                
                selectInput("cols", "Remove certain columns?", choices = c("Yes", "No"), selected = "No"),
                uiOutput("col_choice"),
                
                selectInput("rows", "Remove certain rows?", choices = c("Yes", "No"), selected = "No"),
                uiOutput("row_choice"), 
                
                checkboxInput("hide", "Hide Table (Saves Progress):", value = FALSE))}
        else {
            NULL}})
    
    output$case_choice <- renderUI({
        req(input$case)
        
        if (input$case == "Yes") {
            tagList(
                radioButtons("case_selector", "Case Type:", choices = c("Upper", "Lower")))}
        else {
            NULL}})
    
    output$col_choice <- renderUI({
        req(input$cols)
        
        if (input$cols == "Yes") {
            tagList(
                selectInput("col_selector", "Columns to Remove:", choices = colnames(data()), multiple = TRUE))}
        else {
            NULL}})
    
    output$row_choice <- renderUI({
        req(input$rows)
        
        if (input$rows == "Yes") {
            tagList(
                sliderInput("row_selector", "Rows to Remove:", min = 0, max = nrow(data()), value = 0, step = 1))}})
    
    filtered_dt <- reactive({
        req(data)
        fdt <- data()
        
        if (!is.null(fdt) && nrow(fdt) > 0) {
            
            if (!is.null(input$white) && input$white == "Yes") {
                fdt <- fdt %>%
                    mutate(across(where(is.character), ~ str_trim(.)))}
            
            if (!is.null(input$dupl) && input$dupl == "Yes") {
                fdt <- fdt %>%
                    distinct()}
            
            if (!is.null(input$null) && input$null == "Yes") {
                fdt <- fdt %>%
                    drop_na()}
            
            if (!is.null(input$case) && input$case == "Yes") {
                if (input$case_selector == "Upper") {
                    fdt <- fdt %>%
                        mutate(across(where(is.character), ~ str_to_upper(.)))}
                else if (input$case_selector == "Lower") {
                    fdt <- fdt %>%
                        mutate(across(where(is.character), ~ str_to_lower(.)))}}
            else {
                NULL}
            
            if (!is.null(input$cols) && input$cols == "Yes") {
                if (!is.null(input$col_selector)) {
                    fdt <- fdt %>%
                        select(-all_of(input$col_selector))}}
            else {
                NULL}
            
            if (!is.null(input$rows) && input$rows == "Yes") {
                if (!is.null(input$row_selector)) {
                    fdt <- fdt %>%
                        slice(-(1:input$row_selector))}}
            
            data.frame(fdt)}
        
        else {
            data.frame()}})
    
    output$table <- renderDataTable({
        req(input$table_view == "Yes") 
        fdt <- filtered_dt()
        req(fdt)
        
        if (nrow(fdt) == 0) {
            return(NULL)}
        datatable(fdt)})
    
    observeEvent(input$hide, {
        if (input$hide) {
            output$table <- renderDataTable({NULL})
            hide("white")
            hide("dupl")
            hide("null")
            hide("case")
            hide("cols")
            hide("rows")
            hide("case_choice")
            hide("col_choice")
            hide("row_choice")}
        else {
            output$table <- renderDataTable({
                fdt <- filtered_dt()
                show("white")
                show("dupl")
                show("null")
                show("case")
                show("cols")
                show("rows")
                show("case_choice")
                show("col_choice")
                show("row_choice")
                datatable(fdt)})}})
    
    output$pv_dyn <- renderUI({
        req(input$plot_view)
        req(filtered_dt)
        fdt <- filtered_dt()
        
        if (input$plot_view == "Yes") {
            tagList(
                selectInput("x_value", "X Value:", choices = colnames(fdt)),
                selectInput("y_value", "Y Value:", choices = colnames(fdt)),
                radioButtons("plot_type", "Choose Visualization Type:", choices = c("Pie", "Bar", "Scatter", "Jitter", "Histogram", "Lolipop")))}
        else {
            NULL}})
    
    observeEvent(input$plot_type, {
        if (input$plot_type == "Pie") {
            hide("x_value")}
        else {
            show("x_value")}})
    
    output$plot <- renderPlot({
        req(input$plot_view)
        req(input$plot_type)
        req(filtered_dt)
        fdt <- filtered_dt()
        req(fdt)
        
        if (input$plot_view == "Yes") {
            
            if (input$plot_type == "Pie") {
                fdt <- fdt %>%
                    count(!!sym(input$y_value)) %>%
                    mutate(percentage = n / sum(n) * 100)
                
                ggplot(fdt, aes(x = "", y = n, fill = !!sym(input$y_value))) +
                    geom_bar(stat = "identity") +
                    coord_polar(theta = "y") +
                    labs(title = paste("Pie Chart of", input$y_value, "Elements"), fill = input$y_value) +
                    geom_text(aes(label = paste0(round(percentage, 1), "%")),
                              position = position_stack(vjust = .5), size = 7, color = "white") +
                    
                    theme_void() +
                    theme(plot.title = element_text(size = 25),
                          legend.text = element_text(size = 15),
                          legend.title = element_text(size = 18))
                
            } else if (input$plot_type == "Bar") {
                fdt <- fdt %>%
                    group_by(!!sym(input$x_value)) %>%
                    count(!!sym(input$y_value)) 
                
                
                ggplot(fdt, aes(x = !!sym(input$x_value), y = n, fill = !!sym(input$y_value))) +
                    geom_bar(stat = "identity", position = "dodge", linewidth = 1, color = "black") +
                    labs(title = paste("Bar Chart of", input$x_value, "Over", input$y_value), x = input$x_value, y = input$y_value, fill = input$y_value) +
                    coord_flip() +
                    
                    theme_minimal() +
                    theme(panel.grid = element_line(linewidth = .5, color = "black"),
                          axis.text.x = element_text(size = 15, hjust = 1, angle = 45, face = "bold", color = "black", margin = margin(t = 10)), 
                          axis.text.y = element_text(size = 18, face = "bold", color = "black", margin = margin(l = 10)),
                          plot.title = element_text(size = 25),
                          axis.title = element_text(size = 20),
                          legend.text = element_text(size = 15),
                          legend.title = element_text(size = 18))
                
            } else if (input$plot_type == "Scatter") {
                fdt <- fdt %>%
                    group_by(!!sym(input$x_value)) %>%
                    count(!!sym(input$y_value)) 
                
                ggplot(fdt, aes(x = !!sym(input$x_value), y = n, color = !!sym(input$y_value))) +
                    geom_point(size = 6, alpha = .8) +
                    labs(title = paste("Scatter Plot of", input$x_value, "Over", input$y_value), x = input$x_value, y = input$y_value, color = input$x_value) +
                    
                    theme_minimal() +
                    theme(panel.grid = element_line(linewidth = .5, color = "black"),
                          axis.text.x = element_text(size = 15, hjust = 1, angle = 45, face = "bold", color = "black", margin = margin(t = 10)), 
                          axis.text.y = element_text(size = 18, face = "bold", color = "black", margin = margin(l = 10)),
                          plot.title = element_text(size = 25),
                          axis.title = element_text(size = 20),
                          legend.text = element_text(size = 15),
                          legend.title = element_text(size = 18))}
            
            else if (input$plot_type == "Jitter") {
                fdt <- fdt %>%
                    group_by(!!sym(input$x_value)) %>%
                    count(!!sym(input$y_value)) 
                
                ggplot(fdt, aes(x = !!sym(input$x_value), y = n, color = !!sym(input$y_value))) +
                    geom_jitter(size = 6, width = 0.2, height = 0.2) +
                    labs(title = paste("Jitter Plot of", input$x_value, "Over", input$y_value), x = input$x_value, y = input$y_value, color = input$x_value) +
                    
                    theme_minimal() +
                    theme(panel.grid = element_line(linewidth = .5, color = "black"),
                          axis.text.x = element_text(size = 15, hjust = 1, angle = 45, face = "bold", color = "black", margin = margin(t = 10)), 
                          axis.text.y = element_text(size = 18, face = "bold", color = "black", margin = margin(l = 10)),
                          plot.title = element_text(size = 25),
                          axis.title = element_text(size = 20),
                          legend.text = element_text(size = 15),
                          legend.title = element_text(size = 18))}
            
            else if (input$plot_type == "Histogram") {
                fdt <- fdt %>%
                    group_by(!!sym(input$x_value)) %>%
                    count(!!sym(input$y_value)) 
                
                ggplot(fdt, aes(x = !!sym(input$x_value), y = n, color = !!sym(input$y_value))) +
                    geom_histogram(stat = "identity", position = "stack", binwidth = .5, fill = "lightblue", linewidth = 1.5) +
                    labs(x = input$x_value, y = "Count", fill = input$y_value) +
                    
                    theme_minimal() + 
                    theme(panel.grid = element_line(linewidth = .5, color = "black"),
                          axis.text.x = element_text(size = 15, hjust = 1, angle = 45, face = "bold", color = "black", margin = margin(t = 10)), 
                          axis.text.y = element_text(size = 18, face = "bold", color = "black", margin = margin(l = 10)),
                          plot.title = element_text(size = 25),
                          axis.title = element_text(size = 20),
                          legend.text = element_text(size = 15),
                          legend.title = element_text(size = 18))}
            }
        })
    }

shinyApp(ui = ui, server = server)
