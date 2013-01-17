module EMAlgorithm
  class Gaussian < Model
    attr_accessor :mu, :sigma, :dim

    def initialize(mu = 0.0, sigma = 1.0)
      @mu = mu
      @sigma = sigma
    end

    def probability_density_function(x)
      exp(-((x-@mu)**2.0)/(2.0*@sigma**2))/(sqrt(2.0*PI)*@sigma)
    end

    def probability_density_function_with_observation_weight(x_with_weight)
      x = x_with_weight[0]
      observation_weight = x_with_weight[1]
      observation_weight * probability_density_function(x)
    end

    def update_average!(data_array, temp_weight, temp_weight_per_datum)
      data_sum = (0..(data_array.size-1)).inject(0.0) do |sum, di|
        sum + temp_weight_per_datum[di] * data_array[di]
      end
      @mu = data_sum / temp_weight
    end

    def update_sigma!(data_array, temp_weight, temp_weight_per_datum)
      data_sum = (0..(data_array.size-1)).inject(0.0) do |sum, di|
        sum + temp_weight_per_datum[di] * (data_array[di] - @mu) ** 2
      end
      @sigma = sqrt(data_sum / temp_weight)
    end

    def update_parameters!(data_array, temp_weight, temp_weight_per_datum)
      update_average!(data_array, temp_weight, temp_weight_per_datum)
      update_sigma!(data_array, temp_weight, temp_weight_per_datum)
    end

    def to_gnuplot
      "exp(-((x-(#{round(@mu,6)}))**2.0)/(2.0*#{round(@sigma ** 2,6)}))/(sqrt(2.0*pi)*#{round(@sigma,6)})"
    end

    def to_gnuplot_with_title(weight)
      to_gnuplot + " w l axis x1y2 lw 3 title '#{round(weight,6)}*N(#{round(@mu,6)},#{round(@sigma,6)})'"
    end
  end
end
