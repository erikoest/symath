require 'sy/value'
require 'sy/operator'

module Sy
  class CoDiff < Operator
    def initialize(arg)
      super('codiff', [arg])
    end

    # The co-differential is defined as: (-1)**(n*k+ 1)*d*(F)
    # n : Dimension of the basis vector space
    # k : Grade of input function F
    def get_definition()
      vars = Sy.get_variable(:basis.to_m).row(0)
      n = vars.length
      k = @args[0].type.degree
      sign = (-1)**(n*k + 1) == -1 ? '-1*' : ''

      return "codiff(F) = #{sign}hodge(xd(hodge(F)))".to_mexp
    end

    def to_latex()
      return '\delta ' + @args[0].to_latex
    end
  end
end
