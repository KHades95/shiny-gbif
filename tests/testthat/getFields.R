# Validate index files
multimedia_index <- fread("data/raw/multimedia.csv", nrows = 0)
occurrence_index <- fread("data/raw/occurence.csv", nrows = 1)

# Check structure
#print(multimedia_index)
print(occurrence_index)