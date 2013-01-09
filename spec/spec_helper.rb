require 'rspec'
require 'rack/test'
require 'ruby-em_algorithm/version'
require 'ruby-em_algorithm'

RSpec.configure do |config|
    config.include Rack::Test::Methods
    config.color_enabled = true
end
