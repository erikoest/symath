require 'sy/value'
require 'sy/operator'

module Sy
  class CoDiff < Operator
    def initialize(arg)
      super('codiff', [arg])
    end

    def evaluate()
      # Get list of variables to differentiate with respect to
      vars = Sy.get_variable(:basis.to_m).row(0)

      # Calculate the co-differential, defined as:
      #   (-1)**(n*k+ 1)*d*(F)
      # n : Dimension of the basis vector space
      # k : Grade of input function F
      n = vars.length
      k = args[0].type.degree
      sign = (-1)**(n*k + 1)
      return sign*op(:hodge, op(:diff, op(:hodge, args[0]), *vars)).eval
    end

    def to_latex()
      return '\delta ' + @args[0].to_latex
    end
  end
end
