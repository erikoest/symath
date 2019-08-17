require 'sy/operation'
require 'set'

module Sy
  class Operation::Differential < Operation
    # Calculate differential
    def description
      return 'Calculate differential'
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
        return diff(exp.term1, vars) + diff(exp.term2, vars)
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
      return (wedge(diff(exp.factor1, vars), exp.factor2) +
              wedge(exp.factor1, diff(exp.factor2, vars)))
    end

    def do_fraction(exp, vars)
      return (wedge(diff(exp.dividend, vars), exp.divisor) -
              wedge(exp.dividend, diff(exp.divisor, vars))) /
             (exp.divisor**2)
    end

    def do_power(exp, vars)
      return wedge(wedge(exp, fn(:ln, exp.base)), diff(exp.exponent, vars)) +
             wedge(wedge(exp.exponent, exp.base**(exp.exponent - 1)), diff(exp.base, vars))
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
        return wedge(d, diff(exp.args[0], vars))
      else
        raise 'Cannot calculate differential of expression ' + exp.to_s
      end
    end

    # FIXME: Use the DistributiveLaw class for this.
    # Multiply exp1 over each term in exp2
    def expand_right(exp1, exp2)
      if exp2.is_sum_exp?
        # exp2 is a sum and must be expanded.
        ret = 0.to_m
        exp2.terms.each do |s|
          ret += expand_left(exp1, s)
        end

        return ret
      else
        # Not a sum. Just multiply. If any of the expressions are scalar,
        # we can do with a scalar multiplication.
        if exp1.is_scalar?
          return exp1*exp2
        end

        if exp2.is_scalar?
          return exp2*exp1
        end

        # Both expressions are vectors and must be joined with a wedge operator
        return exp1^exp2
      end
    end

    # Multiply exp2 over each term in exp1
    def expand_left(exp1, exp2)
      if exp1.is_scalar? and exp2.is_scalar?
        # Both parts are scalar. Just multiply.
        return exp1*exp2
      end

      if exp1.is_scalar?
        # exp2 has vector parts. If it is a sum, we must expand the product
        return expand_right(exp1, exp2)
      end

      if exp2.is_scalar?
        # exp1 has vector parts. If it is a sum, we must expand the product
        return expand_right(exp2, exp1)
      end
      
      # Both parts have vector parts. Wedge the two expressions.
      ret = 0.to_m

      exp1.terms.each do |s|
        ret += expand_right(s, exp2)
      end

      return ret
    end

    # Apply wedge product or ordinary product between two expressions,
    # depending on whether or not they have vector parts.
    def wedge(exp1, exp2)
      # Take out the divisor from both exp1 and exp2, then expand left and
      # right side and put back the divisor in the end.
      c = exp1.coefficient.to_m*exp2.coefficient.to_m*exp1.sign*exp2.sign
      d = (exp1.div_factors.to_a + exp2.div_factors.to_a).inject(:*) || 1.to_m

      s1 = (exp1.scalar_factors.inject(:*) || 1.to_m)*(
            exp1.vector_factors.inject(:^) || 1.to_m)
      s2 = (exp2.scalar_factors.inject(:*) || 1.to_m)*(
            exp2.vector_factors.inject(:^) || 1.to_m)
      s3 = expand_left(s1, s2)
      return c*s3/d
    end
  end
end
