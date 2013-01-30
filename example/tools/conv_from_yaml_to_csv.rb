#!/usr/bin/env ruby

require 'yaml'

size = ARGV[1] || 0
size = size.to_i

data_array = YAML.load_file(ARGV[0])
data_array.each do |datum|
  puts datum[0..(size.to_i-1)].join(",")
end
