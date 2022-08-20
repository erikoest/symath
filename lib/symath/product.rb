require 'symath/operator'

module SyMath
  class Product < Operator
    def self.compose_with_simplify(a, b)
      a = a.to_m
      b = b.to_m

      # Multipling a value with an equation multiplies it with both sides,
      # preserving the balance of the equation
      if b.is_a?(SyMath::Equation)
        return eq(a * b.args[0], a * b.args[1])
      end

      if a.is_finite?() == false or b.is_finite?() == false
        return self.simplify_inf(a, b)
      end

      # First try some simple reductions
      # a*1 => a
      return a if b == 1
      return b if a == 1

      # -a*-b => a*b
      if b.is_a?(SyMath::Minus) and a.is_a?(SyMath::Minus)
        return a.argument*b.argument
      end

      # (-a)*b => -(a*b)
      # a*(-b) => -(a*b)
      return -(a*b.argument) if b.is_a?(SyMath::Minus)
      return -(a.argument*b) if a.is_a?(SyMath::Minus)

      if b.is_a?(SyMath::Matrix)
        return self.new(a, b)
      end

      # Tensor-like objects
      if a.type.is_subtype?(:tensor) and b.type.is_subtype?(:tensor)
        if a.type.is_subtype?(:nform) and b.type.is_subtype?(:nform)
          # Expand expression if any of the parts are sum
          if b.is_sum_exp?
            return b.terms.map { |f| a.*(f) }.inject(:+)
          end

          if a.is_sum_exp?
            return a.terms.map { |f| f.wedge(b) }.inject(:+)
          end

          return a.wedge(b)
        end

        if (a.type.is_subtype?(:covector) and b.type.is_subtype?(:covector)) or
          (a.type.is_subtype?(:vector) and b.type.is_subtype?(:vector))
          return a.outer(b)
        end
      end

      if a.base == b.base
        return a.base ** (a.exponent + b.exponent)
      end

      # (1/a)*b => b/a
      if a.is_a?(SyMath::Fraction) and a.dividend == 1.to_m
        return b/a.divisor
      end

      # a*(1/b) => a*/b
      if b.is_a?(SyMath::Fraction) and b.dividend == 1.to_m
        return a/b.divisor
      end

      return self.new(a, b)
    end

    def self.simplify_inf(a, b)
      # Indefinite factors
      if a.is_finite?.nil? or b.is_finite?.nil?
        return self.new(a, b)
      end

      # NaN multiplies to NaN
      if a.is_nan? or b.is_nan?
        return :nan.to_m
      end

      # oo*0 = 0*oo = NaN
      if a.is_zero? or b.is_zero?
        return :nan.to_m
      end

      if SyMath.setting(:complex_arithmetic)
        return :oo.to_m
      else
        if (a.is_positive? and b.is_positive?) or
          (a.is_negative? and b.is_negative?)
          return :oo.to_m
        end

        if (a.is_negative? and b.is_positive?) or
          (a.is_positive? and b.is_negative?)
          return -:oo.to_m
        end
      end
      
      # :nocov:
      raise 'Internal error'
      # :nocov:
    end
    
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
      if factor1.is_a?(SyMath::Matrix)
        return factor1.matrix_mul(factor2)
      elsif factor2.is_a?(SyMath::Matrix) and
           factor1.type.is_scalar?
        return factor2.matrix_mul(factor1)
      end

      return super
    end

    def type()
      return factor1.type.product(factor2.type)
    end

    def mul_symbol()
      return '*'
    end

    def mul_symbol_ltx()
      return '\cdot'
    end

    def to_s()
      if SyMath.setting(:expl_parentheses)
        return '('.to_s + factor1.to_s + mul_symbol + factor2.to_s + ')'.to_s
      end

      if SyMath.setting(:braket_syntax)
        left = factor1.to_s
        if factor1.is_sum_exp?
          left = "(#{left})"
        end

        right = factor2.to_s
        if factor2.is_sum_exp?
          right = "(#{right})"
        end

        if left[-1] == '|' and right[0] == '|'
          return "#{left}#{right[1..-1]}"
        elsif (left[-1] == '|' and right[0] == '<') or
              (left[-1] == '>' and right[0] == '|')
          return "#{left[0..-2]},#{right[1..-1]}"
        elsif left == '>' and right == '<'
          return "#{left}#{right}"
        else
          return "#{left} #{right}"
        end
      end

      return @args.map do |a|
        if a.is_sum_exp?
          '(' + a.to_s + ')'
        else
          a.to_s
        end
      end.join(mul_symbol)
    end

    def to_latex()
      dot = SyMath.setting(:ltx_product_sign) ? " #{mul_symbol_ltx} " : ' '

      if SyMath.setting(:braket_syntax)
        left = factor1.to_latex
        if factor1.is_sum_exp?
          left = "(#{left})"
        end

        right = factor2.to_latex
        if factor2.is_sum_exp?
          right = "(#{right})"
        end

        ret = "#{left} #{right}"

        # Combine bra-kets
        ret = ret.gsub(/\\bra{([^}]+)} \\bra{([^}]+)}/, '\bra{\1, \2}')
        ret = ret.gsub(/\\ket{([^}]+)} \\ket{([^}]+)}/, '\ket{\1, \2}')
        ret = ret.gsub(/\\bra{([^}]+)} \\ket{([^}]+)}/, '\braket{\1}{\2}')

        ret = ret.gsub(/\\bra{([^}]+)} \\braket{([^}]+)}{([^}]+)}/,
                       '\braket{\1, \2}{\3}')
        ret = ret.gsub(/\\braket{([^}]+)}{([^}]+)} \\ket{([^}]+)}/,
                       '\braket{\1}{\2, \3}')

        return ret
      end

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
