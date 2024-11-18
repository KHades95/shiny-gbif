library(data.table)
library(arrow)

# File paths
input_file <- "data/raw/occurence.csv"
partitioned_output <- "data/processed/partitioned_occurence_poland"

# Define chunk size
chunk_size <- 1e6  # Number of rows per chunk

# Open file connection for reading
con <- file(input_file, open = "r")
on.exit(close(con))  # Ensure the connection is closed on exit

# Read and skip the header row
header_line <- readLines(con, n = 1)
header_names <- strsplit(header_line, ",")[[1]]

# Create a temporary directory for storing cleaned chunks
cleaned_chunks_dir <- tempfile()
dir.create(cleaned_chunks_dir)

# Initialize chunk counter
chunk_counter <- 0

repeat {
  # Step 1: Read a chunk of lines from the file
  lines <- readLines(con, n = chunk_size)
  if (length(lines) == 0) break  # Exit the loop if no more lines to read
  
  # Step 2: Convert lines to a data.table
  chunk <- fread(
    text = paste(lines, collapse = "\n"),
    header = FALSE,
    col.names = header_names,
    na.strings = c("", "NA")
  )
  
  # Step 3: Filter And Clean the chunk
  chunk <- chunk[country == "Poland" | countryCode == "PL"]  # Keep only rows for Poland
  
  # Ensure 'coordinateUncertaintyInMeters' is numeric
  chunk[, coordinateUncertaintyInMeters := as.numeric(coordinateUncertaintyInMeters)]
  
  # Remove rows with invalid 'coordinateUncertaintyInMeters'
  chunk <- chunk[!is.na(coordinateUncertaintyInMeters)]
  
  # Step 4: Save the cleaned chunk as a temporary CSV
  chunk_file <- file.path(cleaned_chunks_dir, paste0("chunk_", chunk_counter, ".csv"))
  fwrite(chunk, chunk_file)
  print(chunk_counter)
  chunk_counter <- chunk_counter + 1
  
}

# Step 5: Use Arrow to load cleaned chunks and write partitioned Parquet files
# Combine all cleaned chunk files
cleaned_dataset <- open_dataset(cleaned_chunks_dir, format = "csv")

# Write the partitioned dataset
write_dataset(
  cleaned_dataset,
  path = partitioned_output,
  format = "parquet",
  partitioning = c("scientificName", "vernacularName")
)

# Clean up temporary files
#unlink(cleaned_chunks_dir, recursive = TRUE)
