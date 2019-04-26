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
    
    def is_commutative?()
      return true
    end

    def is_associative?()
      return true
    end

    def is_sum_exp?()
      return true
    end

    def summands_to_a()
      return minuend.summands_to_a + subtrahend.subtrahends_to_a
    end

    def subtrahends_to_a()
      return minuend.subtrahends_to_a + subtrahend.summands_to_a
    end

    def to_s()
      return @args.map { |a| a.to_s }.join(' - ')
    end
  end
end
