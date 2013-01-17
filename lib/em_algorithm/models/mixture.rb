module EMAlgorithm
  class Mixture < Model
    attr_accessor :models, :weights, :method_postfix

    def initialize(options)
      opts = {
        :models =>
        [
          Gaussian.new(0.0, 9.0), Gaussian.new(10.0, 9.0)
        ],
        :weights =>
        [
          0.5, 0.5
        ]
      }.merge(options)
      @models = opts[:models]
      @weights = opts[:weights]
      if !proper_weights?
        argument_error
      end
      @temp_weights = Array.new(@models.size)
      @temp_weight_per_datum = Array.new(@models.size).map { Array.new }
      @method_postfix = ""
    end

    def chi_square(x)
      estimated = pdf_org(x)
      observation_weight = @models.first.observation_weight(x)
      (observation_weight - estimated) ** 2.0 / estimated
    end

    def init_observation_weight(method_postfix, data_array)
      @method_postfix = method_postfix
      @models.each do |model|
        model.init_observation_weight(method_postfix, data_array)
      end
    end

    def argument_error
      raise ArgumentError, "The summation of @weights must be equal to 1.0."
    end

    def add(model = Gaussian.new(0.0, 9.0), weight = 0.0)
      @models << model
      @weights << weight
      if !proper_weights?
        argument_error
      end
    end

    def proper_weights?
      @weights.inject(0) {|sum, v| sum + v} == 1.0
    end

    def probability_density_function(x)
      pdf = 0.0
      @models.each_with_index do |model, mi|
        pdf += model.pdf(x) * @weights[mi]
      end
      pdf
    end

    def probability_density_function_with_observation_weight(x)
      pdf = 0.0
      @models.each_with_index do |model, mi|
        pdf += model.pdf_ow(x) * @weights[mi]
      end
      pdf
    end

    def clear_temp_weight_per_datum!
      @temp_weight_per_datum.each {|w| w.clear}
    end

    def calculate_posterior_data_array(data_array)
      posterior_data_array = Array.new(data_array.size, 0.0)
      @models.each_with_index do |model, mi|
        data_array.each_with_index do |x, di|
          posterior_data_array[di] += @weights[mi] * pdf(x)
        end
      end
      posterior_data_array
    end

    def update_temp_weights!(data_array, posterior_data_array)
      @models.each_with_index do |model, mi|
        data_array.each_with_index do |x, di|
          temp_weight_per_datum = @weights[mi] * pdf(x) / posterior_data_array[di]
          temp_weight_per_datum = 0.0 if temp_weight_per_datum.nan?
          @temp_weight_per_datum[mi] <<  temp_weight_per_datum
        end
        @temp_weights[mi] = @temp_weight_per_datum[mi].inject(0.0) {|sum, w| sum + w}
      end
    end

    def update_weights!(data_array)
      (0..(@models.size-1)).each do |mi|
        @weights[mi] = @temp_weights[mi] / data_array.size
      end
    end

    def update_parameters!(data_array)
      @models.each_with_index do |model, mi|
        model.update_parameters!(data_array, @temp_weights[mi], @temp_weight_per_datum[mi])
      end
      update_weights!(data_array)
    end

    def to_gnuplot
      # output each model (currently assume Gaussian)
      output = []
      @models.each_with_index do |model, mi|
        output << "#{round(@weights[mi],6)} * #{model.to_gnuplot_with_title(@weights[mi])}"
      end
      puts output.join(", ")
      puts ""
      # output mixture model (currently assume Gaussian Mixture model)
      output = []
      @models.each_with_index do |model, mi|
        output << "#{round(@weights[mi],6)} * #{model.to_gnuplot}"
      end
      puts output.join(" + ")
    end

    def debug_output
      $stderr.puts "@weights=#{@weights.inspect}"
      $stderr.puts "@temp_weights=#{@temp_weights.inspect}"
      $stderr.puts "@models"
      $stderr.puts @models.inspect
    end
  end
end
