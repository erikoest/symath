require 'sy/operation'
require 'prime'

module Sy::Operation::Normalization
  include Sy::Operation
  
  # This operation provides an expression object with the normalize() method
  # which normalizes an expression:
  #
  #   equal arguments of a product are contracted to integer powers
  #   arguments of a product are sorted
  #
  #   equal arguments of a sum (with subtractions) are contracted to integer
  #   products arguments in a sum are sorted
  #   subtractive elements are put after the additive elements
  #
  #   vector parts are factorized out of sums
  #
  #   integer sums are calculated
  #   integer products are calculated
  #
  #   fractions of integers are simplified as far as possible
  #
  # The operation is repeated until the expression is no longer changed

  def normalize()
    return iterate('normalize_single_pass')
  end

  def normalize_single_pass()
    if is_sum_exp?
      return normalize_sum
    end

    if is_prod_exp?
      return normalize_product
    end

    if is_a?(Sy::Power)
      return normalize_power
    end
      
    if is_a?(Sy::Matrix)
      return normalize_matrix
    end

    return act_subexpressions('normalize')
  end

  def normalize_sum()
    # Get normalized terms
    terms = self.terms.map do |e|
      if e.is_a?(Sy::Minus)
        e.argument.normalize.neg
      else
        e.normalize
      end
    end

    # Collect equal elements into integer products
    # Vector parts are factorized out
    
    # Hash: product[vector part][scalar part]
    products = {}

    terms.each do |e|
      w = e.vector_factors_exp
      if !products.key?(w)
        products[w] = {}
      end
      
      s = e.scalar_factors_exp
      c = e.coefficient*e.sign
      
      if products[w].key?(s)
        products[w][s] += c
      else
        products[w][s] = c
      end
    end
    
    terms2 = []
    
    products.keys.sort.each do |w|
      # For each vector product, put scalar parts back into a sorted array
      terms3 = []
      
      products[w].keys.sort.each do |k|
        if products[w][k] != 0
          terms3.push(products[w][k].to_m*k)
        end
      end
      
      next if terms3.empty?
      
      terms2.push(terms3.inject(:+)*w)
    end

    if terms2.empty?
      return 0.to_m
    end

    ret = 0.to_m

    terms2.each { |s| ret += s }

    return change_or_nil(ret)
  end
  
  def normalize_product()
    # Collect the factors and divisor factors in an array.
    # Get the sign.
    c  = coefficient
    dc = div_coefficient
    s  = sign
    
    # First examine the coefficients
    if c == 0 and dc > 0
      return 0.to_m
    end

    if c > 0
      # Reduce coefficients by greatest common divisor
      gcd = c.gcd(dc)
      c /= gcd
      dc /= gcd
    end

    # Get normalized factors. Expand all factors that contain vectors in their
    # subexpression sums.
    p = scalar_factors.map { |e| e.normalize }
    d = div_factors.map { |e| e.normalize }

    # Collect equal elements into integer powers
    powers = {}

    p.each do |e|
      # If e is on the form (exp)^n
      if e.exponent.is_a?(Sy::Number)
        ex = e.base
        n = e.exponent.value
      else
        ex = e
        n = 1
      end

      if powers.key?(ex)
        powers[ex] += n
      else
        powers[ex] = n
      end
    end

    d.each do |e|
      # If e is on the form (exp)^n
      if e.exponent.is_a?(Sy::Number)
        ex = e.base
        n = e.exponent.value
      else
        ex = e
        n = 1
      end

      if powers.key?(ex)
        powers[ex] -= n
      else
        powers[ex] = -n
      end
    end

    p2 = []
    d2 = []

    # Put hashed elements back into a sorted array
    powers.keys.sort.each do |k|
      if powers[k] == 1
        p2.push(k)
      elsif powers[k] == -1
        d2.push(k)
      elsif powers[k] > 0
        p2.push(k.power(powers[k].to_m))
      elsif powers[k] < 0
        d2.push(k.power((-powers[k]).to_m))
      end
    end

    if c > 1
      p2.unshift(c.to_m)
    end

    if p2.length > 0
      ret = p2.inject(:*)
    else
      ret = 1.to_m
    end

    if dc > 1
      d2.unshift(dc.to_m)
    end

    if d2.length > 0
      ret = ret / d2.inject(:*)
    end

    ret *= Sy::Variable.normalize_vectors(vector_factors.to_a)

    if (s < 0)
      ret = ret.neg
    end

    return change_or_nil(ret)
  end

  def normalize_power()
    base = self.base.normalize
    expo = exponent.normalize

    if base.is_a?(Sy::Number)
      if expo.is_a?(Sy::Minus) and expo.argument.is_a?(Sy::Number)
        return (1.to_m.div(base.value ** expo.argument.value)).to_m
      end
      if expo.is_a?(Sy::Number)
        return (base.value ** expo.value).to_m
      end
    end

    if base.is_a?(Sy::Power)
      return base.base.power(base.exponent.mul(expo))
    end

    ret = base.power(expo)

    return change_or_nil(ret)
  end

  def normalize_matrix()
    data = (0..nrows - 1).map do |r|
      row(r).map { |e| e.normalize }
    end

    return change_or_nil(Sy::Matrix.new(data))
  end
end
