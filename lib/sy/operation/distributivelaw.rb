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
      acted = argument.expand
      if acted == argument
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
    end

    return
  end

  def expand_recurse(exp1, exp2)
    if exp1.is_sum_exp? and exp1.arity > 1
      ret = 0.to_m
      
      exp1.terms.each do |t|
        ret += expand_recurse(t, exp2)
      end
      return ret
    end
      
    if exp2.is_sum_exp? and exp2.arity > 1
      ret = 0.to_m
      
      exp2.terms.each do |t|
        ret += expand_recurse(exp1, t)
      end
      return ret
    end

    return exp1*exp2
  end

  # The factorize() method factorizes a univariate polynomial expression
  # with integer coefficients.
  # FIXME: Rewrite to support factorization with rational coefficients.
  def factorize()
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
  #   2*a/b + 2*c/(3*b) -> (6*a + 2*c)/(3*b) ?
  def combine_fractions()
    if is_sum_exp?
      return combfrac_sum
    end
    
    sub = act_subexpressions('combine_fractions')
    return sub.nil? ? deep_clone : sub
  end

  def combfrac_add_term(sum, fact, divf, c, dc)
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

    terms.each do |s|
      combfrac_add_term(
        sum,
        s.scalar_factors.inject(:mul),
        s.div_factors.inject(:mul),
        s.coefficient,
        s.div_coefficient,
      )
    end

    ret = nil

    sum.keys.each do |divf|
      s = sum[divf]
      if s[:c] > 1
        # TODO: Distribute the product over the sum, rather than applying it
        # over it.
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
