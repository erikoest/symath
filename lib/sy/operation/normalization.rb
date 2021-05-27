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

    # Normalize all arguments,
    norm = act_subexpressions('normalize')
    return change_or_nil(reduce) if norm.nil?
    # and then simplify the expression.
    return norm.reduce
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
    
    # Hash: product[vector part][scalar part]
    products = {}
    
    terms.each do |t|
      c = 1
      p = []

      t.factors.each do |f|
        if f == -1
          c *= -1
          next
        elsif f.is_number?
          c *= f.value
        else
          p.push f
        end
      end

      if products.key?(p)
        products[p] += c
      else
        products[p] = c
      end
    end

    if products.empty?
      return 0.to_m
    end

    terms2 = []
    products.keys.sort.each do |p|
      p.unshift products[p]

      p = p.inject(1.to_m, :*)
      
      if !Sy.setting(:fraction_exponent_form)
        p = p.product_on_fraction_form
      end

      terms2.push p
    end
    
    ret = terms2.reverse.inject(:+)
    
    return change_or_nil(ret)
  end
  
  def normalize_product()
    # Flatten the expression and order it
    e = factors.map do |f|
      f = f.normalize
    end

    e = e.inject(:*)

    if e.is_prod_exp?
      e = e.order_product
    end

    if e.is_prod_exp?
      e = e.reduce_constant_factors
    end

    if !Sy.setting(:fraction_exponent_form)
      e = e.product_on_fraction_form
    end

    return change_or_nil(e)
  end

  def normalize_power()
    norm = base.normalize.power(exponent.normalize)
    e, sign, changed = norm.reduce_modulo_sign
    if changed
      return sign == 1 ? e : -e
    end

    return nil
  end

  def normalize_matrix()
    data = (0..nrows - 1).map do |r|
      row(r).map { |e| e.normalize }
    end

    return change_or_nil(Sy::Matrix.new(data))
  end

  def product_on_fraction_form
    ret = []
    fact = 1.to_m
    divf = 1.to_m
    
    factors.each do |f|
      if f.is_scalar?
        if f.is_divisor_factor?
          divf *= f.base**f.exponent.argument
        else
          fact *= f
        end
      else
        ret.push(fact/divf, f)
        fact = 1.to_m
        divf = 1.to_m
      end
    end

    ret.push fact/divf
    
    return ret.inject(:*)
  end
  
  # Order the factors first by type, then, for commutative and anti-
  # commutative factors, by content using bubble sort:
  #   sign * constant numbers * scalar factors * other factors
  #
  # - Commutative factors are swapped without changing sign.
  # - Swapping anti-commutative factors changes the sign.
  #
  # Constant numers are multiplied to a single coefficient
  # Other factors are reduced if possible:
  #   fundamental quaternions can always be reduced.
  #   exterior algebra basis vectors can be reduced whenever
  #   a double occurrence is found.
  def order_product()
    # Bubble sort factors. Reduce factors and combine thm whenever possible
    done = false
    sign = 1
    head = self

    while !done
      done = true

      ex = head
      prev = nil

      while ex.is_a?(Sy::Product)
        sign2, changed = ex.reduce_factors_modulo_sign
        done = false if changed
        sign *= sign2

        ex, sign2, changed = ex.combine_factors
        done = false if changed
        sign *= sign2

        # The product has been combined.
        if prev.nil?
          # No prev element. Replace head with ex
          head = ex
        else
          # Attach the combined expression onto the previous product
          # exp and continue
          prev.factor1 = ex
        end

        if !ex.is_a?(Sy::Product)
          next
        end
        
        sign2, changed = ex.compare_factors_and_swap
        done = false if changed
        sign *= sign2

        prev = ex
        ex = ex.factor1
      end
    end

    if sign == -1
      return -head
    else
      return head
    end
  end

  # FIXME: Do the reduction in the combine_factors part.
  # Reduce c and c**-1 by gdc. The expression is expected to be flattened
  # and ordered so that the first argument is the constand and the second
  # argument is the divisor constant.
  def reduce_constant_factors()
    c = nil
    dc = nil

    ret = []

    self.factors.each do |f|
      if c.nil?
        c = 1
        if f.is_number?
          c = f.value
          next
        end
      end

      if dc.nil?
        dc = 1
        if f.is_divisor_factor?
          if f.base.is_number?
            dc = f.base.value**f.exponent.argument.value
            next
          end
        end
      end

      ret.push f
    end
    
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

    if dc != 1
      ret.unshift dc.to_m**-1
    end

    if c != 1
      ret.unshift c.to_m
    end

    if ret.empty?
      return 1.to_m
    else
      return ret.inject(:*)
    end
  end

  # Return result of the two factors multiplied if it simplifies
  # the expression.
  # Returns (new_exp, sign, changed)
  def combine_factors
    if factor1.is_a?(Sy::Product)
      f1 = factor1.factor2
    else
      f1 = factor1
    end
    f2 = factor2

    # Natural numbers are calculated
    if f1.is_number? and f2.is_number?
      return replace_combined_factors((f1.value*f2.value).to_m), 1, true
    end

    if f1.is_unit_quaternion? and f2.is_unit_quaternion?
      ret = f1.calc_unit_quaternions(f2)
      if ret.is_a?(Sy::Minus)
        return replace_combined_factors(ret.argument), -1, true
      else
        return replace_combined_factors(ret), 1, true
      end
    end

    if f1.is_a?(Sy::Power)
      base1 = f1.base
      exp1 = f1.exponent
    else
      base1 = f1
      exp1 = 1.to_m
    end

    if f2.is_a?(Sy::Power)
      base2 = f2.base
      exp2 = f2.exponent
    else
      base2 = f2
      exp2 = 1.to_m
    end

    if base1 == base2
      if base1.type.is_subtype?('tensor') and base2.type.is_subtype?('tensor')
        return replace_combined_factors(0.to_m), 1, true
      end
      
      return replace_combined_factors(base1**(exp1 + exp2)), 1, true
    end
    
    return self, 1, false
  end

  # Replace factor1 and factor2 with e. Return new combined expression
  def replace_combined_factors(e)
    if factor1.is_a?(Sy::Product)
      return factor1.factor1*e
    else
      return e
    end
  end

  # Reduce first and second factor. Return sign and changed
  def reduce_factors_modulo_sign()
    if factor1.is_a?(Sy::Product)
      f1, sign1, changed1 = factor1.factor2.reduce_modulo_sign
      if changed1
        self.factor1.factor2 = f1
      end
    else
      f1, sign1, changed1 = factor1.reduce_modulo_sign
      if changed1
        self.factor1 = f1
      end
    end

    f2, sign2, changed2 = factor2.reduce_modulo_sign
    if changed2
      self.factor2 = f2
    end

    return sign1*sign2, (changed1 or changed2)
  end

  # Compare first and second element in product. Swap if they can and
  # should be swapped. Return (sign, changed).
  def compare_factors_and_swap()
    f1 = factor1.is_a?(Sy::Product) ? factor1.factor2 : factor1
    f2 = factor2

    if !f1.type.is_subtype?(:linop) or !f2.type.is_subtype?(:linop)
      # Non-linear operator cannot be swapped
      return 1, false
    end

    if !f1.type.is_scalar? and f2.type.is_scalar?
      # Scalars always go before non-scalar linops
      swap_factors
      return 1, true
    end

    if (f1.type.is_vector? or f1.type.is_dform?) and
      (f2.type.is_vector? or f2.type.is_dform?)
      # Only order simple vectors. Don't order vector
      # expressions
      # FIXME: We could do that. If so, we must get the dimension
      # of the variable and swap sign only if dim(f1)*dim(f2) is
      # odd.
      if f1.is_a?(Sy::Variable) and f2.is_a?(Sy::Variable)
        # Order vector factors
        if f2 < f1
          swap_factors
          return -1, true
        else
          return 1, false
        end
      end
    end

    if f1.type.is_scalar? and f2.type.is_scalar?
      # Corner case. Order the imagninary unit above other scalars in order
      # to make it bubble up to the other quaternions.
      if f2 == :i
        return 1, false
      end

      if f1 == :i
        swap_factors
        return 1, true
      end
        
      # Order scalar factors
      if f2 < f1
        swap_factors
        return 1, true
      else
        return 1, false
      end
    end

    # FIXME: Order other commutative and anti-commutative operators
    return 1, false
  end

  # Swap first and second argument in product
  def swap_factors()
    f2 = self.factor2
    if self.factor1.is_a?(Sy::Product)
      self.factor2 = self.factor1.factor2
      self.factor1.factor2 = f2
    else
      self.factor2 = self.factor1
      self.factor1 = f2
    end
  end
end
