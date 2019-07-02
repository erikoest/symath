require 'sy/function'

module Sy
  class Subtraction < Function
    def initialize(arg1, arg2)
      super('-', [arg1, arg2])
    end

    def minuend()
      return @args[0]
    end

    def subtrahend()
      return @args[1]
    end
    
    def is_sum_exp?()
      return true
    end

    def is_scalar?()
      return (minuend.is_scalar? and subtrahend.is_scalar?)
    end

    def summands()
      return Enumerator.new do |s|
        minuend.summands.each { |s1| s << s1 }
        subtrahend.subtrahends.each { |s2| s << s2 }
      end
    end

    def subtrahends()
      return Enumerator.new do |s|
        minuend.subtrahends.each { |s1| s << s1 }
        subtrahend.summands.each { |s2| s << s2 }
      end
    end

    def type()
      if summand1.type == summand2.type
        return summand1.type
      else
        return 'invalid'.to_t
      end
    end
    
    def to_s()
      if subtrahend.is_a?(Sy::Sum)
        return minuend.to_s + ' - (' + subtrahend.to_s + ')'
      else
        return minuend.to_s + ' - ' + subtrahend.to_s
      end
    end

    def to_latex()
      if subtrahend.is_a?(Sy::Sum)
        return minuend.to_latex + ' - (' + subtrahend.to_latex + ')'
      else
        return minuend.to_latex + ' - ' + subtrahend.to_latex
      end
    end
  end
end
