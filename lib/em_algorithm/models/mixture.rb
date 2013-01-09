module EMAlgorithm
  class Mixture < Model
    attr_accessor :models, :weights

    def initialize(options)
      opts = {
        :models =>
        [
          Gauss.new(0.0, 9.0), Gauss.new(10.0, 9.0)
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
    end

    def argument_error
      raise ArgumentError, "The summation of @weights must be equal to 1.0."
    end

    def add(model = Gauss.new(0.0, 9.0), weight = 0.0)
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

    def to_gnuplot
      # output each model (currently assume Gauss)
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
  end
end
