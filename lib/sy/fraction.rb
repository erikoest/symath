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

    def is_scalar?()
      return dividend.is_scalar?()
    end

    def factors()
      return Enumerator.new do |f|
        dividend.factors.each { |d1| f << d1 }
        divisor.factors.each { |d2|
          if d2 != 1
            f << d2**-1
          end
        }
      end
    end
    
    def scalar_factors()
      return Enumerator.new do |f|
        dividend.scalar_factors.each { |d1| f << d1 }
        divisor.div_factors.each { |d2| f << d2 }
      end
    end

    def div_factors()
      # FIXME: Error if any of the div_factors are non-scalar
      return Enumerator.new do |d|
        dividend.div_factors.each { |d1| d << d1 }
        divisor.factors.each { |d2| d << d2 }
      end
    end

    def vector_factors_REMOVE()
      return Enumerator.new do |f|
        dividend.vector_factors_REMOVE.each { |d1| f << d1 }
      end
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

    def type()
      if dividend.type.is_subtype?('rational')
        return 'rational'.to_t
      else
        return dividend.type
      end
    end
    
    def to_s()
      dividend_str = dividend.is_sum_exp? ? '(' + dividend.to_s + ')' : dividend.to_s
      divisor_str = (divisor.is_sum_exp? or divisor.is_prod_exp?) ?
                      '(' + divisor.to_s + ')' :
                      divisor.to_s
      return dividend_str + '/' + divisor_str
    end

    def to_latex()
      return '\frac{' + dividend.to_latex + '}{' + divisor.to_latex + '}'
    end
  end
end
