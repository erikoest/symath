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
        'Sy::Subtraction' => 4,
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
    # Overridden math operators
    # These operators are purely compositional. No reductions are performed.
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

      # Is this really a subtraction
      if o.is_a?(Sy::Minus)
        return sub(o.args[0])
      end

      if self.is_a?(Sy::Minus)
        return o.sub(self.args[0])
      end
      
      s = scalar_factors_exp
      w = vector_factors_exp
      if s == o.scalar_factors_exp and
        w == o.vector_factors_exp
        ret = (coefficient + o.coefficient).to_m
        if s != 1.to_m
          ret.mult(s)
        end

        if w != 1.to_m
          ret *= w
        end
        
        return ret
      end

      return self + o
    end

    def sub(other)
      o = other.to_m
      return self if o == 0
      return o.minus if self == 0

      # Is this really an addition?
      if o.is_a?(Sy::Minus)
        return self.add(o.args[0])
      end
      
      s = scalar_factors_exp
      w = vector_factors_exp

      if s == other.scalar_factors_exp and
        w == other.vector_factors_exp        
        ret = (coefficient - other.coefficient).to_m
        return 0.to_m if ret == 0
        if s != 1.to_m
          ret.mult(s)
        end

        if w != 1.to_m
          ret *= w
        end

        return ret
      end

      return self - o
    end
    
    def minus()
      if self.is_a?(Sy::Minus)
        # - - a => a
        return self.args[0]
      else
        return - self
      end
    end

    def mult(other)
      o = other.to_m

      # First try some simple reductions
      # a*1 => a
      return self if o == 1
      return o if self == 1

      # -a*-b => a*b
      if o.is_a?(Sy::Minus) and self.is_a?(Sy::Minus)
        return args[0].mult(o.args[0])
      end

      # (-a)*b => -(a*b)
      # a*(-b) => -(a*b)
      return self.mult(o.args[0]).minus if o.is_a?(Sy::Minus)
      return self.args[0].mult(o).minus if self.is_a?(Sy::Minus)
      
      if o.is_a?(Sy::Matrix)
        return o.mult(self)
      end
      
      if base == o.base
        return base ** (exponent.add(o.exponent))
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
    # Helper methods for the normalization operation. These are overridden by
    # the subclasses. Default behaviour is defined here.
    ##

    # Value is a sum, subtraction of unitary minus
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
    
    # Return the scalar factors and division factors as an expression.
    def scalar_factors_exp()
      ret = 1.to_m
      scalar_factors.each do |f|
        ret = ret.mult(f)
      end

      d = div_coefficient.to_m
      div_factors.each do |f|
        d = d.mult(f)
      end
      
      if d != 1.to_m
        ret /= d
      end
      
      return ret
    end

    # Return vector factors as an expression
    def vector_factors_exp()
      w = vector_factors.inject(:^)
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

    def normalize()
      return @@actions[:norm].act(self)
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
