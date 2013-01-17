#!/usr/bin/env ruby

require 'yaml'
require 'gsl'
include GSL

def bivariate_gaussian(number, mu_x, mu_y, sigma_x, sigma_y, rho, seed)
  r = Rng.alloc(Rng::TAUS, seed)
  array_x = []
  array_y = []
  array_xy = []
  number.times do
    x, y = r.bivariate_gaussian(sigma_x, sigma_y, rho)
    array_x << x + mu_x
    array_y << y + mu_y
    array_xy << [x + mu_x, y + mu_y]
  end

  v_x = Vector.alloc(array_x)
  v_y = Vector.alloc(array_y)

  if ARGV[0] == "without_weight"
    return array_xy
  end

  h = Histogram2d.alloc(30, [-6, 6], 30, [-6, 6])
  h.fill(v_x, v_y)
  data_array = []
  (0..(h.nx-1)).each do |x|
    (0..(h.ny-1)).each do |y|
      #if ARGV[0] == "gnuplot"
        #puts "#{x} #{y} #{h[x,y]}"
        #h.fprintf($stdout, range_format = "%e", bin_format = "%e")
      #end
      data_array << [(h.xrange[x]+h.xrange[x+1])/2.0, (h.yrange[y]+h.yrange[y+1])/2.0, h[x,y]]
    end
  end
  data_array
end

#data_array = bivariate_gaussian(1200, 1.0, 1.0, 1.0, 1.0, 0, 1)
data_array = bivariate_gaussian(6000, 1, 1, 1, 1, 0, 1)
data_array += bivariate_gaussian(3000, -1, -2, 1, 1, 0, 1)
if ARGV[0] == "without_weight"
  puts data_array.to_yaml
  exit(0)
end
sum = data_array.inject(0.0) do |sum, datum|
  sum + datum[2]
end
data_array = data_array.map do |datum|
  [datum[0], datum[1], datum[2] / sum]
end
if ARGV[0] == "gnuplot"
  #exit(0)
  data_array.each do |datum|
    next if datum[2] == 0.0
    puts "#{datum[0]} #{datum[1]} #{datum[2]}"
  end
elsif ARGV[0].nil?
  data_array = data_array.reject {|datum| datum[2] == 0.0}
  puts data_array.to_yaml
end
