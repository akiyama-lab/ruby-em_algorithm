module EMAlgorithm
  class Gauss < Model
    attr_accessor :mu, :sigma2

    def initialize(mu = 0.0, sigma2 = 1.0)
      @mu = mu
      @sigma2 = sigma2
    end

    def probability_density_function(x)
      sigma = sqrt(@sigma2)
      exp(-((x-@mu)**2.0)/(2.0*@sigma2))/(sqrt(2.0*PI)*sigma)
    end

    def to_gnuplot
      "exp(-((x-(#{round(@mu,6)}))**2.0)/(2.0*#{round(@sigma2,6)}))/(sqrt(2.0*pi)*sqrt(#{round(@sigma2,6)}))"
    end

    def to_gnuplot_with_title(weight)
      to_gnuplot + " w l axis x1y2 lw 3 title '#{round(weight,6)}*N(#{round(@mu,6)},#{round(@sigma2,6)})'"
    end
  end
end
