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
#  :models => [MdGaussian.new(Vector[1.0, 1.0], Matrix[[9.0, 0.0], [0.0, 9.0]])],
#  :weights => [1.0]
#)
#model = Mixture.new(
#  :models => [MdGaussian.new(Vector[1.24102564102564, 1.3843589743589746], Matrix[[4.114512820512822, 1.095717948717949], [1.095717948717949, 3.558512820512825]]), MdGaussian.new(Vector[-0.9518604651162781, -2.0293023255813956], Matrix[[3.4144651162790747, 1.764395348837209], [1.764395348837209, 6.793999999999991]])],
#  :weights => [0.5, 0.5]
#)
#model = Mixture.new(
#  :models => [MdGaussian.new(Vector[-3.0, -4.0], Matrix[[9.0, 0.0], [0.0, 9.0]]), MdGaussian.new(Vector[2.0, 2.0], Matrix[[9.0, 0.0], [0.0, 9.0]])],
#  :weights => [0.5, 0.5]
#)
model = Mixture.new(
  :models => [MdGaussian.new(Vector[-5.0, -5.0], Matrix[[9.0, 0.0], [0.0, 9.0]]), MdGaussian.new(Vector[5.0, 5.0], Matrix[[9.0, 0.0], [0.0, 9.0]])],
  :weights => [0.5, 0.5]
)

em = EMAlgorithm::Base.new(:model => model, :data_array => data_array,
                           :value_distribution_estimation => true,
                           :debug => true
                          )
em.run!
#puts em.model.to_gnuplot(:mixture_only)
#puts em.model.to_gnuplot
puts em.model.value_distribution_to_gnuplot(em.const)

