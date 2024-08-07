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
