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
library(plotly)

ui <- fluidPage(
    useShinyjs(), 
    titlePanel("Data Cleaner & Visualizer"),
    
    sidebarLayout(
        sidebarPanel(
            fileInput("file", HTML("Import your file:<br>(CSV, JSON, XML, XLSX, ODS)")),
            uiOutput("file_sidebar"),
            uiOutput("download")),
        mainPanel(
            uiOutput("uio"),
            DTOutput("table"),
            plotlyOutput("plot", height = 800, width = 1200))))

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
                
                checkboxInput("hide", "Hide DataTable?"))}
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
    
    output$table <- renderDT({
        req(input$table_view == "Yes") 
        fdt <- filtered_dt()
        req(fdt)
        
        if (nrow(fdt) == 0) {
            return(NULL)}
        datatable(fdt)})
    
    observeEvent(input$table_view, {
        if (input$table_view == "No") {
            output$table <- renderDT({NULL})}
        else if (input$table_view == "Yes") {
            output$table <- renderDT({
                fdt <- filtered_dt()
                datatable(fdt)})}})
    
    observeEvent(input$hide, {
        if (input$hide) {
            output$table <- renderDT({NULL})
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
            output$table <- renderDT({
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
                selectInput("dvt", "Data Visualization Type?", choices = c("--No Selection", "Plot Variation")),
                uiOutput("dvtui"))}
        else if (input$plot_view == "No") {
            return(NULL)}})
    
    output$dvtui <- renderUI({
        req(input$dvt)
        req(filtered_dt)
        fdt <- filtered_dt()
        
        if (input$dvt != "--No Selection") {
            tagList(
                selectInput("x_value", "X Value:", choices = colnames(fdt)),
                selectInput("y_value", "Y Value:", choices = colnames(fdt)),
                selectInput("fill", "Fill Variables?", choices = c("Yes", "No"), selected = "No"),
                uiOutput("fill_v"),
                
                radioButtons("plot_type", "", choices = ""))}})
    
    output$fill_v <- renderUI({
        req(input$fill)
        req(filtered_dt)
        fdt <- filtered_dt()
        req(fdt)
        
        if (input$y_value %in% colnames(fdt)) {
            
            if (input$fill == "Yes") {
                selectInput("filler", "Column to fill:", choices = colnames(fdt))}
            else {
                NULL}}})
    
    output$download <- renderUI({
        req(input$table_view)
        req(input$plot_view)
        
        if (input$table_view == "Yes" || input$plot_view == "Yes") {
            tagList(
                if (input$table_view == "Yes") {
                    downloadButton("download_file", "Download Data File:")})}
        else {
            NULL}})
    
    observeEvent(input$dvt, {
        req(input$dvt)
        
        if (input$dvt == "Plot Variation") {
            updateRadioButtons(session, "plot_type", "Plot Type:", choices = c("Bar", "Box", "Scatter", "Line", "Density"))
            show("plot_type")}
        else {
            hide("plot_type")}})
    
    observeEvent(input$plot_type, {
        req(input$dvt)
        req(input$plot_type)
        
        if (input$plot_type %in% c("Density")) {
            show("fill")
            hide("y_value")}
        else if (input$plot_type == "Line") {
            hide("fill")}
        else {
            hide("fill")
            hide("filler")
            show("y_value")
            show("x_value")}})
    
    output$plot <- renderPlotly({
        req(input$plot_view)
        req(input$plot_type)
        req(filtered_dt)
        fdt <- filtered_dt()
        req(fdt)
        req(input$x_value %in% colnames(fdt))
        req(input$y_value %in% colnames(fdt))
        
        if (input$dvt == "--No Selection") {
            return(NULL)
        } else if (input$plot_view == "No") {
            return(NULL)
        }
        
        fdt <- filtered_dt()
        req(nrow(fdt) > 0)
        
        gtheme <- theme_minimal() +
            theme(panel.grid = element_line(color = "black", linewidth = .5)) +
            theme(axis.text.x = element_text(size = 15, angle = 45, hjust = 1, face = "bold", color = "black",
                                             margin = margin(b = 10)), 
                  axis.text.y = element_text(size = 15, angle = 45, hjust = 1, face = "bold", color = "black",  
                                             margin = margin(r = 10)),
                  plot.title = element_text(size = 25),
                  axis.title = element_text(size = 20),
                  legend.text = element_text(size = 15),
                  legend.title = element_text(size = 18, margin = margin(b = 10)))
        
        
        if (input$plot_type == "Box") {
            boxp <- ggplot(fdt, aes(x = !!sym(input$x_value), y = !!sym(input$y_value), fill = !!sym(input$x_value))) +
                geom_boxplot(size = 1) +
                labs(title = paste0("Box Plot of ", input$x_value, " By ", input$y_value), x = input$x_value, y = input$y_value) + 
                gtheme
            ggplotly(boxp)}
        
        else if (input$plot_type == "Scatter") {
            scatp <- ggplot(fdt, aes(x = !!sym(input$x_value), y = !!sym(input$y_value), color = !!sym(input$x_value))) +
                geom_point(size = 4, alpha = .6) +
                labs(title = paste0("Scatter Plot of ", input$x_value, " By ", input$y_value), x = input$x_value, y = input$y_value) + 
                gtheme
            ggplotly(scatp)}
        
        else if (input$plot_type == "Line") {
            linep <- ggplot(fdt, aes(x = !!sym(input$x_value), y = !!sym(input$y_value), color = !!sym(input$x_value))) +
                geom_line(linewidth = 5) +
                labs(title = paste0("Line Plot of ", input$x_value, " Over ", input$y_value), x = input$x_value, y = input$y_value) +
                gtheme
            ggplotly(linep)}
        
        else if (input$plot_type == "Bar") {
            barp <- ggplot(fdt, aes(x = !!sym(input$x_value), y = !!sym(input$y_value), fill = !!sym(input$x_value))) +
                geom_bar(stat = "identity", position = "dodge", linewidth = 1, color = "black") +
                labs(title = paste0("Bar Plot of ", input$x_value, " Over ", input$y_value), x = input$x_value, y = input$y_value) +
                gtheme
            ggplotly(barp)}
        
        else if (input$plot_type == "Density") {
            if (input$fill == "Yes" && !is.null(input$filler)) {
                densp <- ggplot(fdt, aes(x = !!sym(input$x_value), fill = !!sym(input$filler))) +
                    geom_density(alpha = 0.5) +
                    labs(title = paste0("Density Plot of ", input$x_value, " By ", input$filler), x = input$x_value) +
                    gtheme}
            else {
                densp <- ggplot(fdt, aes(x = !!sym(input$x_value))) +
                    geom_density(aes(fill = !!sym(input$x_value)), alpha = 0.5) +
                    labs(title = paste0("Density Plot of ", input$x_value), x = input$x_value) +
                    gtheme}
            ggplotly(densp)}})}


shinyApp(ui = ui, server = server)
