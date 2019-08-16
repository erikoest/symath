require 'sy/poly'

module Sy
  # Class representing a galois field, i.e finite field
  class Poly::Galois < Poly
    attr_reader :p

    # Create gl instance from dup or a gl of the same order.
    def initialize(args)
      if args.key?(:dup)
        init_from_dup(args[:dup], args[:p])
        return
      end

      if args.key?(:gl)
        init_from_gl(args[:gl])
        return
      end

      if args.key?(:arr)
        init_from_array(args[:arr], args[:p], args[:var])
        return
      end
      
      raise 'Bad arguments for Poly::Galois constructor'
    end

    def init_from_dup(dup, p)
      @arr = dup.arr.map { |t| t % p }
      @p = p
      @var = dup.var
    end

    def init_from_gl(gl)
      @arr = gl.arr
      @p = gl.p
      @var = gl.var
    end

    def init_from_array(arr, p, var)
      @arr = arr
      @p = p
      @var = var
    end

    # Convenience method for creating a new gl of the same order
    # and the same variable
    def new_gl(arr)
      return Sy::Poly::Galois.new({ :arr => arr, :p => @p, :var => @var })
    end

    def zero()
      return new_gl([])
    end

    def one()
      return new_gl([1])
    end

    def gl_x()
      new_gl([1, 0])
    end
    
    # Assert that two fields have the same order
    def assert_order(g)
      if @p != g.p
        raise 'Fields do not have the same order'
      end
    end
    
    def to_dup()
      ret = @arr.map do |e|
        if e <= @p / 2
          e
        else
          e - @p
        end
      end
      
      return Sy::Poly::DUP.new({ :arr => ret, :var => @var })
    end

    def invert(a)
      p = @p
      raise "No inverse - #{a} and #{p} not coprime" unless a.gcd(p) == 1

      return p if p == 1

      m0, inv, x0 = p, 1, 0

      while a > 1
        inv -= (a / p) * x0
        a, p = p, a % p
        inv, x0 = x0, inv
      end
      
      inv += m0 if inv < 0

      return inv
    end
    
    def factor_sqf()
      (lc, f) = monic

      if f.degree < 1
        return [lc, zero]
      end

      factors = f.zassenhaus

      return [lc, factors]
    end

    # Return true if polynomial is square free
    def sqf_p()
      (lc, f) = monic

      if f.zero?
        return true
      else
        return f.gcd(f.diff).arr == [1]
      end
    end
    
    def sqf_list()
      n = 1
      sqf = false
      factors = []
      r = @p

      (lc, f) = monic

      if degree < 1
        return [lc, []]
      end

      f = self
      
      while true
        ff = f.diff

        if !ff.zero?
          g = f.gcd(ff)
          h = f / g
        
          i = 1
        
          while h.arr != [1]
            gg = g.gcd(h)
            hh = h / gg

            if hh.degree > 0
              factors << [hh, i*n]
            end

            g = g / gg
            h = gg
            i += 1
          end

          if g.arr == [1]
            sqf = true
          else
            f = g
          end
        end

        if !sqf
          d = f.degree/r

          f = new_gl((0..d).map { |i| f[i*r] })
          n = n*r
        else
          break
        end
      end

      return [lc, factors]
    end                  
                
    def factor()
      (lc, f) = monic

      if f.degree < 1
        return [lc, []]
      end

      factors = []

      f.sqf_list[1].each do |g, n|
        g.factor_sqf[1].each do |h|
          factors << [h, n]
        end
      end

      return [lc, sort_factors_multiple(factors)]
    end
    
    # Compute f**(p**n - 1) / 2 in GF(p)[x]/(g)
    # (Utility function for edf_zassenhaus)
    def pow_pnm1d2(n, g, b)
      f = rem(g)
      h = f
      r = f

      (n - 1).times do
        h = h.frobenius_map(g, b)
        r = (r*h) % g
      end

      return r.pow_mod((@p - 1)/2, g)
    end

    def frobenius_monomial_base()
      n = degree

      if n == 0
        return []
      end

      b = []
      b << one

      if @p < n
        (1..n - 1).each do |i|
          mon = b[i - 1].lshift(@p)
          b << mon % self
        end
      elsif n > 1
        b << new_gl([1, 0]).pow_mod(@p, self)
        (2..n - 1).each do |i|
          b << (b[i - 1]*b[1]) % self
        end
      end

      return b
    end

    def frobenius_map(g, b)
      f = self
      m = g.degree

      if f.degree >= m
        f = rem(g)
      end

      if f.zero?
        return zero
      end
      
      n = f.degree
      sf = new_gl([f[-1]])

      (1..n).each do |i|
        sf += b[i]*f[n - i]
      end

      return sf
    end
    
    # Deterministic distinct degree factorization
    def ddf_zassenhaus()
      x = gl_x
      
      i = 1
      g = x
      factors = []

      f = self
      b = f.frobenius_monomial_base

      while 2*i <= f.degree
        g = g.frobenius_map(f, b)
        h = f.gcd(g - x)

        if h.arr != [1]
          factors << [h, i]

          f = f / h
          g = g % f
          b = f.frobenius_monomial_base
        end

        i += 1
      end

      if f.arr != [1]
        return factors + [[f, f.degree]]
      else
        return factors
      end
    end

    # Generate random polynomial of degree n
    def random_gl(n)
      ret = [1]
      (n).times { ret << rand(@p) }
      return new_gl(ret)
    end
    
    # Equal degree factorization
    def edf_zassenhaus(n)
      factors = [self.clone]

      if degree <= n
        return factors
      end

      nn = degree / n

      if @p != 2
        b = frobenius_monomial_base
      end

      while factors.size < nn
        r = random_gl(2*n - 1)
      
        if @p == 2
          h = r
          
          (2**(n*nn - 1)).times do
            r = r.pow_mod(2, self)
            h += r
          end

          g = gcd(h)
        else
          h = r.pow_pnm1d2(n, self, b)
          g = gcd(h - 1)
        end
        
        if g.arr != [1] and g != self
          factors = g.edf_zassenhaus(n) + (self / g).edf_zassenhaus(n)
        end
      end

      return sort_factors(factors)
    end
    
    def zassenhaus()
      factors = []

      ddf_zassenhaus.each do |f|
        factors += f[0].edf_zassenhaus(f[1])
      end
      
      return sort_factors(factors)
    end

    # Extended gcd for two polynomials
    def gcdex(g)
      assert_order(g)

      if self.zero? and g.zero?
        return [one, zero, zero]
      end

      (p0, r0) = monic
      (p1, r1) = g.monic

      if zero?
        return [zero, new_gl([invert(p1)]), r1]
      end

      if g.zero?
        return [new_gl([invert(p0)]), zero, r0]
      end

      s0, s1 = new_gl([invert(p0)]), zero
      t0, t1 = zero, new_gl([invert(p1)])

      while true
        (qq, rr) = r0.div(r1)

        if rr.zero?
          break
        end

        r0 = r1
        (c, r1) = rr.monic

        inv = invert(c)

        s = s0 - s1*qq
        t = t0 - t1*qq

        s0 = s1
        s1 = s*inv

        t0 = t1
        t1 = t*inv
      end

      return [s1, t1, r1]
    end

    # Divide coefficients by lc
    def monic()
      if zero?
        return self.clone
      end

      c = lc
      return [c, mul_ground(invert(c))]
    end

    def diff()
      d = degree
      res = @arr.each_with_index.map { |e, i| e*(d - i) % @p }
      res.pop

      return new_gl(res).strip!
    end

    def gcd(g)
      assert_order(g)

      f = self
      # Euclidian algorithm for gcd      
      while !g.zero?
        (f, g) = [g, f.rem(g)]
      end

      return f.monic[1]
    end    

    def pow_mod(n, g)
      if n == 0
        return one
      elsif n == 1
        return self % g
      elsif n == 2
        return self**2 % g
      end

      f = self
      h = one

      while true
        if n.odd?
          h = (h*f) % g
          n -= 1
        end

        n >>= 1

        if n == 0
          break
        end

        f = f**2 % g
      end

      return h
    end

    # Return true if f is square free
    def sqf?()
      (x, f) = monic

      if f.zero?
        return true
      else
        return f.gcd(f.diff).arr == [1]
      end
    end

    # Sum two polynomials
    def add(g)
      ret = @arr.clone

      rd = degree
      gd = g.degree
      
      if gd > rd
        (gd - rd).times { ret.unshift(0) }
        rd += gd - rd
      end

      (0..gd).each do |i|
        ret[rd - i] = (ret[rd - i] + g[gd - i]) % @p
      end
      
      return new_gl(ret).strip!
    end

    # Subtract a polynomial from this one
    def sub(g)
      ret = @arr.clone

      rd = degree
      gd = g.degree

      if gd > rd
        (gd - rd).times { ret.unshift(0) }
        rd += gd - rd
      end

      (0..gd).each do |i|
        ret[rd - i] = (ret[rd - i] - g[gd - i]) % @p
      end
      
      return new_gl(ret).strip!
    end

    def add_ground(a)
      return add(new_gl([a]))
    end

    def sub_ground(a)
      return sub(new_gl([a]))
    end
    
    # Return the negative of the polynomial
    def neg()
      return new_dup(@arr.map { |t| -t % @p })
    end
    
    def mul(g)
      df = degree
      dg = g.degree

      dh = df + dg
      if dh > 0
        h = [0]*(dh + 1)
      else
        h = []
      end

      (0..dh).each do |i|
        coeff = 0

        a = [0, i - dg].max
        b = [i, df].min
        (a..b).each do |j|
          coeff += self[j]*g[i - j]
        end

        h[i] = coeff % p
      end

      ret = new_gl(h)
      ret.strip!
      return ret
    end
    
    def mul_ground(a)
      if a == 0
        return zero
      else
        return new_gl(@arr.map { |e| a*e % @p})
      end
    end

    def sqr()
      d = degree
      dh = 2*d
      h = []

      (0..dh).each do |i|
        coeff = 0

        jmin = [0, i - d].max
        jmax = [i, d].min

        n = jmax - jmin + 1
        jmax = jmin + n/2 - 1

        (jmin..jmax).each do |j|
          coeff += self[j]*self[i - j]
        end

        coeff += coeff

        if n.odd?
          elem = self[jmax + 1]
          coeff += elem**2
        end

        h << coeff % @p
      end

      return new_gl(h).strip!
    end

    def quo(g)
      return div(g)[0]
    end

    def rem(f)
      return div(f)[1]
    end

    def div(g)
      assert_order(g)

      df = degree
      dg = g.degree

      if g.zero?
        raise 'Division by zero'
      elsif df < dg
        return [zero, self.clone]
      end

      inv = invert(g[0])

      h = @arr.clone
      dq = df - dg
      dr = dg - 1

      (0..df).each do |i|
        coeff = h[i]

        a = [0, dg - i].max
        b = [df - i, dr].min
        (a..b).each do |j|
          coeff -= h[i + j - dg]*g[dg - j]
        end

        if i <= dq
          coeff *= inv
        end

        h[i] = coeff % @p
      end

      return [new_gl(h[0..dq]), new_gl(h[dq + 1..-1]).strip!]
    end

    def lshift(n)
      if zero?
        return zero
      else
        return new_gl(@arr + [0]*n)
      end
    end
    
    def to_s()
      return @arr.to_s + '/' + @p.to_s
    end
  end
end
