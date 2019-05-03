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

    def abs_factors_to_a()
      return argument.abs_factors_to_a
    end

    def div_factors_to_a()
      return argument.div_factors_to_a
    end

    def coefficientless()
      return argument.coefficientless
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
    
    def summands_to_a()
      return argument.subtrahends_to_a
    end

    def subtrahends_to_a()
      return argument.summands_to_a
    end

    def to_s()
      return '- ' + argument.to_s
    end
  end
end
