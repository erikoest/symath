require "sy/version"
require "sy/parser"

require 'sy/type'
require 'sy/function'
require 'sy/operator'
require 'sy/diff'
require 'sy/int'
require 'sy/bounds'
require 'sy/sharp'
require 'sy/flat'
require 'sy/hodge'
require 'sy/grad'
require 'sy/curl'
require 'sy/div'
require 'sy/laplacian'
require 'sy/codiff'
require 'sy/sum'
require 'sy/minus'
require 'sy/product'
require 'sy/wedge'
require 'sy/fraction'
require 'sy/power'
require 'sy/variable'
require 'sy/constantsymbol'
require 'sy/number'
require 'sy/value'
require 'sy/matrix'
require 'sy/equation'
require 'sy/diff'
require 'sy/poly'
require 'sy/poly/dup'
require 'sy/poly/galois'
require 'sy/path'

module Sy
  @@global_settings = {
    # Symbol used to represent the differential operator
    # on variables
    :diff_symbol => 'd',
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

    # Use complex arithmetic. Negative square roots are reduced to i*square root
    # of the positive part. The complex infinity is used rather than the
    # positive and negative real infinities.
    :complex_arithmetic => true,

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
  
  @@function_definitions = {
  }

  @@operator_definitions = {
  }

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

  def self.get_functions()
    return @@function_definitions
  end

  def self.get_function(f)
    return @@function_definitions[f]
  end
  
  def self.define_function(definition, exp)
    # Definition must be a function
    if !definition.is_a?(Sy::Function)
      raise definition.to_s + ' is not a function'
    end

    vars = {}
    definition.args.each do |a|
      # Each argument must be a variable
      if !a.is_a?(Sy::Variable)
        raise 'Function argument ' + a.to_s + ' is not a variable'
      end
      
      # All variables must be different
      if vars.key?(a.name.to_sym)
        raise 'Variable ' + a.to_s + ' occurs multiple times'
      end

      vars[a.name.to_sym] = true
    end

    if !exp.is_a?(Sy::Value)
      raise exp.to_s + ' is not a Sy::Value'
    end

    @@function_definitions[definition.name.to_sym] = {
      :definition => definition,
      :expression => exp,
    }
  end

  def self.clear_function(name)
    @@function_definitions.delete(name.to_sym)
  end

  def self.get_operators()
    return @@operator_definitions
  end

  def self.get_operator(o)
    return @@operator_definitions[o]
  end

  def self.define_operator(definition, exp)
    # Each argument must be a variable
    if !definition.is_a?(Sy::Operator)
      raise definition.to_s + ' is not a function'
    end
    
    vars = {}
    definition.args.each do |a|
      # Each argument must be a variable
      if !a.is_a?(Sy::Variable)
        raise 'Function argument ' + a.to_s + ' is not a variable'
      end
      
      # All variables must be different
      if vars.key?(a.name.to_sym)
        raise 'Variable ' + a.to_s + ' occurs multiple times'
      end

      vars[a.name.to_sym] = true
    end
    
    if !exp.is_a?(Sy::Value)
      raise exp.to_s + ' is not a Sy::Value'
    end

    @@operator_definitions[definition] = {
      definition => definition,
      expression => exp,
    }
  end

  def self.clear_operator(name)
    @@opertor_definitions[name.to_sym]
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
    if !var.is_a?(Sy::Variable)
      raise var.to_s + ' is not a variable'
    end

    if !value.is_a?(Sy::Value)
      raise value.to_s + ' is not a Sy::Value'
    end
    
    @@variable_assignments[var] = value

    # Re-calculate basis vectors if the basis or the metric tensor
    # changes
    if var.name.to_sym == :g or var.name.to_sym == :basis
      Sy::Variable.recalc_basis_vectors
    end
  end

  def self.set_metric(g, basis = nil)
    @@variable_assignments[:g.to_m] = g
    if !basis.nil?
      @@variable_assignments[:basis.to_m] = basis
    end

    Sy::Variable.recalc_basis_vectors
  end

  def self.clear_variable(var)
    @@variable_assignments.delete(var.to_m)
  end

  def self.clear_variables()
    @@variable_assignments.keys.each do |v|
      next if @@special_variables.key?(v.name.to_sym)
      
      @@variable_assignments.delete(v)
    end
  end

  @@parser = Sy::Parser.new

  def self.parse(str)
    return @@parser.parse(str)
  end

  # Calculate basis vectors on startup
  Sy::Variable.recalc_basis_vectors

  # Initialize various static data used by the operation
  # modules.
  Sy::Operation::Differential.initialize
  Sy::Operation::Integration.initialize
  Sy::Function::Trig.initialize
end

class String
  def to_mexp()
    return Sy.parse(self)
  end
end
