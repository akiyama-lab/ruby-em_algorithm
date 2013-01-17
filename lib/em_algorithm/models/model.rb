module EMAlgorithm
  class Model

    def pdf(x)
      # method "probability_density_function" must be implemented
      probability_density_function(x)
    end

    # posterior_data_array may have posterior probability values or estimated values with the assumed distribution.
    # If the values are estimated value (not the probability), we assume them as the frequency of the observation.
    # As a result, the estimated values can be considered as a probability distribution.
    # For example, if the model is specified as 2 dimension, and the argument data has 3 dimension.
    # 3rd value is used as the weight (frequency) of the observation.
    def pdf_ow(x)
      # method "probability_density_function" must be implemented
      probability_density_function_with_observation_weight(x)
    end

    def round(n, d)
      (n * 10 ** d).round / 10.0 ** d
    end
  end
end
