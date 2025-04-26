# Load Rails environment to access all models and services
require File.expand_path('../config/environment', __FILE__)

origin_port = Inputs::Port.input(port_type: "origin port")
destination_port = Inputs::Port.input(port_type: "destination port")
criteria = Inputs::Criteria.input

# TODO: search and print results
