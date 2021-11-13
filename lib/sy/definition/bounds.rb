require 'sy/value'
require 'sy/definition/operator'

module Sy
  class Definition::Bounds < Definition::Operator
    def initialize()
      super(:bounds, args: [:ex, :v, :a, :b],
            exp: fn(lmd(:ex.to_m, :v), :b) - fn(lmd(:ex.to_m, :v), :a))
    end

    def validate_args(e)
      var = e.args[1]
      
      if !var.is_a?(Sy::Definition::Variable)
        raise "Expected variable for var, got " + var.class.name
      end

      if !var.type.is_scalar?
        raise "Expected var to be a scalar, got " + var.to_s
      end
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
