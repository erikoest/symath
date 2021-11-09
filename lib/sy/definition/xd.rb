require 'sy/value'
require 'sy/definition/operator'

module Sy
  class Definition::Xd < Definition::Operator
    def initialize()
      super(:xd)
    end

    def evaluate_exp(e)
      vars = Sy.get_variable(:basis.to_m).row(0)

      return e.args[0].d(vars)
    end

    def to_latex(args)
      if !args
        args = @args
      end

      return "\\mathrm{d}(#{args[0].to_latex})"
    end
  end
end
