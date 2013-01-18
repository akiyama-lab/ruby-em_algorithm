require 'em_algorithm/models/model'
require 'em_algorithm/models/gaussian'
require 'em_algorithm/models/md_gaussian'
require 'em_algorithm/models/mixture'
require 'em_algorithm/convergence/check_method'
require 'em_algorithm/convergence/likelihood'
require 'em_algorithm/convergence/chi_square'

module EMAlgorithm
  include Math
  include GSL

  MAX_ITERATION = 10000

  class Base

    attr_accessor :model, :data_array, :likelihood

    # * Model limitation
    # currently only Gaussian Mixture model is supported.
    # if you want to use simple Gaussian, you must use a mixture model
    # which has only one Gaussian model entry with weight 1.0.
    #
    # * Data limitation
    # currently only one dimension is supported.
    def initialize(options)
      opts = {
        :model => Mixture.new(:models => [Gaussian.new(0.0, 9.0)], :weights => [1.0]),
        :data_array => [],
        :convergence_check => "Likelihood",
        :use_observation_weight => false
      }.merge(options)
      @model = opts[:model]
      @data_array = opts[:data_array]
      @conv_check = (eval opts[:convergence_check]).new(@data_array, @model)
      if opts[:use_observation_weight]
        @model.init_method_postfix("_ow")
      end
    end

    # calculate @posterior_data_array
    def estep
      @model.clear_temp_weight_per_datum!
      @posterior_data_array = @model.calculate_posterior_data_array(@data_array)
      @model.update_temp_weights!(@data_array, @posterior_data_array)
    end

    # calculate posterior model parameters
    def mstep
      # debug
      $stderr.puts @model.inspect
      @model.update_parameters!(@data_array)
    end

    def run!
      MAX_ITERATION.times do |i|
        $stderr.puts "step#{i}"
        # check convergence
        @conv_check.calculate
        @conv_check.debug_output
        if @conv_check.converged?
          break
        end
        $stderr.puts @model.debug_output.inspect
        #p @model.models
        $stderr.puts ""
        estep
        mstep
      end
      @model
    end
  end
end
