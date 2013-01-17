#!/usr/bin/env ruby

require 'yaml'
require 'ruby-em_algorithm'
include EMAlgorithm
include GSL

data_array = YAML.load_file(ARGV[0]).map {|v| GSL::Vector[v]}

#model = Mixture.new(
#  :models => [Gaussian.new(0.0, 3.0)],
#  :weights => [1.0]
#)
#model = Mixture.new(
#  :models => [MdGaussian.new(Vector[10.0, 10.0], Matrix[[9.0, 0.0], [0.0, 9.0]])],
#  :weights => [1.0]
#)
#model = Mixture.new(
#  :models => [MdGaussian.new(Vector[1.0, 1.0], Matrix[[1.0, 0.0], [0.0, 1.0]])],
#  :weights => [1.0]
#)
model = Mixture.new(
  :models => [MdGaussian.new(Vector[-2.0, -2.0], Matrix[[9.0, 0.0], [0.0, 9.0]]), MdGaussian.new(Vector[2.0, 2.0], Matrix[[9.0, 0.0], [0.0, 9.0]])],
  :weights => [0.5, 0.5]
)

em = EMAlgorithm::Base.new(:model => model, :data_array => data_array,
                           :convergence_check => "ChiSquare",
                           :use_observation_weight => true)
em.run!
em.model.to_gnuplot
