require 'sy/operation'
require 'prime'

module Sy
  # Normalizes an expression:
  #   equal arguments of a product are contracted to integer powers
  #   arguments of a product are sorted

  #   equal arguments of a sum (with subtractions) are contracted to integer products
  #   arguments in a sum are sorted
  #   subtractive elements are put after the additive elements

  #   integer sums are calculated
  #   integer products are calculated

  #   fractions of integers are simplified as far as possible

  # The operation is repeated until no 
  class Operation::Normalization < Operation
    def description
      return 'Normalize expression'
    end

    def result_is_normal?
      return true
    end
    
    def act(exp)
      return iterate(exp)
    end

    def single_pass(exp)
      if exp.is_sum_exp?
        return do_sum(exp)
      end

      if exp.is_prod_exp?
        return do_product(exp)
      end

      if exp.is_a?(Sy::Power)
        return do_power(exp)
      end
      
      return act_subexpressions(exp)
    end

    def do_sum(exp)
      # Get normalized summands and subtrahends
      a = exp.summands.map { |e| act(e) }
      s = exp.subtrahends.map { |e| act(e) }

      # Collect equal elements into integer products
      products = {}
      
      a.each do |e|
        # Sum up all constant numbers
        if e.is_a?(Sy::Number)
          if products.key?(1)
            products[1] += e.value
          else
            products[1] = e.value
          end
          next
        end

        ex = e.abs_factors_exp
        c = e.coefficient*e.sign

        if products.key?(ex)
          products[ex] += c
        else
          products[ex] = c
        end
      end

      s.each do |e|
        # Subtract all constant numbers
        if e.is_a?(Sy::Number)
          if products.key?(1)
            products[1] -= e.value
          else
            products[1] = -e.value
          end
          next
        end

        ex = e.abs_factors_exp
        c = e.coefficient*e.sign
        
        if products.key?(ex)
          products[ex] -= c
        else
          products[ex] = -c
        end
      end

      a2 = []
      s2 = []

      if products.key?(1)
        if products[1] > 0
          a2.push(products[1].to_m)
        elsif products[1] < 0
          s2.push((-products[1]).to_m)
        end
        products.delete(1)
      end

      # Put hashed elements back into a sorted array
      products.keys.sort.each do |k|
        next if products[k] == 0
        
        if products[k] > 0
          a2.push(products[k].to_m.mult(k))
        elsif products[k] < 0
          s2.push((-products[k]).to_m.mult(k))
        end
      end

      if a2.length + s2.length == 0
        return 0.to_m
      end

      ret = 0.to_m

      a2.each { |s| ret = ret.add(s) }
      s2.each { |s| ret = ret.sub(s) }

      return exp == ret ? nil : ret
    end

    def do_product(exp)
      # Collect the factors and divisor factors in an array.
      # Get the sign.
      c  = exp.coefficient
      dc = exp.div_coefficient
      s  = exp.sign

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

      # Get normalized factors
      p = exp.scalar_factors.map { |e| act(e) }
      d = exp.div_factors.map { |e| act(e) }

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
          p2.push(k**(powers[k].to_m))
        elsif powers[k] < 0
          d2.push(k**(powers[k].to_m))
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

      # Order vector factors and add them to the result
      vhash = {}
      vinv = {}
      vectors = exp.vector_factors.each_with_index do |v, i|
        # Double occurence of a vector gives zero result
        if vhash.key?(v)
          vhash = nil
          break
        end
        vhash[v] = i
        vinv[i] = v
      end

      if vhash.nil?
        # Double vector occurence
        ret *= 0.to_m
      elsif vhash.length != 0
        # Positive number of vectors. Order them into a wedge product structure and
        # flip the sign for each permutation.
        vlist = vhash.keys.sort
        vlist.each_with_index do |v, i|
          # Skip if the vector is already in place
          next if vhash[v] == i
          
          # Swap vectors
          vinv[vhash[v]] = vinv[i]
          vhash[vinv[i]] = vhash[v]
          vhash[v] = i
          vinv[i] = v
          
          # Flip sign
          s *= -1
        end

        if ret == 1.to_m
          ret = vlist.inject(:^)
        else
          ret *= vlist.inject(:^)
        end
      end

      if (s < 0)
        ret = -ret
      end

      return exp == ret ? nil : ret
    end

    def do_power(exp)
      base = act(exp.base)
      expo = act(exp.exponent)

      if base.is_a?(Sy::Power)
        return base.base.power(base.exponent * expo)
      end

      ret = base ** expo

      return exp == ret ? nil : ret
    end
  end
end
