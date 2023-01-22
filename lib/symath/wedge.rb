require 'symath/product'

module SyMath
  class Wedge < Product
    def initialize(arg1, arg2)
      super(arg1, arg2)
      @name = '^'
    end

    def self.compose_with_simplify(a, b)
      a = a.to_m
      b = b.to_m

      # If one of the factors is scalar, multiply it on the left hand side
      if !a.type.is_subtype?(:tensor)
        return a*b
      end

      if !b.type.is_subtype?(:tensor)
        return b*a
      end

      # dx^dx**-1 = 1
      if a.is_a?(SyMath::Power) and a.exponent == -1 and  a.base == b
        return 1
      end

      # dx**-1^dx = 1
      if b.is_a?(SyMath::Power) and b.exponent == -1 and  b.base == a
        return 1.to_m
      end

      # Treat minus expression
      if a.is_a?(SyMath::Minus)
        return -(a.argument^b)
      end

      if b.is_a?(SyMath::Minus)
        return -(a^b.argument)
      end

      # Expand expression if any of the parts are sum
      if b.is_sum_exp?
        return b.terms.map { |f| a.^(f) }.inject(:+)
      end

      if a.is_sum_exp?
        return a.terms.map { |f|
          if f.type.is_subtype?('tensor')
            f.^(b)
          else
            f.mul(b)
          end
        }.inject(:+)
      end

      # If a or b is a product, assume that left side is tensor type and
      # right side is scalar. Split scalars and tensors and multiply/wedge
      # then correspondingly.
      if a.class == SyMath::Product
        return a.factor1*(a.factor2^b)
      end

      if b.class == SyMath::Product
        return b.factor1*(a^b.factor2)
      end

      if !a.is_a?(SyMath::Wedge) and !b.is_a?(SyMath::Wedge)
        if a == b and a.type.degree.odd?
          return 0.to_m
        end

        if a > b
          if (a.type.degree*b.type.degree).odd?
            return -1.to_m*(b.wedge(a))
          else
            return b.wedge(a)
          end
        end

        return a.wedge(b)
      end

      if !b.is_a?(SyMath::Wedge)
        # a must be a wedge, and is assumed to be ordered
        return a.wedge_ordered(b)
      end

      # a must be a wedge
      ret = a
      sign = 1
      b.wedge_factors.each do |w|
        if !ret.is_a?(SyMath::Wedge)
          ret = ret^w
        else
          ret = ret.wedge_ordered(w)
        end
        
        if ret == 0.to_m
          return ret
        end

        if ret.is_a?(SyMath::Product) and ret.factor1 == -1.to_m
          sign *= -1
          ret = ret.factor2
        end
      end

      if sign == -1
        ret = -1.to_m*ret
      end

      return ret
    end

    # Compose ordered wedge of self and w together with a sign if w is
    # shifted an even number of times. We assume self is already
    # ordered and flattened. Return 0 if w is an odd dimensional form
    # and w already exists in self.
    def wedge_ordered(w)
      if w == factor2 and w.type.degree.odd?
        return 0.to_m
      end

      if w > factor2
        return self.wedge(w)
      end

      if factor1.is_a?(SyMath::Wedge)
        f1 = factor1.wedge_ordered(w)

        if f1 == 0.to_m
          return 0.to_m
        end

        return -f1^factor2
      else
        if w == factor1 and w.type.degree.odd?
          return 0.to_m
        elsif w > factor1
          ret = (factor1.wedge(w)).wedge(factor2)
          if (w.type.degree*factor1.type.degree).odd?
            return -ret
          else
            return ret
          end
        else
          return (w.wedge(factor1)).wedge(factor2)
        end
      end
    end

    def is_prod_exp?()
      return false
    end

    def factors()
      # Override from product. Don't enumerate factors
      return [self].to_enum
    end

    def wedge_factors()
      return Enumerator.new do |f|
        factor1.wedge_factors.each { |f1| f << f1 }
        factor2.wedge_factors.each { |f2| f << f2 }
      end
    end

    def type()
      return factor1.type.wedge(factor2.type)
    end

    def to_s()
      if SyMath.setting(:expl_parentheses)
        return '('.to_s + factor1.to_s + '^' + factor2.to_s + ')'.to_s
      else
        return @args.map do |a|
          if a.is_sum_exp?
            '(' + a.to_s + ')'
          else
            a.to_s
          end
        end.join('^')
      end
    end

    def to_latex()
      return @args.map { |a| a.to_latex }.join('\wedge')
    end
  end
end
