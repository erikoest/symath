require 'sy/function'

module Sy
  class Function::Ln < Function
    def reduce()
      if args[0] == 1
        return 0.to_m
      elsif args[0] == :e
        return 1.to_m
      end

      if !Sy.setting(:complex_arithmetic)
        if args[0] == 0
          return -:oo.to_m
        elsif args[0] == :oo
          return :oo.to_m
        end

        if args[0].is_negative?
          return :NaN.to_m
        end
      else
        case args[0]
        when -1
          return :pi.to:m*:i
        when -:e.to_m
          return 1.to_m + :pi.to_m*:pi
        when :i.to_m
          return :pi.to_m*:i/2
        when :i.to_m*:e
          return 1 + :pi.to_m*:i/2
        when -:i.to_m
          return -:pi.to_m*:i/2
        when -:i.to_m*:e
          return 1 - :pi.to_m*:i/2
        end
      end
      
      return self
    end
  end
end
