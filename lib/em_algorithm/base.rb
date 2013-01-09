require 'em_algorithm/models/model'
require 'em_algorithm/models/gauss'
require 'em_algorithm/models/mixture'

module EMAlgorithm
  MAX_ITERATION = 10000
  class Base
    class TempWeight
      def initialize(num_models)
        @weight_per_datum = Array.new(num_models).map { Array.new }
        @weight = Array.new(num_models)
      end

      def clear!
        @weight_per_datum.each do |w|
          w.clear
        end
      end

      def update!(data_array, posterior_data_array, mix_model)
        mix_model.models.each_with_index do |model, mi|
          data_array.each_with_index do |x, di|
            @weight_per_datum[mi] <<  mix_model.weights[mi] * model.pdf(x) / posterior_data_array[di]
          end
          @weight[mi] = @weight_per_datum[mi].inject(0.0) {|sum, w| sum + w}
        end
      end

      def weight_per_datum(model_index, data_index)
        @weight_per_datum[model_index][data_index]
      end

      def weight(model_index)
        @weight[model_index]
      end
    end

    class Likelihood
      THRESHOLD = 0.0001
      #THRESHOLD = 0.01

      attr_accessor :history

      def initialize(data_array, model)
        @data_array = data_array
        @model = model
        @history = []
      end

      # calculate log likelihood
      def calculate
        likelihood = @data_array.inject(0.0) do |likelihood, x|
          likelihood + log(@model.pdf(x))
        end
        @history << likelihood
        likelihood
      end

      def value
        @history.last
      end

      def converged?
        return if @history.length == 1
        (@history[-1] - @history[-2]).abs < THRESHOLD
      end
    end

    attr_accessor :model, :data_array, :likelihood

    # * Model limitation
    # currently only Gaussian Mixture model is supported.
    # if you want to use simple Gauss, you must use a mixture model
    # which has only one Gauss model entry with weight 1.0.
    #
    # * Data limitation
    # currently only one dimension is supported.
    def initialize(options)
      opts = {
        :model => Mixture.new(:models => [Gauss.new(0.0, 9.0)], :weights => [1.0]),
        :data_array => []
      }.merge(options)
      @model = opts[:model]
      @data_array = opts[:data_array]
      @posterior_data_array = Array.new(@data_array.size, 0.0)
      @temp_weight = TempWeight.new(@model.models.size)
      @likelihood = Likelihood.new(@data_array, @model)
    end

    def clear_posterior_data_array!
      @posterior_data_array = Array.new(@data_array.size, 0.0)
    end

    # calculate @posterior_data_array
    def estep
      @temp_weight.clear!

      clear_posterior_data_array!

      @model.models.each_with_index do |model, mi|
        @data_array.each_with_index do |x, di|
          @posterior_data_array[di] += @model.weights[mi] * model.pdf(x)
        end
      end

      @temp_weight.update!(@data_array, @posterior_data_array, @model)
    end

    def update_average
      @model.models.each_with_index do |model, mi|
        data_sum = (0..(@data_array.size-1)).inject(0.0) do |sum, di|
          sum + @temp_weight.weight_per_datum(mi, di) * @data_array[di]
        end
        model.mu = data_sum / @temp_weight.weight(mi)
      end
    end

    def update_sigma2
      @model.models.each_with_index do |model, mi|
        data_sum = (0..(@data_array.size-1)).inject(0.0) do |sum, di|
          sum + @temp_weight.weight_per_datum(mi, di) * (@data_array[di] - model.mu) ** 2
        end
        model.sigma2 = data_sum / @temp_weight.weight(mi)
      end
    end

    def update_weight
      @model.models.each_with_index do |models, mi|
        @model.weights[mi] = @temp_weight.weight(mi) / @data_array.size
      end
    end

    # calculate posterior model parameters
    def mstep
      update_average

      update_sigma2

      update_weight
    end

    def run!
      MAX_ITERATION.times do |i|
        puts "step#{i}"
        @likelihood.calculate
        puts "log_likelihood: #{@likelihood.value}"
        p @model.models
        puts ""
        estep
        mstep
        if @likelihood.converged?
          break
        end
      end
      @model
    end
  end
end
