# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ruby-em_algorithm/version', __FILE__)

Gem::Specification.new do |gem|
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '~> 2.8'
  gem.add_development_dependency 'gsl'

  gem.authors       = ["Jun Sugahara", "Toyokazu Akiyama"]
  gem.email         = ["toyokazu@gmail.com"]
  gem.description   = %q{EMAlgorithm for Ruby}
  gem.summary       = %q{EMAlgorithm for Ruby}
  gem.homepage      = ""

  gem.files         = `find . -not \\( -regex ".*\\.git.*" -o -regex "\\./pkg.*" -o -regex "\\./spec.*" \\)`.split("\n").map{ |f| f.gsub(/^.\//, '') }
  gem.test_files    = `find spec/*`.split("\n")
  gem.name          = "ruby-em_algorithm"
  gem.require_paths = ["lib"]
  gem.version       = EMAlgorithm::VERSION

end
