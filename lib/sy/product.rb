require 'sy/function'

module Sy
  class Product < Function
    def initialize(arg1, arg2)
      super('*', [arg1, arg2])
    end

    def factor1()
      return @args[0]
    end

    def factor1=(f)
      @args[0] = f
    end

    def factor2()
      return @args[1]
    end
    
    def factor2=(f)
      @args[1] = f
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

    def factors()
      return Enumerator.new do |f|
        factor1.factors.each { |f1| f << f1 }
        factor2.factors.each { |f2| f << f2 }
      end
    end
    
    def evaluate()
      if factor1.is_a?(Sy::Matrix)
        return factor1.matrix_mul(factor2)
      elsif factor2.is_a?(Sy::Matrix) and
           factor1.is_scalar
        return factor2.matrix_mul(factor1)
      end

      # TODO: Expand product of sums
      return self
    end

    def type()
      return factor1.type.product(factor2.type)
    end

    def to_s()
      if Sy.setting(:expl_parentheses)
        return '('.to_s + factor1.to_s + '*' + factor2.to_s + ')'.to_s
      else
        return @args.map do |a|
          if a.is_sum_exp?
            '(' + a.to_s + ')'
          else
            a.to_s
          end
        end.join('*')
      end
    end

    def to_latex()
      dot = Sy.setting(:ltx_product_sign) ? ' \cdot ' : ' ';
      
      return @args.map do |a|
        if a.is_sum_exp?
          '(' + a.to_latex + ')'
        else
          a.to_latex
        end
      end.join(dot)
    end      
  end
end
