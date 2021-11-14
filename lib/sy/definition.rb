# This class represents a definition of a constant, variable, operator or
# number. A function or operator can be used in an expression with and without
# arguments. In the latter case, they behave as a constant of type function or
# operator.

# A special case of a definition is the lambda function, which is a function
# with no name but a number of arguments, and an expression. 

module Sy
  # Empty submodule in which to define methods for function, operator and constant
  # definitions. The submodule can be extended/included into the code of the user
  # code in order to make the math expressions simpler.
  module Definitions
  end

  class Definition < Value
    attr_reader :name
    attr_reader :description

    @@definitions = {}

    @@skip_method_def = {
      :+   => true,
      :-   => true,
      :*   => true,
      :/   => true,
      :**  => true,
      :'=' => true,
      :op  => true,
      :fn  => true,
    }

    def self.init_builtin()
      # Create the builtin operators. The constructor will define the
      # operators so they can be used in expressions.
      Sy::Definition::Operator.new(:+)
      Sy::Definition::Operator.new(:-)
      Sy::Definition::Operator.new(:*)
      Sy::Definition::Operator.new(:/)
      Sy::Definition::Operator.new(:**)
      Sy::Definition::Operator.new(:^)
      Sy::Definition::Operator.new(:'=')

      Sy::Definition::Constant.init_builtin
      Sy::Definition::Function.init_builtin
      Sy::Definition::Operator.init_builtin
    end

    def self.get(name)
      if !@@definitions.has_key?(name.to_sym)
        raise "#{name} is not defined."
      end

      return @@definitions[name.to_sym]
    end

    def self.define(name, s)
      if @@definitions.has_key?(name.to_sym)
        raise "#{name} is already defined."
      end

      @@definitions[name.to_sym] = s

      # Create a method for the definition. Without arguments, the method
      # returns the definition object itself. With arguments, it returns
      # the operator/function applied to a list of arguments.
      if !Sy::Definitions.private_method_defined?(name) and
        !Sy::Definitions.method_defined?(name) and
        !@@skip_method_def[name.to_sym]

        Sy::Definitions.define_method :"#{name}" do |*args|
          sym = s
          if args.length > 0
            return sym.call(*args)
          else
            return sym
          end
        end
      end
    end

    def self.undefine(name)
      if !@@definitions.has_key?(name.to_sym)
        raise "#{name} is not undefined."
      end

      @@definitions.delete(name.to_sym)
    end

    def self.defined?(name)
      return @@definitions.has_key?(name.to_sym)
    end

    def self.definitions()
      return @@definitions.values
    end

    def initialize(name, define_symbol: true, description: nil)
      @name = name.to_sym

      # Create a method for the definition if it's not a number or lambda
      if define_symbol
        self.class.define(name, self)
      end

      if description.nil?
        @description = self.to_s
      else
        @description = description
      end
    end

    def reduce_call(c)
      return c
    end

    def variables()
      return []
    end

    def replace(map)
      return self
    end

    def is_function?()
      return false
    end

    def is_operator?()
      return false
    end
    
    def arity()
      return 0
    end
    
    def hash()
      return @name.hash
    end

    def ==(other)
      o = other.to_m
      return false if self.class.name != o.class.name
      return false if @name.to_s != o.name.to_s
      return true
    end

    # FIXME: Do we need to redefine it in all subclasses?
    alias eql? ==

    # FIXME: Identical to operator comparison
    def <=>(other)
      if self.class.name != other.class.name
        return super(other)
      end

      if name != other.name
        return name.to_s <=> other.name.to_s
      end

      return 0
    end

    # is_self_adjoint
    # is_additive
    # is_homogenous
    # is_conjugate_homogenous
    # is_linear (additive + homogenous)
    # is_antilinear (additive + conjugate_homogenous)

    def is_constant?(vars = nil)
      return true
    end

    def to_s()
      return @name.to_s
    end

    def to_latex()
      return "#{name}"
    end

    def inspect()
      if Sy.setting(:inspect_to_s)
        return "#{name}"
      else
        return super.inspect
      end
    end
  end
end

def definition(name)
  return Sy::Definition.get(name)
end

def definitions()
  return Sy::Definition.definitions
end

require 'sy/definition/variable'
require 'sy/definition/constant'
require 'sy/definition/number'
require 'sy/definition/operator'
require 'sy/definition/function'
