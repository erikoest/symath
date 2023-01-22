require "symath/version"
require "symath/parser"

require 'symath/type'
require 'symath/operator'
require 'symath/sum'
require 'symath/minus'
require 'symath/product'
require 'symath/wedge'
require 'symath/outer'
require 'symath/fraction'
require 'symath/power'
require 'symath/definition'
require 'symath/value'
require 'symath/matrix'
require 'symath/equation'
require 'symath/poly'
require 'symath/poly/dup'
require 'symath/poly/galois'

module SyMath
  @@global_settings = {
    # Symbol used to represent vector variables
    :vector_symbol => '\'',

    # Use (dirac) braket syntax for vectors and oneform
    :braket_syntax => true,
    # Show all parantheses on +, *, / and ^ operators.
    :expl_parentheses => false,
    # Represent square roots with the root symbol or as a fraction exponent
    :sq_exponent_form => false,
    # Represent fraction of scalars as a negative exponent
    :fraction_exponent_form => false,
    # Show the multiplication sign in LaTeX output
    :ltx_product_sign => false,

    # Simplify expression at the time they are composed
    :compose_with_simplify => true,

    # Use complex arithmetic. Negative square roots are reduced to i*square
    # root of the positive part. The complex infinity is used rather than the
    # positive and negative real infinities.
    :complex_arithmetic => true,

    # Override inspect for value objects. This makes expression dumps more
    # readable, but less precise.
    :inspect_to_s => true,

    # Biggest factorial that we calculate to a value
    :max_calculated_factorial => 100,
  }

  # Note: No type checking here, although the library code expects the various
  # parameters to be of specific types (boolean, string, etc.). Failure and/or
  # strange behaviour must be expected if they are set to different types.
  def self.setting(name, value = nil)
    name = name.to_sym
    if !@@global_settings.key?(name)
      raise "Setting #{name} does not exist"
    end

    if !value.nil?
      @@global_settings[name] = value
    end

    return @@global_settings[name]
  end

  def self.settings()
    return @@global_settings
  end

  def self.define_equation(exp1, exp2)
    return SyMath::Equation.new(exp1, exp2)
  end

  @@parser = SyMath::Parser.new

  def self.parse(str)
    return @@parser.parse(str)
  end

  @@vector_spaces = {}
  @@default_vector_space = nil

  def self.list_vector_spaces()
    return @@vector_spaces.keys
  end

  def self.register_vector_space(vs)
    if @@vector_spaces.has_key?(vs.name)
      raise "Vector space #{vs.name} already exists"
    end

    @@vector_spaces[vs.name] = vs
  end

  def self.set_default_vector_space(vs)
    if !vs.is_a?(SyMath::VectorSpace)
      vs = self.get_vector_space(vs)
    end

    @@default_vector_space = vs
  end

  def self.get_vector_space(name = nil)
    if name.nil?
      return @@default_vector_space
    else
      return @@vector_spaces[name]
    end
  end

  # Initialize various static data used by the operation
  # modules.
  SyMath::Definition.init_builtin
  SyMath::VectorSpace.initialize
  SyMath::Definition::Constant.initialize
  SyMath::Definition::Trig.initialize
  SyMath::Definition::QLogicGate.initialize
  SyMath::Operation::Differential.initialize
  SyMath::Operation::Integration.initialize
end

require 'symath/vectorspace'
