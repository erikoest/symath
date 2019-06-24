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

    def scalar_factors()
      return argument.scalar_factors
    end

    def div_factors()
      return argument.div_factors
    end

    def abs_factors_exp()
      return argument.abs_factors_exp
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
    
    def summands()
      return argument.subtrahends
    end

    def subtrahends()
      return argument.summands
    end

    def to_s()
      return '- ' + argument.to_s
    end

    def to_latex()
      return '- ' + argument.to_latex
    end
  end
end
