require 'sy/function'

module Sy
  class Function::Fact < Function
    def reduce()
      if args[0].is_number?
        if args[0].value <= Sy.setting(:max_calculated_factorial)
          return (2..args[0].value).reduce(1, :*).to_m
        end
      end

      return self
    end

    def to_s()
      if (args[0].is_a?(Sy::Variable) or args[0].is_a?(Sy::ConstantSymbol))
        return args[0].to_s + '!'.to_s
      else
        return '('.to_s + args[0].to_s + ')!'.to_s
      end
    end
    
    def to_latex()
      return args[0].to_latex + '!'.to_s
    end
  end
end
