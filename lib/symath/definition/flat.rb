require 'symath/value'
require 'symath/definition/operator'

module SyMath
  class Definition::Flat < Definition::Operator
    def initialize()
      super(:flat)
    end

    def description()
      return 'flat(f) - musical lower/flat/b isomorphic operator'
    end

    def evaluate_call(c)
      # Must normalize input, operation depends on factorized vectors
      return c.args[0].evaluate.normalize.flat
    end

    def to_s(args = nil)
      if !args
        args = @args
      end

      return "b(#{args[0]})"
    end
    
    def latex_format()
      return '%s^\flat'
    end
  end
end
