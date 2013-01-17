#!/usr/bin/env ruby

require 'yaml'
require 'gsl'
include GSL

data_array = YAML.load_file(ARGV[0])

h = Histogram2d.alloc(16, [-6, 6], 16, [-6, 6])
data_array.each do |x|
  h.increment(x[0], x[1])
end

(0..(h.nx-1)).each do |x|
  (0..(h.ny-1)).each do |y|
    h.fprintf($stdout, range_format = "%e", bin_format = "%e")
  end
end

$stderr.puts "xmean: #{h.xmean}, xsigma: #{h.xsigma}, ymean: #{h.ymean}, ysigma: #{h.ysigma}"
