require 'sy/operation'

module Sy
  # Combine fractions. Examples:
  #   a/c + b/c   -> (a + b)/c
  #   2/3 + 3/4   -> 17/12
  #   a/2 + 2*a/3 -> 7*a/6
  #   2*a/b + 2*c/(3*b) -> (6*a + 2*c)/(3*b) ?
  class CombineFractions < Operation
    def description
      return 'Combine fractions'
    end

    def act(exp)
      return single_pass(exp)
    end

    def single_pass(exp)
      if exp.is_sum_exp?
        return do_sum(exp)
      end
      
      sub = act_subexpressions(exp)
      return sub.nil? ? exp : sub
    end

    def add_summand(sum, fact, divf, c, dc)
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
        fact *= c.to_m
      end

      if s[:fact].nil?
        fact += s[:c].to_m if s[:c] > 1
      else
        fact += s[:c] > 1 ? s[:c].to_m*s[:fact] : s[:fact]
      end

      s[:fact] = fact
      s[:c] = 1
    end

    def do_sum(exp)
      sum = {}

      exp.summands.each do |s|
        add_summand(
          sum,
          s.abs_factors.inject(:*),
          s.div_factors.inject(:*),
          s.coefficient,
          s.div_coefficient,
        )
      end

      exp.subtrahends.each do |s|
        add_summand(
          sum,
          s.abs_factors.inject(:*),
          s.div_factors.inject(:*),
          -s.coefficient,
          s.div_coefficient,
        )
      end

      ret = nil

      sum.keys.each do |divf|
        s = sum[divf]
        if s[:c] > 1
          # TODO: Distribute the product over the sum, rather than applying it
          # over it.
          r = s[:c].to_m*s[:fact]
        else
          r = s[:fact]
        end

        if divf.nil?
          r = r/s[:dc] if s[:dc] > 1
        elsif s[:dc] > 1
          r = r/(s[:dc].to_m*divf)
        else
          r = r/divf
        end

        if ret.nil?
          ret = r
        else
          ret = ret + r
        end

        return ret
      end
    end
  end
end
