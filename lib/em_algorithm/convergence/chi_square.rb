module EMAlgorithm
  class ChiSquare < CheckMethod
    STAT_THRESHOLD = 0.05
    CONV_THRESHOLD = 0.001

    attr_accessor :history

    def initialize(data_array, model)
      @data_array = data_array
      @model = model
      @history = []
    end

    # calculate chi square
    def calculate
      chi_square = @data_array.inject(0.0) do |chi_square, x|
        chi_square + @model.chi_square(x)
      end
      @history << chi_square
      chi_square
    end

    def value
      @history.last
    end

    def converged?
      return false if @history.length == 1
      (@history[-1] < STAT_THRESHOLD) || ((@history[-1] - @history[-2]).abs < CONV_THRESHOLD)
    end

    def debug_output
      $stderr.puts "ChiSquare: #{value}"
    end
  end
end
