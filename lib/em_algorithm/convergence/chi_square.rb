module EMAlgorithm
  class ChiSquare < CheckMethod
    STAT_THRESHOLD = 0.05
    CONV_THRESHOLD = 0.01

    attr_accessor :history

    def initialize(data_array)
      @data_array = data_array
      @history = []
    end

    # calculate chi square
    def calculate(model, const)
      chi_square = 0.0
      @data_array.each do |x|
        value = x[x.size-1]
        pdf = model.pdf(x[0..(x.size-2)])
        next if value <= 1.0
        estimated = const * pdf
        chi_square += (value - estimated)**2 / estimated
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
