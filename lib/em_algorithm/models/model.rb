module EMAlgorithm
  class Model
    # round digit for gnuplot
    DIGIT = 6

    def pdf(x)
      # method "probability_density_function" must be implemented
      probability_density_function(x)
    end

    def value_distribution(const, x)
      const * pdf(x)
    end

    def value_distribution_to_gnuplot(const)
      "#{const.round(DIGIT)}*(#{to_gnuplot(:mixture_only)})"
    end
  end
end
