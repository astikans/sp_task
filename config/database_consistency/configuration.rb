require "yaml"

module DatabaseConsistency
  # The class to access configuration options
  class Configuration
    MY_DEFAULT_PATH = "config/initializers/database_consistency/database_consistency.yml"
    # def initialize(file_paths = DEFAULT_PATH) # << original one
    def initialize(file_paths = nil)
      @configuration = existing_configurations(MY_DEFAULT_PATH).then do |existing_paths|
        puts "Loaded configurations: #{existing_paths.join(', ')}"
        extract_configurations(existing_paths)
      end
    end
  end
end
