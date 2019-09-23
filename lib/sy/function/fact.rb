require 'sy/function'

module Sy
  class Function::Fact < Function
    def reduce()
      if args[0].is_a?(Sy::Number)
        if args[0].value <= Sy.setting(:max_calculated_factorial)
          return (2..args[0].value).reduce(1, :*).to_m
        end
      end

      return self
    end

    def to_s()
      return args[0].to_s + '!'.to_s
    end
    
    def to_latex()
      return args[0].to_latex + '!'.to_s
    end
  end
end
