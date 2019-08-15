require 'sy/function'

module Sy
  class Minus < Function
    def initialize(arg)
      super('-', [arg])
    end

    def argument()
      return @args[0]
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

    def vector_factors()
      return argument.vector_factors
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
        argument.terms.each { |s1| s << s1.minus }
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
      return '- ' + argument.to_s
    end

    def to_latex()
      return '- ' + argument.to_latex
    end
  end
end
