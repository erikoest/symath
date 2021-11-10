require 'sy/value'
require 'sy/definition/operator'

module Sy
  class Definition::CoDiff < Definition::Operator
    def initialize()
      # The co-differential is defined as: (-1)**(n*k+ 1)*d*(F).
      # n : Dimension of the basis vector space
      # k : Grade of input function F
      # (the sign is calculated by the overridden evaluate method)
      super(:codiff, args: [:f], exp: 'hodge(xd(hodge(f)))')
    end

    def evaluate_call(c)
      vars = Sy.get_variable(:basis.to_m).row(0)
      n = vars.length
      k = c.args[0].type.degree
      sign = ((-1)**(n*k + 1)).to_m

      return sign*super(c)
    end

    def latex_format()
      return '\delta %s'
    end
  end
end
