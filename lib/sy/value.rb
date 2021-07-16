require 'sy/operation'
require 'sy/operation/match'
require 'sy/operation/normalization'
require 'sy/operation/distributivelaw'
require 'sy/operation/differential'
require 'sy/operation/integration'
require 'sy/operation/exterior'

module Sy
  class Value
    include Operation::Match
    include Operation::Normalization
    include Operation::DistributiveLaw
    include Operation::Differential
    include Operation::Integration
    include Operation::Exterior
    
    @@class_order = [
      'Sy::Number',
      'Sy::ConstantSymbol',
      'Sy::Variable',
      'Sy::Minus',
      'Sy::Power',
      'Sy::Wedge',
      'Sy::Fraction',
      'Sy::Product',
      'Sy::Sum',
      'Sy::Function::Abs',
      'Sy::Function::Arccos',
      'Sy::Function::Arcosh',
      'Sy::Function::Arccot',
      'Sy::Function::Arcoth',
      'Sy::Function::Arccsc',
      'Sy::Function::Arcsch',
      'Sy::Function::Arcsec',
      'Sy::Function::Arsech',
      'Sy::Function::Arcsin',
      'Sy::Function::Arsinh',
      'Sy::Function::Arctan',
      'Sy::Function::Artanh',
      'Sy::Function::Cos',
      'Sy::Function::Cosh',
      'Sy::Function::Cot',
      'Sy::Function::Coth',
      'Sy::Function::Csc',
      'Sy::Function::Csch',
      'Sy::Function::Exp',
      'Sy::Function::Fact',
      'Sy::Function::Ln',
      'Sy::Function::Sec',
      'Sy::Function::Sech',
      'Sy::Function::Sin',
      'Sy::Function::Sinh',
      'Sy::Function::Sqrt',
      'Sy::Function::Tan',
      'Sy::Function::Tanh',
      'Sy::Function',
      'Sy::Operator',
    ]

    @@class_order_hash = {}

    @@class_order.each_with_index do |e, i|
      @@class_order_hash[e] = i
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

    # Add infinite values
    def add_inf(o)
      # Indefinite terms
      if self.is_finite?.nil? or o.is_finite?.nil?
        return self.add(o)
      end
      
      # NaN add to NaN
      if self.is_nan? or o.is_nan?
        return :NaN.to_m
      end

      if Sy.setting(:complex_arithmetic)
        # +- oo +- oo = NaN
        if (self.is_finite? == false and o.is_finite? == false)
          return :NaN.to_m
        end

        # oo + n = n + oo = NaN
        if (self.is_finite? == false or o.is_finite? == false)
          return :oo.to_m
        end
      else
        # oo - oo = -oo + oo = NaN
        if (self.is_finite? == false and o.is_finite? == false)
          if (self.is_positive? and o.is_negative?) or
            (self.is_negative? and o.is_positive?)
            return :NaN.to_m
          end
        end

        # oo + n = n + oo = oo + oo = oo
        if self.is_finite? == false
          return self
        end

        # n - oo = - oo + n = -oo - oo = -oo
        if o.is_finite? == false
          return o
        end
      end

      # :nocov:
      raise 'Internal error'
      # :nocov:
    end

    # Sub infinite values
    def sub_inf(o)
      # Indefinite terms
      if self.is_finite?.nil? or o.is_finite?.nil?
        return self.sub(o)
      end

      # NaN subtracts to NaN
      if self.is_nan? or o.is_nan?
        return :NaN.to_m
      end

      if Sy.setting(:complex_arithmetic)
        # +- oo +- oo = NaN
        if (self.is_finite? == false and o.is_finite? == false)
          return :NaN.to_m
        end

        # oo + n = n + oo = oo
        if (self.is_finite? == false or o.is_finite? == false)
          return :oo.to_m
        end
      else
        # oo - oo = -oo + oo = NaN
        if (self.is_finite? == false and o.is_finite? == false)
          if (self.is_positive? and o.is_positive?) or
            (self.is_negative? and o.is_negative?)
            return :NaN.to_m
          end
        end

        # oo + n = oo + oo = oo
        # -oo + n = -oo - oo = -oo
        if self.is_finite? == false
          return self
        end
        
        # n - oo = -oo
        # n + oo = oo
        if o.is_finite? == false
          return -o
        end
      end

      # :nocov:
      raise 'Internal error'
      # :nocov:
    end
    
    # Multiply infinite values
    def mul_inf(o)
      # Indefinite factors
      if self.is_finite?.nil? or o.is_finite?.nil?
        return self.mul(o)
      end

      # NaN multiplies to NaN
      if self.is_nan? or o.is_nan?
        return :NaN.to_m
      end

      # oo*0 = 0*oo = NaN
      if self.is_zero? or o.is_zero?
        return :NaN.to_m
      end

      if Sy.setting(:complex_arithmetic)
        return :oo.to_m
      else
        if (self.is_positive? and o.is_positive?) or
          (self.is_negative? and o.is_negative?)
          return :oo.to_m
        end

        if (self.is_negative? and o.is_positive?) or
          (self.is_positive? and o.is_negative?)
          return -:oo.to_m
        end
      end
      
      # :nocov:
      raise 'Internal error'
      # :nocov:
    end

    # Divide infinite values
    def div_inf(o)
      # Indefinite factors
      if self.is_finite?.nil? or o.is_finite?.nil?
        return self.div(o)
      end

      # NaN/* = */NaN = NaN
      if self.is_nan? or o.is_nan?
        return :NaN.to_m
      end
      
      # oo/oo = oo/-oo = -oo/oo = NaN
      if self.is_finite? == false and o.is_finite? == false
        return :NaN.to_m
      end

      # */0 = NaN
      if o.is_zero?
        if Sy.setting(:complex_arithmetic)
          return :oo.to_m
        else
          return :NaN.to_m
        end
      end

      # n/oo = n/-oo = 0
      if self.is_finite?
        return 0.to_m
      end

      # oo/n = -oo/-n = oo, -oo/n = oo/-n = -oo
      if o.is_finite?
        if Sy.setting(:complex_arithmetic)
          return :oo.to_m
        else
          if self.sign == o.sign
            return :oo.to_m
          else
            return -:oo.to_m
          end
        end
      end

      # :nocov:
      raise 'Internal error'
      # :nocov:
    end

    # Power of infinite values
    def power_inf(o)
      # Indefinite factors
      if self.is_finite?.nil? or o.is_finite?.nil?
        return self.power(o)
      end

      # NaN**(..) = NaN, (..)**NaN = NaN
      if self.is_nan? or o.is_nan?
        return :NaN.to_m
      end

      # 1**oo = 1**-oo = oo**0 = -oo**0 = NaN
      if self == 1 or o.is_zero?
        return :NaN.to_m
      end

      if Sy.setting(:complex_arithmetic)
        if o.is_finite? == false
          return :NaN.to_m
        else
          return :oo.to_m
        end
      else
        if self.is_zero? and o.is_finite? == false
          return :NaN.to_m
        end

        # n**-oo = oo**-oo = -oo**-oo = 0
        if o.is_finite? == false and o.is_negative?
          return 0.to_m
        end
        
        if self.is_finite? == false and self.is_negative?
          if o.is_finite? == true
            # -oo*n = oo*(-1**n)
            return :oo.to_m.mul(self.sign**o)
          else
            # -oo**oo = NaN
            return :NaN.to_m
          end
        end

        # -n**oo => NaN
        if self.is_finite? and self.is_negative?
          return :NaN.to_m
        end
        
        # The only remaining possibilities:
        # oo**n = n*oo = oo*oo = oo
        return :oo.to_m
      end
    end
    
    ##
    # Overridden object operators.
    # These operations do some simple reductions.
    ##
    def +(other)
      if other.is_a?(Sy::Equation)
        return eq(self + other.args[0], self + other.args[1])
      end

      o = other.to_m

      if !Sy.setting(:compose_with_simplify)
        return self.add(o)
      end

      if is_finite?() == false or o.is_finite?() == false
        return self.add_inf(o)
      end
      
      return self if o == 0
      return o if self == 0

      sc = 1
      sf = []
      oc = 1
      of = []

      factors.each do |f|
        if f == -1
          sc *= -1
        elsif f.is_number?
          sc *= f.value
        else
          sf.push f
        end
      end

      o.factors.each do |f|
        if f == -1
          oc *= -1
        elsif f.is_number?
          oc *= f.value
        else
          of.push f
        end
      end
      
      sc += oc

      if sf == of
        if sc == 0
          return 0.to_m
        end

        if sc != 1
          sf.unshift sc.to_m
        end

        return sf.empty? ? 1.to_m : sf.inject(:*)
      end

      return self.add(o)
    end

    def inv()
      return 1/self
    end
    
    def -(other)
      if other.is_a?(Sy::Equation)
        return eq(self - other.args[0], self - other.args[1])
      end

      o = other.to_m

      if !Sy.setting(:compose_with_simplify)
        return self.sub(o)
      end
      
      if is_finite?() == false or o.is_finite?() == false
        return self.sub_inf(o)
      end
      
      return self + -1.to_m*o
    end

    def -@()
      if !Sy.setting(:compose_with_simplify)
        return self.neg
      end

      if self == 0
        return self
      end
      
      if self.is_a?(Sy::Minus)
        # - - a => a
        return self.argument
      else
        return self.neg
      end
    end

    def *(other)
      if other.is_a?(Sy::Equation)
        return eq(self * other.args[0], self * other.args[1])
      end

      o = other.to_m

      if !Sy.setting(:compose_with_simplify)
        return self.mul(o)
      end

      if is_finite?() == false or o.is_finite?() == false
        return self.mul_inf(o)
      end
      
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
        return self.mul(o)
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

      if self.type.is_subtype?(:tensor) and o.type.is_subtype?(:tensor)
        # Expand expression if any of the parts are sum
        if o.is_sum_exp?
          return o.terms.map { |f| self.*(f) }.inject(:+)
        end

        if self.is_sum_exp?
          return terms.map { |f| f.wedge(o) }.inject(:+)
        end
        
        return self.wedge(o)
      end
      
      return self.mul(o)
    end

    def /(other)
      o = other.to_m

      if !Sy.setting(:compose_with_simplify)
        return self.div(o)
      end
      
      return self if o == 1

      if is_finite?() == false or o.is_finite?() == false
        return self.div_inf(o)
      end
      
      # Divide by zero
      if o.is_zero?
        if Sy.setting(:complex_arithmetic)
          if self.is_zero?
            return :NaN.to_m
          else
            return :oo.to_m
          end
        else
          return :NaN.to_m
        end
      end

      if self.is_a?(Sy::Fraction)
        if o.is_a?(Sy::Fraction)
          return (dividend*o.divisor).div(divisor*o.dividend)
        else
          return dividend.div(divisor*o)
        end
      elsif o.is_a?(Sy::Fraction)
        return (self*o.divisor).div(o.dividend)
      end
      
      return self.div(o)
    end

    def **(other)
      o = other.to_m

      if !Sy.setting(:compose_with_simplify)
        return self.power(o)
      end
      
      if is_finite?() == false or o.is_finite?() == false
        return self.power_inf(o)
      end
            
      # 0**0 = NaN
      if self.is_zero? and o.is_zero?
        return :NaN.to_m
      end

      # n**1 = n
      if o == 1
        return self
      end
      
      if self.is_a?(Sy::Power)
        return self.base**(self.exponent*o)
      end

      return self.power(o)
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

