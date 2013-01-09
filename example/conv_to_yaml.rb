#!/usr/bin/env ruby

require 'yaml'

data_array = []
open(ARGV[0]) do |f|
  begin
    while true do
       data_array << f.readline.gsub("\r*\n", "").to_f
    end
  rescue EOFError => e
  rescue => e
    $stderr.puts e.message
  end
end

puts data_array.to_yaml
