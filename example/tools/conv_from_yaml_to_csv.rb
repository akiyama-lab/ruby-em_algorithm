#!/usr/bin/env ruby

require 'yaml'

data_array = YAML.load_file(ARGV[0])
data_array.each do |datum|
  puts datum.join(",")
end
