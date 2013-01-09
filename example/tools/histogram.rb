require 'yaml'
require 'gsl'

file_path = ARGV[0]
bin = ARGV[1].to_i
range_from = ARGV[2].to_f
range_to = ARGV[3].to_f

data_array = YAML.load_file(file_path)
v = GSL::Vector[data_array]
if range_from != 0 && range_to != 0
  h = v.histogram(bin,[range_from, range_to])
  h.fprintf($stdout, range_format = "%e", bin_format = "%e")
else
  h = v.histogram(bin)
  h.fprintf($stdout, range_format = "%e", bin_format = "%e")
end
#h.graph("-T X -C -g 3")
