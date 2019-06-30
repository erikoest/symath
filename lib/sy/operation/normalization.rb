require 'sy/operation'
require 'prime'

module Sy
  # Normalizes an expression:
  #   equal arguments of a product are contracted to integer powers
  #   arguments of a product are sorted

  #   equal arguments of a sum (with subtractions) are contracted to integer products
  #   arguments in a sum are sorted
  #   subtractive elements are put after the additive elements

  #   vector parts are factorized out of sums

  #   integer sums are calculated
  #   integer products are calculated

  #   fractions of integers are simplified as far as possible

  # The operation is repeated until the expression is no longer changed
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
      
      if exp.is_a?(Sy::Matrix)
        return do_matrix(exp)
      end
      
      return act_subexpressions(exp)
    end

    def do_sum(exp)
      one = 1.to_m
      # Get normalized summands and subtrahends
      add = exp.summands.map { |e| act(e) }
      sub = exp.subtrahends.map { |e| act(e) }

      # Collect equal elements into integer products
      # Vector parts are factorized out

      # Hash: product[vector part][scalar part]
      products = {}

      add.each do |e|
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

      sub.each do |e|
        w = e.vector_factors_exp
        if !products.key?(w)
          products[w] = {}
        end

        s = e.scalar_factors_exp
        c = e.coefficient*e.sign
        
        if products[w].key?(s)
          products[w][s] -= c
        else
          products[w][s] = -c
        end
      end

      a2 = []
      s2 = []

      products.keys.sort.each do |w|
        # For each vector product, put scalar parts back into a sorted array
        a3 = []
        s3 = []
        
        products[w].keys.sort.each do |k|
          next if products[w][k] == 0
        
          if products[w][k] > 0
            a3.push(products[w][k].to_m.mult(k))
          elsif products[w][k] < 0
            s3.push((-products[w][k]).to_m.mult(k))
          end
        end

        next if a3.length + s3.length == 0
        
        if w == one
          a2 += a3
          s2 += s3
        else
          if a3.length == 0
            s2.push(s3.inject(:add).mult(w))
          else
            p = 0.to_m
            a3.each { |s| p = p.add(s) }
            s3.each { |s| p = p.sub(s) }
            a2.push(p.mult(w))
          end
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
          d2.push(k**((-powers[k]).to_m))
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

      if base.is_a?(Sy::Number)
        if expo.is_a?(Sy::Minus) and expo.args[0].is_a?(Sy::Number)
          return (1.to_m/(base.value ** expo.args[0].value)).to_m
        end
        if expo.is_a?(Sy::Number)
          return (base.value ** expo.value).to_m
        end
      end

      if base.is_a?(Sy::Power)
        return base.base.power(base.exponent * expo)
      end

      ret = base ** expo

      return exp == ret ? nil : ret
    end

    def do_matrix(exp)
      data = (0..exp.nrows - 1).map do |r|
        exp.row(r).map { |e| act(e) }
      end

      ret = Sy::Matrix.new(data)
      return exp == ret ? nil : ret
    end
  end
end
