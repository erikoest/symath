require 'symath/definition/function'

module SyMath
  class Definition::Fact < Definition::Function
    def initialize()
      super(:fact)
    end

    def description()
      return 'fact(x) - factorial'
    end

    def reduce_call(c)
      arg = c.args[0]
      
      if arg.is_number?
        if arg.value <= SyMath.setting(:max_calculated_factorial)
          return (2..arg.value).reduce(1, :*).to_m
        end
      end

      return c
    end

    def to_s(args = nil)
      if args
        if args[0].is_a?(SyMath::Definition::Variable) or
          args[0].is_a?(SyMath::Definition::Constant)
          arg = args[0].to_s
        else
          arg = "(#{args[0].to_s})"
        end
      else
        arg = '(...)'
      end

      return "#{arg}!"
    end

    def to_latex(args = nil)
      if args
        if args[0].is_a?(SyMath::Definition::Variable) or
          args[0].is_a?(SyMath::Definition::Constant)
          arg = args[0].to_latex
        else
          arg = "(#{args[0].to_latex})"
        end
      else
        arg = '(...)'
      end
      
      return "#{arg}!"
    end
  end
end
