#!/usr/bin/env ruby

require 'yaml'
require 'rsruby'
require 'gsl'

include GSL

r = RSRuby.instance
c = r.eval_R(<<-RCOMMAND)
a <- read.csv('#{ARGV[0]}.csv')
kmeans(a,2)
RCOMMAND

data_array = YAML.load_file("#{ARGV[0]}.txt").map {|v| Vector[v] }
cluster = Array.new(c["size"].size).map { {"mu_sum" => 0.0, "sigma_sum" => Matrix.alloc(data_array[0].size, data_array[0].size)} }
c["cluster"].each_with_index do |num, di|
  cluster[num - 1]["mu_sum"] += data_array[di]
  cluster[num - 1]["sigma_sum"] += data_array[di].trans * data_array[di]
end
c["size"].each_with_index do |size, num|
  cluster[num]["mu"] = cluster[num]["mu_sum"] / size
  cluster[num]["sigma"] = cluster[num]["sigma_sum"] / size
end

c["centers"].each_with_index do |cen, ci|
  puts "### cluster #{ci}"
  p cen
end
cluster.each_with_index do |clu, ci|
  puts "### cluster #{ci}"
  p clu["mu"].to_a
  p clu["sigma"].to_a
end
