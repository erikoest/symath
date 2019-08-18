
require 'sy/operation'
require 'sy/operation/evaluation'
require 'sy/operation/normalization'
require 'sy/operation/distributivelaw'
require 'sy/operation/differential'
require 'sy/operation/integration'
require 'sy/operation/exterior'
require 'sy/operation/trigreduction'

module Sy
  class Value
    include Operation::Evaluation
    include Operation::Normalization
    include Operation::DistributiveLaw
    include Operation::TrigReduction
    include Operation::Differential
    include Operation::Integration
    include Operation::Exterior
    
    def deep_clone()
      return Marshal.load(Marshal.dump(self))
    end

    def seek(path, start = 0, stop = nil)
      if path.path.length < start
        raise 'Path start out of range'
      end
      
      if path.path.length == start
        return self
      end

      if !self.is_a?(Sy::Operator)
        raise 'Path not found in expression.'
      end

      sube = self.args[path.path[start]]
      return sube.seek(path, start + 1)
    end

    def replace_subex(path, subex)
      if path.length == 0
        return subex
      end

      argpos = path.pop;
      self.seek(path).args[argpos] = subex

      return self
    end

    # Needed for value objects to be hashable. Subclasses should override this to return a
    # value which tends to be different for unequal objects.
    def hash()
      return 1
    end
    
    # Equality operator. Two expressions are considered equal if they are
    # structurally equal and have the same variable names
    def ==(other)
      return false
    end

    # Sorting/ordering operator. The ordering is used by the normalization to
    # order the parts of a sum, product etc.
    def <=>(other)
      class_order = {
        'Sy::Operator' => 1,
        'Sy::Function' => 2,
        'Sy::Sum' => 3,
        'Sy::Product' => 5,
        'Sy::Fraction' => 6,
        'Sy::Wedge' => 7,
        'Sy::Power' => 8,
        'Sy::Minus' => 9,
        'Sy::Variable' => 10,
        'Sy::ConstantSymbol' => 11,
        'Sy::Number' => 12,
      }

      return class_order[self.class.name] <=> class_order[other.class.name]
    end

    def <(other)
      return (self <=> other) < 0
    end

    def >(other)
      return (self <=> other) > 0
    end

    def <=(other)
      return (self <=> other) <= 0
    end

    def >=(other)
      return (self <=> other) >= 0
    end

    # Returns true if this is a function declaration, a operator declaration or
    # a variable assignment
    def is_definition?()
      # The expression must have an equation at the top node
      return false if !is_a?(Sy::Equation)

      # Is this a variable assigment?
      return true if args[0].is_a?(Sy::Variable)

      # Or an operator or function?
      return false if !args[0].is_a?(Sy::Operator)

      vars = {}

      args[0].args.each do |a|
        # All arguments must be variables
        return false if !a.is_a?(Sy::Variable)
        
        # All argument variables must be unique
        return false if vars.key?(a.name.to_sym)

        vars[a.name.to_sym] = true
      end

      return true
    end

    # Return true if value is constant relative to changes in any of the given
    # set of variables. If no variable set is given, returns true if
    # expression is always constant.
    def is_constant?(vars = nil)
      return true
    end

    # Return all free variables found in the expression
    def variables()
      return []
    end

    # Replaces map of variables with expressions. Overridden by subclasses
    def replace(map)
      return self
    end
    
    ##
    # Compositional math operator methods. No reductions are performed.
    ##
    def add(other)
      return Sy::Sum.new(self, other.to_m)
    end

    def sub(other)
      return Sy::Sum.new(self, Sy::Minus.new(other.to_m))
    end

    def neg()
      return Sy::Minus.new(self)
    end

    def mul(other)
      return Sy::Product.new(self, other.to_m)
    end

    def div(other)
      return Sy::Fraction.new(self, other.to_m)
    end
    
    def power(other)
      return Sy::Power.new(self, other.to_m)
    end

    def wedge(other)
      return Sy::Wedge.new(self, other.to_m)
    end

    ##
    # Overridden object operators.
    # These operations do some simple reductions.
    ##
    def +(other)
      o = other.to_m
      return self if o == 0
      return o if self == 0

      # Is this really a subtraction
      if o.is_a?(Sy::Minus)
        return self - o.argument
      end

      if self.is_a?(Sy::Minus)
        return o - self.argument
      end
      
      s = scalar_factors_exp
      w = vector_factors_exp
      if s == o.scalar_factors_exp and
        w == o.vector_factors_exp
        ret = (coefficient + o.coefficient).to_m
        if s != 1.to_m
          ret *= s
        end

        if w != 1.to_m
          ret = ret.mul(w)
        end
        
        return ret
      end

      return self.add(o)
    end

    def -(other)
      o = other.to_m
      return self if o == 0
      return -o if self == 0

      # Is this really an addition?
      if o.is_a?(Sy::Minus)
        return self + o.argument
      end
      
      s = scalar_factors_exp
      w = vector_factors_exp

      if s == o.scalar_factors_exp and
        w == o.vector_factors_exp        
        ret = (coefficient - o.coefficient).to_m
        return 0.to_m if ret == 0
        if s != 1.to_m
          ret = ret.mul(s)
        end

        if w != 1.to_m
          ret = ret.mul(w)
        end

        return ret
      end

      return self.sub(o)
    end

    def -@()
      if self.is_a?(Sy::Minus)
        # - - a => a
        return self.argument
      else
        return self.neg
      end
    end

    def *(other)
      o = other.to_m

      # First try some simple reductions
      # a*1 => a
      return self if o == 1
      return o if self == 1

      # -a*-b => a*b
      if o.is_a?(Sy::Minus) and self.is_a?(Sy::Minus)
        return argument*o.argument
      end

      # (-a)*b => -(a*b)
      # a*(-b) => -(a*b)
      return -(self*o.argument) if o.is_a?(Sy::Minus)
      return -(self.argument*o) if self.is_a?(Sy::Minus)
      
      if o.is_a?(Sy::Matrix)
        return o*self
      end
      
      if base == o.base
        return base ** (exponent + o.exponent)
      end

      # (1/a)*other => other/a
      if self.is_a?(Sy::Fraction) and dividend == 1.to_m
        return o/divisor
      end

      # self*(1/a) => self*/a
      if o.is_a?(Sy::Fraction) and o.dividend == 1.to_m
        return self/o.divisor
      end
      
      return self.mul(o)
    end

    def /(other)
      o = other.to_m
      return self if o == 1

      if self.is_a?(Sy::Fraction)
        return dividend.div(divisor*o)
      end
      
      return self.div(o)
    end

    def **(other)
      o = other.to_m
      if self.is_a?(Sy::Power)
        return self.base**(self.exponent*o)
      end

      return self.power(o)
    end

    def ^(other)
      o = other.to_m
      return self if o == 1
      return o if self == 1

      w = vector_factors_exp
      ow = o.vector_factors_exp

      if ow == 1
        # Ordinary multiplication
        return self*o
      else
        # Other is a vector. If self is a product, assume vector part
        # is in the second argument, and apply the wedge to it.
        # Hack!
        if self.is_a?(Sy::Product) and !self.is_a?(Sy::Wedge)
          return factor1*(factor2^o)
        else
          return self.wedge(o)
        end
      end
    end

    ##
    # Helper methods for the normalization operation. These are overridden by
    # the subclasses. Default behaviour is defined here.
    ##

    # Value is a sum or unitary minus
    def is_sum_exp?()
      return false
    end

    # Value is a product, fraction or unitary minus
    def is_prod_exp?()
      return false
    end

    # Value is a scalar, i.e. has no vector parts, down to non-sum and non-product
    # functions and operators.
    def is_scalar?()
      return true
    end
    
    # Returns the terms of a sum in an array.
    # Defaults to self for non-sums.
    def terms()
      return [self]
    end

    # Returns the base of a power expression.
    # Defaults to self for non-powers.
    def base()
      return self
    end

    # Returns the exponent of a power expression.
    # Defaults to self for non-powers.
    def exponent()
      return 1.to_m
    end
    
    # Returns the absolute scalar factors of a product in an array.
    # Defaults to self for non-products.
    def scalar_factors()
      return [self].to_enum
    end

    # Returns the absolute factors of a divisor in an array (including vector
    # components.
    # Defaults to nothing for non-fractions.
    def div_factors()
      return [].to_enum
    end
    
    # Return the scalar factors and division factors as an expression.
    def scalar_factors_exp()
      ret = 1.to_m
      scalar_factors.each do |f|
        ret *= f
      end

      d = div_coefficient.to_m
      div_factors.each do |f|
        d *= f
      end
      
      if d != 1.to_m
        ret= ret.div(d)
      end
      
      return ret
    end

    # Return vector factors as an expression
    def vector_factors_exp()
      w = vector_factors.inject(:wedge)
      if (w.nil?)
        return 1.to_m
      else
        return w
      end
    end

    # Return the constant factor of a product
    def coefficient()
      return 1
    end

    # Return constant factor of divisor
    def div_coefficient()
      return 1
    end

    # Return vector factors in an array
    # Defaults to nothing for non-vectors and non-wedge products
    def vector_factors()
      return [].to_enum
    end
    
    # Returns the accumulated sign of a product.
    # Defaults to 1 for positive non-sum expressions.
    def sign()
      return 1
    end

    # By default, assume an unknown expression to be scalar
    def type()
      return 'scalar'.to_t
    end

    alias eql? ==

    def to_m()
      return self
    end
  end
end

class Integer
  alias_method :super_add, :+
  alias_method :super_sub, :-
  alias_method :super_mul, :*
  alias_method :super_div, :/
  alias_method :super_pow, :**
  alias_method :super_wedge, :^
  
  def +(other)
    if other.class.method_defined?(:to_m) and !other.is_a?(Integer)
      return self.to_m + other.to_m
    else
      return self.super_add(other)
    end
  end

  def -(other)
    if other.class.method_defined?(:to_m) and !other.is_a?(Integer)
      return self.to_m - other.to_m
    else
      return self.super_sub(other)
    end
  end

  def *(other)
    if other.class.method_defined?(:to_m) and !other.is_a?(Integer)
      return self.to_m*other.to_m
    else
      return self.super_mul(other)
    end
  end

  def /(other)
    if other.class.method_defined?(:to_m) and !other.is_a?(Integer)
      return self.to_m/other.to_m
    else
      return self.super_div(other)
    end
  end

  def **(other)
    if other.class.method_defined?(:to_m)  and !other.is_a?(Integer)
      return self.to_m**other.to_m
    else
      return self.super_pow(other)
    end
  end

  def ^(other)
    if other.class.method_defined?(:to_m)  and !other.is_a?(Integer)
      return self.to_m^other.to_m
    else
      return self.super_wedge(other)
    end
  end
end

class Symbol
  def +(other)
    if other.class.method_defined?(:to_m)
      return self.to_m + other.to_m
    else
      return super(other)
    end
  end

  def -(other)
    if other.class.method_defined?(:to_m)
      return self.to_m - other.to_m
    else
      return super(other)
    end
  end

  def -@()
    return - self.to_m
  end

  def *(other)
    if other.class.method_defined?(:to_m)
      return self.to_m*other.to_m
    else
      return super(other)
    end
  end

  def /(other)
    if other.class.method_defined?(:to_m)
      return self.to_m/other.to_m
    else
      return super(other)
    end
  end

  def **(other)
    if other.class.method_defined?(:to_m)
      return self.to_m**other.to_m
    else
      return super(other)
    end
  end

  def ^(other)
    if other.class.method_defined?(:to_m)
      return self.to_m^other.to_m
    else
      return super(other)
    end
  end
end

