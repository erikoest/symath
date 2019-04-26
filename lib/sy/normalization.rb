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
  class Normalization < Operation
    def act(exp)
      result = self.deep_clone(exp)
      changes = false

      while true
        pass = self.single_pass(result)
        break if pass.nil?
        result = pass
        changes = true
      end

      return if !changes
      return result
    end

    def single_pass(exp)
      if exp.is_a?(Sy::Variable)
        return
      end
      
      if exp.is_sum_exp?
        return self.do_sum(exp)
      end

      if exp.is_prod_exp?
        return self.do_product(exp)
      end

      if exp.is_a?(Sy::Power)
        return self.do_power(exp)
      end
      
      return self.do_operator(exp)
    end

    def do_sum(exp)
      # Collect all the added and subtracted elements in two arrays
      a = exp.summands_to_a
      s = exp.subtrahends_to_a

      # Normalize each added element
      a2 = a.map do |e|
        e2 = self.act(e)
        e2.nil? ? e : e2
      end

      # Normalize each subtracted element
      s2 = s.map do |e|
        e2 = self.act(e)
        e2.nil? ? e : e2
      end

      # Collect equal elements into integer products
      products = {}
      a2.each do |e|
        # Sum up all constant numbers
        if e.is_a?(Sy::Number)
          if products.key?(1)
            products[1] += e.value
          else
            products[1] = e.value
          end
          next
        end

        ex = e.coefficientless
        n = e.coefficient

        if products.key?(ex)
          products[ex] += n
        else
          products[ex] = n
        end
      end

      s2.each do |e|
        # Subtract constant numbers
        if e.is_a?(Sy::Number)
          if products.key?(1)
            products[1] -= e.value
          else
            products[1] = e.value
          end
          next
        end

        ex = e.coefficientless
        n = e.coefficient
        
        if products.key?(ex)
          products[ex] -= n
        else
          products[ex] = -n
        end
      end

      a3 = []
      s3 = []

      if products.key?(1)
        if products[1] > 0
          a3.push(products[1].to_m)
        elsif products[1] < 0
          s3.push(products[1].to_m)
        end
        products.delete(1)
      end

      # Put hashed elements back into a sorted array
      products.keys.sort.each do |k|
        next if products[k] == 0
        
        if products[k] == 1
          a3.push(k)
        elsif products[k] == -1
          s3.push(k)
        elsif products[k] > 0
          a3.push(products[k].to_m * k)
        elsif products[k] < 0
          s3.push(products[k].to_m * -k)
        end
      end

      # If there are changes, return a sum chain of the changed or reordered elements
      return if a == a3 and s == s3

      if a3.length + s3.length == 0
        return 0.to_m
      end

      if a3.length > 0
        ret = a3.shift
      else
        ret = -s3.shift
      end

      while a3.length > 0
        ret += a3.shift
      end
      
      while s3.length > 0
        ret -= s3.shift
      end

      return ret
    end

    def do_product(exp)
      # Collect the factors and divisor factors in an array.
      # Get the sign.
      p  = exp.abs_factors_to_a
      d  = exp.div_factors_to_a
      c  = exp.coefficient
      dc = exp.div_coefficient
      s  = exp.sign

      # First examine the coefficients
      if c == 0 and dc > 0
        return 0.to_m
      end
      
      factors = { 1 => 1 }

      c.prime_division.flat_map do |f, pow|
        if factors.key?(f)
          factors[f] += pow
        else
          factors[f] = pow
        end
      end

      dc.prime_division.flat_map do |f, pow|
        if factors.key?(f)
          factors[f] -= pow
        else
          factors[f] = -pow
        end
      end

      c = factors.map { |f,pow| pow < 0 ? 1 : f**pow }.inject(:*)
      dc = factors.map { |f,pow| pow > 0 ? 1 : f**-pow }.inject(:*)

      # Normalize each element.
      p2 = p.map do |e|
        e2 = self.act(e)
        e2.nil? ? e : e2
      end

      d2 = d.map do |e|
        e2 = self.act(e)
        e2.nil? ? e : e2
      end

      # Collect equal elements into integer powers
      powers = {}

      p2.each do |e|
        # Constant numbers are handled by the coefficient
        next if e.is_a?(Sy::Number)

        ex = e
        n = 1

        # If e is on the form (exp)^n
        if e.is_a?(Sy::Power)
          if e.exponent.is_a?(Sy::Number)
            ex = e.base
            n = e.exponent.value
          end
        end

        if powers.key?(ex)
          powers[ex] += n
        else
          powers[ex] = n
        end
      end

      d2.each do |e|
        # Constant numbers are handled by the coefficient
        next if e.is_a?(Sy::Number)
      
        ex = e
        n = 1

        # If e is on the form (exp)^n
        if e.is_a?(Sy::Power)
          if e.exponent.is_a?(Sy::Number)
            ex = e.base
            n = e.exponent.value
          end
        end

        if powers.key?(ex)
          powers[ex] -= n
        else
          powers[ex] = -n
        end
      end

      p3 = []
      d3 = []

      # Put hashed elements back into a sorted array
      powers.keys.sort.each do |k|
        if powers[k] == 1
          p3.push(k)
        elsif powers[k] == -1
          d3.push(k)
        elsif powers[k] > 0
          p3.push(k**(powers[k].to_m))
        elsif powers[k] < 0
          d3.push(k**(powers[k].to_m))
        end
      end

      # Build expression from p3, d3 and coefficients
      if c != 1
        p3.unshift(c.to_m)
      end

      if dc != 1
        d3.unshift(dc.to_m)
      end

      if p3.length == 0
        ret = 1.to_m
      else
        ret = p3.shift
      end

      while p3.length > 0
        ret *= p3.shift
      end

      if d3.length > 0
        div = d3.shift
        
        while d3.length > 0
          div *= d3.shift
        end
        ret = ret / div
      end
      
      return exp == ret ? nil : ret
    end

    def do_power(exp)
      base = self.act(exp.base)
      expo = self.act(exp.exponent)

      changed_args = (base.nil? and expo.nil?) ? false : true
      
      if base.nil?
        base = exp.base
      end

      if expo.nil?
        expo = exp.exponent
      end

      if base.is_a?(Sy::Power)
        return base.base**(base.exponent * expo)
      end

      if changed_args
        return base ** expo
      end
      
      return
    end
    
    def do_operator(exp)
      # Normalize each argument
      changes = false
      (0...exp.arity).to_a.each do |i|
        arg = self.act(exp.args[i])
        if !arg.nil?
          exp.args[i] = arg
          changes = true
        end
      end

      if changes
        return exp
      else
        return
      end
    end
  end
end
