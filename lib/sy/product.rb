require 'sy/function'

module Sy
  class Product < Function
    def initialize(arg1, arg2)
      super('*', [arg1, arg2])
    end

    def factor1()
      return @args[0]
    end

    def factor2()
      return @args[1]
    end
    
    def is_commutative?()
      return true
    end

    def is_associative?()
      return true
    end

    def is_prod_exp?()
      return true
    end

    def abs_factors_to_a()
      return factor1.abs_factors_to_a + factor2.abs_factors_to_a
    end

    def div_factors_to_a()
      return factor1.div_factors_to_a + factor2.div_factors_to_a
    end

    def coefficientless()
      if factor1.is_a?(Sy::Number)
        return factor2.coefficientless
      elsif factor2.is_a?(Sy::Number)
        return factor1.coefficientless
      else
        return factor1.coefficientless * factor2.coefficientless
      end
    end
    
    def coefficient()
      return factor1.coefficient*factor2.coefficient
    end

    def div_coefficient()
      return factor1.div_coefficient*factor2.div_coefficient
    end
    
    def sign()
      return factor1.sign*factor2.sign
    end
    
    def to_s()
      return @args.map do |a|
        if a.is_sum_exp?
          '(' + a.to_s + ')'
        else
          a.to_s
        end
      end.join('*')
    end
  end
end
