require 'sy/function'

module Sy
  class Function::Abs < Function
    def reduce()
      if args[0].is_nan?
        return :NaN.to_m
      # Corner case, -oo is positive with complex arithmetic, so we need a specific check
      # for that.
      elsif args[0].is_negative? or args[0] == -:oo
        return - args[0]
      elsif args[0].is_positive? or args[0].is_zero?
        return args[0]
      else
        return self
      end
    end

    def to_s()
      return '|'.to_s + args[0].to_s + '|'.to_s
    end
    
    def to_latex()
      return '\lvert'.to_s + args[0].to_latex + '\rvert'.to_s
    end
  end
end
