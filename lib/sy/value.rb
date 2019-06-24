module Sy
  class Value
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
    
    def hash()
      return 1
    end
    
    # Equality operator. Two expressions are considered equal if they are structurally
    # equal and have the same variable names
    def ==(other)
      return false
    end

    # Sorting/ordering operator. The ordering is used by the normalization to order the
    # parts of a sum, product etc.
    def <=>(other)
      class_order = {
        'Sy::Number' => 1,
        'Sy::ConstantSymbol' => 2,
        'Sy::Variable' => 3,
        'Sy::Minus' => 4,
        'Sy::Power' => 5,
        'Sy::Fraction' => 6,
        'Sy::Product' => 7,
        'Sy::Subtraction' => 8,
        'Sy::Sum' => 9,
        'Sy::Function' => 10,
        'Sy::Operator' => 11,
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
    
    # Return true if value is constant relative to changes in any of the given set of
    # variables. If no variable set is given, returns true if expression is alawys
    # constant.
    def is_constant?(vars = nil)
      return true
    end

    # Return all free variables found in the expression
    def variables()
      return []
    end
    
    def replace(var, exp)
      raise "Don't know how to replace a " + self.class.name
    end
    
    ##
    # Overridden math operators
    # These operators are only used for composing expression. No reductions are
    # performed.
    ##
    def +(other)
      return Sy::Sum.new(self, other.to_m)
    end

    def -(other)
      return Sy::Subtraction.new(self, other.to_m)
    end

    def -@()
      return Sy::Minus.new(self)
    end

    def *(other)
      return Sy::Product.new(self, other.to_m)
    end

    def /(other)
      return Sy::Fraction.new(self, other.to_m)
    end
    
    def **(other)
      return Sy::Power.new(self, other.to_m)
    end

    def ^(other)
      return Sy::Wedge.new(self, other.to_m)
    end

    ##
    # Math operations with simple reductions.
    ##
    def add(other)
      o = other.to_m
      return self if o == 0
      return o if self == 0

      noc = self.abs_factors_exp
      if noc == o.abs_factors_exp
        c2 = self.coefficient + o.coefficient
        return noc == 1.to_m ? c2.to_m : c2*noc
      end

      return self + o
    end

    def sub(other)
      o = other.to_m
      return self if o == 0
      return -o if self == 0

      noc = self.abs_factors_exp
      if noc == other.abs_factors_exp
        c2 = self.coefficient + other.coefficient
        return 0.to_m if c2 == 0
        return noc == 1.to_m ? c2.to_m : c2*noc
      end

      return self - o
    end
    
    def mult(other)
      o = other.to_m
      return self if o == 1
      return o if self == 1

      if base == o.base
        return base ** (exponent + o.exponent)
      end

      if self.is_a?(Sy::Fraction) and dividend == 1.to_m
        return o / divisor
      end

      if o.is_a?(Sy::Fraction) and o.dividend == 1.to_m
        return self / o.divisor
      end
      
      return self * o
    end

    def div(other)
      o = other.to_m
      return self if o == 1

      if self.is_a?(Sy::Fraction)
        return dividend / (divisor * o)
      end
      
      return self / o
    end

    def power(other)
      o = other.to_m
      if self.is_a?(Sy::Power)
        return self.base.power(self.exponent.mult(o))
      end

      return self**o
    end
    
    def wedge(other)
      o = other.to_m
      return self if o == 1
      return o if self == 1

      if base == o.base
        return base ** (exponent + o.exponent)
      end

      if self.is_a?(Sy::Fraction) and dividend == 1.to_m
        return o / divisor
      end

      if o.is_a?(Sy::Fraction) and o.dividend == 1.to_m
        return self / o.divisor
      end
      
      return self ^ o
    end

    ##
    # Helper methods for the normalization operation. These are overridden by the
    # subclasses. Default behaviour is defined here.
    ##

    # Value is a sum, subtraction of unitary minus
    def is_sum_exp?()
      return false
    end

    # Value is a product, fraction or unitary minus
    def is_prod_exp?()
      return false
    end
    
    # Returns the positive elements of a sum in an array.
    # Defaults to self for non-sums.
    def summands()
      return [self]
    end

    # Returns the negative elements of a sum in an array.
    # Defaults to nothing for non-sums.
    def subtrahends()
      return []
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
    
    # Return the non-constant factors and division factors of the expression.
    def abs_factors_exp()
      return self
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

    def type()
      return type('unknown')
    end

    alias eql? ==

    def to_str()
      return to_s
    end

    def to_m()
      return self
    end
  end
end
