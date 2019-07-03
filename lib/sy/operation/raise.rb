require 'sy/operation'

module Sy
  class Operation::Raise < Operation

    def description
      return 'Calculate \'sharp\' contra-variant vector from covariant dual'
    end

    def act(exp)
      res = act_subexpressions(exp)
      res = exp if res.nil?

      if res.is_a?(Sy::Variable)
        if res.type.is_subtype?('dform')
          return res.raise_dform
        end
      end

      return res
    end
  end
end
