require 'sy/operation'
require 'set'

module Sy
  class Differential < Operation
    # Calculate differential
    def description
      return 'Calculate differential'
    end

    def result_is_normal?
      return false
    end

    def act(exp, var)
      return diff(exp, var)*var.to_diff
    end

    def diff(exp, var)
      if exp.is_constant?([var].to_set)
        return 0.to_m
      end

      if exp == var
        return 1.to_m
      end
      
      if exp.is_a?(Sy::Sum)
        return diff(exp.summand1, var) + diff(exp.summand2, var)
      end

      if exp.is_a?(Sy::Subtraction)
        return diff(exp.minuend, var) - diff(exp.subtrahend, var)
      end

      if exp.is_a?(Sy::Minus)
        return -diff(exp.argument, var)
      end

      if exp.is_a?(Sy::Product)
        return do_product(exp, var)
      end

      if exp.is_a?(Sy::Fraction)
        return do_fraction(exp, var)
      end

      if exp.is_a?(Sy::Power)
        return do_power(exp, var)
      end

      if exp.is_a?(Sy::Function)
        return do_function(exp, var)
      end
      
      raise 'Cannot calculate derivative of expression ' + exp.to_s
    end

    def do_product(exp, var)
      return diff(exp.factor1, var)*exp.factor2 + exp.factor1*diff(exp.factor2, var)
    end

    def do_fraction(exp, var)
      return diff(exp.dividend, var)*exp.divisor - exp.dividend*diff(exp.divisor, var) /
                                                  (exp.divisor**2)
    end

    def do_power(exp, var)
      return exp*fn(:ln, exp.base)*diff(exp.exponent, var) +
             exp.exponent*exp.base**(exp.exponent - 1)*diff(exp.base, var)
    end

    def do_function(exp, var)
      d = case exp.name.to_s
          # Exponential function
          when 'exp' then exp
          when 'ln' then 1.to_m/exp.args[0]
          # Trigonometric functions
          when 'sin' then fn(:cos, exp.args[0])
          when 'cos' then -fn(:sin, exp.args[0])
          when 'tan' then 1.to_m + fn(:tan, exp.args[0])**2
          when 'cot' then -(1.to_m + fn(:cot, exp.args[0])**2)
          when 'sec' then fn(:sec, exp.args[0])*fn(:tan, exp.args[0])
          when 'csc' then -fn(:cot, exp.args[0])*fn(:csc, exp.args[0])
          else raise 'Cannot calculate differential of function' + exp.to_s
        end
      return d*diff(exp.args[0], var)
    end
  end
end
