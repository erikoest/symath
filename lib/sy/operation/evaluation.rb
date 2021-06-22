require 'sy/operation'

module Sy::Operation::Evaluation
  # This operation provides the method eval which evaluates operators
  # and formulaic functions in the expression.

  # FIXME: Rename to recursive_eval?
  def eval()
    res = deep_clone
    
    # Recurse down operator arguments
    res = res.act_subexpressions('eval')
    res = deep_clone if res.nil?

    if res.is_a?(Sy::Operator) and has_action?
      res = res.evaluate
    end

    return res
  end
end
