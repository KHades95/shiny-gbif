library(data.table)
library(arrow)

# File paths
output_poland_file <- "data/processed/poland_occurence.csv"
partitioned_output <- "data/processed/partitioned_poland"

# Step 2: Define Arrow Schema with Correct Types
arrow_schema <- arrow::schema(
  id = arrow::utf8(),
  occurrenceID = arrow::utf8(),
  catalogNumber = arrow::utf8(),
  basisOfRecord = arrow::utf8(),
  collectionCode = arrow::utf8(),
  scientificName = arrow::utf8(),
  taxonRank = arrow::utf8(),
  kingdom = arrow::utf8(),
  family = arrow::utf8(),
  higherClassification = arrow::utf8(),
  vernacularName = arrow::utf8(),
  previousIdentifications = arrow::utf8(),
  individualCount = arrow::int32(),  # Numeric with possible missing values
  lifeStage = arrow::utf8(),
  sex = arrow::utf8(),
  longitudeDecimal = arrow::float64(), # Ensure numeric
  latitudeDecimal = arrow::float64(),  # Ensure numeric
  geodeticDatum = arrow::utf8(),
  dataGeneralizations = arrow::utf8(),
  coordinateUncertaintyInMeters = arrow::float64(), # Numeric
  continent = arrow::utf8(),
  country = arrow::utf8(),
  countryCode = arrow::utf8(),
  stateProvince = arrow::utf8(),
  locality = arrow::utf8(),
  habitat = arrow::utf8(),
  recordedBy = arrow::utf8(),
  eventID = arrow::utf8(),
  eventDate = arrow::date32(),  # Convert to proper date format
  eventTime = arrow::time32("s"),  # Convert to proper time format
  samplingProtocol = arrow::utf8(),
  behavior = arrow::utf8(),
  associatedTaxa = arrow::utf8(),
  references = arrow::utf8(),
  rightsHolder = arrow::utf8(),
  license = arrow::utf8(),
  modified = arrow::utf8()
)

# Step 3: Load the Cleaned Poland Dataset into Arrow
print("Importing Poland Data ...")
poland_dataset <- arrow::read_csv_arrow(
  file = output_poland_file,
  schema = arrow_schema,
  skip = 1 # Skip the header row
)
print("Imported Poland Data ...")

# Step 4: Write the Partitioned Dataset
print("Generating partition ...")
arrow::write_dataset(
  poland_dataset,
  path = partitioned_output,
  format = "parquet",
  partitioning = c("scientificName", "vernacularName")
)
print("Generated partition ...")

print("Poland data has been successfully cleaned, exported, and partitioned.")
