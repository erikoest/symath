require 'sy/operation'

module Sy
  class Operation::Lower < Operation

    def description
      return 'Calculate \'flat\' covariant vector from contra-variant dual'
    end
    
    def act(exp)
      res = act_subexpressions(exp)
      res = exp if res.nil?

      if res.is_a?(Sy::Variable)
        if res.type.is_subtype?('vector')
          return res.lower_vector
        end
      end

      return res
    end
  end
end
