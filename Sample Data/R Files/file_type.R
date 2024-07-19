dt <- reactive({
    req(input$file)
    file_ext = file_ext(input$file$datapath)
    
    file_type <- switch(file_ext, 
           "csv" = read.csv(input$file$datapath), 
           "json" = fromJSON(input$file$datapath), 
           "xls" = read_xlsx(input$file$datapath, sheet = 1), 
           "xlsx" = read_xlsx(input$file$datapath, sheet = 1), 
           "ods" = read_ods(input$file$datapath), 
           stop("Incorrect file type. Please retry in the following format: CSV, JSON, XLSX, XLS, ODS."))})
