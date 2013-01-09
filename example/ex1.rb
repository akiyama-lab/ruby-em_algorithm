#!/usr/bin/env ruby

require 'yaml'
require 'ruby-em_algorithm'
include EMAlgorithm

data_array = YAML.load_file(ARGV[0])

model = Mixture.new(
  :models => [Gauss.new(0.0, 9.0), Gauss.new(10.0, 9.0)],
  :weights => [0.5, 0.5]
)

em = EMAlgorithm::Base.new(:model => model, :data_array => data_array)
em.run!
em.model.to_gnuplot
