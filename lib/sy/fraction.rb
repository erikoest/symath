require 'sy/function'

module Sy
  class Fraction < Function
    def initialize(dividend, divisor)
      super('/', [dividend, divisor])
    end

    def dividend()
      return @args[0]
    end

    def divisor()
      return @args[1]
    end
    
    def is_prod_exp?()
      return true
    end

    def abs_factors_to_a()
      return dividend.abs_factors_to_a + divisor.div_factors_to_a
    end

    def div_factors_to_a()
      return dividend.div_factors_to_a + divisor.abs_factors_to_a
    end

    def coefficient()
      return dividend.coefficient
    end

    def div_coefficient()
      return dividend.div_coefficient*divisor.coefficient
    end
    
    def sign()
      return dividend.sign*divisor.sign
    end

    def to_s()
      dividend_str = dividend.is_sum_exp? ? '(' + dividend.to_s + ')' : dividend.to_s
      divisor_str = (divisor.is_sum_exp? or divisor.is_prod_exp?) ?
                      '(' + divisor.to_s + ')' :
                      divisor.to_s
      return dividend_str + '/' + divisor_str
    end
  end
end
