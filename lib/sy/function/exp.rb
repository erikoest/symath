require 'sy/function'

module Sy
  class Function::Exp < Function
    def reduce()
      if args[0] == 0
        return 1.to_m
      elsif args[0] == 1
        return :e.to_m
      end

      if args[0].is_finite? == false
        if Sy.setting(:complex_arithmetic)
          return :NaN.to_m
        else
          if args[0].is_positive?
            return :oo.to_m
          else
            return 0.to_m
          end
        end
      end
      
      return self
    end
  end
end
