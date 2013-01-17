module EMAlgorithm
  class Model

    def method_postfix
      @method_postfix.nil? ? "_org" : @method_postfix
    end

    def pdf(x)
      # method "probability_density_function" must be implemented
      method("pdf#{method_postfix}").call(x)
    end

    def pdf_org(x)
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

    def avg_u(data_array, di)
      method("avg_u#{method_postfix}").call(data_array, di)
    end

    def avg_u_org(data_array, di)
      average_unit(data_array, di)
    end

    def avg_u_ow(data_array, di)
      average_unit_with_observation_weight(data_array, di)
    end

    def sig2_u(data_array, di)
      method("sig2_u#{method_postfix}").call(data_array, di)
    end

    def sig2_u_org(data_array, di)
      sigma2_unit(data_array, di)
    end

    def sig2_u_ow(data_array, di)
      sigma2_unit_with_observation_weight(data_array, di)
    end

    def round(n, d)
      (n * 10 ** d).round / 10.0 ** d
    end
  end
end
