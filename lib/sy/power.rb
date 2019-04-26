require 'sy/function'

module Sy
  class Power < Function
    def initialize(base, exponent)
      super('^', [base, exponent])
    end

    def base()
      return @args[0]
    end
    
    def exponent()
      return @args[1]
    end

    def to_s()
      if base.is_sum_exp? or base.is_prod_exp? or base.is_a?(Sy::Power)
        base_str = '(' + @args[0].to_s + ')'
      else
        base_str = @args[0].to_s
      end

      expo_str = (exponent.is_sum_exp? or exponent.is_prod_exp?) ?
                 '(' + exponent.to_s + ')' :
                 exponent.to_s
      
      return base_str + '^' + expo_str
    end
  end
end
