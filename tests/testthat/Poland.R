library(data.table)
library(arrow)

# File paths
input_file <- "data/raw/occurence.csv"
output_poland_file <- "data/processed/poland_occurence.csv"
partitioned_output <- "data/processed/partitioned_poland_occurence"

# Define chunk size for processing
chunk_size <- 1e6  # Number of rows per chunk

# Define column data types explicitly (based on GBIF schema)
col_types <- list(
  id = "character",
  occurrenceID = "character",
  catalogNumber = "character",
  basisOfRecord = "character",
  collectionCode = "character",
  scientificName = "character",
  taxonRank = "character",
  kingdom = "character",
  family = "character",
  higherClassification = "character",
  vernacularName = "character",
  previousIdentifications = "character",
  individualCount = "numeric",
  lifeStage = "character",
  sex = "character",
  longitudeDecimal = "numeric",
  latitudeDecimal = "numeric",
  geodeticDatum = "character",
  dataGeneralizations = "character",
  coordinateUncertaintyInMeters = "numeric",
  continent = "character",
  country = "character",
  countryCode = "character",
  stateProvince = "character",
  locality = "character",
  habitat = "character",
  recordedBy = "character",
  eventID = "character",
  eventDate = "character",
  eventTime = "character",
  samplingProtocol = "character",
  behavior = "character",
  associatedTaxa = "character",
  references = "character",
  rightsHolder = "character",
  license = "character",
  modified = "character"
)

# Open file connection for reading
con <- file(input_file, open = "r")
on.exit(close(con))  # Ensure the connection is closed on exit

# Read and skip the header line
header_line <- readLines(con, n = 1)
header_names <- strsplit(header_line, ",")[[1]]

# Initialize Poland CSV with headers
empty_dt <- data.table(matrix(ncol = length(header_names), nrow = 0))
setnames(empty_dt, header_names)
fwrite(empty_dt, output_poland_file)
chunk_count <- 0
repeat {
  # Step 1: Read a chunk of lines
  lines <- readLines(con, n = chunk_size)
  if (length(lines) == 0) break  # Exit the loop if no more lines to read
  
  # Step 2: Convert lines to a data.table
  chunk <- fread(
    text = paste(lines, collapse = "\n"),
    header = FALSE,
    col.names = header_names,
    na.strings = c("", "NA"),
    colClasses = col_types
  )
  
  # Step 3: Filter rows for Poland
  chunk_poland <- chunk[country == "Poland" | countryCode == "PL"]
  
  # Step 4: Append the filtered rows to the Poland output file
  fwrite(chunk_poland, output_poland_file, append = TRUE)
  chunk_count <- chunk_count + 1
  print(paste("Chunck", chunk_count, "is writed"))
}

# Step 5: Use Arrow to generate an indexed dataset for Poland
# Open the filtered Poland dataset
poland_dataset <- open_dataset(output_poland_file, format = "csv", schema = schema(
  id = utf8(),
  occurrenceID = utf8(),
  catalogNumber = utf8(),
  basisOfRecord = utf8(),
  collectionCode = utf8(),
  scientificName = utf8(),
  taxonRank = utf8(),
  kingdom = utf8(),
  family = utf8(),
  higherClassification = utf8(),
  vernacularName = utf8(),
  previousIdentifications = utf8(),
  individualCount = float64(),
  lifeStage = utf8(),
  sex = utf8(),
  longitudeDecimal = float64(),
  latitudeDecimal = float64(),
  geodeticDatum = utf8(),
  dataGeneralizations = utf8(),
  coordinateUncertaintyInMeters = float64(),
  continent = utf8(),
  country = utf8(),
  countryCode = utf8(),
  stateProvince = utf8(),
  locality = utf8(),
  habitat = utf8(),
  recordedBy = utf8(),
  eventID = utf8(),
  eventDate = utf8(),
  eventTime = utf8(),
  samplingProtocol = utf8(),
  behavior = utf8(),
  associatedTaxa = utf8(),
  references = utf8(),
  rightsHolder = utf8(),
  license = utf8(),
  modified = utf8()
))

# Write the partitioned dataset
write_dataset(
  poland_dataset,
  path = partitioned_output,
  format = "parquet",
  partitioning = c("scientificName", "vernacularName")
)

# Clean up
close(con)

print("Poland data has been successfully exported and partitioned.")
