require 'sy/operation'

module Sy
  # Apply distributive law over products of sums:
  #   a*(b + c) -> a*b + a*c
  #   a*(b - c) -> a*b - a*c
  # The transformation iterates until no changes occur. Thus, the expression
  #   (a + b)*(c + d) transforms to a*c + a*d + b*c + b*d
  class Operation::DistributiveLaw < Operation
    def description
      return 'Apply distributive law'
    end

    def act(exp)
      return iterate(exp)
    end

    def single_pass(exp)
      if exp.is_a?(Sy::Minus)
        acted = act(exp.argument)
        if acted == exp.argument
          return nil
        else
          return -acted
        end
      end

      if exp.is_a?(Sy::Product)
        if (exp.factor1.is_sum_exp? and exp.factor1.arity > 1) or
          (exp.factor2.is_sum_exp? and exp.factor2.arity > 1)
          return expand(exp.factor1, exp.factor2)
        end
      end

      return nil
    end

    def expand(exp1, exp2)
      if exp1.is_sum_exp? and exp1.arity > 1
        ret = 0.to_m
        
        exp1.terms.each do |t|
          ret += expand(t, exp2)
        end
        return ret
      end
      
      if exp2.is_sum_exp? and exp2.arity > 1
        ret = 0.to_m

        exp2.terms.each do |t|
          ret += expand(exp1, t)
        end
        return ret
      end

      return exp1*exp2
    end
  end
end
