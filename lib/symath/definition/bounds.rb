require 'symath/value'
require 'symath/definition/operator'

module SyMath
  class Definition::Bounds < Definition::Operator
    def initialize()
      super(:bounds, args: [:f, :a, :b],
            exp: :f.to_m.(:b) - :f.to_m.(:a))
    end

    def description()
      return 'bounds(ex, x, a, b) - bounds operator, (ex)[x=b] - (ex)[x=a]'
    end

    def to_s(args = nil)
      if !args
        args = @args
      end

      exp = args[0]
      a = args[2]
      b = args[3]

      return "[#{exp}](#{a},#{b})"
    end

    def to_latex(args = nil)
      if !args
        args = @args
      end

      exp = args[0].to_latex
      a = args[2].to_latex
      b = args[3].to_latex

      return "\\left[#{exp}\\right]^{#{b}}_{#{a}}"
    end
  end
end
