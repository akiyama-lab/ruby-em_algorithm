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

    attr_accessor :model, :original_data_array, :data_array, :likelihood, :num_step, :const

    # * Model limitation
    # currently only Gaussian Mixture model is supported.
    # if you want to use simple Gaussian, you must use a mixture model
    # which has only one Gaussian model entry with weight 1.0.
    #
    # * Input data format
    # You can estimate the probability distribution and the target value distribution.
    # If you want to estimate the target value distribution, you must specify the target
    # value and its correspondence area size into the input vector x.
    # x[-2]: target value
    # x[-1]: correspondent area size
    def initialize(options)
      opts = {
        :model => Mixture.new(:models => [Gaussian.new(0.0, 9.0)], :weights => [1.0]),
        :data_array => [],
        :value_distribution_estimation => false,
        :debug => true
      }.merge(options)
      @model = opts[:model]
      @original_data_array = opts[:data_array]
      @value_distribution_estimation = opts[:value_distribution_estimation]
      if @value_distribution_estimation
        @data_array = value_to_frequency(@original_data_array)
      else
        @data_array = @original_data_array
      end
      @likelihood = Likelihood.new(@data_array)
      @debug = opts[:debug]
      @const = 1.0
    end

    # calculate @posterior_data_array
    def estep
      @model.clear_temp_weight_per_datum!
      @posterior_data_array = @model.calculate_posterior_data_array(@data_array)
      @model.update_temp_weights!(@data_array, @posterior_data_array)
    end

    # calculate posterior model parameters
    def mstep
      if @debug
        $stderr.puts @model.inspect
      end
      @model.update_parameters!(@data_array)
    end

    def run!
      MAX_ITERATION.times do |i|
        if @debug
          $stderr.puts "step#{i}"
        end
        # check convergence
        @likelihood.calculate(@model)
        if @debug
          $stderr.puts @likelihood.debug_output
        end
        if @likelihood.converged?
          @num_step = i
          if @value_distribution_estimation
            @const = distribution_to_value_ratio
          end
          break
        end
        if @debug
          $stderr.puts @model.debug_output
          $stderr.puts ""
        end
        estep
        mstep
      end
      @model
    end

    def value_to_frequency(data_array)
      modified_data_array = []
      data_array.each do |x|
        x[x.size-2].round.times do
          x_without_value = x[0..(x.size-3)]
          x_without_value = x_without_value.first if x_without_value.size == 1
          modified_data_array << x_without_value
        end
      end
      modified_data_array
    end

    # the integration of the distribution equal 1.0
    # so thus, the integration of the target value means the ratio of
    # probability distribution and the target value distribution
    def distribution_to_value_ratio
      integrated_value = 0.0
      @original_data_array.each do |x|
        value = x[x.size-2]
        integrated_value += value * x[x.size-1]
      end
      integrated_value
    end
  end
end
