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

    def abs_factors()
      return Enumerator.new do |f|
        factor1.abs_factors.each { |f1| f << f1 }
        factor2.abs_factors.each { |f2| f << f2 }
      end
    end

    def div_factors()
      return Enumerator.new do |d|
        factor1.div_factors.each { |d1| d << d1 }
        factor2.div_factors.each { |d2| d << d2 }
      end
    end

    def abs_factors_exp()
      if factor1.is_a?(Sy::Number) and factor2.is_a?(Sy::Number)
        return 1.to_m
      end

      if factor1.is_a?(Sy::Number)
        return factor2
      end

      if factor2.is_a?(Sy::Number)
        return factor1
      end

      return factor1.abs_factors_exp.mult(factor2.abs_factors_exp)
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
