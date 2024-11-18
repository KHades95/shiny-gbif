timeline_module_ui <- function(id) {
  ns <- NS(id)
  tagList(
    plotlyOutput(ns("timeline_plot"), height = "400px")
  )
}

timeline_module_server <- function(id, filtered_data) {
  moduleServer(id, function(input, output, session) {
    output$timeline_plot <- renderPlotly({
      # Access the filtered dataset
      data <- filtered_data() # Use reactive dataset
      
      # Ensure eventDate is valid and group by it
      if (!"eventDate" %in% names(data)) {
        stop("The dataset must include an 'eventDate' column.")
      }
      
      data <- data %>%
        filter(!is.na(eventDate)) %>% # Remove invalid dates
        group_by(eventDate) %>%
        summarize(count = n(), .groups = "drop") # Summarize counts by date
      
      # Generate the Plotly timeline plot
      plot_ly(data, x = ~eventDate, y = ~count, type = "scatter", mode = "lines+markers",
              line = list(shape = "spline")) %>%
        layout(
          title = "Observation Timeline",
          xaxis = list(title = "Date"),
          yaxis = list(title = "Observation Count")
        )
    })
  })
}
