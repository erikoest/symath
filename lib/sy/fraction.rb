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

    def evaluate()
      if dividend.is_a?(Sy::Matrix)
        return dividend.matrix_div(divisor)
      end

      # TODO: Expand product of sums
      return self
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
      if Sy.setting(:expl_parentheses)
        return '('.to_s + dividend_str + '/' + divisor_str + ')'.to_s
      else
        return dividend_str + '/' + divisor_str
      end
    end

    def to_latex()
      return '\frac{' + dividend.to_latex + '}{' + divisor.to_latex + '}'
    end
  end
end
