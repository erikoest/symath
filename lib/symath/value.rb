require 'symath/operation'
require 'symath/operation/match'
require 'symath/operation/normalization'
require 'symath/operation/distributivelaw'
require 'symath/operation/differential'
require 'symath/operation/integration'
require 'symath/operation/exterior'

module SyMath
  class Value
    include Operation::Match
    include Operation::Normalization
    include Operation::DistributiveLaw
    include Operation::Differential
    include Operation::Integration
    include Operation::Exterior
    
    @@class_order = [
      'SyMath::Definition::Number',
      'SyMath::Definition::Constant',
      'SyMath::Definition::Variable',
      'SyMath::Definition::Function',
      'SyMath::Definition::Operator',
      'SyMath::Definition',
      'SyMath::Minus',
      'SyMath::Power',
      'SyMath::Wedge',
      'SyMath::Fraction',
      'SyMath::Product',
      'SyMath::Sum',
      'SyMath::Operator',
    ]

    @@class_order_hash = {}

    @@class_order.each_with_index do |e, i|
      @@class_order_hash[e] = i
    end

    def self.create(definition, *args)
      if !definition.is_a?(SyMath::Value)
        definition = SyMath::Definition.get(definition)
      end
      
      if SyMath.setting(:compose_with_simplify)
        return self.compose_with_simplify(definition, *args)
      else
        return self.new(definition, *args)
      end
    end

    # Compose with simplify. Defaults to composition with no reductions
    def self.compose_with_simplify(*args)
      return self.new(*args)
    end
    
    def deep_clone()
      return Marshal.load(Marshal.dump(self))
    end

    # Sorting/ordering operator. The ordering is used by the normalization to
    # order the parts of a sum, product etc.
    def <=>(other)
      return @@class_order_hash[self.class.name] <=>
        @@class_order_hash[other.class.name]
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

    # Default properties for operators
    # Note: Returning nil here means neither true or false, but unknown.
    def is_nan?()
      return
    end

    def is_finite?()
      return
    end

    def is_positive?()
      return
    end

    def is_negative?()
      if is_nan?
        return false
      end

      return (is_positive? == false and is_zero? == false)
    end

    def is_number?()
      return false
    end

    def is_negative_number?()
      return false
    end
    
    def is_zero?()
      return
    end

    def is_divisor_factor?()
      return false
    end

    def is_unit_quaternion?()
      return false
    end

    # Reduce expression if possible. Defaults to no reduction
    def reduce()
      return self
    end

    # Evaluate expression. Defaults to no evaluation
    def evaluate()
      return self
    end

    ##
    # Compositional math operator methods. No reductions are performed.
    ##
    def add(other)
      return SyMath::Sum.new(self, other.to_m)
    end

    def sub(other)
      return SyMath::Sum.new(self, SyMath::Minus.new(other.to_m))
    end

    def neg()
      return SyMath::Minus.new(self)
    end

    def mul(other)
      return SyMath::Product.new(self, other.to_m)
    end

    def div(other)
      return SyMath::Fraction.new(self, other.to_m)
    end
    
    def power(other)
      return SyMath::Power.new(self, other.to_m)
    end

    def wedge(other)
      return SyMath::Wedge.new(self, other.to_m)
    end

    ##
    # Overridden object operators.
    # These operations do some simple reductions.
    ##
    def +(other)
      return SyMath::Sum.create(self, other)
    end

    def -(other)
      return self + (- other)
    end

    def -@()
      return SyMath::Minus.create(self)
    end

    def *(other)
      return SyMath::Product.create(self, other)
    end

    def /(other)
      return SyMath::Fraction.create(self, other)
    end

    def inv()
      return 1/self
    end
    
    def **(other)
      return SyMath::Power.create(self, other)
    end

    def ^(other)
      # Identical with *. We apply * or ^ depending on what
      # the arguments are.
      return self*other
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
    
    # Return factors in enumerator
    def factors()
      return [self].to_enum
    end

    # Returns the accumulated sign of a product.
    # Defaults to 1 for positive non-sum expressions.
    def sign()
      return 1
    end

    # Simple reduction rules, allows sign to change. Returns
    # (reduced exp, sign, changed). Defaults to no change
    def reduce_modulo_sign
      return self, 1, false
    end

    # By default, assume an unknown expression to be scalar
    def type()
      return 'scalar'.to_t
    end

    alias eql? ==

    def to_m()
      return self
    end

    def inspect()
      if SyMath.setting(:inspect_to_s)
        return self.to_s
      else
        return super.inspect
      end
    end

    def dump(indent = 0)
      i = ' '*indent
      return "#{i}#{self.class}: #{self}"
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
    return self.to_m + other.to_m
  end

  def -(other)
    return self.to_m - other.to_m
  end

  def -@()
    return - self.to_m
  end

  def *(other)
    return self.to_m*other.to_m
  end

  def /(other)
    return self.to_m/other.to_m
  end

  def **(other)
    return self.to_m**other.to_m
  end

  def ^(other)
    return self.to_m^other.to_m
  end
end

class String
  def to_m()
    return SyMath.parse(self)
  end
end
