require 'sy/value'
require 'sy/operator'

module Sy
  class Laplacian < Operator
    def initialize(arg)
      super('laplacian', [arg])
    end

    def evaluate()
      # Get list of variables to differentiate with respect to
      vars = Sy.get_variable(:basis.to_m).row(0)
      
      # The laplacian is defined as *d*dF
      return op(:hodge,
                op(:diff,
                   op(:hodge,
                      op(:diff, args[0], *vars)
                     ),
                   *vars
                  )
               ).evaluate_recursive
    end

    def to_latex()
      return '\nabla^2 ' + @args[0].to_latex
    end
  end
end
