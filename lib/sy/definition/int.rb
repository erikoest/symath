require 'sy/value'
require 'sy/definition/operator'

module Sy
  class Definition::Int < Definition::Operator
    def initialize()
      super(:int)
    end
    
    def validate_args(e)
      var = e.args[1]
      a = e.args[2]
      b = e.args[3]

      if !var.nil?
        if !var.is_a?(Sy::Variable)
          raise "Expected variable for var, got " + var.class.name
        end

        if !var.is_d?
          raise "Expected var to be a differential, got " + var.to_s
        end
      end
      if (!a.nil? and b.nil?) or (a.nil? and !b.nil?)
        raise "A cannot be defined without b and vica versa."
      end
    end

    def evaluate_exp(e)
      exp = e.args[0]
      var = e.args[1]
      a = e.args[2]
      b = e.args[3]

      if a.nil?
        ret = exp.anti_derivative(var)
        return ret.nil? ? nil : ret + :C.to_m
      else
        int = exp.anti_derivative(var)
        return op(:bounds, int, var.undiff, a, b)
      end
    end

    def to_latex(args)
      if !args
        args = @args
      end
      
      if args[0].is_sum_exp?
        exp = "\\left(#{args[0].to_latex}\\right)"
      else
        exp = args[0].to_latex
      end

      var = args[1]
      a = args[2]
      b = args[3]

      if a.nil?
        return "\\int #{exp}\\,#{var.to_latex}"
      else
        return "\\int_{#{a.to_latex}}^{#{b.to_latex}} #{exp}\\,#{var.to_latex}"
      end
    end
  end
end
