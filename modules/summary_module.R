summary_module_ui <- function(id) {
  ns <- NS(id)
  tagList(
    valueBoxOutput(ns("top_species")),
    valueBoxOutput(ns("total_observations"))
  )
}

summary_module_server <- function(id, filtered_data) {
  moduleServer(id, function(input, output, session) {
    output$top_species <- renderValueBox({
      # Access the reactive filtered dataset
      data <- filtered_data()
      
      # Find the most observed species
      top_species <- data %>%
        group_by(scientificName) %>%
        summarize(count = n(), .groups = "drop") %>%
        arrange(desc(count)) %>%
        head(1)
      
      # Render the value box for top species
      if (nrow(top_species) > 0) {
        valueBox(
          top_species$count[1],
          paste("Top Observed Species:", top_species$scientificName[1]),
          icon = icon("feather")
        )
      } else {
        valueBox("No Data", "Top Observed Species", icon = icon("feather"))
      }
    })
    
    output$total_observations <- renderValueBox({
      # Access the reactive filtered dataset
      data <- filtered_data()
      
      # Calculate total observations
      total_obs <- nrow(data)
      
      # Render the value box for total observations
      valueBox(
        total_obs,
        "Total Observations",
        icon = icon("binoculars")
      )
    })
  })
}
