library(data.table)

create_multi_index_optimized <- function(file, filter_columns, index_file, delimiter = ",", chunk_size = 100000, write_buffer = 1000000) {
  # Open a connection to the file
  con <- file(file, "r")
  
  # Read header to determine column names
  header <- readLines(con, n = 1)
  column_names <- unlist(strsplit(header, delimiter, fixed = TRUE))
  
  # Validate filter_columns
  if (any(!(filter_columns %in% column_names))) {
    stop("Some filter columns do not exist in the file.")
  }
  
  # Get column indices for filter_columns
  filter_indices <- match(filter_columns, column_names)
  
  # Initialize variables
  line_number <- 0
  buffer <- data.table()  # Buffer for incremental writing
  
  # Ensure the index file starts fresh
  fwrite(data.table(line_number = integer(), setNames(replicate(length(filter_columns), character()), filter_columns)), 
         index_file, append = FALSE)  # Create an empty file with headers
  
  # Read the file in chunks
  while (TRUE) {
    # Read the next chunk
    lines <- readLines(con, n = chunk_size, warn = FALSE)
    if (length(lines) == 0) break  # Stop if no more lines
    
    line_number_start <- line_number + 1
    line_number <- line_number + length(lines)
    
    # Split lines by the delimiter
    split_data <- tstrsplit(lines, delimiter, fixed = TRUE)
    
    # Extract required columns
    chunk_data <- lapply(filter_indices, function(i) split_data[[i]])
    names(chunk_data) <- filter_columns  # Assign column names
    
    # Create chunk index
    chunk_index <- data.table(
      line_number = seq(line_number_start, line_number),
      chunk_data
    )
    
    # Add chunk to buffer
    buffer <- rbindlist(list(buffer, chunk_index), use.names = TRUE, fill = TRUE)
    
    # Write buffer to disk if it exceeds the write_buffer size
    if (nrow(buffer) >= write_buffer) {
      fwrite(buffer, index_file, append = TRUE)
      buffer <- data.table()  # Reset buffer
    }
    break
  }
  
  close(con)  # Close the file connection
  print(nrow(buffer))
  print(buffer[1])
  # Write remaining buffer to disk
  if (nrow(buffer) > 0) {
    #fwrite(buffer, index_file, append = TRUE)
  }
  
  print(paste("Index created:", index_file))
}


# Example: Create index for multimedia.csv
#create_multi_index(
#  "data/raw/multimedia.csv",
#  filter_columns = c("column1", "column2", "column3"),  # Replace with actual column names
#  index_file = "data/processed/multimedia_index.csv",
#  delimiter = ","
#)

# Example: Create index for occurence.csv
create_multi_index_optimized(
  "data/raw/occurence.csv",
  filter_columns = c("vernacularName", "scientificName"),  # Replace with actual column names
  index_file = "data/processed/occurence_index.csv",
  delimiter = ","
)
