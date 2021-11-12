require 'sy/operation'
require 'set'

module Sy::Operation::Integration
  class IntegrationError < StandardError
  end
  
  # This operation provides methods for calculating some simple indefinite
  # integrals (anti derivatives), and definite integrals from the boundaries
  # of the anti-derivatives.
  # NB: The algorithm is home made and extermely limited. It should be
  # replaced with some of the known integration algorithm

  @@functions = {}

  def self.initialize()
    # Anti-derivatives of simple functions with one variable
    # FIXME: Clean up formulas
    @@functions = {
      # Logarithm
      :ln  => :a.to_m*fn(:ln, :a.to_m) - :a.to_m,
      # Trigonometric functions
      :sin => - fn(:cos, :a.to_m),
      :cos => fn(:sin, :a.to_m),
      :tan => - fn(:ln, fn(:abs, fn(:cos, :a.to_m))),
      :cot => fn(:ln, fn(:abs, fn(:sin, :a.to_m))),
      :sec => fn(:ln, fn(:abs, fn(:sec, :a.to_m) + fn(:tan, :a.to_m))),
      :csc => - fn(:ln, fn(:abs, fn(:csc, :a.to_m) + fn(:cot, :a.to_m))),
      # Inverse trigonometric functions
      :arcsin => :a.to_m*fn(:arcsin, :a.to_m) + fn(:sqrt, 1.to_m - :a.to_m**2),
      :arccos => :a.to_m*fn(:arccos, :a.to_m) - fn(:sqrt, 1.to_m - :a.to_m**2),
      :arctan => :a.to_m*fn(:arctan, :a.to_m) -
                 fn(:ln, fn(:abs, 1.to_m + :a.to_m**2))/2,
      :arccot => :a.to_m*fn(:arccot, :a.to_m) +
                 fn(:ln, fn(:abs, 1.to_m + :a.to_m**2))/2,
      :arcsec => :a.to_m*fn(:arcsec, :a.to_m) -
                 fn(:ln, fn(:abs, 1.to_m + fn(:sqrt, 1.to_m - :a.to_m**-2))),
      :arccsc => :a.to_m*fn(:arccsc, :a.to_m) +
                 fn(:ln, fn(:abs, 1.to_m + fn(:sqrt, 1.to_m - :a.to_m**-2))),
      # Hyperbolic functions
      :sinh => fn(:cosh, :a.to_m),
      :cosh => fn(:sinh, :a.to_m),
      :tanh => fn(:ln, fn(:cosh, :a.to_m)),
      :coth => fn(:ln, fn(:abs, fn(:sinh, :a.to_m))),
      :sech => fn(:arctan, fn(:sinh, :a.to_m)),
      :csch => fn(:ln, fn(:abs, fn(:tanh, :a.to_m/2))),
      # Inverse hyperbolic functions
      :arsinh => :a.to_m*fn(:arsinh, :a.to_m) - fn(:sqrt, :a.to_m**2 + 1),
      :arcosh => :a.to_m*fn(:arcosh, :a.to_m) - fn(:sqrt, :a.to_m**2 - 1),
      :artanh => :a.to_m*fn(:artanh, :a.to_m) + fn(:ln, 1.to_m - :a.to_m**2)/2,
      :arcoth => :a.to_m*fn(:arcoth, :a.to_m) + fn(:ln, :a.to_m**2 - 1)/2,
      :arsech => :a.to_m*fn(:arsech, :a.to_m) + fn(:arcsin, :a.to_m),
      :arcsch => :a.to_m*fn(:arcsch, :a.to_m) + fn(:abs, fn(:arsinh, :a.to_m)),
    }

    @@patterns = {
      # Polynomial functions
      (1 - :a**2)**(-1.to_m/2)   => fn(:arcsin, :a),
      (1 + :a**2)**-1            => fn(:arctan, :a),
      # Logarithmic functions
      fn(:ln, :a)**2             => :a*fn(:ln, :a)**2 - 2*:a*fn(:ln, :a) + 2*:a,
      1/(:a*fn(:ln, :a))         => fn(:ln, fn(:abs, fn(:ln, :a))),
      # Trigonometric functions
      fn(:sin, :a)**2            => (:a - fn(:sin, :a)*fn(:cos, :a))/2,
      fn(:sin, :a)**3            => fn(:cos, 3*:a)/12 - 3*fn(:cos, :a)/4,
      fn(:cos, :a)**2            => (:a + fn(:sin, :a)*fn(:cos, :a))/2,
      fn(:cos, :a)**3            => fn(:sin, 3*:a)/12 + 3*fn(:sin, :a)/4,
      fn(:sec, :a)**2            => fn(:tan, :a),
      fn(:sec, :a)**3            => fn(:sec, :a)*fn(:tan, :a)/2 +
                                    fn(:ln, fn(:abs, fn(:sec, :a) + fn(:tan, :a)))/2,    
      fn(:csc, :a)**2            => - fn(:cot, :a),
      fn(:csc, :a)**3            => - fn(:csc, :a)*fn(:cot, :a)/2 -
                                    fn(:ln, fn(:abs, fn(:csc, :a) + fn(:cot, :a)))/2,
      # Hyperbolic functions
      fn(:sinh, :x)**2           => fn(:sinh, 2*:a)/4 - :a/2,
      fn(:cosh, :x)**2           => fn(:sinh, 2*:a)/4 + :a/2,
      fn(:tanh, :x)**2           => :a - fn(:tanh, :a),
      # Combined trigonometric functions
      fn(:sin, :a)*fn(:cos, :a)     => fn(:sin, :a)**2/2,
      fn(:sec, :a)*fn(:tan, :a)     => fn(:sec, :a),
      fn(:csc, :a)*fn(:cot, :a)     => - fn(:csc, :a),
      1/(fn(:sin, :a)*fn(:cos, :a)) => fn(:ln, fn(:abs, fn(:tan, :a))),
      fn(:sin, fn(:ln, :a))         => :a*(fn(:sin, fn(:ln, :a)) -
                                           fn(:cos, fn(:ln, :a)))/2,
      fn(:cos, fn(:ln, :a))         => :a*(fn(:sin, fn(:ln, :a)) +
                                           fn(:cos, fn(:ln, :a)))/2,
    }
  end

  def anti_derivative(var)
    raise 'Var is not a differential' if !var.is_d?

    if is_constant?([var.undiff].to_set)
      return int_constant(var)
    end

    if self.is_a?(Sy::Minus)
      return - self.argument.anti_derivative(var)
    end

    if is_sum_exp?
      return int_sum(var)
    end

    if is_prod_exp?
      return int_product(var)
    end

    if is_a?(Sy::Operator) and @@functions.key?(name.to_sym)
      return int_function(var)
    end

    return int_power(var)
  end

  def int_failure()    
    raise IntegrationError, 'Cannot find an antiderivative for expression ' + to_s
  end

  def int_pattern(var)
    # Try to match expression against various patterns
    vu = var.undiff
    a = :a.to_m

    @@patterns.each do |f, f_int|
      m = match(f, [a])
      next if m.nil?

      m.each do |mi|
        # We must check that variable a maps to c1*x + c2
        (c1, c2) = get_linear_constants(mi[a], var)
        next if c1.nil?

        # We have found a match, and the argument is a linear function.
        # Substitute the argument into the free variable of the pattern
        # function.
        ret = f_int.deep_clone
        ret.replace({ a => mi[a] })
        return c1.inv*ret
      end
    end

    # Give up!
    int_failure
  end

  def int_constant(var)
    # c => c*x
    return mul(var.undiff)
  end
    
  def int_product(var)
    vu = var.undiff
    vset = [vu].to_set

    prodc = 1.to_m
    proda = []
    diva = []
    
    factors.each do |f|
      if !f.type.is_subtype?(:scalar)
        int_failure
      end

      if f.is_constant?(vset)
        prodc *= f
        next
      end

      if f.is_divisor_factor?
        diva.push f.base**f.exponent.argument
        next
      end

      proda.push f
    end

    # c/exp
    if proda.length == 0 and diva.length == 1
      return prodc*diva[0].int_inv(var)
    end

    # c*exp
    if proda.length == 1 and diva.length == 0
      return prodc*proda[0].anti_derivative(var)
    end

    exp = proda.inject(1.to_m, :*)/diva.inject(1.to_m, :*)
    return prodc*exp.int_pattern(var)
  end

  def get_linear_constants(arg, var)
    # If arg is on the form c1*var + c2, return the two constants.
    vu = var.undiff
    vset = [vu].to_set
    c1 = 0.to_m
    c2 = 0.to_m

    arg.terms.each do |t|
      if t.is_constant?(vset)
        c2 += t
      else
        # Split term into a constant part and (hopefully) a single factor
        # which equals to var
        prodc = 1.to_m
        has_var = false

        t.factors.each do |f|
          if !f.type.is_subtype?(:scalar)
            # Non-scalar factor. Don't know what to do
            return
          end

          if f.is_constant?(vset)
            prodc *= f
            next
          end

          # Found more than one var. Return negative
          if has_var
            return
          end

          # Factor is var. Remember it, but continue to examine the other
          # factors.
          if f == vu
            has_var = true
            next
          end

          # Factor is a function of var. Return negative
          return
        end

        c1 += prodc
      end

      # Return negative if the whole expression is constant
      return if c1 == 0
    end

    return [c1, c2]
  end

  def int_inv(var)
    # Hack: integrate 1/exp (by convention of the sibling functions,
    # it should have integrated exp)
    xp = exponent
    vu = var.undiff
    vset = [vu].to_set

    if base == vu and xp.is_constant?(vset)
      if xp == 1.to_m
        # 1/x => ln|x|
        return fn(:ln, fn(:abs, vu))
      else
        # 1/x**n => x**(1 - n)/(1 - n)
        return vu**(1.to_m - xp)/(1.to_m - xp)
      end
    end

    (self**-1).int_pattern(var)
  end

  def int_function(var)
    # At this point exp is a single argument function which we know how
    # to integrate. Check that the argument is a linear function
    arg = args[0]
    (c1, c2) = get_linear_constants(arg, var)
    if c1.nil?
      # Argument is not linear. Try pattern match as a last resort.
      return int_pattern(var)
    else
      # The function argument is linear. Do the integration.
      # int(func(c1*x + c2)) -> Func(c1*x+ c2)/c1
      fexp = @@functions[name.to_sym].deep_clone
      fexp.replace({ :a.to_m =>  arg })
      return c1.inv*fexp
    end
  end

  def int_power(var)
    # At this point, exp should not be a constant, a sum or a product.
    vu = var.undiff
    vset = [vu].to_set

    b = base
    xp = exponent

    if b == vu
      if !xp.is_constant?(vset)
        # Cannot integrate x**f(x)
        int_failure
      end

      # x**n => x**(n + 1)/(n + 1)
      return vu**(xp + 1)/(xp + 1)
    end

    # Check exponential functions
    if b.is_constant?(vset)
      (c1, c2) = get_linear_constants(xp, var)
      # b**(c1*x + c2) => b**(c1*x + c2)/(b*ln(c1))
      if c1.nil?
        int_failure
      end

      return b**(xp)/(c1*fn(:ln, b))
    end

    # Try pattern match as last resort
    int_pattern(var)
  end
    
  def int_sum(var)
    ret = 0.to_m
    terms.each { |s| ret += s.anti_derivative(var) }
    return ret
  end

  # This method calculates the difference of two boundary values of an
  # expression (typically used for calculating the definite integral from
  # the anti-derivative, using the fundamental theorem of calculus)
  def integral_bounds(var, a, b)
    bexp = deep_clone.replace({ var =>  b })
    aexp = deep_clone.replace({ var =>  a })
    return bexp - aexp
  end
end
