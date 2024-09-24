library(shiny)
library(shinyjs)

ui <- fluidPage(
    useShinyjs(),
    
    tags$style(HTML("
    .custom-container {
        display: flex;
        justify-content: center;
        align-items: center;
        flex-direction: column;
        height: 100vh;
    }

    .custom-sidebar {
        display: flex;
        align-items: center;
        justify-content: center;
        flex-direction: column;
        width: 800px;
        height: 390px;
        padding: 20px;
        margin-top: 40px;
        border: 2px solid lightgray;
        background: white;
        border-radius: 10px;
        box-shadow: 0px 0px 10px lightgray;
    }

    .title {
        display: flex;
        align-items: center;
        justify-content: center;
        flex-direction: column;
        width: 400px;
        height: 100px;
        margin-right: 20px;
        font-size: 80px;
        font-family: fantasy;
        color: black;

    }
    
    .title_ex {
        display: flex;
        align-items: center;
        justify-content: center;
        flex-direction: column;
        width: 800px;
        height: 100px;
        margin-right: 20px;
        font-size: 30px;
        font-family: Verdana, Geneva, Tahoma, sans-serif;
        color: black;

    }
    
    
    #date {
        font-size: 20px;
        
    }
    
    #date input {
        font-size: 20px; 
        padding: 20px;
        border-radius: 5px;
    }
    
    
    #start {
        width: 580px;
        padding: 12px;
        margin-bottom: 20px;
        margin-top: 10px;
        background: rgb(77, 87, 94);
        border: 2px solid rgb(185, 185, 185);
        color: white;
        font-size: 20px;
    }
    
    #start:hover {
        background: rgb(185, 185, 185);
        border: 2px solid rgb(185, 185, 185);
        color: black;
    }
    
    #end {
        width: 580px;
        padding: 12px;
        margin-bottom: 20px;
        background: rgb(77, 87, 94);
        border: 2px solid rgb(185, 185, 185);
        color: white;
        font-size: 20px;
    
    }
    
    #end:hover {
        background: rgb(185, 185, 185);
        border: 2px solid rgb(185, 185, 185);
        color: black;
    }
    
    
    #begin {
        width: 580px;
        padding: 15px;
        background: rgb(49, 131, 189);
        border: 2px solid rgb(31, 95, 141);
        color: white;
        font-size: 20px;
    }
    
    #begin:hover {
        background: rgb(77, 143, 191);
        border: 2px solid rgb(77, 143, 191);
        color: white;
    }
    
    .shiny-notification {
        position: fixed;
        top: 35.8%;
        left: 48.6%;
        transform: translate(-50%, -50%);
        width: 800px;
        font-size: 14px;
        font-weight: bold;
        padding: 12px;
        color: black;
        border: 2px solid lightgray;
        border-radius: 8px;
    }
    
    .shiny-notification-error {
        background-color: rgb(255, 228, 146);
    }
    
    .shiny-notification-error:hover {
        background-color: rgb(255, 146, 146);
    }
    
    .shiny-notification-message {
        background-color: rgb(160, 237, 106);
    
    }

    ")),
    
    div(class = "custom-container",
        div(class = "title", 
            "AFSS"),
        div(class = "title_ex", "Automated File Sorting Software"),
        sidebarLayout(
            sidebarPanel(
                class = "custom-sidebar",
                dateRangeInput("date", "Input Date Range:", start = Sys.Date(), end = Sys.Date()),
                actionButton("start", "Starting File Destination"), 
                
                actionButton("end", "Ending File Directory"), 
                
                actionButton("begin", "Begin")),
            
            mainPanel())))

server <- function(input, output, session) {
    
    start_file <- reactiveVal(NULL)
    end_file <- reactiveVal(NULL)
    
    observeEvent(input$start, {
        selected_start <- choose.dir(caption = "Choose a Starting Directory")
        
        if (is.na(selected_start) || selected_start == "") {
            selected_start <- NULL}
        
        start_file(selected_start)
        
        if (!is.null(start_file())) {
            showNotification(paste("Starting File", start_file()), type = "message")}
        else {
            showNotification("No Directory Selected", type = "error")}})
    
    observeEvent(input$end, {
        selected_end <- choose.dir(caption = "Choose an Ending Directory")
        
        if (is.na(selected_end) || selected_end == "") {
            selected_end <- NULL}
        
        end_file(selected_end)
        
        if (!is.null(end_file())) {
            showNotification(paste("End File", end_file()), type = "message")}
        else {
            showNotification("No Directory Selected", type = "error")}})
    
    observeEvent(input$begin, {
        if (is.null(start_file()) || start_file() == "" || is.na(start_file())) {
            showNotification("Error: Starting directory is not selected!", type = "error")
            return(NULL)}
        
        if (is.null(end_file()) || end_file() == "" || is.na(end_file())) {
            showNotification("Error: Ending directory is not selected!", type = "error")
            return(NULL)}
        
        if (is.null(input$date) || length(input$date) != 2) {
            showNotification("Error: Date range is not selected!", type = "error")
            return(NULL)}
        
        start_dir <- start_file()
        end_dir <- end_file()
        start_date <- as.character(input$date[1])
        end_date <- as.character(input$date[2])
        
        system2("python", args = c("C:/Users/joshlewis/Downloads/ShinyApp/file_sort.py", start_dir, end_dir, start_date, end_date), stdout = TRUE, stderr = TRUE)
        
        showNotification("Files Have Been Rearranged!", type = "message")})}

shinyApp(ui, server)
