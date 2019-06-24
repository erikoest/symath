require 'sy/operation'
require 'set'

module Sy
  class IntegrationError < StandardError
  end
  
  class Operation::Integration < Operation
    # Calculate some simple indefinite integrals (anti derivatives)
    # NB: This operation is home made and extermely limited. It should be replaced
    # with some of the known integration algorithm
    def description
      return 'Calculate indefinite integral'
    end

    def result_is_normal?
      return false
    end

    def act(exp, var)
      begin
        return int(exp, var) + :C.to_m
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
      divc = exp.div_coefficient.to_m
      diva = []
      vu = var.undiff
      vset = [vu].to_set

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
          # 1/x^n => x^(1 - n)/(1 - n)
          return vu**(1.to_m - xp)/(1.to_m - xp)
        end
      end

      failure(1.to_m/exp)
    end

    def do_other(exp, var)
      # At this point, exp should not be a constant, a sum or a product.
      vu = var.undiff
      vset = [vu].to_set
      b = exp.base
      xp = exp.exponent

      if b == vu
        if !xp.is_constant?(vset)
          # Cannot integrate x^f(x)
          failure(exp)
        end

        # x^n => x^(n + 1)/(n + 1)
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
        
        # a^(b*x) => a^(b*x)/(b*ln(a))
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
