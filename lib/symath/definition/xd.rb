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
      vars = SyMath.get_vector_space.basis.row(0)

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
