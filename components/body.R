dashboard_body <- function() {
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/app.css")
    ),
    fluidRow(
      div(
        class = "col-sm-4",
        selectInput("vernacularName1", "VernacularName", choices = c("Bear", "Tiger", "Rabbit"), selected = "Bear")
      ),
      div(
        class = "col-sm-4",
        selectInput("vernacularName2", "VernacularName", choices = c("Bear", "Tiger", "Rabbit"), selected = "Bear")
      )
    ),
    fluidRow(
      valueBoxOutput("sales_revenue", width = 3),
      valueBoxOutput("production_costs", width = 3),
      valueBoxOutput("active_users", width = 3),
      valueBoxOutput("open_complaints", width = 3)
    ),
    fluidRow(
      box(
        title = "Sales Revenue by Country", 
        status = "primary", 
        solidHeader = TRUE, 
        width = 12,
        leafletOutput("sales_map", height = "500px")
      )
    )
  )
}
