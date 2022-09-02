require 'symath/operator'

module SyMath
  class Power < Operator
    def self.compose_with_simplify(a, b)
      a = a.to_m
      b = b.to_m

      if a.is_finite?() == false or b.is_finite?() == false
        return self.simplify_inf(a, b)
      end
            
      # 0**0 = NaN
      if a.is_zero? and b.is_zero?
        return :nan.to_m
      end

      # n**1 = n
      if b == 1
        return a
      end
      
      if a.is_a?(SyMath::Power)
        return a.base**(a.exponent*b)
      end

      return self.new(a, b)
    end

    def self.simplify_inf(a, b)
      # Indefinite factors
      if a.is_finite?.nil? or b.is_finite?.nil?
        return self.new(a, b)
      end

      # NaN**(..) = NaN, (..)**NaN = NaN
      if a.is_nan? or b.is_nan?
        return :nan.to_m
      end

      # 1**oo = 1**-oo = oo**0 = -oo**0 = NaN
      if a == 1 or b.is_zero?
        return :nan.to_m
      end

      if SyMath.setting(:complex_arithmetic)
        if b.is_finite? == false
          return :nan.to_m
        else
          return :oo.to_m
        end
      else
        if a.is_zero? and b.is_finite? == false
          return :nan.to_m
        end

        # n**-oo = oo**-oo = -oo**-oo = 0
        if b.is_finite? == false and b.is_negative?
          return 0.to_m
        end
        
        if a.is_finite? == false and a.is_negative?
          if b.is_finite? == true
            # -oo*n = oo*(-1**n)
            return :oo.to_m.mul(a.sign**b)
          else
            # -oo**oo = NaN
            return :nan.to_m
          end
        end

        # -n**oo => NaN
        if a.is_finite? and a.is_negative?
          return :nan.to_m
        end
        
        # The only remaining possibilities:
        # oo**n = n*oo = oo*oo = oo
        return :oo.to_m
      end
    end
    
    def initialize(base, exponent)
      super('**', [base, exponent])
    end

    def base()
      return @args[0]
    end
    
    def exponent()
      return @args[1]
    end

    # Expression is on the form a**-n, n is a positive number
    def is_divisor_factor?()
      return exponent.is_negative_number?
    end

    # Reduce power of power
    def reduce_power_modulo_sign(e)
      # p**q**r reduces to p**(q*r)
      return self.base.power(self.exponent.mul(e)), 1, true
    end

    def reduce_modulo_sign
      # a to the power of 1 reduces to a
      if exponent == 1
        return base, 1, true
      end

      if base != 0 and exponent == 0
        return 1.to_m, 1, true
      end

      # Reduce positive integer power of vectors and dforms to zero
      if (base.type.is_dform? or base.type.is_vector?) and
        exponent.is_number?
        return 0.to_m, 1, true
      end
      
      # Delegate further reduction rules to the various types of bases
      return base.reduce_power_modulo_sign(exponent)
    end

    def type()
      return base.type.product(base.type)
    end

    def to_s()
      if base.is_sum_exp? or base.is_prod_exp? or base.is_a?(SyMath::Power)
        base_str = '(' + base.to_s + ')'
      else
        base_str = base.to_s
      end

      expo_str = (exponent.is_sum_exp? or exponent.is_prod_exp?) ?
                 '(' + exponent.to_s + ')' :
                 exponent.to_s
      
      return base_str + '**' + expo_str
    end

    def to_latex()
      if base.is_sum_exp? or base.is_prod_exp? or base.is_a?(SyMath::Power)
        base_str = '\left(' + base.to_latex + '\right)'
      else
        base_str = base.to_latex
      end

      return base_str + '^' + '{' + exponent.to_latex + '}'
    end
  end
end
