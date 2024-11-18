library(data.table)

# Load the specific row to check its contents
problematic_row <- fread("data/raw/occurence.csv", select = 27, skip = 4453, nrows = 1)
print(problematic_row)