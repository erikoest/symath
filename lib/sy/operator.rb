require 'sy/value'
require 'set'

module Sy
  class Operator < Value
    attr_reader :name
    attr_accessor :args

    def arity
      return @args.length
    end
    
    def initialize(name, args)
      @name = name
      @args = args
    end

    def to_s()
      return @name.to_s + '(' + @args.map { |a| a.to_s }.join(',') + ')'
    end

    def hash()
      h = @name.hash
      @args.each do |a|
        h ^= a.hash
      end

      return h
    end
    
    def ==(other)
      o = Sy.value(other)
      return false if self.class.name != o.class.name
      return false if name.to_s != o.name.to_s
      return false if arity != o.arity
      return args.eql?(o.args)
    end

    def <=>(other)
      if self.class.name != other.class.name
        return super(other)
      end

      if name != other.name
        return name.to_s <=> other.name.to_s
      end

      if arity != other.arity
        return arity <=> other.arity
      end

      (0...arity).to_a.each do |i|
        diff = args[i] <=> other.args[i]
        if diff != 0
          return diff
        end
      end

      return 0
    end

    alias eql? ==

    def is_constant?(vars = nil)
      @args.each do |a|
        return false if !a.is_constant?(vars)
      end

      return true
    end

    def variables()
      ret = [].to_set
      @args.each do |a|
        ret.merge(a.variables)
      end

      return ret
    end
  end
end

def op(name, *args)
  return Sy::Operator.new(name, args)
end
