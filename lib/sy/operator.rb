require 'sy/value'
require 'set'

module Sy
  class Operator < Value
    attr_reader :definition
    attr_accessor :args

    # Compose with simplify. Defaults to composition with no reductions
    def self.compose_with_simplify(*args)
      d = args[0]
      if d.is_a?(Sy::Definition::Operator)
        ret = d.compose_with_simplify(*args)
        if ret
          return ret
        end
      end
      
      return self.new(*args)
    end

    def name()
      return definition.name
    end

    # Return arguments 
    def args_assoc()
      if is_associative?
        return args.map { |a| a.class == self.class ? a.args_assoc : [a] }.inject(:+)
      else
        return args
      end
    end

    def is_commutative?()
      return false
    end
    
    def is_associative?()
      return false
    end

    def evaluate()
      puts "Evaluating #{self}"
      definition.evaluate_exp(self)
    end

    def arity()
      return @args.length
    end

    def initialize(definition, args)
      if !definition.is_a?(Sy::Value)
        definition = Sy::Definition.get(definition)
      end

      @definition = definition
      @args       = args

      if definition.is_a?(Sy::Definition::Operator)
        definition.validate_args(self)
      end
    end

    def to_s()
      if definition.is_a?(Sy::Definition::Operator)
        return definition.to_s(@args)
      else
        # Lambda call
        arglist = @args.map { |a| a.to_s }.join(',')
        
        return "(#{definition}).(#{arglist})"
      end
    end

    def to_latex()
      return definition.to_latex(@args)
    end

    def dump(indent = 0)
      i = ' '*indent
      puts i + self.class.to_s + ': ' + name.to_s
      args.each do |a|
        a.dump(indent + 2)
      end
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
      return args == o.args
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

    def reduce()
      return definition.reduce_exp(self)
    end

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

      definition.replace(map)

      return self
    end
  end
end
