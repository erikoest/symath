require 'symath/value'
require 'symath/definition/operator'

module SyMath
  class Definition::Curl < Definition::Operator
    def initialize()
      # Curl is defined as (*(d(Fb)))#
      super(:curl, args: [:f], exp: '#(hodge(xd(b(f))))')
    end

    def description()
      return 'curl(f) - curl of vector field f'
    end

    def evaluate_call(c)
      if SyMath.get_variable(:basis.to_m).row(0).length != 3
        raise 'Curl is only defined for 3 dimensions'
      end

      return super(c)
    end

    def latex_format()
      return '\nabla\times %s'
    end
  end
end
