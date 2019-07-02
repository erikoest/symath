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
    
    def is_sum_exp?()
      return true
    end

    def is_scalar?()
      return (summand1.is_scalar? and summand2.is_scalar?)
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

    def type()
      return summand1.type.sum(summand2.type)
    end
    
    def to_s()
      return @args.map { |a| a.to_s }.join(' + ')
    end

    def to_latex()
      return @args.map { |a| a.to_latex }.join(' + ')
    end
  end
end
