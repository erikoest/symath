require 'sy/operation'
require 'set'

module Sy
  class Derivative < Operation
    def initialize(var)
      @var = var
      @varset = [var].to_set
    end
    
    def act(exp)
      if exp.is_constant?(@varset)
        return 0.to_m
      end

      if exp == @var
        return 1.to_m
      end
      
      if exp.is_a?(Sy::Sum)
        return self.act(exp.summand1) + self.act(exp.summand2)
      end

      if exp.is_a?(Sy::Subtraction)
        return self.act(exp.minuend) - self.act(exp.subtrahend)
      end

      if exp.is_a?(Sy::Minus)
        return -self.act(exp.argument)
      end

      if exp.is_a?(Sy::Product)
        return self.do_product(exp)
      end

      if exp.is_a?(Sy::Fraction)
        return self.do_fraction(exp)
      end

      if exp.is_a?(Sy::Power)
        return self.do_power(exp)
      end

      if exp.is_a?(Sy::Function)
        return self.do_function(exp)
      end
      
      raise 'Cannot calculate derivative of expression ' + exp.to_s
    end

    def do_product(exp)
      return self.act(exp.factor1)*exp.factor2 + exp.factor1*self.act(exp.factor2)
    end

    def do_fraction(exp)
      return self.act(exp.dividend)*exp.divisor - exp.dividend*self.act(exp.divisor) /
                                                  (exp.divisor**2)
    end

    def do_power(exp)
      return exp*fn(:ln, exp.base)*self.act(exp.exponent) +
             exp.exponent*exp.base**(exp.exponent - 1)*self.act(exp.base)
    end

    def do_function(exp)
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
          else raise 'Cannot calculate derivative of expression' + exp.to_s
        end
      return d*self.act(exp.args[0])
    end
  end
end
