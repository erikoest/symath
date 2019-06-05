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

    def to_s()
      return @args.map { |a| a.to_s }.join(' - ')
    end

    def to_latex()
      return @args.map { |a| a.to_latex }.join(' - ')
    end
  end
end
