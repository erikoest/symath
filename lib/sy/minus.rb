require 'sy/function'

module Sy
  class Minus < Function
    def initialize(arg)
      super('-', [arg])
    end

    def argument()
      return @args[0]
    end

    def is_positive?()
      if argument.is_nan?
        return
      end

      if Sy.setting(:complex_arithmetic) and argument.is_finite? == false
        # Define complex infinity to be positive
        return true
      end

      if argument.is_positive?().nil?
        return
      end

      return (!argument.is_positive? and !argument.is_zero?)
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

    def is_scalar?()
      return argument.is_scalar?()
    end

    def scalar_factors()
      return argument.scalar_factors
    end

    def div_factors()
      return argument.div_factors
    end

    def vector_factors_REMOVE()
      return argument.vector_factors_REMOVE
    end
    
    def factors()
      return Enumerator.new do |f|
        f << -1.to_m
        argument.factors.each { |f1| f << f1 }
      end
    end

    def coefficient()
      return argument.coefficient
    end
    
    def div_coefficient()
      return argument.div_coefficient
    end

    def sign()
      return -argument.sign
    end
    
    def terms()
      return Enumerator.new do |s|
        argument.terms.each { |s1| s << s1.neg }
      end
    end

    def order()
      return -arguent.order
    end
    
    def reduce_constant_factors()
      return -argument.reduce_constant_factors
    end
      
    # Simple reduction rules, allows sign to change. Returns
    # (reduced exp, sign, changed).
    def reduce_modulo_sign
      red, sign, changed = argument.reduce_modulo_sign
      return red, -sign, true
    end

    def type()
      if argument.type.is_subtype?('integer')
        return 'integer'.to_t
      else
        return argument.type
      end
    end
    
    def to_s()
      if Sy.setting(:expl_parentheses)
        return '(- '.to_s + argument.to_s + ')'.to_s
      else
        if argument.is_a?(Sy::Sum)
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
