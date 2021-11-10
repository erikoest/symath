require 'sy/definition/function'

module Sy
  class Definition::Ln < Definition::Function
    def initialize()
      super(:ln)
    end

    def reduce_call(c)
      arg = c.args[0]
      
      if arg == 1
        return 0.to_m
      elsif arg == :e
        return 1.to_m
      end

      if !Sy.setting(:complex_arithmetic)
        if arg == 0
          return -:oo.to_m
        elsif arg == :oo
          return :oo.to_m
        end

        if arg.is_a?(Sy::Minus)
          return :nan.to_m
        end
      else
        case arg
        when -1
          return :pi.to_m*:i
        when -:e.to_m
          return 1.to_m + :pi.to_m*:i
        when :i.to_m
          return :pi.to_m*:i/2
        when :e.to_m*:i
          return 1.to_m + :pi.to_m*:i/2
        when -:i.to_m
          return -:pi.to_m*:i/2
        when -:e.to_m*:i
          return 1.to_m - :pi.to_m*:i/2
        end
      end

      return c
    end
  end
end
