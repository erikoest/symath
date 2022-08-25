require 'symath/operator'

module SyMath
  class Minus < Operator
    def self.compose_with_simplify(a)
      a = a.to_m

      if a == 0
        return a
      end
      
      if a.is_a?(SyMath::Minus)
        # - - a => a
        return a.argument
      else
        return self.new(a)
      end
    end

    def initialize(arg)
      super('-', [arg])
    end

    def argument()
      return @args[0]
    end

    def is_positive?()
      if argument.is_nan?
        return false
      end

      if SyMath.setting(:complex_arithmetic) and (argument.is_finite? == false)
        # Define complex infinity to be positive
        return true
      end

      if argument.is_positive?.nil?
        return
      end

      return (!argument.is_positive? and !argument.is_zero?)
    end

    def conjugate()
      # Small reduction rule in order to make the conjugate look slightly
      # better without full normalization
      ret = argument.conjugate
      return - ret
    end

    def is_negative_number?()
      return argument.is_number?
    end

    def is_zero?()
      return argument.is_zero?
    end

    def is_finite?()
      return argument.is_finite?
    end
    
    def is_sum_exp?()
      return true
    end

    def is_prod_exp?()
      return true
    end

    def factors()
      return Enumerator.new do |f|
        f << -1.to_m
        argument.factors.each { |f1| f << f1 }
      end
    end

    def sign()
      return -argument.sign
    end
    
    def terms()
      return Enumerator.new do |s|
        argument.terms.each { |s1| s << s1.neg }
      end
    end

    def reduce_constant_factors()
      return -argument.reduce_constant_factors
    end

    def reduce_power_modulo_sign(e)
      if e.is_negative_number?
        e = e.argument
      elsif !e.is_number?
        return self, 1, false
      end

      ret, sign, changed = (argument**e).reduce_modulo_sign
      if e.value.odd?
        sign *= -1
      end

      return ret, sign, true
    end

    # Simple reduction rules, allows sign to change. Returns
    # (reduced exp, sign, changed).
    def reduce_modulo_sign
      red, sign, changed = argument.reduce_modulo_sign
      return red, -sign, true
    end

    def calc_mx()
      a = argument.calc_mx

      if a.is_a?(SyMath::Matrix)
        return a.matrix_neg
      else
        return -a
      end
    end

    def type()
      if argument.type.is_subtype?('integer')
        return 'integer'.to_t
      else
        return argument.type
      end
    end
    
    def to_s()
      if SyMath.setting(:expl_parentheses)
        return '(- '.to_s + argument.to_s + ')'.to_s
      else
        if argument.is_a?(SyMath::Sum)
          return '- ('.to_s + argument.to_s + ')'.to_s
        else
          return '- '.to_s + argument.to_s
        end
      end
    end

    def to_latex()
      return '- '.to_s + argument.to_latex
    end
  end
end
