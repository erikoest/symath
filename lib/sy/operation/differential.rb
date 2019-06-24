require 'sy/operation'
require 'set'

module Sy
  class Operation::Differential < Operation
    # Calculate differential
    def description
      return 'Calculate differential'
    end

    def result_is_normal?
      return false
    end

    def act(exp, vars)
      return diff(exp, vars)
    end

    def diff(exp, vars)
      if exp.is_constant?(vars)
        return 0.to_m
      end

      if vars.member?(exp)
        return exp.to_diff
      end
      
      if exp.is_a?(Sy::Sum)
        return diff(exp.summand1, vars) + diff(exp.summand2, vars)
      end

      if exp.is_a?(Sy::Subtraction)
        return diff(exp.minuend, vars) - diff(exp.subtrahend, vars)
      end

      if exp.is_a?(Sy::Minus)
        return -diff(exp.argument, vars)
      end

      if exp.is_a?(Sy::Product)
        return do_product(exp, vars)
      end
      
      if exp.is_a?(Sy::Wedge)
        return do_product(exp, vars)
      end
      
      if exp.is_a?(Sy::Fraction)
        return do_fraction(exp, vars)
      end

      if exp.is_a?(Sy::Power)
        return do_power(exp, vars)
      end

      if exp.is_a?(Sy::Function)
        return do_function(exp, vars)
      end
      
      raise 'Cannot calculate derivative of expression ' + exp.to_s
    end

    # For simplicity, just use wedge products all the time. They will be normalized
    # to scalar products afterwards.
    def do_product(exp, vars)
      return (diff(exp.factor1, vars)^exp.factor2) + (exp.factor1^diff(exp.factor2, vars))
    end

    def do_fraction(exp, vars)
      return ((diff(exp.dividend, vars)^exp.divisor) -
              (exp.dividend^diff(exp.divisor, vars))) /
             (exp.divisor**2)
    end

    def do_power(exp, vars)
      return (exp^fn(:ln, exp.base)^diff(exp.exponent, vars)) +
             (exp.exponent^(exp.base**(exp.exponent - 1))^diff(exp.base, vars))
    end

    def do_function(exp, vars)
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
      return d^diff(exp.args[0], vars)
    end
  end
end
