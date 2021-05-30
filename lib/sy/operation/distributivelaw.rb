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
      acted = argument.expand_single_pass
      if acted.nil?
        return
      else
        return -acted
      end
    end

    if is_a?(Sy::Product)
      if (factor1.is_sum_exp? and factor1.arity > 1) or
         (factor2.is_sum_exp? and factor2.arity > 1)
        return expand_recurse(factor1, factor2)
      end

      return
    end

    changed = false
    if is_sum_exp?
      ret = 0.to_m
      
      terms.each do |t|
        acted = t.expand_single_pass
        if acted.nil?
          ret += t
        else
          ret += acted
          changed = true
        end
      end

      if changed
        return ret
      end
    end
    
    return
  end

  def expand_recurse(exp1, exp2)
    sign = 1.to_m

    if exp1.is_a?(Sy::Minus)
      exp1 = exp1.argument
      sign = -sign
    end

    if exp2.is_a?(Sy::Minus)
      exp2 = exp2.argument
      sign = -sign
    end

    if exp1.is_sum_exp? and exp1.arity > 1
      ret = 0.to_m
      
      exp1.terms.each do |t|
        ret += sign*expand_recurse(t, exp2)
      end
      return ret
    end
      
    if exp2.is_sum_exp? and exp2.arity > 1
      ret = 0.to_m
      
      exp2.terms.each do |t|
        ret += sign*expand_recurse(exp1, t)
      end
      return ret
    end

    if exp1.is_a?(Sy::Product)
      exp1 = expand_recurse(exp1.factor1, exp1.factor2)
    end

    if exp2.is_a?(Sy::Product)
      exp2 = expand_recurse(exp2.factor1, exp2.factor2)
    end
    
    return sign*exp1*exp2
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
      sum = combfrac_sum
      return sum.nil? ? deep_clone : sum
    end
    
    sub = act_subexpressions('combine_fractions')
    return sub.nil? ? deep_clone : sub
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

    ret = nil

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

      if ret.nil?
        ret = r
      else
        ret = ret.add(r)
      end

      return ret
    end
  end
end
