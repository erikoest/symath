require 'sy/operation'

module Sy
  class Operation::Bounds < Operation

    def description
      return 'Subtract upper bound from lower bound'
    end

    def act(exp, var, a, b)
      bexp = exp.deep_clone.replace({ var =>  b })
      aexp = exp.deep_clone.replace({ var =>  a })
      return bexp - aexp
    end
  end
end
