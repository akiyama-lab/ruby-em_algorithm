module EMAlgorithm
  class Likelihood < CheckMethod
    #THRESHOLD = 0.0001
    THRESHOLD = 0.01

    attr_accessor :history

    def initialize(data_array)
      @data_array = data_array
      @history = []
    end

    # calculate log likelihood
    def calculate(model)
      likelihood = @data_array.inject(0.0) do |likelihood, x|
        likelihood + log(model.pdf(x))
      end
      @history << likelihood
      likelihood
    end

    def value
      @history.last
    end

    def converged?
      return false if @history.length == 1
      (@history[-1] - @history[-2]).abs < THRESHOLD
    end

    def debug_output
      "Likelihood: #{value}"
    end
  end
end
