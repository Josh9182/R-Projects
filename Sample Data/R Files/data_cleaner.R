ui <- fluidPage(
    titlePanel("Data Cleaner"),
    
    sidebarLayout(
        sidebarPanel(
            fileInput("file", "Import your CSV, JSON, XLM, XLSX, or ODS file below:"), 
            selectInput("white", "Trim white space?", choices = NULL), 
            selectInput("null", "Remove NULL values?", choices = NULL), 
            checkboxGroupInput("cols", "Remove certain columns?", choices = NULL),
            selectInput("row_choice", "Remove certain rows?", choices = NULL)), 
        mainPanel(
            dataTableOutput("table"))))
