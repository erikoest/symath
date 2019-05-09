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

    # Return positive summands
    def summands()
      return Enumerator.new do |s|
        summand1.summands.each { |s1| s << s1 }
        summand2.summands.each { |s2| s << s2 }
      end
    end

    # Return subtrahends 
    def subtrahends()
      return Enumerator.new do |s|
        summand1.subtrahends.each { |s1| s << s1 }
        summand2.subtrahends.each { |s2| s << s2 }
      end
    end
    
    def to_s()
      return @args.map { |a| a.to_s }.join(' + ')
    end
  end
end
