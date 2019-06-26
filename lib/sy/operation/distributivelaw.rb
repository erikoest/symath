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
      if exp.is_a?(Sy::Product)
        if exp.factor1.is_sum_exp? and exp.factor1.arity > 1
          return multiply_right(exp)
        elsif exp.factor2.is_sum_exp? and exp.factor2.arity > 1
          return multiply_left(exp)
        end
      end

      if exp.is_sum_exp?
        return act_subexpressions(exp)
      end
    end

    def multiply_right(exp)
      p = exp.factor2
      ret = 0.to_m

      exp.factor1.summands.each do |s|
        ret = ret.add(s*p)
      end
        
      exp.factor1.subtrahends.each do |s|
        ret = ret.sub(s*p)
      end

      return ret      
    end

    def multiply_left(exp)
      p = exp.factor1
      ret = 0.to_m

      exp.factor2.summands.each do |s|
        ret = ret.add(p*s)
      end
        
      exp.factor2.subtrahends.each do |s|
        ret = ret.sub(p*s)
      end

      return ret      
    end
  end
end