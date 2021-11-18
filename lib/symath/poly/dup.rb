require 'symath/poly'
require 'symath/poly/galois'
require 'cmath'

module SyMath
  # Class representing a univariate polynomial. The polynomial is represented
  # by an array in of the polynomial coefficients in 'dense form', i.e.
  # zero-coefficients are included in the list. The coefficients are stored
  # in decreasing order starting with the highest degree, and ending with the
  # constant.
  class Poly::DUP < Poly
    def initialize(args)
      if args.is_a?(SyMath::Value)
        init_from_exp(args)
        return
      end

      if args.key?(:arr)
        init_from_array(args[:arr], args[:var])
        return
      end

      raise 'Bad arguments for Poly::DUP constructor'
    end

    def init_from_array(arr, var)
      @arr = arr
      @var = var
    end
    
    def init_from_exp(e)
      # From this point, expect e to be a SyMath::Value
      error = 'Expression ' + e.to_s + ' is not an univariate polynomial'
      max_degree = 0
      terms = {}

      # Assert that this really is an univariate polynomial, and build
      # the dup array representation.
      e.terms.each do |s|
        var = nil
        c = 1
        d = 0
        
        s.factors.each do |f|
          if f.is_a?(SyMath::Fraction)
            raise error
          end

          if f == -1
            c *= -1
          elsif f.is_number?
            c *= f.value
          else
            if !var.nil?
              raise error
            end

            var = f.base
            if !var.is_a?(SyMath::Definition::Variable)
              raise error
            end

            if !f.exponent.is_number?
              raise error
            end
            d = f.exponent.value
          end
        end

        if !var.nil?
          if @var.nil?
            @var = var
          elsif @var != var
            raise error
          end
        end

        if terms.key?(d)
          terms[d] += c
        else
          terms[d] = c
        end

        if d > max_degree
          max_degree = d
        end
      end

      @arr = (0..max_degree).to_a.reverse.map do |d|
        if terms.key?(d)
          terms[d]
        else
          0
        end
      end

      strip!
    end

    def to_galois(p)
      return SyMath::Poly::Galois.new({ :dup => self, :p => p })      
    end
    
    # Convenience method. Returns a a new instance from array, on the
    # same variable as this instance.
    def new_dup(arr)
      return self.class.new({ :arr => arr, :var => @var })
    end

    # Convenience methods for creating some commonly used constant polynomials
    def zero()
      return new_dup([0])
    end
    
    def one()
      return new_dup([1])
    end

    def minus_one()
      return new_dup([-1])
    end
    
    def factor
      # Transform to primitive form
      (cont, g) = primitive

      # Transform left coefficient to positive
      if g.lc < 0
        cont = -cont
        g = -g
      end

      n = g.degree

      # Handle some rivial cases
      if n <= 0
        # 0, cont
        return [cont, []]
      elsif n == 1
        # cont*(a*x + b)
        return [cont, [[g, 1]]]
      end

      # Remove square factors
      g = g.sqf_part

      # Use the zassenhaus algorithm to compute candidate factors
      h = g.zassenhaus

      # Check each of the candidate factors by dividing the original
      # polynomial with each of them until the quotient is 1.
      factors = trial_division(h)

      return [cont, factors]
    end

    def trial_division(factors)
      result = []
      f = self

      factors.each do |factor|
        k = 0

        while true
          (q, r) = f.div(factor)

          if r.zero?
            f = q
            k += 1
          else
            break
          end
        end

        result << [factor, k]
      end

      return sort_factors_multiple(result)
    end
    
    def hensel_step(m, g, h, s, t)
      mm = m**2

      e = (self - g*h) % mm

      (q, r) = (s*e).div(h)

      q = q % mm
      r = r % mm

      u = t*e + q*g

      gg = (g + u) % mm
      hh = (h + r) % mm

      u = s*gg + t*hh
      b = (u - one) % mm

      (c, d) = (s*b).div(hh)

      c = c % mm
      d = d % mm

      u = t*b + c*gg
      ss = (s - d) % mm
      tt = (t - u) % mm

      return [gg, hh, ss, tt]
    end
    
    def hensel_lift(p, f_list, l)
      r = f_list.size
      lcf = lc

      if r == 1
        ff = self * gcdext(lcf, p**l)[1]
        return [ ff % (p**l) ]
      end

      m = p
      k = r / 2
      d = CMath.log(l, 2).ceil

      g = new_dup([lcf]).to_galois(p)

      f_list[0..k - 1].each do |f_i|
        g = g*f_i.to_galois(p)
      end

      h = f_list[k].to_galois(p)

      f_list[k + 1..-1].each do |f_i|
        h = h*f_i.to_galois(p)
      end

      (s, t, x) = g.gcdex(h)

      g = g.to_dup
      h = h.to_dup
      s = s.to_dup
      t = t.to_dup

      d.times do
        (g, h, s, t) = hensel_step(m, g, h, s, t)
        m = m**2
      end

      return g.hensel_lift(p, f_list[0..k - 1], l) +
             h.hensel_lift(p, f_list[k..-1], l)
    end

    # Zassenhaus algorithm for factorizing square free polynomial
    def zassenhaus()
      n = degree

      # Trivial case, a*x + b
      if n == 1
        return [self.clone]
      end

      # Calculate bound of px:
      # n = deg(f)
      # B = sqrt(n + 1)*2^n*max_norm(f)*lc(f)
      # C = (n + 1)^2n*A^(2n - 1)
      # gm = 2log(cc,2)
      # bound = 2*gm*ln(gm)
      fc = self[-1]
      aa = max_norm
      b = lc
      bb = (CMath.sqrt(n + 1).floor*2**n*aa*b).abs.to_i # Integer square root??
      cc = ((n + 1)**(2*n)*aa**(2*n - 1)).to_i
      gamma = (2*CMath.log(cc, 2)).ceil
      bound = (2*gamma*CMath.log(gamma)).to_i

      a = []

      # Choose a prime number p such that f be square free in Z_p
      # if there are many factors in Z_p, choose among a few different p
      # the one with fewer factors
      (3..bound).each do |px|
        # Skip non prime px and px which do not divide lc(f)
        if !Prime.prime?(px) or (b % px) == 0
          next
        end

        # px = convert(px) ???

        # Convert f to a galois field of order px
        ff = self.to_galois(px)

        # Skip if ff has square factors
        if !ff.sqf_p
          next
        end

        # Factorize ff and store all factors together with its order px
        fsqfx = ff.factor_sqf[1]
        a << [px, fsqfx]

        if fsqfx.size < 15 or a.size > 4
          break
        end
      end

      # Select the factor list with the fewest factors.
      (p, fsqf) = a.min { |x| x[1].size }
      l = CMath.log(2*bb + 1, p).ceil

      # Convert the factors back to integer polynomials
      modular = fsqf.map { |ff| ff.to_dup }

      # Hensel lift of modular -> g
      g = hensel_lift(p, modular, l)

      # Start with T as the set of factors in array g.
      tt = (0..g.size - 1).to_a
      factors = []
      s = 1
      pl = p**l  # pl =~ 2*bb + 1

      f = self

      while 2*s <= tt.size
        inc_s = true

        tt.combination(s).each do |ss|
          # Calculate G as the product of the subset S of factors. Lift
          # the constant coefficient of G.
          gg = new_dup([b])
          ss.each { |i| gg = gg*g[i] }
          gg = (gg % pl).primitive[1]
          q = gg[-1]

          # If it does not divide the input polynomial constant (fc), G
          # does not divide the input polynomial.
          if q != 0 and fc % q != 0
            next
          end
          
          tt_new = tt - ss

          # Calculate H as the product of the remaining factors in T.
          hh = new_dup([b])
          tt_new.each { |i| hh = hh*g[i] }
          hh = hh % pl

          # If the norm of the candidate G and the remaining H are bigger than
          # the bound B, we have a valid candidate.
          # - Store it in the factors list
          # - Remove its corresponding selection from T
          # - Continue with H as the remaining polynomial
          if gg.l1_norm*hh.l1_norm <= bb
            tt = tt_new

            gg = gg.primitive[1]
            f = hh.primitive[1]

            factors << gg
            b = f.lc

            inc_s = false
            break
          end
        end

        s += 1 if inc_s
      end

      return factors + [f]
    end

    # Return square free part of f
    def sqf_part()
      # Trivial case
      if zero?
        return self.clone
      end

      if lc < 0
        f = -self
      else
        f = self
      end

      sqf = f/f.gcd(f.diff)[0]

      return sqf.primitive[1]
    end

    # Decompose a polynomial into square free components
    def sqf_list()
      (coeff, f) = primitive

      if f.lc < 0
        f = -f
        coeff = -coeff
      end

      # Trivial case, constant polynomial
      if f.degree <= 0
        return coeff, []
      end

      res = []
      i = 1

      (g, p, q) = f.gcd(f.diff)

      while true
        h = q - p.diff

        if h.zero?
          res << [p, i]
          break
        end

        (g, p, q) = p.gcd(h)

        if g.degree > 0
          res << [g, i]
        end

        i += 1
      end

      return [coeff, res]
    end
    
    # Fast differentiation of polynomial
    def diff
      d = degree
      res = @arr.each_with_index.map { |e, i| e*(d - i) }
      res.pop

      return new_dup(res)
    end

    # Extended gcd for two integers
    def gcdext(x, y)
      if x < 0
        g, a, b = gcdext(-x, y)
        return [g, -a, b]
      end
      if y < 0
        g, a, b = gcdext(x, -y)
        return [g, a, -b]
      end
      r0, r1 = x, y
      a0 = b1 = 1
      a1 = b0 = 0
      until r1.zero?
        q = r0 / r1
        r0, r1 = r1, r0 - q*r1
        a0, a1 = a1, a0 - q*a1
        b0, b1 = b1, b0 - q*b1
      end

      return [r0, a0, b0]
    end

    # FIXME: Implement heuristic gcd?
    def gcd(g)
      # Trivial cases
      if zero? and g.zero?
        return [zero, zero, zero]
      end
      if zero?
        if g.lc >= 0
          return [g, zero, one]
        else
          return [-g, zero, minus_one]
        end
      end

      if g.zero?
        if lc >= 0
          return [f, one, zero]
        else
          return [-f, zero, one]
        end
      end

      (fc, ff) = primitive
      (gc, gg) = g.primitive

      c = fc.gcd(gc)
      
      h = subresultants(g)[-1]
      h = h.primitive[1]

      if (h.lc < 0)
        c = -c
      end

      h = h*c
      
      cff = self/h
      cfg = g/h

      return [h, cff, cfg]
    end

    # Calculate subresultants of polynomials self and g
    def subresultants(g)
      f = self
      
      n = f.degree
      m = g.degree

      if n < m
        f, g = g, f
        n, m = m, n
      end
      
      if f.zero?
        return []
      end

      if g.zero?
        return [f.clone]
      end

      r = [f.clone, g.clone]
      d = n - m

      b = (-1)**(d + 1)

      h = f.pseudo_rem(g)*b

      lc = g.lc
      c = -(lc**d)

      while !h.zero?
        k = h.degree
        r << h

        f, g, m, d = g, h, k, m - k

        b = -lc * c**d

        h = f.pseudo_rem(g)/b

        lc = g.lc

        if d > 1
          q = c**(d - 1)
          c = ((-lc)**d).to_i/q.to_i
        else
          c = -lc
        end
      end
      
      return r          
    end
    
    # Compute content and primitive form
    def primitive()
      if zero?
        return [0, self.clone]
      end

      cont = content

      if cont == 1
        return [cont, self.clone]
      else
        return [cont, self/cont]
      end
    end
    
    def content()
      cont = 0

      @arr.each do |c|
        cont = cont.gcd(c)

        break if cont == 1
      end

      return cont
    end

    def lshift(n)
      if zero?
        return zero
      else
        return new_dup(@arr + [0]*n)
      end
    end

    def rshift(n)
      return new_dup(@arr[0..-n - 1])
    end

    # Slice of polynomial between two degrees, >= a and < b
    def slice(a, b)
      s = @arr.size
      aa = [0, s - a].max
      bb = [0, s - b].max

      if aa <= 0
        return zero
      end
      
      ret = @arr[bb..aa-1]

      if ret == []
        return zero
      else
        return new_dup(ret + [0]*a)
      end
    end
    
    def trunc(p)
      ret = @arr.map do |e|
        ep = e % p
        if ep > p / 2
          ep - p
        else
          ep
        end
      end
                    
      return new_dup(ret).strip!
    end

    def l1_norm()
      return 0 if zero?

      return @arr.map { |e| e.abs }.inject(:+)
    end

    # Sum two polynomials
    def add(g)
      ret = @arr.clone

      if g.degree > degree
        (g.degree - degree).times { ret.unshift(0) }
      end

      (0..g.degree).each do |i|
        ret[ret.size - i - 1] += g[g.degree - i]
      end
      
      return new_dup(ret).strip!
    end

    # Subtract a polynomial from this one
    def sub(g)
      ret = @arr.clone

      if g.degree > degree
        (g.degree - degree).times { ret.unshift(0) }
      end

      (0..g.degree).each do |i|
        ret[ret.size - i - 1] -= g[g.degree - i]
      end
      
      return new_dup(ret).strip!
    end

    # Return the negative of the polynomial
    def neg()
      return new_dup(@arr.map { |t| -t })
    end

    def mul(g)
      if self == g
        return self**2
      end

      if zero? and g.zero?
        return zero
      end

      df = degree
      dg = g.degree

      n = [df, dg].max + 1

      if n < 100
        h = []

        (0..df + dg).each do |i|
          coeff = 0

          a = [0, i - dg].max
          b = [df, i].min
          (a..b).each do |j|
            coeff += self[j]*g[i - j]
          end
          h << coeff
        end

        return new_dup(h).strip!
      else
        # Use Karatsuba's algorithm for large polygons.
        n2 = n/2

        fl = slice(0, n2)
        gl = g.slice(0, n2)

        fh = slice(n2, n).rshift(n2)
        gh = g.slice(n2, n).rshift(n2)

        lo = fl*gl
        hi = fh*gh

        mid = (fl + fh)*(gl + gh)
        mid -= lo + hi

        return lo + mid.lshift(n2) + hi.lshift(2*n2)
      end
    end

    def mul_ground(c)
      ret = @arr.map { |t| t*c }
      return new_dup(ret).strip!
    end
    
    # Multiply a polynomial with a single term.
    def mul_term(c, j)
      ret = @arr.map { |t| t*c }
      j.times { ret.push(0) }

      return new_dup(ret).strip!
    end

    # Compute pseudo remainder of self / g
    def pseudo_rem(g)
      df = self.degree
      dg = g.degree

      r = self
      dr = df

      if g.zero?
        raise 'Division by zero'
      elsif df < dg
        return self.clone # self is remainder
      end

      n = df - dg + 1

      while true
        j = dr - dg
        n -= 1

        rr = r*g.lc
        gg = g.mul_term(r.lc, j)
        r = rr - gg

        _dr = dr
        dr = r.degree

        if dr < dg
          break
        elsif !(dr < _dr)
          raise 'Polynomial division failed'
        end
      end  

      return r*g.lc**n
    end

    def div(g)
      # returns qv and r such that:
      # f = fv*qv + r
      df = degree
      dg = g.degree

      if g.zero?
        raise 'Division by zero'
      elsif df < dg
        return [zero, self.clone]  # no quotient, f is remainder
      end
      
      # Start with f as remainder, no quotient
      q = zero
      r = self
      dr = df

      lc_g = g.lc
      
      while true
        lc_r = r.lc

        if (lc_r % lc_g) != 0
          break
        end

        c = lc_r / lc_g
        j = dr - dg

        q = q + one.mul_term(c, j)
        r = r - g.mul_term(c, j)

        _dr = dr
        dr = r.degree

        if dr < dg
          break
        elsif dr >= _dr
          raise 'Polynomial division failed'
        end
      end

      return [q, r]
    end      
    
    def quo(g)
      return div(g)[0]
    end

    # Quotient by constant for each coefficient
    def quo_ground(c)
      ret = @arr.map { |t| t.to_i/c.to_i }

      return new_dup(ret).strip!
    end

    def max_norm()
      if zero?
        return 0
      else
        return @arr.map { |e| e.abs }.max
      end
    end

    def to_s()
      return @arr.to_s
    end
  end
end
