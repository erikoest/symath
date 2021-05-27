require 'sy/function'

module Sy
  class Power < Function
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

    # Simple reduction rules, allows sign to change. Returns
    # (reduced exp, sign, changed).
    def reduce_modulo_sign
      # Powers of 1 reduces to 1
      if base == 1 and exponent.is_finite?
        return base, 1, true
      end

      # Power of 0 reduces to 0
      if base == 0 and exponent.is_finite? and exponent != 0
        return 0.to_m, 1, true
      end
      
      # Number power of number reduces to number
      if base.is_number? and exponent.is_number?
        return (base.value ** exponent.value).to_m, 1, true
      end

      # p**q**r reduces to p**(q*r)
      if base.is_a?(Sy::Power)
        return base.base.power(base.exponent.mul(exponent), 1, true)
      end
      
      # Reduce power of vectors and dforms to zero
      if base.type.is_dform? or base.type.is_vector?
        return 0.to_m, 1, true
      end
      
      # Remaining code reduces only quaternions
      if !base.is_unit_quaternion?
        return self, 1, false
      end
      
      # q**n for some unit quaternion
      # Exponent is 1 or not a number
      # FIXME: Why not replace e**1 with e?
      if !exponent.is_number? or exponent == 1
        return self, 1, false
      end

      if exponent == 0
        return 1.to_m, 1, true
      end

      # e is on the form q**n for some integer n >= 2
      x = exponent.value
      
      if x.odd?
        ret = base
        x -= 1.to_m
      else
        ret = 1.to_m
      end

      if (x/2).odd?
        return ret, -1, true
      else
        return ret, 1, true
      end
    end    

    def to_s()
      if base.is_sum_exp? or base.is_prod_exp? or base.is_a?(Sy::Power)
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
      if base.is_sum_exp? or base.is_prod_exp? or base.is_a?(Sy::Power)
        base_str = '\left(' + base.to_latex + '\right)'
      else
        base_str = base.to_latex
      end

      return base_str + '^' + '{' + exponent.to_latex + '}'
    end
  end
end
