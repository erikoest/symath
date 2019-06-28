require 'sy/operation'
require 'set'

module Sy
  class IntegrationError < StandardError
  end
  
  class Operation::Integration < Operation
    # Calculate some simple indefinite integrals (anti derivatives)
    # NB: This operation is home made and extermely limited. It should be
    # replaced with some of the known integration algorithm
    def description
      return 'Calculate indefinite integral'
    end

    def result_is_normal?
      return false
    end

    def act(exp, var)
      begin
        return int(exp, var)
      rescue IntegrationError => e
        puts e.to_s
#        puts e.backtrace.join("\n")
      end

      # Expression is not an integral, or the integration
      # routine failed.
      return
    end
    
    def int(exp, var)
      raise 'Var is not a differential' if !var.is_diff?

      if exp.is_constant?([var.undiff].to_set)
        return do_constant(exp, var)
      end
      
      if exp.is_sum_exp?
        return do_sum(exp, var)
      end

      if exp.is_prod_exp?
        return do_product(exp, var)
      end

      return do_other(exp, var)
    end

    def failure(exp)
      raise Sy::IntegrationError, 'Cannot find an antiderivative for expression ' + exp.to_s
    end

    def do_constant(exp, var)
      # c => c*x
      return exp*var.undiff
    end
    
    def do_product(exp, var)
      vu = var.undiff
      vset = [vu].to_set

      divc = exp.div_coefficient.to_m
      diva = []

      exp.div_factors.each do |d|
        if d.is_constant?(vset)
          divc *= d
        else
          diva.push(d)
        end
      end

      prodc = exp.coefficient.to_m
      proda = []

      exp.scalar_factors.each do |f|
        if f.is_constant?(vset)
          prodc *= f
        else
          proda.push(f)
        end
      end

      # We don't know how to integrate vectors
      exp.vector_factors.each do |v|
        failure(exp)
      end

      if exp.sign < 0
        prodc -= prodc
      end

      prodc /= divc
      
      if proda.length + diva.length == 0
        failure(exp)
      end

      if proda.length == 0 and diva.length == 1
        return prodc*do_inv(diva[0], var)
      end
      
      if proda.length == 1 and diva.length == 0
        return prodc*do_other(proda[0], var)
      end

      failure(exp)
    end

    def do_inv(exp, var)
      # Hack: integrate 1/exp (but by convention of the sibling functions, it should
      # have integrated exp)
      xp = exp.exponent
      vu = var.undiff
      vset = [vu].to_set
      
      if exp.base == vu and xp.is_constant?(vset)
        if xp == 1.to_m
          # 1/x => ln|x|
          return fn(:ln, fn(:abs, vu))
        else
          # 1/x**n => x**(1 - n)/(1 - n)
          return vu**(1.to_m - xp)/(1.to_m - xp)
        end
      end

      failure(1.to_m/exp)
    end

    # Anti-derivatives of simple functions with one variable
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
      :arctan => :a.to_m*fn(:arctan, :a.to_m) - fn(:ln, fn(:abs, 1.to_m + :a.to_m**2))/2,
      :arccot => :a.to_m*fn(:arccot, :a.to_m) + fn(:ln, fn(:abs, 1.to_m + :a.to_m**2))/2,
      :arcsec => :a.to_m*fn(:arcsec, :a.to_m) - fn(:ln, fn(:abs, 1.to_m + fn(:sqrt, 1.to_m - :a.to_m**-2))),
      :arccsc => :a.to_m*fn(:arccsc, :a.to_m) + fn(:ln, fn(:abs, 1.to_m + fn(:sqrt, 1.to_m - :a.to_m**-2))),
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

    def do_function(exp, var)
      vu = var.undiff
      vset = [vu].to_set
      arg = exp.args[0]

      # Split exp into a constant part and (hopefully) a single factor
      # which equals to var
      divc = arg.div_coefficient.to_m

      # We expect all divisor factors to be constant with respect to var
      arg.div_factors.each do |d|
        if !d.is_constant?(vset)
          failure(exp)
        end
        divc *= d
      end

      prodc = arg.coefficient.to_m
      has_var = false

      arg.scalar_factors.each do |f|
        # Constant factor with respect to var
        if f.is_constant?(vset)
          prodc *= f
          next
        end

        # Found more than one var
        if has_var
          failure(exp)
        end

        # Factor is var. Remember it, but continue to examine the other factors.
        if f == vu
          has_var = true
          next
        end

        # Factor is a function of var. Too difficult for us to integrate
        failure(exp)
      end

      # We don't know how to integrate vectors
      arg.vector_factors.each do |v|
        failure(exp)
      end

      if arg.sign < 0
        prodc -= prodc
      end

      # Calculate divc as the inverse of the constant part of the function arg
      divc /= prodc

      # int(func(n*x)) -> Func(n*x)/n
      fexp = @@functions[exp.name.to_sym].deep_clone
      fexp.replace({ :a.to_m =>  arg })
      return divc*fexp
    end

    def do_other(exp, var)
      # At this point, exp should not be a constant, a sum or a product.
      vu = var.undiff
      vset = [vu].to_set

      if exp.is_a?(Sy::Function) and @@functions.key?(exp.name.to_sym)
        return do_function(exp, var)
      end

      b = exp.base
      xp = exp.exponent

      if b == vu
        if !xp.is_constant?(vset)
          # Cannot integrate x**f(x)
          failure(exp)
        end

        # x**n => x**(n + 1)/(n + 1)
        return vu**(xp + 1)/(xp + 1)
      end

      # Check exponential functions
      if b.is_constant?(vset)
        # FIXME: Should consider moving this code out to the value class
        # We could extend the coefficient methods to include an optional
        # variable set, and return the part of the expression which is
        # constant with respect to the set.
        divc = xp.div_coefficient.to_m
        
        xp.div_factors.each do |d|
          if d.is_constant?(vset)
            divc *= d
          else
            failure(exp)
          end
        end

        prodc = xp.coefficient.to_m
        proda = []
      
        xp.scalar_factors.each do |f|
          if f.is_constant?(vset)
            prodc *= f
          elsif f == vu
            proda.push(f)
          else
            failure(exp)
          end
        end

        if xp.sign < 0
          prodc -= prodc
        end

        if (proda.length != 1)
          failure(exp)
        end

        prodc /= divc
        
        # a**(b*x) => a**(b*x)/(b*ln(a))
        return b**(prodc*vu)/(prodc*fn(:ln, b))
      end
      
      failure(exp)
    end
    
    def do_sum(exp, var)
      ret = 0.to_m
      exp.summands.each { |s| ret += int(s, var) }
      exp.subtrahends.each { |s| ret -= int(s, var) }
      return ret
    end
  end
end
