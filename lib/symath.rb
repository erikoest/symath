require "symath/version"
require "symath/parser"

require 'symath/type'
require 'symath/operator'
require 'symath/sum'
require 'symath/minus'
require 'symath/product'
require 'symath/wedge'
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
    # Symbol used to represent the differential operator
    # on variables
    :d_symbol => 'd',
    # Symbol used to represent vector variables
    :vector_symbol => '\'',
    # Symbol used to represent covector variables
    :covector_symbol => '.',

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
  
  @@special_variables = {
    :basis.to_m => 1,
    :g.to_m => 1,
  }

  @@variable_assignments = {
    # Some variables with special meanings

    # Row matrix of variable names used as the coordinates in differential
    # geometry analyses. These define the dimension of the manifold, and
    # also as the default names of the basis vectors and co-vectors of the
    # tangent space.
    :basis.to_m => [:x1, :x2, :x3].to_m,

    # Metric tensor, relative to the chosen basis (subscript indexes)
    :g.to_m => [[1, 0, 0],
                [0, 1, 0],
                [0, 0, 1]].to_m,
  }

  def self.define_equation(exp1, exp2)
    return SyMath::Equation.new(exp1, exp2)
  end

  def self.get_variables()
    return @@variable_assignments
  end

  def self.get_variable(var)
    return @@variable_assignments[var.to_m]
  end

  def self.assign_variable(var, value)
    var = var.to_m
    value = value.to_m
    
    # Check that name is a variable
    if !var.is_a?(SyMath::Definition::Variable)
      raise "#{var} is not a variable"
    end

    if !value.is_a?(SyMath::Value)
      raise "#{value} is not a SyMath::Value"
    end
    
    @@variable_assignments[var] = value

    # Re-calculate basis vectors if the basis or the metric tensor
    # changes
    if var.name.to_sym == :g or var.name.to_sym == :basis
      SyMath::Definition::Variable.recalc_basis_vectors
    end
  end

  def self.set_metric(g, basis = nil)
    @@variable_assignments[:g.to_m] = g
    if !basis.nil?
      @@variable_assignments[:basis.to_m] = basis
    end

    SyMath::Definition::Variable.recalc_basis_vectors
  end

  def self.clear_variable(var)
    @@variable_assignments.delete(var.to_m)
  end

  @@parser = SyMath::Parser.new

  def self.parse(str)
    return @@parser.parse(str)
  end

  # Initialize various static data used by the operation
  # modules.
  SyMath::Definition.init_builtin
  SyMath::Definition::Trig.initialize
  SyMath::Operation::Differential.initialize
  SyMath::Operation::Integration.initialize

  # Calculate basis vectors on startup
  SyMath::Definition::Variable.recalc_basis_vectors
end
