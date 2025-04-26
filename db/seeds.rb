json_file_path = 'response.json'

DataImporter.call(
  Readers::JsonFileReader.read(json_file_path)
)

puts "✓ Seeded the database with the data from the JSON file - #{json_file_path}"