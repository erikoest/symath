require 'sy/operation'
require 'set'

module Sy::Operation::Differential
  include Sy::Operation

  # The diff() method provided in this operation module calculates the
  # differential with respect to a given set of variables. Note that the
  # operation returns the differential and not the derivative, so the
  # resulting expression is a differential form.

  @@functions = {}
    
  # Module initialization
  def self.initialize()
    # Map of single argument functions to their derivative. By convention,
    # the free variable name is :a
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

  def diff(vars)
    if is_constant?(vars)
      return 0.to_m
    end

    if vars.member?(self)
      return to_diff
    end
      
    if is_a?(Sy::Sum)
      return term1.diff(vars) + term2.diff(vars)
    end

    if is_a?(Sy::Minus)
      return -argument.diff(vars)
    end

    if is_a?(Sy::Product)
      return diff_product(vars)
    end
      
    if is_a?(Sy::Wedge)
      return diff_product(vars)
    end
      
    if is_a?(Sy::Fraction)
      return diff_fraction(vars)
    end

    if is_a?(Sy::Power)
      return diff_power(vars)
    end

    if is_a?(Sy::Function)
      return diff_function(vars)
    end
      
    raise 'Cannot calculate derivative of expression ' + to_s
  end

  # For simplicity, just use wedge products all the time. They will be
  # normalized to scalar products afterwards.
  def diff_product(vars)
    return (_diff_wedge(factor1.diff(vars), factor2) +
            _diff_wedge(factor1, factor2.diff(vars)))
  end

  def diff_fraction(vars)
    return (_diff_wedge(dividend.diff(vars), divisor) -
            _diff_wedge(dividend, divisor.diff(vars))) /
           (divisor**2)
  end

  def diff_power(vars)
    return _diff_wedge(_diff_wedge(self, fn(:ln, base)), exponent.diff(vars)) +
           _diff_wedge(_diff_wedge(exponent, base**(exponent - 1)),
                                   base.diff(vars))
  end

  def diff_function(vars)
    if @@functions.key?(name.to_sym)
      d = @@functions[name.to_sym].deep_clone
      d.replace({ :a.to_m => args[0] })
      return _diff_wedge(d, args[0].diff(vars))
    else
      raise 'Cannot calculate differential of expression ' + to_s
    end
  end
  
  # Apply wedge product or ordinary product between two expressions,
  # depending on whether or not they have vector parts.
  def _diff_wedge(exp1, exp2)
    # Take out the divisor from both exp1 and exp2, then expand left and
    # right side and put back the divisor in the end.
    c = exp1.coefficient.to_m*exp2.coefficient.to_m*exp1.sign*exp2.sign
    d = (exp1.div_factors.to_a + exp2.div_factors.to_a).inject(:*) || 1.to_m

    s1 = (exp1.scalar_factors.inject(:*) || 1.to_m)*(
          exp1.vector_factors.inject(:^) || 1.to_m)
    s2 = (exp2.scalar_factors.inject(:*) || 1.to_m)*(
          exp2.vector_factors.inject(:^) || 1.to_m)
    s3 = s1.mul(s2).expand
    return c*s3/d
  end
end
