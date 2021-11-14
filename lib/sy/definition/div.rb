require 'sy/value'
require 'sy/definition/operator'

module Sy
  class Definition::Div < Definition::Operator
    def initialize()
      # Div is defined as *d*(Fb)
      super(:div, args: [:f], exp: 'hodge(xd(hodge(b(f))))')
    end

    def description()
      return 'div(f) - divergence of vector field f'
    end

    def evaluate_call(c)
      if Sy.get_variable(:basis.to_m).row(0).length != 3
        raise 'Div is only defined for 3 dimensions'
      end

      super(c)
    end

    def latex_format()
      return '\nabla\cdot %s'
    end
  end
end
