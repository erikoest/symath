require 'sy/definition/function'

module Sy
  class Definition::Abs < Definition::Function
    def initialize()
      super(:abs)
    end

    def reduce_call(c)
      arg = c.args[0]
      if arg.is_nan?
        return :nan.to_m
      # Corner case, -oo is positive with complex arithmetic, so we need a
      # specific check for that.
      elsif arg.is_negative? or arg == -:oo
        return - arg
      elsif arg.is_positive? or arg.is_zero?
        return arg
      else
        return c
      end
    end

    def to_s(args = nil)
      if args
        arg = args[0].to_s
      else
        arg = '...'
      end

      return "|#{arg}|"
    end

    def to_latex(args = nil)
      if args
        arg = args[0].to_latex
      else
        arg = '...'
      end
      
      return "\\lvert#{arg}\\rvert"
    end
  end
end
