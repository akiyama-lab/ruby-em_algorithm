module EMAlgorithm
  class Model
    def pdf(x)
      # method "probability_density_function" must be implemented
      probability_density_function(x)
    end

    def round(n, d)
      (n * 10 ** d).round / 10.0 ** d
    end
  end
end
