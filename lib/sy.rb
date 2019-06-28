require "sy/version"
require "sy/parser"

require 'sy/type'
require 'sy/function'
require 'sy/sum'
require 'sy/subtraction'
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
require 'sy/operation'
require 'sy/path'

module Sy
  @@global_settings = {
    # Symbol used by parser and to_s/to_latex methods to represent the differential
    # operator on variables
    :diff_symbol => 'd',
    # Symbol used by parser and to_s method to represent vector variables
    :vector_symbol => '''',
    # Boolean setting for whether to represent square roots with the root symbol
    # or as a fraction exponent
    :sq_exponent_form => false,
  }
  
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

    # Row matrix of variable names used as the coordinates in differential geometry
    # analyses. These define the dimension of the manifold, and also as the default names
    # of the basis vectors and co-vectors of the tangent space.
    :basis.to_m => [:x1.to_m, :x2.to_m, :x3.to_m].to_m,

    # Metric tensor, relative to the chosen basis.
    :g.to_m => [[1.to_m, 0.to_m, 0.to_m],
                [0.to_m, 1.to_m, 0.to_m],
                [0.to_m, 0.to_m, 1.to_m]].to_m,
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
    return @@variable_assignments[var]
  end

  def self.assign_variable(var, value)
    # Check that name is a variable
    if !var.is_a?(Sy::Variable)
      raise var.to_s + ' is not a variable'
    end

    if !value.is_a?(Sy::Value)
      raise value.to_s + ' is not a Sy::Value'
    end
    
    @@variable_assignments[var] = value
  end

  def self.clear_variable(var)
    @@variable_assignments.delete(var)
  end

  def self.clear_variables()
    @@variable_assignments.keys.each do |v|
      next if @@special_variables.key?(v.name.to_sym)
      
      @@variable_assignments.delete(v)
    end
  end
end
