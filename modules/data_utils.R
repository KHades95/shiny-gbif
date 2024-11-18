library(arrow)
library(dplyr)

# Function to load the partitioned dataset
load_partitioned_dataset <- function(partitioned_path) {
  open_dataset(partitioned_path, format = "parquet")
}

# Function to get unique scientific and vernacular names for filtering
get_filter_choices <- function(dataset) {
  list(
    scientific_names = dataset %>%
      select(scientificName) %>%
      distinct() %>%
      collect() %>%
      pull(scientificName),
    vernacular_names = dataset %>%
      select(vernacularName) %>%
      distinct() %>%
      collect() %>%
      pull(vernacularName)
  )
}

# Function to filter the dataset based on user inputs
filter_partitioned_data <- function(dataset, scientific_name = NULL, vernacular_name = NULL) {
  filtered_dataset <- dataset
  
  if (!is.null(scientific_name)) {
    filtered_dataset <- filtered_dataset %>%
      filter(scientificName == scientific_name)
  }
  
  if (!is.null(vernacular_name)) {
    filtered_dataset <- filtered_dataset %>%
      filter(vernacularName == vernacular_name)
  }
  
  filtered_dataset %>%
    select(
      longitudeDecimal, latitudeDecimal, scientificName,
      vernacularName, locality
    ) %>%
    collect()
}
