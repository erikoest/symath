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

  # FIXME. The differential method should work on a function and return
  # a lambda with :x/:dx as free variable, for each variable of the
  # input function.

  # Module initialization
  def self.initialize()
    # Map of single argument functions to their derivative.
    # FIXME: Check whether this still works if the symbol a is defined?
    @@functions = {
      # Exponential and trigonometric functions
      :exp => definition(:exp),
      :ln  => lmd(1.to_m/:a.to_m, :a),
      # Trigonometric functions
      :sin => definition(:cos),
      :cos => lmd(- fn(:sin, :a), :a),
      :tan => lmd(1.to_m + fn(:tan, :a)**2, :a),
      :cot => lmd(- (1.to_m + fn(:cot, :a)**2), :a),
      :sec => lmd(fn(:sec, :a)*fn(:tan, :a), :a),
      :csc => lmd(- fn(:cot, :a.to_m)*fn(:csc, :a.to_m), :a),
      # Inverse trigonometric functions
      :arcsin => lmd(1.to_m/fn(:sqrt, 1.to_m - :a.to_m**2), :a),
      :arccos => lmd(- 1.to_m/fn(:sqrt, 1.to_m - :a.to_m**2), :a),
      :arctan => lmd(1.to_m/fn(:sqrt, 1.to_m + :a.to_m**2), :a),
      :arcsec => lmd(1.to_m/(fn(:abs, :a)*fn(:sqrt, :a.to_m**2 - 1)), :a),
      :arccsc => lmd(- 1.to_m/(fn(:abs, :a)*fn(:sqrt, :a.to_m**2 - 1)), :a),
      :arccot => lmd(- 1.to_m/(1.to_m + :a.to_m**2), :a),
      # Hyperbolic functions
      :sinh => definition(:cosh),
      :cosh => definition(:sinh),
      :tanh => lmd(fn(:sech, :a)**2, :a),
      :sech => lmd(- fn(:tanh, :a)*fn(:sech, :a), :a),
      :csch => lmd(- fn(:coth, :a)*fn(:csch, :a), :a),
      :coth => lmd(- fn(:csch, :a)**2, :a),
      # Inverse hyperbolic functions
      :arsinh => lmd(1.to_m/fn(:sqrt, :a.to_m**2 + 1), :a),
      :arcosh => lmd(1.to_m/fn(:sqrt, :a.to_m**2 - 1), :a),
      :artanh => lmd(1.to_m/(1.to_m - :a.to_m**2), :a),
      :arsech => lmd(- 1.to_m/(:a.to_m*fn(:sqrt, 1.to_m - :a.to_m**2)), :a),
      :arcsch => lmd(- 1.to_m/(fn(:abs, :a.to_m)*fn(:sqrt, :a.to_m**2 + 1)), :a),
      :arcoth => lmd(1.to_m/(1.to_m - :a.to_m**2), :a),
    }
  end

  def d(vars)
    if self.is_a?(Sy::Definition::Function)
      return d_function_def(vars)
    end

    # d(c) = 0 for constant c
    if is_constant?(vars)
      return 0.to_m
    end

    # d(v) = dv for variable v
    if vars.member?(self)
      return to_d
    end

    # d(a + b + ...) = d(a) + d(b) + ...
    if is_a?(Sy::Sum)
      return term1.d(vars) + term2.d(vars)
    end

    # d(-a) = -d(a)
    if is_a?(Sy::Minus)
      return -argument.d(vars)
    end

    # Product rule
    if is_a?(Sy::Product)
      return d_product(vars)
    end

    # Fraction rule
    if is_a?(Sy::Fraction)
      return d_fraction(vars)
    end

    # Power rule
    if is_a?(Sy::Power)
      return d_power(vars)
    end

    # Derivative of function
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

  def d_function_def(vars)
    if name != '' and @@functions.key?(name.to_sym)
      df = @@functions[name.to_sym]
      dfcall = df.(args[0]).evaluate
      return _d_wedge(dfcall, args[0].d(vars))
    end

    if !exp.nil?
      return self.(*args).evaluate.d(vars)
    end

    d_failure
  end

  def d_function(vars)
    if !self.is_a?Sy::Operator
      d_failure
    end

    if name != '' and @@functions.key?(name.to_sym)
      df = @@functions[name.to_sym]
      dfcall = df.(args[0]).evaluate
      return _d_wedge(dfcall, args[0].d(vars))
    end

    if !definition.exp.nil?
      return definition.(*args).evaluate.d(vars)
    end

    d_failure
  end

  # Apply wedge product or ordinary product between two expressions,
  # depending on whether or not they have vector parts.
  def _d_wedge(exp1, exp2)
    # The product operator will determine whether this is a scalar
    # or a wedge product.
    return (exp1.factors.to_a + exp2.factors.to_a).inject(:*)
  end
end
