require 'sy/operation'

module Sy
  class Operation::Raise < Operation

    def description
      return 'Calculate \'sharp\' contra-variant vector from covariant dual'
    end

    def act(exp)
      act_subexpressions(exp)

      if exp.is_a?(Sy::Variable)
        if exp.type.is_subtype?('dform')
          return exp.raise_dform
        end
      end

      return exp
    end
  end
end
