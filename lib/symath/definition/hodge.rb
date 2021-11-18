require 'symath/value'
require 'symath/definition/operator'

module SyMath
  class Definition::Hodge < Definition::Operator
    def initialize()
      super(:hodge)
    end

    def description()
      return 'hodge(f) - hodge star operator'
    end

    def evaluate_call(c)
      # Must normalize input, operation depends on factorized vectors
      return c.args[0].evaluate.normalize.hodge
    end

    def latex_format()
      return '\star %s'
    end
  end
end
