require 'sy/value'
require 'sy/operator'

module Sy
  class Curl < Operator
    def initialize(arg)
      super('curl', [arg])
    end

    def evaluate()
      if Sy.get_variable(:basis.to_m).row(0).length != 3
        raise 'Curl is only defined for 3 dimensions'
      end

      # Get list of variables to differentiate with respect to
      vars = Sy.get_variable(:basis.to_m).row(0)
      
      # Curl is defined as (*(d(Fb)))#
      return @@actions[:eval].act(op(:raise, op(:hodge, op(:diff, op(:lower, args[0]), *vars))))
    end
  end
end
