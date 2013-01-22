module EMAlgorithm
  class Mixture < Model
    attr_accessor :models, :weights

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

    def clear_temp_weight_per_datum!
      @temp_weight_per_datum.each {|w| w.clear}
    end

    def calculate_posterior_data_array(data_array)
      posterior_data_array = Array.new(data_array.size, 0.0)
      @models.each_with_index do |model, mi|
        data_array.each_with_index do |x, di|
          posterior_data_array[di] += @weights[mi] * model.pdf(x)
        end
      end
      posterior_data_array
    end

    def update_temp_weights!(data_array, posterior_data_array)
      @models.each_with_index do |model, mi|
        data_array.each_with_index do |x, di|
          temp_weight_per_datum = @weights[mi] * model.pdf(x) / posterior_data_array[di]
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

    # output types
    # :full (default)
    # :separate_only
    # :mixture_only
    def to_gnuplot(type = :full)
      # output each model (currently assume Gaussian)
      output = []
      @models.each_with_index do |model, mi|
        output << "#{@weights[mi].round(DIGIT)} * #{model.to_gnuplot_with_title(@weights[mi])}"
      end
      separate = output.join(", ")
      # output mixture model (currently assume Gaussian Mixture model)
      output = []
      @models.each_with_index do |model, mi|
        output << "#{@weights[mi].round(DIGIT)} * #{model.to_gnuplot}"
      end
      mixture = output.join(" + ")
      case type
      when :separate_only
        return separate
      when :mixture_only
        return mixture
      end
      "#{separate}, #{mixture}"
    end

    def debug_output
      <<-DEBUG_OUT
  @weights=#{@weights.inspect}
  @temp_weights=#{@temp_weights.inspect}
  @models
   #{@models.inspect}
      DEBUG_OUT
    end
  end
end
