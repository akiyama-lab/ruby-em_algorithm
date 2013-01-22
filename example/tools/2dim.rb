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

  #h = Histogram2d.alloc(30, [-6, 6], 30, [-6, 6])
  h = Histogram2d.alloc(100, [-10, 10], 100, [-10, 10])
  #h = Histogram2d.alloc(256, [-6, 6], 256, [-6, 6])
  h.fill(v_x, v_y)
  data_array = []
  (0..(h.nx-1)).each do |x|
    (0..(h.ny-1)).each do |y|
      data_array << [(h.xrange[x]+h.xrange[x+1])/2.0, (h.yrange[y]+h.yrange[y+1])/2.0, h[x,y].to_f, (h.xrange[x]-h.xrange[x+1]).abs*(h.yrange[y]-h.yrange[y+1]).abs]
      #p [(h.xrange[x]+h.xrange[x+1])/2.0, (h.yrange[y]+h.yrange[y+1])/2.0, h[x,y].to_f, (h.xrange[x]-h.xrange[x+1]).abs*(h.yrange[y]-h.yrange[y+1]).abs]
    end
  end
  data_array
end

#data_array = bivariate_gaussian(24000, 1.0, 1.0, 1.0, 1.0, 0, 1)

data_array = bivariate_gaussian(24000, 1, 1, 1, 1, 0, 1)
data_array += bivariate_gaussian(12000, -1, -2, 1, 1, 0, 1)

#data_array = bivariate_gaussian(2400, 1, 1, 1, 1, 0, 1)
#data_array += bivariate_gaussian(1200, -1, -2, 1, 1, 0, 1)

#data_array = bivariate_gaussian(6000, 1, 1, 1, 1, 0, 1)
#data_array += bivariate_gaussian(3000, -1, -2, 1, 1, 0, 1)
if ARGV[0] == "without_weight"
  puts data_array.to_yaml
  exit(0)
end
data_array = data_array.map do |datum|
  if rand > 1.0
    [datum[0], datum[1], 0.0, 0.0]
  else
    [datum[0], datum[1], datum[2], datum[3]]
  end
end
if ARGV[0] == "gnuplot"
  data_array.each do |datum|
    next if datum[2] == 0.0
    puts "#{datum[0]} #{datum[1]} #{datum[2]}"
  end
elsif ARGV[0].nil?
  data_array = data_array.reject {|datum| datum[2] == 0.0}
  puts data_array.to_yaml
end
