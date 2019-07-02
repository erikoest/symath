require 'sy/operation'

module Sy
  class Operation::Hodge < Operation

    def description
      return 'Hodge star operator'
    end
    
    def act(exp)
      # Replace nvectors and nforms with their hodge dual

      # Product expressions are split into a scalar part which is kept and a vector part which
      # is replaced with its hodge dual
      if exp.is_prod_exp?
        s = exp.scalar_factors_exp
        c = exp.coefficient.to_m
        dc = exp.div_coefficient.to_m
        h = Sy::Variable.hodge_dual(exp.vector_factors_exp)

        return exp.sign.to_m.mult(c.mult(s).div(dc)).mult(h)
      end

      # Recurse down sums and subtractions
      if exp.is_sum_exp?
        act_subexpressions(exp)
        return exp
      end

      # Other operators and functions are ignored
      return exp
    end
  end
end
