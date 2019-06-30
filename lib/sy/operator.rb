require 'sy/value'
require 'set'

module Sy
  class Operator < Value
    attr_reader :name
    attr_accessor :args
    
    def self.builtin_operators()
      return @@builtin_operators
    end

    def has_action?()
      return @@actions.key?(@name.to_sym)
    end

    def evaluate()
      if has_action?
        return @@actions[@name.to_sym].act(*args)
      end

      o = Sy.get_operator(self.name.to_sym)
      if !o.nil?
        d = o[:definition]
        res = o[:expression].deep_clone
        if res.args.length == self.args.length
          map = {}
          d.args.each_with_index do |a, i|
            map[a] = self.args[i]
          end
          res.replace(map)
          return res
        end
      end

      return self
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

    def replace(map)
      @args = @args.map do |a|
        a.replace(map)
      end

      return self
    end
  end
end

require 'sy/diff'
require 'sy/int'
require 'sy/bounds'
require 'sy/raise'
require 'sy/lower'
require 'sy/hodge'

def op(name, *args)
  case name.to_s
  when 'diff'
    return Sy::Diff.new(*args)
  when 'int'
    return Sy::Int.new(*args)
  when 'bounds'
    return Sy::Bounds.new(*args)
  when '='
    return Sy::Equation.new(*args)
  when 'raise'
    return Sy::Raise.new(*args)
  when 'lower'
    return Sy::Lower.new(*args)
  when 'hodge'
    return Sy::Hodge.new(*args)
  end

  return Sy::Operator.new(name, args)
end
