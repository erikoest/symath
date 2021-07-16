require 'sy/value'
require 'sy/operator'

module Sy
  class Div < Operator
    def initialize(arg)
      super('div', [arg])
    end

    # Div is defined as *d*(Fb)
    def get_definition()
      if Sy.get_variable(:basis.to_m).row(0).length != 3
        raise 'Div is only defined for 3 dimensions'
      end

      return 'div(F) = hodge(xd(hodge(b(F))))'.to_mexp
    end

    def to_latex()
      return '\nabla\cdot ' + @args[0].to_latex
    end
  end
end
