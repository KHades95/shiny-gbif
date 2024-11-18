search_module_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectizeInput(ns("scientific_name"), "Search Scientific Name", choices = NULL, multiple = FALSE),
    selectizeInput(ns("vernacular_name"), "Search Vernacular Name", choices = NULL, multiple = FALSE)
  )
}

search_module_server <- function(id, dataset, filtered_data) {
  moduleServer(id, function(input, output, session) {
    # Reactive value to ensure dropdowns are populated only once
    initialized <- reactiveVal(FALSE)
    
    # Populate dropdowns only once
    observe({
      if (!initialized()) {
        scientific_names <- dataset %>%
          select(scientificName) %>%
          distinct() %>%
          collect() %>%
          pull(scientificName)
        
        vernacular_names <- dataset %>%
          select(vernacularName) %>%
          distinct() %>%
          collect() %>%
          pull(vernacularName)
        
        # Add "All" option to the dropdowns
        scientific_names <- c("All", scientific_names)
        vernacular_names <- c("All", vernacular_names)
        
        updateSelectizeInput(session, "scientific_name", choices = scientific_names, server = TRUE)
        updateSelectizeInput(session, "vernacular_name", choices = vernacular_names, server = TRUE)
        
        # Mark as initialized
        initialized(TRUE)
      }
    })
    
    # Filter dataset based on user selection
    observe({
      selected_scientific <- input$scientific_name
      selected_vernacular <- input$vernacular_name
      
      filtered <- dataset
      
      if (!is.null(selected_scientific) && selected_scientific != "All") {
        filtered <- filtered %>%
          filter(scientificName == selected_scientific)
      }
      
      if (!is.null(selected_vernacular) && selected_vernacular != "All") {
        filtered <- filtered %>%
          filter(vernacularName == selected_vernacular)
      }
      
      # Update filtered data (collect to load into memory)
      filtered_data(filtered %>% collect())
    })
  })
}

