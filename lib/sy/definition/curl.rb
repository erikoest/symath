require 'sy/value'
require 'sy/definition/operator'

module Sy
  class Definition::Curl < Definition::Operator
    def initialize()
      # Curl is defined as (*(d(Fb)))#
      super(:curl, args: [:f], exp: '#(hodge(xd(b(f))))')
    end

    def evaluate(e)
      if Sy.get_variable(:basis.to_m).row(0).length != 3
        raise 'Curl is only defined for 3 dimensions'
      end

      return super(e)
    end

    def latex_format()
      return '\nabla\times %s'
    end
  end
end
