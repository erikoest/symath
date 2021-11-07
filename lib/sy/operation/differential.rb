require 'sy/operation'
require 'set'

module Sy::Operation::Differential
  class DifferentialError < StandardError
  end

  include Sy::Operation

  # The d() method provided in this operation module calculates the
  # differential with respect to a given set of variables. Note that the
  # operation returns the differential and not the derivative, so the
  # resulting expression is a differential form.

  # Module initialization
  def self.initialize()
    # Map of single argument functions to their derivative. By convention,
    # the free variable name is :a
    # FIXME: This does not work if the function definition 'a' exists.
    #        Use lambda operators.
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
  end

  def d(vars)
    if is_constant?(vars)
      return 0.to_m
    end

    if vars.member?(self)
      return to_d
    end
      
    if is_a?(Sy::Sum)
      return term1.d(vars) + term2.d(vars)
    end

    if is_a?(Sy::Minus)
      return -argument.d(vars)
    end

    if is_a?(Sy::Product)
      return d_product(vars)
    end

    if is_a?(Sy::Fraction)
      return d_fraction(vars)
    end

    if is_a?(Sy::Power)
      return d_power(vars)
    end

    return d_function(vars)
  end

  def d_failure()
    raise DifferentialError, 'Cannot calculate differential of expression ' + to_s
  end

  # For simplicity, just use wedge products all the time. They will be
  # normalized to scalar products afterwards.
  def d_product(vars)
    return (_d_wedge(factor1.d(vars), factor2) +
            _d_wedge(factor1, factor2.d(vars)))
  end

  def d_fraction(vars)
    return (_d_wedge(dividend.d(vars), divisor) -
            _d_wedge(dividend, divisor.d(vars))) /
           (divisor**2)
  end

  def d_power(vars)
    return _d_wedge(_d_wedge(self, fn(:ln, base)), exponent.d(vars)) +
           _d_wedge(_d_wedge(exponent, base**(exponent - 1)),
                                   base.d(vars))
  end

  def d_function(vars)
    if !self.is_a?Sy::Operator
      d_failure
    end
    
    if !@@functions.key?(name.to_sym)
      d_failure
    end
    
    d = @@functions[name.to_sym].deep_clone
    d.replace({ :a.to_m => args[0] })
    return _d_wedge(d, args[0].d(vars))
  end
  
  # Apply wedge product or ordinary product between two expressions,
  # depending on whether or not they have vector parts.
  def _d_wedge(exp1, exp2)
    # The product operator will determine whether this is a scalar
    # or a wedge product.
    return (exp1.factors.to_a + exp2.factors.to_a).inject(:*)
  end
end
