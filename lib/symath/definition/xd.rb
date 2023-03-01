require 'symath/value'
require 'symath/definition/operator'

module SyMath
  class Definition::Xd < Definition::Operator
    def initialize()
      super(:xd)
    end

    def description()
      return 'd(f) - exterior derivative of f'
    end

    def evaluate_call(c)
      # Differentiate over all free variables
      vars = c.args[0].variables;
      return c.args[0].evaluate.d(vars)
    end

    def to_latex(args)
      if !args
        args = @args
      end

      return "\\mathrm{d}(#{args[0].to_latex})"
    end
  end
end
