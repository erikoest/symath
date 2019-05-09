require 'sy/operation'

module Sy
  # Apply distributive law over products of sums:
  #   a*(b + c) -> a*b + a*c
  #   a*(b - c) -> a*b - a*c
  # The transformation iterates until no changes occur. Thus, the expression
  #   (a + b)*(c + d) transforms to a*c + a*d + b*c + b*d
  class DistributiveLaw < Operation
    def description
      return 'Apply distributive law'
    end

    def act(exp)
      return iterate(exp)
    end

    def single_pass(exp)
      if exp.is_prod_exp?
        if exp.factor1.is_sum_exp? and exp.factor1.arity > 1
          return self.multiply_right(exp)
        elsif exp.factor2.is_sum_exp? and exp.factor2.arity > 1
          return self.multiply_left(exp)
        end
      end

      if exp.is_sum_exp?
        return act_subexpressions(exp)
      end
    end

    def multiply_right(exp)
      a = exp.factor1.summands.to_a
      s = exp.factor1.subtrahends.to_a
      p = exp.factor2

      if a.length > 0
        ret = a.shift * p
      else
        ret = -s.shift * p
      end

      while a.length > 0
        ret += a.shift * p
      end

      while s.length > 0
        ret -= s.shift * p
      end

      return ret      
    end

    def multiply_left(exp)
      a = exp.factor2.summands.to_a
      s = exp.factor2.subtrahends.to_a
      p = exp.factor1

      if a.length > 0
        ret = a.shift * p
      else
        ret = -s.shift * p
      end

      while a.length > 0
        ret += a.shift * p
      end
      
      while s.length > 0
        ret -= s.shift * p
      end

      return ret      
    end
  end
end
