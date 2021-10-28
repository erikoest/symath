require 'sy/value'
require 'sy/operator'

module Sy
  class ExteriorDerivative < Operator
    def initialize(arg, *vars)
      super('xd', [arg])
    end

    def evaluate()
      vars = Sy.get_variable(:basis.to_m).row(0)

      return @args[0].d(vars)
    end

    def to_latex()
      return '\mathrm{d}(' + @args[0].to_latex + ')'
    end
  end
end
