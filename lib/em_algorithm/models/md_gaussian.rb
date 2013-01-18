module EMAlgorithm
  class MdGaussian < Model
    attr_accessor :mu, :sigma2

    def initialize(mu = GSL::Vector[0.0, 0.0], sigma2 = GSL::Matrix[[1.0, 0.0], [0.0, 1.0]], c = nil)
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
      @const = c
      @update_const = (!@const.nil?)
      @method_postfix = ""
    end

    def remove_weight(x_with_weight)
      x_with_weight[0..(@mu.size-1)]
    end

    def observation_weight(x_with_weight)
      x_with_weight[@mu.size]
    end

    def const
      @const.nil? ? 1.0 : @const
    end

    def init_method_postfix(method_postfix)
      @method_postfix = method_postfix
    end

    def probability_density_function(x_with_weight)
      x = remove_weight(x_with_weight)
      exp(-((x-@mu) * @sigma2_invert * (x-@mu).trans)/2.0)/((sqrt(2.0*PI)**@mu.size)*@sqrt_sigma2_det)
    end

    def probability_density_function_with_observation_weight(x_with_weight)
      observation_weight(x_with_weight) * probability_density_function(x_with_weight)
    end

    # TODO
    # mstep may not require observation weight revision
    def revise_weight(data_array, temp_weight, temp_weight_per_datum)
      return temp_weight if @method_postfix.empty?
      return @revised_weight if !@revised_weight.nil?
      @revised_weight = 0.0
      temp_weight_per_datum.each_with_index do |w, di|
        @revised_weight += w * observation_weight(data_array[di])
      end
      @revised_weight
    end

    def average_unit(data_array, di)
      remove_weight(data_array[di])
    end

    # TODO
    # mstep may not require observation weight revision
    def average_unit_with_observation_weight(data_array, di)
      #average_unit(data_array, di)
      observation_weight(data_array[di]) * average_unit(data_array, di)
    end

    alias :average_unit_ow :average_unit_with_observation_weight

    def update_average!(data_array, temp_weight, temp_weight_per_datum)
      data_sum = (0..(data_array.size-1)).inject(GSL::Vector.alloc(@mu.size).set_zero) do |sum, di|
        sum + temp_weight_per_datum[di] * method("average_unit#{@method_postfix}").call(data_array, di)
      end
      @mu = data_sum / revise_weight(data_array, temp_weight, temp_weight_per_datum)
    end

    def sigma2_unit(data_array, di)
      (remove_weight(data_array[di]) - @mu).trans * (remove_weight(data_array[di]) - @mu)
    end

    # TODO
    # mstep may not require observation weight revision
    def sigma2_unit_with_observation_weight(data_array, di)
      #sigma2_unit(data_array, di)
      observation_weight(data_array[di]) * sigma2_unit(data_array, di)
    end

    alias :sigma2_unit_ow :sigma2_unit_with_observation_weight

    def update_sigma2!(data_array, temp_weight, temp_weight_per_datum)
      data_sum = (0..(data_array.size-1)).inject(0.0) do |sum, di|
        sum + temp_weight_per_datum[di] * method("sigma2_unit#{@method_postfix}").call(data_array, di)
      end
      $stderr.puts "(data_sum / revise_weight(data_array, temp_weight, temp_weight_per_datum)) ="
      $stderr.puts (data_sum / revise_weight(data_array, temp_weight, temp_weight_per_datum)).inspect
      @sigma2 = (data_sum / revise_weight(data_array, temp_weight, temp_weight_per_datum))
      @sqrt_sigma2_det = sqrt(@sigma2.det)
      @sigma2_invert = @sigma2.invert
    end

    # TODO
    # update_const! may not be required
    def update_const!(data_array, temp_weight, temp_weight_per_datum)
      #data_sum = (0..(data_array.size-1)).inject(0.0) do |sum, di|
      #  sum + temp_weight_per_datum[di] * observation_weight(data_array[di])
      #end
      #@const = (data_sum / revise_weight(data_array, temp_weight, temp_weight_per_datum))
      @const = observation_weight(data_array.max {|a,b| observation_weight(a) <=> observation_weight(b)}) / pdf(@mu)
    end

    def update_parameters!(data_array, temp_weight, temp_weight_per_datum)
      @revised_weight = nil
      update_average!(data_array, temp_weight, temp_weight_per_datum)
      update_sigma2!(data_array, temp_weight, temp_weight_per_datum)
      if @update_const
        update_const!(data_array, temp_weight, temp_weight_per_datum)
      end
    end

    def to_gnuplot
      if @mu.size == 2
        # [x - mu_x, y - mu_y] * [[s_x, s_xy], [s_xy,  s_y]] * [x - mu_x, y - mu_y]
        # = s_x*(x - mu_x)**2 + 2*s_xy*(x - mu_x)(y - mu_y) + s_y*(y - mu_y)**2
        sigma2_xy = @sigma2[0,1] + @sigma2[1,0]
        xy = "+(#{round(sigma2_xy,6)})*(x-(#{round(@mu[0],6)}))*(y-(#{round(@mu[1],6)}))" if sigma2_xy > 0 || sigma2_xy < 0
        const = @const.nil? ? 1.0 : round(@const,6)
        "(#{const}) * exp(-((#{round(@sigma2[0,0],6)})*(x-(#{round(@mu[0],6)}))**2.0+(#{round(@sigma2[1,1],6)})*(y-(#{round(@mu[1],6)}))**2.0#{xy})/2.0)/(sqrt(2.0*pi)*(#{round(@sqrt_sigma2_det,6)}))"
      else
        "N(#{@mu.to_a.inspect}, #{@sigma2.to_a.inspect})"
      end
    end

    def to_gnuplot_with_title(weight)
      if @mu.size == 2
        to_gnuplot + " w l lw 3 title '#{round(weight,6)}*N(#{@mu.map{|mu| round(mu,6)}.to_a.inspect},#{@sigma2.map{|sigma2| round(sigma2,6)}.to_a.inspect})'"
      else
        "N(#{@mu.to_a.inspect}, #{@sigma2.to_a.inspect})"
      end
    end
  end
end
