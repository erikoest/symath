# This class represents a definition of a constant, variable, operator or
# number. A function or operator can be used in an expression with and without
# arguments. In the latter case, they behave as a constant of type function or
# operator.

# A special case of a definition is the lambda function, which is a function
# with no name but a number of arguments, and an expression. 

module SyMath
  # Empty submodule in which to define methods for function, operator and constant
  # definitions. The submodule can be extended/included into the code of the user
  # code in order to make the math expressions simpler.
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
      SyMath::Definition::Function.new(:+)
      SyMath::Definition::Function.new(:-)
      SyMath::Definition::Function.new(:*)
      SyMath::Definition::Function.new(:/)
      SyMath::Definition::Function.new(:**)
      SyMath::Definition::Function.new(:^)
      SyMath::Definition::Function.new(:'=')

      SyMath::Definition::Constant.init_builtin
      SyMath::Definition::Function.init_builtin
      SyMath::Definition::Operator.init_builtin
    end

    def self.get(name, type)
      if !@@definitions.has_key?(type.to_sym) or
         !@@definitions[type.to_sym].has_key?(name.to_sym)
        raise "#{name} (#{type}) is not defined."
      end

      return @@definitions[type.to_sym][name.to_sym]
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

    # Note: We could generalize this method to a reduce_tensor_pair:
    #   Herm*Herm -> 1
    #   H|1> -> |+>
    #   H H|1> -> |0> etc.
    # We could also define an object for linear operators, covectors and
    # vectors, then use the reduce_call() method for simplifications.

    # q0 = [1, 0]
    # q1 = [0, 1]
    # q- = [1, -1]/sqrt(2)
    # q+ = [1,  1]/sqrt(2)

    @@braket_reduction_map = {
      :q0 => {
        :q1     => 0,
        :qminus => 1,
        :qpluss => 1,
      },
      :q1 => {
        :q0     => 0,
        :qminus => -1,
        :qpluss => 1,
      },
      :qminus => {
        :q0     => 1,
        :q1     => -1,
        :qpluss => 0,
      },
      :qpluss => {
        :q0     => 1,
        :q1     => 1,
        :qminus => 0,
      },
    }

    def reduce_braket_pair(o)
      # FIXME: This is true only for unit vectors and covectors
      # <a|a> = 1
      if self.name == o.name
        return 1.to_m
      end

      # Reduce specific constant qubit pairs
      if @@braket_reduction_map.has_key?(self.name) and
         @@braket_reduction_map[self.name].has_key?(o.name)
        ret = @@braket_reduction_map[self.name][o.name]
        if (ret != 0)
          ret = ret.to_m/fn(:sqrt, 2)
        else
          ret = ret.to_m
        end

        return ret
      end

      return nil
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
      if @name == :qpluss
        return '+'
      elsif @name == :qminus
        return '-'
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
        if SyMath.setting(:braket_syntax)
          return "|#{qubit_name}>"
        else
          return @name.to_s + SyMath.setting(:vector_symbol)
        end
      elsif @type.is_covector?
        if SyMath.setting(:braket_syntax)
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
