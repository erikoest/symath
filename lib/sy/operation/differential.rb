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

    @@functions = {
      # Exponential and trigonometric functions
      :exp => fn(:exp, :a.to_m),
      :ln  => 1.to_m/:a.to_m,
      # Trigonometric functions
      :sin => fn(:cos, :a.to_m),
      :cos => - fn(:sin, :a.to_m),
      :tan => 1.to_m + fn(:tan, :a.to_m)**2,
      :cot => - (1.to_m + fn(:cot, :a.to_m)**2),
      :sec => fn(:sec, :a.to_m)*fn(:tan, :a.to_m),
      :csc => - fn(:cot, :a.to_m)*fn(:csc, :a.to_m),
      # Inverse trigonometric functions
      :arcsin => 1.to_m/fn(:sqrt, 1.to_m - :a.to_m**2),
      :arccos => - 1.to_m/fn(:sqrt, 1.to_m - :a.to_m**2),
      :arctan => 1.to_m/fn(:sqrt, 1.to_m + :a.to_m**2),
      :arcsec => 1.to_m/(fn(:abs, :a.to_m)*fn(:sqrt, :a.to_m**2 - 1)),
      :arccsc => - 1.to_m/(fn(:abs, :a.to_m)*fn(:sqrt, :a.to_m**2 - 1)),
      :arccot => - 1.to_m/(1.to_m + :a.to_m**2),
      # Hyperbolic functions
      :sinh => fn(:cosh, :a.to_m),
      :cosh => fn(:sinh, :a.to_m),
      :tanh => fn(:sech, :a.to_m)**2,
      :sech => - fn(:tanh, :a.to_m)*fn(:sech, :a.to_m),
      :csch => - fn(:coth, :a.to_m)*fn(:csch, :a.to_m),
      :coth => - fn(:csch, :a.to_m)**2,
      # Inverse hyperbolic functions
      :arsinh => 1.to_m/fn(:sqrt, :a.to_m**2 + 1),
      :arcosh => 1.to_m/fn(:sqrt, :a.to_m**2 - 1),
      :artanh => 1.to_m/(1.to_m - :a.to_m**2),
      :arsech => - 1.to_m/(:a.to_m*fn(:sqrt, 1.to_m - :a.to_m**2)),
      :arcsch => - 1.to_m/(fn(:abs, :a.to_m)*fn(:sqrt, :a.to_m**2 + 1)),
      :arcoth => 1.to_m/(1.to_m - :a.to_m**2),
    }
    
    def do_function(exp, vars)
      if @@functions.key?(exp.name.to_sym)
        d = @@functions[exp.name.to_sym].deep_clone
        d.replace({ :a.to_m => exp.args[0] })
        return d^diff(exp.args[0], vars)
      else
        raise 'Cannot calculate differential of expression ' + exp.to_s
      end
    end
  end
end
