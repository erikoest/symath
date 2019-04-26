require 'sy/function'

module Sy
  class Sum < Function
    def initialize(arg1, arg2)
      super('+', [arg1, arg2])
    end

    def summand1()
      return @args[0]
    end

    def summand2()
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

    # Return array of positive summands
    def summands_to_a()
      return summand1.summands_to_a + summand2.summands_to_a
    end

    # Return array of subtrahends 
    def subtrahends_to_a()
      return summand1.subtrahends_to_a + summand2.subtrahends_to_a
    end
    
    def to_s()
      return @args.map { |a| a.to_s }.join(' + ')
    end
  end
end
