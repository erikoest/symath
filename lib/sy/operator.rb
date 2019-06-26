require 'sy/value'
require 'set'

module Sy
  class Operator < Value
    attr_reader :name
    attr_accessor :args

    def self.builtin_operators()
      return @@builtin_operators.map { |o| o.to_s }
    end

    def has_action?()
      return @@actions.key?(@name.to_sym)
    end

    def evaluate()
      if has_action?
        return @@actions[@name.to_sym].act(*args)
      else
        return self
      end
    end
    
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

    def to_latex()
      return @name.to_s + '(' + @args.map { |a| a.to_latex }.join(',') + ')'
    end

    def hash()
      h = @name.hash
      @args.each do |a|
        h ^= a.hash
      end

      return h
    end
    
    def ==(other)
      o = other.to_m
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
      vars = @args.map { |a| a.variables }
      return vars.length == 0 ? vars : vars.inject(:|)
    end

    def replace(var, exp)
      @args = @args.map do |a|
        a.replace(var, exp)
      end

      return self
    end
  end
end

require 'sy/diff'
require 'sy/int'
require 'sy/bounds'

def op(name, *args)
  if name.eql?(:diff.to_s)
    return Sy::Diff.new(*args)
  end

  if name.eql?(:int.to_s)
    return Sy::Int.new(*args)
  end

  if name.eql?(:bounds.to_s)
    return Sy::Bounds.new(*args)
  end
  
  return Sy::Operator.new(name, args)
end
