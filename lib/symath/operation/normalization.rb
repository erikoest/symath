require 'symath/operation'
require 'prime'

module SyMath::Operation::Normalization
  include SyMath::Operation

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
    if self.is_a?(SyMath::Equation)
      return SyMath::Equation.new(args[0].normalize, args[1].normalize)
    end

    return iterate('normalize_single_pass')
  end

  def normalize_single_pass
    if is_sum_exp?
      return normalize_sum
    end

    if is_prod_exp?
      return normalize_product
    end

    if is_a?(SyMath::Wedge)
      return normalize_wedge
    end

    if is_a?(SyMath::Power)
      return normalize_power
    end

    if is_a?(SyMath::Matrix)
      return normalize_matrix
    end

    if is_a?(SyMath::Definition::Operator) and !@exp.nil?
      @exp = @exp.normalize
    end

    return recurse('normalize', 'reduce')
  end

  def normalize_sum()
    # Get normalized terms
    terms = self.terms.map do |e|
      if e.is_a?(SyMath::Minus)
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

    terms2 = []
    products.keys.sort.each do |p|
      p.unshift products[p]

      p = p.inject(1.to_m, :*)
      
      if !SyMath.setting(:fraction_exponent_form)
        p = p.product_on_fraction_form
      end

      terms2.push p
    end

    ret = terms2.reverse.inject(:+)
    
    return ret
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

    if !SyMath.setting(:fraction_exponent_form)
      e = e.product_on_fraction_form
    end

    return e
  end

  def normalize_wedge()
    ret = nil

    self.wedge_factors.each do |w|
      if ret.nil?
        ret = w
      else
        ret = ret^w
      end
    end

    return ret
  end

  def normalize_power()
    b = base.normalize
    e = exponent.normalize

    norm = b.power(e)
    e, sign, changed = norm.reduce_modulo_sign

    if !changed
      return norm
    end

    e *= -1 if sign == -1
    return e
  end

  def normalize_matrix()
    data = (0..nrows - 1).map do |r|
      row(r).map { |e| e.normalize }
    end

    return SyMath::Matrix.new(data)
  end

  def product_on_fraction_form
    ret = []
    fact = 1.to_m
    divf = 1.to_m

    factors.each do |f|
      if f.type.is_scalar?
        if f.is_divisor_factor?
          divf *= f.base**f.exponent.argument
        else
          fact *= f
        end
      else
        if divf != 1
          fact = fact/divf
        end
        if fact != 1
          ret.push fact
        end

        fact = f
        divf = 1.to_m
      end
    end

    if divf != 1
      fact = fact/divf
    end
    if fact != 1
      ret.push fact
    end

    return ret.empty? ? 1.to_m : ret.inject(:*)
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

      while ex.is_a?(SyMath::Product)
        if factor1.is_a?(SyMath::Product)
          f, sign2, changed = factor1.factor2.reduce_modulo_sign
          if changed
            self.factor1.factor2 = f
            done = false
          end
        else
          f, sign2, changed = factor1.reduce_modulo_sign
          if changed
            self.factor1 = f
            done = false
          end
        end

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

        if !ex.is_a?(SyMath::Product)
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

    if self == 1
      return 1.to_m
    end

    self.factors.each do |f|
      if dc.nil?
        if f.is_divisor_factor?
          if f.base.is_number?
            dc = f.base.value**f.exponent.argument.value
            next
          end
        end
      end

      if c.nil?
        if f.is_number?
          c = f.value
          next
        end
      end

      c = 1 if c.nil?
      dc = 1 if dc.nil?

      ret.push f
    end

    c = 1 if c.nil?
    dc = 1 if dc.nil?

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

    return ret.inject(:*)
  end

  # Return result of the two factors multiplied if it simplifies
  # the expression.
  # Returns (new_exp, sign, changed)
  def combine_factors
    if factor1.is_a?(SyMath::Product)
      f1 = factor1.factor2
    else
      f1 = factor1
    end
    f2 = factor2

    reduced, sign, chg = f1.reduce_product_modulo_sign(f2)

    if chg
      return replace_combined_factors(reduced), sign, true
    end

    # Only reduce scalars
    if f1.is_a?(SyMath::Power)
      base1 = f1.base
      exp1 = f1.exponent
    else
      base1 = f1
      exp1 = 1.to_m
    end

    if f2.is_a?(SyMath::Power)
      base2 = f2.base
      exp2 = f2.exponent
    else
      base2 = f2
      exp2 = 1.to_m
    end

    if base1.type.is_scalar? and base2.type.is_scalar?
      if base1 == base2
        return replace_combined_factors(base1**(exp1 + exp2)), 1, true
      end
    end
    
    return self, 1, false
  end

  # Replace factor1 and factor2 with e. Return new combined expression
  def replace_combined_factors(e)
    if factor1.is_a?(SyMath::Product)
      return factor1.factor1*e
    else
      return e
    end
  end

  # Compare first and second element in product. Swap if they can and
  # should be swapped. Return (sign, changed).
  def compare_factors_and_swap()
    f1 = factor1.is_a?(SyMath::Product) ? factor1.factor2 : factor1
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

      # Normalize as power factors so all factors with the same base
      # end up at the same place and can be combined.
      f1 = f1.power(1) if !f1.is_a?(SyMath::Power)
      f2 = f2.power(1) if !f2.is_a?(SyMath::Power)

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
    if self.factor1.is_a?(SyMath::Product)
      self.factor2 = self.factor1.factor2
      self.factor1.factor2 = f2
    else
      self.factor2 = self.factor1
      self.factor1 = f2
    end
  end
end
