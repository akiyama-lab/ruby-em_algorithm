module EMAlgorithm
  class MdGaussian < Model
    attr_accessor :mu, :sigma2

    def initialize(mu = GSL::Vector[0.0, 0.0], sigma2 = GSL::Matrix[[1.0, 0.0], [0.0, 1.0]])
      # check mu
      if mu.class != GSL::Vector
        raise ArgumentError, "mu should be GSL::Vector."
      end
      @mu = mu
      # check sigma2
      if sigma2.class != GSL::Matrix
        raise ArgumentError, "sigma2 should be GSL::Matrix."
      elsif sigma2.size1 != @mu.size || sigma2.size2 != @mu.size
        raise ArgumentError, "The size of sigma2 matrix does not match with mu vector."
      end
      @sigma2 = sigma2
      @sqrt_sigma2_det = sqrt(@sigma2.det)
      @sigma2_invert = @sigma2.invert
    end

    def probability_density_function(x)
      exp(-((x-@mu) * @sigma2_invert * (x-@mu).trans)/2.0)/((sqrt(2.0*PI)**@mu.size)*@sqrt_sigma2_det)
    end

    def update_average!(data_array, temp_weight, temp_weight_per_datum)
      data_sum = (0..(data_array.size-1)).inject(GSL::Vector.alloc(@mu.size).set_zero) do |sum, di|
        sum + temp_weight_per_datum[di] * data_array[di]
      end
      @mu = data_sum / temp_weight
    end

    def update_sigma2!(data_array, temp_weight, temp_weight_per_datum)
      data_sum = (0..(data_array.size-1)).inject(0.0) do |sum, di|
        sum + temp_weight_per_datum[di] * (data_array[di] - @mu).trans * (data_array[di] - @mu)
      end
      @sigma2 = (data_sum / temp_weight)
      @sqrt_sigma2_det = sqrt(@sigma2.det)
      @sigma2_invert = @sigma2.invert
    end

    def update_parameters!(data_array, temp_weight, temp_weight_per_datum)
      update_average!(data_array, temp_weight, temp_weight_per_datum)
      update_sigma2!(data_array, temp_weight, temp_weight_per_datum)
    end

    def to_gnuplot
      if @mu.size == 2
        # [x - mu_x, y - mu_y] * [[s_x, s_xy], [s_xy,  s_y]] * [x - mu_x, y - mu_y]
        # = s_x*(x - mu_x)**2 + 2*s_xy*(x - mu_x)(y - mu_y) + s_y*(y - mu_y)**2
        sigma2_xy = @sigma2[0,1] + @sigma2[1,0]
        xy = "+(#{sigma2_xy.round((DIGIT))})*(x-(#{@mu[0].round((DIGIT))}))*(y-(#{@mu[1].round((DIGIT))}))" if sigma2_xy > 0 || sigma2_xy < 0
        "exp(-((#{@sigma2[0,0].round((DIGIT))})*(x-(#{@mu[0].round((DIGIT))}))**2.0+(#{@sigma2[1,1].round((DIGIT))})*(y-(#{@mu[1].round((DIGIT))}))**2.0#{xy})/2.0)/((sqrt(2.0*pi))**#{@mu.size}*(#{@sqrt_sigma2_det.round((DIGIT))}))"
      else
        "N(#{@mu.to_a.inspect}, #{@sigma2.to_a.inspect})"
      end
    end

    def to_gnuplot_with_title(weight)
      if @mu.size == 2
        to_gnuplot + " w l lw 3 title '#{weight.round((DIGIT))}*N(#{@mu.map{|mu| mu.round((DIGIT))}.to_a.inspect},#{@sigma2.map{|sigma2| sigma2.round((DIGIT))}.to_a.inspect})'"
      else
        "N(#{@mu.to_a.inspect}, #{@sigma2.to_a.inspect})"
      end
    end
  end
end
