observe({
    req(clean_dt())
    
    updateCheckboxGroupInput(session, "x_value", choices = colnames(clean_dt()), selected = colnames(clean_dt())[1])
    updateSelectInput(session, "y_value", choices = colnames(clean_dt()), selected = colnames(clean_dt())[2])
    
    numeric_data <- clean_dt() %>%
        select(where(is.numeric))
    
    if (ncol(numeric_data) > 0) {
        numeric_min <- min(numeric_data, na.rm = TRUE)
        numeric_max <- max(numeric_data, na.rm = TRUE)
        
        updateSliderInput(session, "xrange", min = numeric_min, max = numeric_max, 
                          value = c(numeric_min, numeric_max))
        updateSliderInput(session, "yrange", min = numeric_min, max = numeric_max, 
                          value = c(numeric_min, numeric_max))}})
