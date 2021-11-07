require 'sy/operation'
require 'sy/poly/dup'

module Sy::Operation::DistributiveLaw
  # The expand() method expands a product using the distributive law over
  # products of sums:
  #   a*(b + c) -> a*b + a*c
  #   a*(b - c) -> a*b - a*c
  # The transformation iterates until no changes occur. Thus, the expression
  #   (a + b)*(c + d) transforms to a*c + a*d + b*c + b*d
  def expand()
    return iterate('expand_single_pass')
  end

  def expand_single_pass
    if is_a?(Sy::Minus)
      return -argument.expand_single_pass
    end

    if is_a?(Sy::Power) or is_a?(Sy::Product)
      ret = 1.to_m

      factors.each do |f|
        if f.is_a?(Sy::Power)
          if f.exponent.is_number?
            f.exponent.value.times { ret = expand_product(ret, f.base) }
          else
            ret = expand_product(ret, f)
          end
        else
          ret = expand_product(ret, f)
        end
      end

      return ret
    end

    if is_sum_exp?
      ret = 0.to_m
      
      terms.each do |t|
        ret += t.expand_single_pass
      end

      return ret
    end
    
    return self
  end

  def expand_product(exp1, exp2)
    sign = 1.to_m

    if exp1.is_a?(Sy::Minus)
      exp1 = exp1.argument
      sign = -sign
    end

    if exp2.is_a?(Sy::Minus)
      exp2 = exp2.argument
      sign = -sign
    end

    ret = 0.to_m
      
    exp1.terms.each do |t1|
      exp2.terms.each do |t2|
        ret += sign*t1*t2
      end
    end

    return ret
  end

  def has_fractional_terms?()
    terms.each do |t|
      t.factors.each do |f|
        if f.is_divisor_factor?
          return true
        end
      end
    end

    return false
  end

  # Collect factors which occur in each term.
  def factorize_simple()
    return self if !self.is_sum_exp?

    sfactors = {}
    vfactors = {}
    coeffs = []
    dcoeffs = []
    vectors = []
    
    terms.each_with_index do |t, i|
      c = 1
      dc = 1
      vf = 1.to_m
      
      t.factors.each do |f|
        # Sign
        if f == -1
          c *= -1
          next
        end

        # Constant
        if f.is_number?
          c *= f.value
          next
        end

        if f.is_divisor_factor?
          # Divisor constant
          if f.base.is_number?
            dc *= f.base.value**f.exponent.argument.value
            next
          end

          # Divisor factor
          ex = f.base

          if !sfactors.key?(ex)
            sfactors[ex] = []
          end

          if sfactors[ex][i].nil?
            sfactors[ex][i] = - f.exponent.argument.value
          else
            sfactors[ex][i] -= f.exponent.argument.value
          end
          next
        end

        # Vector factor
        if f.type.is_subtype?(:tensor)
          vf *= f
          next
        end

        # Scalar factor
        if f.exponent.is_number?
          ex = f.base
          n = f.exponent.value
        else
          ex = f
          n = 1
        end
      
        if !sfactors.key?(ex)
          sfactors[ex] = []
        end
      
        sfactors[ex][i] = n.value        
      end
      
      coeffs.push(c)
      dcoeffs.push(dc)
      vectors.push(vf)
    end

    # If there is only one term, there is nothing to factorize
    if coeffs.length == 1
      return self
    end

    # Try to factorize the scalar part
    spart = 1.to_m
    dpart = 1.to_m
    sfactors.each do |ex, pow|
      # Replace nil with 0 and extend array to full length
      pow.map! { |i| i || 0 }
      (coeffs.length - pow.length).times { pow << 0 }

      if pow.max > 0 and pow.min > 0
        f = pow.min
        pow.map! { |i| i - f }
        spart = spart*ex**f
      end
      
      if pow.max < 0 and pow.min < 0
        f = pow.max
        pow.map! { |i| i - f }
        dpart = dpart*ex**(-f)
      end
    end
    
    # Return self if there were no common factors.
    if spart == 1 and dpart == 1
      return self
    end

    # Extract gcd from coeffs and dcoeffs
    gcd_coeffs = coeffs.inject(:gcd)
    gcd_dcoeffs = dcoeffs.inject(:gcd)
    coeffs.map! { |i| i/gcd_coeffs }
    dcoeffs.map! { |i| i/gcd_dcoeffs }
    
    newsum = 0.to_m

    (0..coeffs.length-1).each do |i|
      t = coeffs[i].to_m
      
      sfactors.each do |ex, pow|
        next if pow[i].nil?
        if pow[i] > 0
          t *= ex**pow[i]
        elsif pow[i] < 0
          t /= ex**(-pow[i])
        end
      end

      t /= dcoeffs[i]
      t *= vectors[i]

      newsum += t
    end

    return gcd_coeffs*spart*newsum/(gcd_dcoeffs*dpart)
  end
  
  # The factorize() method factorizes a univariate polynomial expression
  # with integer coefficients.
  def factorize()
    if (has_fractional_terms?)
      e = combine_fractions
      if e.is_a?(Sy::Fraction)
        return e.dividend.factorize_integer_poly.div(e.divisor)
      end
    else
      return factorize_integer_poly
    end
  end
    
  def factorize_integer_poly()
    dup = Sy::Poly::DUP.new(self)
    factors = dup.factor
      
    ret = factors[1].map do |f|
      if f[1] != 1
        f[0].to_m.power(f[1])
      else
        f[0].to_m
      end
    end

    if factors[0] != 1
      ret.unshift(factors[0].to_m)
    end

    return ret.inject(:mul)
  end


  # The combine_fractions() method combines fractions by first determining
  # their least common denominator, then applying the distributive law.
  # Examples:
  #   a/c + b/c   -> (a + b)/c
  #   2/3 + 3/4   -> 17/12
  #   a/2 + 2*a/3 -> 7*a/6
  #   2*a/b + 2*c/(3*b) -> (6*a + 2*c)/(3*b)
  def combine_fractions()
    if is_sum_exp?
      return combfrac_sum
    end

    return recurse('combine_fractions', nil)
  end

  def combfrac_add_term(sum, t)
    c = 1
    dc = 1
    fact = 1.to_m
    divf = 1.to_m

    t.factors.each do |f|
      if f.is_number?
        c *= f.value
        next
      end

      if f == -1
        fact *= -1
        next
      end

      if f.is_divisor_factor?
        if f.base.is_number?
          dc *= (f.base.value**f.exponent.argument.value)
        else
          divf *= f.base
        end
        next
      end

      fact *= f
    end

    if !sum.key?(divf)
      sum[divf] = {}
      sum[divf][:fact] = fact
      sum[divf][:c] = c
      sum[divf][:dc] = dc
      return
    end

    s = sum[divf]
    lcm = dc.lcm(s[:dc])

    if lcm > dc
      c *= lcm/dc
      dc = lcm
    end

    if lcm > s[:dc]
      s[:c] *= lcm/s[:dc]
      s[:dc] = lcm
    end

    if fact.nil?
      fact = c.to_m
    elsif c > 1
      fact = fact.mul(c.to_m)
    end

    if s[:fact].nil?
      fact = fact.add(s[:c].to_m) if s[:c] > 1
    else
      fact = fact.add(s[:c] > 1 ? s[:c].to_m*s[:fact] : s[:fact])
    end
    
    s[:fact] = fact
    s[:c] = 1
  end

  def combfrac_sum
    sum = {}

    terms.each do |t|
      combfrac_add_term(sum, t)
    end

    ret = 0.to_m

    puts sum

    sum.keys.each do |divf|
      s = sum[divf]
      if s[:c] > 1
        r = s[:c].to_m.mul(s[:fact])
      else
        r = s[:fact]
      end

      if divf.nil?
        r = r.div(s[:dc]) if s[:dc] > 1
      elsif s[:dc] > 1
        r = r.div(s[:dc].to_m*divf)
      else
        r = r.div(divf)
      end

      ret += r
      return ret
    end
  end
end
