module Sy
  def self.value(val)
    return val if val.is_a?(Sy::Value)
    if val.is_a?(Integer)
      if val >= 0
        return val.to_m
      else
        return -val.to_m
      end
    end

    if val.is_a?(String) or val.is_a?(Symbol)
      return val.to_m
    end

    raise sprintf("Cannot convert %s to a Sy::Value", val.class)
  end

  class Value
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
    
    # Equality operator. Two expressions are considered equal if they are structurally equal and
    # have the same variable names
    def ==(other)
      return false
    end

    # Sorting/ordering operator. The ordering is used by the normalization to order the parts of a
    # sum, product etc.
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
    
    # Return true if value is constant relative to changes in any of the given set of variables.
    # If no variable set is given, returns true if expression is alawys constant.
    def is_constant?(vars = nil)
      return true
    end

    # Return all free variables found in the expression
    def variables()
      return [].to_set
    end
    
    ##
    # Overridden math operators
    ##    
    def +(other)
      return Sy::Sum.new(self, Sy.value(other))
    end

    def -(other)
      return Sy::Subtraction.new(self, Sy.value(other))
    end

    def -@()
      return Sy::Minus.new(self)
    end

    def *(other)
      return Sy::Product.new(self, Sy.value(other))
    end

    def /(other)
      return Sy::Fraction.new(self, Sy.value(other))
    end
    
    def **(other)
      return Sy::Power.new(self, Sy.value(other))
    end

    ##
    # Helper methods for the normalization operation. These are overridden by the subclasses. Default
    # behaviour is defined here.
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
    def summands_to_a()
      return [self]
    end

    # Returns the negative elements of a sum in an array.
    # Defaults to nothing for non-sums.
    def subtrahends_to_a()
      return []
    end

    # Returns the absolute factors of a product in an array.
    # Defaults to self for non-products.
    def abs_factors_to_a()
      return [self]
    end

    # Returns the absolute factors of a divisor in an array.
    # Defaults to nothing for non-fractions.
    def div_factors_to_a()
      return []
    end

    # Return the expression stripped of the coefficient
    # Defaults to self for all non-products
    def coefficientless()
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
    
    # Returns the accumulated sign of a product.
    # Defaults to 1 for positive non-sum expressions.
    def sign()
      return 1
    end

    alias eql? ==

    def to_str
      return to_s
    end
  end
end
