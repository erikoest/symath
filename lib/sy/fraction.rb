require 'sy/function'

module Sy
  class Fraction < Function
    def self.compose_with_simplify(a, b)
      a = a.to_m
      b = b.to_m

      return a if b == 1

      if a.is_finite?() == false or b.is_finite?() == false
        return self.simplify_inf(a, b)
      end
      
      # Divide by zero
      if b.is_zero?
        if Sy.setting(:complex_arithmetic)
          if a.is_zero?
            return :NaN.to_m
          else
            return :oo.to_m
          end
        else
          return :NaN.to_m
        end
      end

      if a.is_a?(Sy::Fraction)
        if b.is_a?(Sy::Fraction)
          return self.new(a.dividend*b.divisor, a.divisor*b.dividend)
        else
          return self.new(a.dividend, a.divisor*b)
        end
      elsif b.is_a?(Sy::Fraction)
        return self.new(a*b.divisor, b.dividend)
      end

      return self.new(a, b)
    end

    # Divide infinite values
    def self.simplify_inf(a, b)
      # Indefinite factors
      if a.is_finite?.nil? or b.is_finite?.nil?
        return self.new(a, b)
      end

      # NaN/* = */NaN = NaN
      if a.is_nan? or b.is_nan?
        return :NaN.to_m
      end
      
      # oo/oo = oo/-oo = -oo/oo = NaN
      if a.is_finite? == false and b.is_finite? == false
        return :NaN.to_m
      end

      # */0 = NaN
      if b.is_zero?
        if Sy.setting(:complex_arithmetic)
          return :oo.to_m
        else
          return :NaN.to_m
        end
      end

      # n/oo = n/-oo = 0
      if a.is_finite?
        return 0.to_m
      end

      # oo/n = -oo/-n = oo, -oo/n = oo/-n = -oo
      if b.is_finite?
        if Sy.setting(:complex_arithmetic)
          return :oo.to_m
        else
          if a.sign == b.sign
            return :oo.to_m
          else
            return -:oo.to_m
          end
        end
      end

      # :nocov:
      raise 'Internal error'
      # :nocov:
    end

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
