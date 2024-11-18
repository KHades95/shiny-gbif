library(shiny)
library(leaflet)
library(arrow)
library(dplyr)

# UI for the Map Module
map_module_ui <- function(id) {
  ns <- NS(id)
  tagList(
    leafletOutput(ns("map"), height = "600px")
  )
}
map_module_server <- function(id, filtered_data) {
  moduleServer(id, function(input, output, session) {
    map_data <- reactive({
      data <- filtered_data()
      
      if (is.null(data) || nrow(data) == 0) {
        return(NULL)
      }
      
      data %>%
        filter(!is.na(longitudeDecimal) & !is.na(latitudeDecimal)) %>%
        group_by(scientificName, vernacularName) %>%
        summarize(
          count = n(),
          longitudeDecimal = mean(longitudeDecimal, na.rm = TRUE),
          latitudeDecimal = mean(latitudeDecimal, na.rm = TRUE),
          .groups = "drop"
        ) %>%
        arrange(desc(count))
    })
    
    output$map <- renderLeaflet({
      data <- map_data()
      
      if (is.null(data) || nrow(data) == 0) {
        leaflet() %>%
          addProviderTiles(providers$Esri.WorldStreetMap) %>%
          setView(lng = 19.1451, lat = 51.9194, zoom = 6) %>%
          addPopups(
            lng = 19.1451,
            lat = 51.9194,
            popup = "No data available",
            options = popupOptions(closeButton = FALSE)
          )
      } else {
        leaflet(data) %>%
          addProviderTiles(providers$Esri.WorldStreetMap) %>%
          setView(
            lng = mean(data$longitudeDecimal, na.rm = TRUE),
            lat = mean(data$latitudeDecimal, na.rm = TRUE),
            zoom = 6
          ) %>%
          addCircleMarkers(
            lng = ~longitudeDecimal,
            lat = ~latitudeDecimal,
            popup = ~paste(
              "Scientific Name:", scientificName, "<br>",
              "Vernacular Name:", vernacularName, "<br>",
              "Observations:", count
            ),
            clusterOptions = markerClusterOptions()
          )
      }
    })
  })
}


