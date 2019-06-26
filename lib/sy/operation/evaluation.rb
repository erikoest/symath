require 'sy/operation'

module Sy
  class Operation::Evaluation < Operation
    def description
      return 'Evaluate an operator or function'
    end

    def act(exp)
      res = exp.deep_clone

      # Recurse down operator arguments
      res = act_subexpressions(res)
      res = exp if res.nil?

      if res.is_a?(Sy::Operator) and res.has_action?
        res = res.evaluate
      end

      return res
    end
  end
end
