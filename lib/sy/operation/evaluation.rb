require 'sy/operation'

module Sy::Operation::Evaluation
  # This operation provides the method eval which evaluates operators
  # and formulaic functions in the expression.

  def evaluate_recursive()
    res = deep_clone
    
    # Recurse down operator arguments
    res = res.act_subexpressions('evaluate_recursive')
    res = deep_clone if res.nil?

    if res.is_a?(Sy::Operator) and has_action?
      res = res.evaluate
    end

    return res
  end
end
