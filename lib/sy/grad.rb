require 'sy/value'
require 'sy/operator'

module Sy
  class Grad < Operator
    def initialize(arg)
      super('grad', [arg])
    end

    def evaluate()
      # Get list of variables to differentiate with respect to
      vars = Sy.get_variable(:basis.to_m).row(0)
      
      # Grad is defined as (dF)#
      return op(:sharp, op(:diff, args[0], *vars)).evaluate_recursive
    end

    def to_latex()
      return '\nabla ' + @args[0].to_latex
    end
  end
end
