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
            plotlyOutput("heatmap"))))

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
    
    
}
