require 'sy/operation'

module Sy
  class Operation::Lower < Operation

    def description
      return 'Calculate \'flat\' covariant vector from contra-variant dual'
    end
    
    def act(exp)
      act_subexpressions(exp)

      if exp.is_a?(Sy::Variable)
        if exp.type.is_subtype?('vector')
          return exp.lower_vector
        end
      end

      return exp
    end
  end
end
