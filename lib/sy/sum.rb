require 'sy/operator'

module Sy
  class Sum < Operator
    def self.compose_with_simplify(a, b)
      a = a.to_m
      b = b.to_m

      # Adding a value to an equation adds it to both sides, preserving
      # the balance of the equation
      if b.is_a?(Sy::Equation)
        return eq(a + b.args[0], a + b.args[1])
      end

      if a.is_finite?() == false or b.is_finite?() == false
        return self.simplify_inf(a, b)
      end

      return a if b == 0
      return b if a == 0

      sc = 1
      sf = []
      oc = 1
      of = []

      a.factors.each do |f|
        if f == -1
          sc *= -1
        elsif f.is_number?
          sc *= f.value
        else
          sf.push f
        end
      end

      b.factors.each do |f|
        if f == -1
          oc *= -1
        elsif f.is_number?
          oc *= f.value
        else
          of.push f
        end
      end
      
      sc += oc

      if sf == of
        if sc == 0
          return 0.to_m
        end

        if sc != 1
          sf.unshift sc.to_m
        end

        return sf.empty? ? 1.to_m : sf.inject(:*)
      end

      return self.new(a, b)
    end

    def self.simplify_inf(a, b)
      # Indefinite terms
      if a.is_finite?.nil? or b.is_finite?.nil?
        return a.add(b)
      end
      
      # NaN add to NaN
      if a.is_nan? or b.is_nan?
        return :nan.to_m
      end

      if Sy.setting(:complex_arithmetic)
        # +- oo +- oo = NaN
        if (a.is_finite? == false and b.is_finite? == false)
          return :nan.to_m
        end

        # oo + n = n + oo = NaN
        if (a.is_finite? == false or b.is_finite? == false)
          return :oo.to_m
        end
      else
        # oo - oo = -oo + oo = NaN
        if (a.is_finite? == false and b.is_finite? == false)
          if (a.is_positive? and b.is_negative?) or
            (a.is_negative? and b.is_positive?)
            return :nan.to_m
          end
        end

        # oo + n = n + oo = oo + oo = oo
        if a.is_finite? == false
          return a
        end

        # n - oo = - oo + n = -oo - oo = -oo
        if b.is_finite? == false
          return b
        end
      end

      # :nocov:
      raise 'Internal error'
      # :nocov:
    end
    
    def initialize(arg1, arg2)
      super('+', [arg1, arg2])
    end

    def term1()
      return @args[0]
    end

    def term2()
      return @args[1]
    end

    def is_commutative?()
      return true
    end
    
    def is_associative?()
      return true
    end

    def is_sum_exp?()
      return true
    end

    # Return all terms in the sum
    def terms()
      return Enumerator.new do |s|
        term1.terms.each { |s1| s << s1 }
        term2.terms.each { |s2| s << s2 }
      end
    end

    def evaluate
      if term1.type.is_matrix?
        return term1.matrix_add(term2)
      end

      return self
    end

    def type()
      return term1.type.sum(term2.type)
    end

    def to_s()
      if Sy.setting(:expl_parentheses)
        return '('.to_s + term1.to_s + ' + ' + term2.to_s + ')'.to_s
      else
        if term2.is_a?(Sy::Minus)
          return term1.to_s + " " + term2.to_s
        else
          return term1.to_s + " + " + term2.to_s
        end
      end
    end

    def to_latex()
      if term2.is_a?(Sy::Minus)
        return term1.to_latex + ' ' + term2.to_latex
      else
        return term1.to_latex + ' + ' + term2.to_latex
      end
    end
  end
end
