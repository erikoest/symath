require 'sy/value'
require 'set'

module Sy
  class Operator < Value
    attr_reader :name
    attr_accessor :args

    def has_definition?()
      return !get_definition.nil?
    end

    def get_definition()
      return Sy.get_operator(self.name)
    end

    def get_action()
      return
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

    def expand_formula()
      d = get_definition
      return self if d.nil?

      dd = d[:definition]
      res = d[:expression].deep_clone
      if dd.args.length == self.args.length
        map = {}
        dd.args.each_with_index do |a, i|
          map[a] = self.args[i]
        end
        res.replace(map)
        return res
      else
        raise "Cannot expand #{dd} with #{self.args.length} arguments (expected #{dd.args.length})"
      end
    end

    def evaluate()
      if has_definition?
        # Expand operator definition into formula expression, evaluate
        # all sub-expressions, then evaluate the expression itself.
        expand_formula.recurse('evaluate')
      else
        a = get_action
        if a.nil?
          return self
        else
          return args[0].send(a)
        end
      end
    end

    def arity
      return @args.length
    end

    @@skip_method_def = {
      :+ => true,
      :- => true,
      :* => true,
      :/ => true,
      :** => true,
    }
    
    def initialize(name, args)
      @name = name
      @args = args

      # Create ruby method for the function if the method name is not
      # already taken.
      if !self.kind_of?(Sy::Constant) and
        !Object.private_method_defined?(name) and
        !Object.method_defined?(name) and
        !@@skip_method_def[name.to_sym]
        clazz = self.class
        Object.define_method :"#{name}" do |*args|
          return clazz.new("#{name}", args.map { |a| a.to_m })
        end
      end
    end

    def to_s()
      return @name.to_s + '(' + @args.map { |a| a.to_s }.join(',') + ')'
    end

    def to_latex()
      return '\operatorname{' + @name.to_s + '}(' + @args.map { |a| a.to_latex }.join(',') + ')'
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

    @@builtin_operators = {
      :diff   => 'Sy::Diff',
      :int    => 'Sy::Int',
      :bounds => 'Sy::Bounds',
      :'='    => 'Sy::Equation',
      :sharp  => 'Sy::Sharp',
      :flat   => 'Sy::Flat',
      :hodge  => 'Sy::Hodge',
      :grad   => 'Sy::Grad',
      :curl   => 'Sy::Curl',
      :div    => 'Sy::Div',
      :laplacian => 'Sy::Laplacian',
      :codiff => 'Sy::CoDiff',
      :xd     => 'Sy::ExteriorDerivative',
    }

    def self.is_builtin?(name)
      return @@builtin_operators.key?(name)
    end

    def self.builtin(name, args)
      name = name.to_sym
      if !self.is_builtin?(name)
        return
      end

      clazz = Object.const_get(@@builtin_operators[name])
      return clazz.new(*args.map { |a| a.nil? ? a : a.to_m })
    end
  end
end

def op(name, *args)
  op = Sy::Operator.builtin(name, args)
  if !op.nil?
    return op
  end

  # Not a built-in operator. Create a custom one.
  return Sy::Operator.new(name, args.map { |a| a.to_m })
end
