# Load Rails environment to access all models and services
require File.expand_path('../config/environment', __FILE__)

origin_port = Inputs::Port.input(port_type: "origin port")
destination_port = Inputs::Port.input(port_type: "destination port")
criteria = Inputs::Criteria.input

search_class = CriteriaConstants::AVAILABLE_CRITERIA[criteria].constantize
result = search_class.search(origin_port, destination_port)
ap result  # Use awesome_print to prettify the output
