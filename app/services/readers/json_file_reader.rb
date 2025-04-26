# Reads and parses a JSON file from the given file path.
# Used by DataImporter to import data from JSON files.
#
# @param file_path [String] Path to the JSON file to read
# @return [Hash] Parsed JSON data as a Ruby hash
module Readers
  class JsonFileReader
    def self.read(file_path)
      new(file_path).read
    end

    def initialize(file_path)
      @file_path = file_path
    end

    def read
      JSON.parse(File.read(@file_path))
    end
  end
end