# This class represents a definition of a constant, variable, operator or
# number. A function or operator can be used in an expression with and without
# arguments. In the latter case, they behave as a constant of type function or
# operator.

# A special case of a definition is the lambda function, which is a function
# with no name but a number of arguments, and an expression. 

module SyMath
  # Empty submodule in which to define methods for function, operator and
  # constant definitions. The submodule can be extended/included into the
  # code of the user code in order to make the math expressions simpler.
  module Definitions
  end

  class Definition < Value
    attr_reader :name
    attr_reader :description
    attr_reader :type

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
      # Create the builtin algebraic functions. The constructor will
      # define the functions so they can be used in expressions.
      SyMath::Definition::Operator.new(:+)
      SyMath::Definition::Operator.new(:-)
      SyMath::Definition::Operator.new(:*)
      SyMath::Definition::Operator.new(:/)
      SyMath::Definition::Operator.new(:**)
      SyMath::Definition::Operator.new(:^)
      SyMath::Definition::Operator.new(:'=')

      SyMath::Definition::Constant.init_builtin
      SyMath::Definition::Function.init_builtin
      SyMath::Definition::Operator.init_builtin
    end

    def self.get(name, type = nil)
      # No type supplied. Try to determine type from value
      if type.nil?
        type = SyMath::Definition::Constant.default_type_for_constant(name)
      end

      # Still no type. Look up various types of definitions in order
      if type.nil?
        type = 'any type'
        types = ['real', 'function', 'linop', 'operator']
      else
        types = [type]
      end

      types.each do |t|
        if @@definitions.has_key?(t.to_sym) and
           @@definitions[t.to_sym].has_key?(name.to_sym)
          return @@definitions[t.to_sym][name.to_sym]
        end
      end

      raise "#{name} (#{type}) is not defined."
    end

    def self.define(s)
      if !@@definitions.has_key?(s.type.name.to_sym)
        @@definitions[s.type.name.to_sym] = {}
      end

      if @@definitions[s.type.name.to_sym].has_key?(s.name.to_sym)
        raise "#{name} (#{s.type.name}) is already defined."
      end

      @@definitions[s.type.name.to_sym][s.name.to_sym] = s

      # Create a method for the definition. Without arguments, the method
      # returns the definition object itself. With arguments, it returns
      # the operator/function applied to a list of arguments.
      if !SyMath::Definitions.private_method_defined?(s.name) and
        !SyMath::Definitions.method_defined?(s.name) and
        !@@skip_method_def[s.name.to_sym]

        SyMath::Definitions.define_method :"#{s.name}" do |*args|
          sym = s
          if args.length > 0
            return sym.call(*args)
          else
            return sym
          end
        end
      end
    end

    def self.undefine(name, type)
      if !@@definitions.has_key?(type.to_sym) or
         !@@definitions[type.to_sym].has_key?(name.to_sym)
        raise "#{name} is not undefined."
      end

      @@definitions.delete(name.to_sym)
    end

    def self.defined?(name, type)
      return (@@definitions.has_key?(type.to_sym) and
              @@definitions[type.to_sym].has_key?(name.to_sym))
    end

    def self.definitions()
      return @@definitions.values
    end

    def initialize(name, define_symbol: true, description: nil, type: 'real')
      @name = name.to_sym
      @type = type.to_t

      # Create a method for the definition if it's not a number or lambda
      if define_symbol
        self.class.define(self)
      end

      if description.nil?
        @description = self.to_s
      else
        @description = description
      end
    end

    def product_reductions()
      return nil
    end

    def reduce_product_modulo_sign(o)
      map = product_reductions

      if !map.nil?
        if map.has_key?(o)
          ret = map[o]
          if ret.is_a?(SyMath::Minus)
            return ret.argument, -1, true
          else
            return ret, 1, true
          end
        end
      end

      return self, 1, false
    end

    def reduce_power_call(c, e)
      return c, 1, false
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
      return false if self.type.name != o.type.name
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

    def qubit_name()
      if @name == :qplus
        return '+'
      elsif @name == :qminus
        return '-'
      elsif @name == :qright
        return 'R'
      elsif @name == :qleft
        return 'L'
      elsif @name =~ /^q[0-9]+$/
        return @name[1..-1]
      else
        return @name
      end
    end

    def to_s()
      if @type.is_dform?
        return SyMath.setting(:d_symbol) + undiff.to_s
      elsif @type.is_vector?
        if vector_space.normalized? and SyMath.setting(:braket_syntax)
          return "|#{qubit_name}>"
        else
          return @name.to_s + SyMath.setting(:vector_symbol)
        end
      elsif @type.is_covector?
        if vector_space.normalized? and SyMath.setting(:braket_syntax)
          return "<#{qubit_name}|"
        else
          return @name.to_s + SyMath.setting(:covector_symbol)
        end
      elsif @type.is_subtype?('tensor')
        return @name.to_s + '['.to_s + @type.index_str + ']'.to_s
      else
        return @name.to_s
      end
    end

    def to_latex()
      return "#{name}"
    end

    def inspect()
      if SyMath.setting(:inspect_to_s)
        return to_s
      else
        return super.inspect
      end
    end
  end
end

def definition(name, type)
  return SyMath::Definition.get(name, type)
end

def definitions()
  return SyMath::Definition.definitions
end

require 'symath/definition/variable'
require 'symath/definition/constant'
require 'symath/definition/number'
require 'symath/definition/operator'
require 'symath/definition/function'
