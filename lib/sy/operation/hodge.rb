require 'sy/operation'

module Sy
  class Operation::Hodge < Operation

    def description
      return 'Hodge star operator'
    end
    
    def act(exp)
      # Recurse down sums and subtractions
      if exp.is_sum_exp?
        act_subexpressions(exp)
        return exp
      else
        # Replace nvectors and nforms with their hodge dual
        s = exp.scalar_factors_exp
        c = exp.coefficient.to_m
        dc = exp.div_coefficient.to_m
        h = Sy::Variable.hodge_dual(exp.vector_factors_exp)
        return exp.sign.to_m.mult(c.mult(s).div(dc)).mult(h)
      end
    end
  end
end
