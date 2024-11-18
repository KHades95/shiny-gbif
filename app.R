library(shiny)
library(shinydashboard)
library(arrow)

# Load Data
partitioned_path <- "data/processed/partitioned_poland"
dataset <- open_dataset(partitioned_path, format = "parquet")

# Load modules
source("modules/search_module.R")
source("modules/summary_module.R")
source("modules/timeline_module.R")
source("modules/map_module.R")

# UI
ui <- dashboardPage(
  dashboardHeader(title = "Biodiversity Dashboard"),
  dashboardSidebar(
    # Search module in the sidebar
    search_module_ui("search_module")
  ),
  dashboardBody(
    # Include external JavaScript and CSS for styling and loader
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "app.css"), # External CSS
      tags$script(src = "custom_script.js")                              # External JavaScript
    ),
    
    # Loader screen (hidden when app is loaded)
    tags$div(id = "loading-screen",
             tags$div(id = "loader", class = "spinner")
    ),
    
    # Main content
    fluidRow(
      # Summary module in the first row
      summary_module_ui("summary_module")
    ),
    fluidRow(
      # Map module on the left
      box(width = 12, map_module_ui("map_module")),
      
      # Timeline module on the right
      box(width = 12, timeline_module_ui("timeline_module"))
    )
  )
)

# Server
server <- function(input, output, session) {
  # Reactive value to hold the filtered dataset
  filtered_data <- reactiveVal(dataset)
  
  # Search module for filtering
  search_module_server("search_module", dataset, filtered_data)
  
  # Summary module (uses filtered data)
  summary_module_server("summary_module", filtered_data)
  
  # Map module (uses filtered data)
  map_module_server("map_module", filtered_data)
  
  # Timeline module (uses filtered data)
  timeline_module_server("timeline_module", filtered_data)
  
  # Remove loader when the app is ready
  session$onFlushed(function() {
    shinyjs::hide(id = "loading-screen", anim = TRUE, animType = "fade")
  }, once = TRUE)
}

# Run the app
shinyApp(ui, server)
