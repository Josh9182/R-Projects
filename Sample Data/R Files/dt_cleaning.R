clean_dt <- reactive({
        req(dt())
    
        validate(need(nrow(dt()) > 0 && ncol(dt()) > 0, 
                      "Data table must have at least 1 row and 1 column."))
        dt() %>%
            na.omit() %>%
            unique() %>%
            mutate(across(where(is.character)), ~ str_to_lower(trimws(.x)))})
