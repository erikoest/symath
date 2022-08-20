require 'spec_helper'
require 'symath'

module SyMath
  extend SyMath::Definitions
  
  x = :x.to_m
  y = :y.to_m
  a = :a.to_m
  b = :b.to_m
  
  dx = :dx.to_m(:dform)
  dy = :dy.to_m(:dform)
  dz = :dz.to_m(:dform)

  op12 = :op12.to_m(SyMath::Type.new('operator'))

  m23 = [[1, 2, 3], [4, 5, 6]].to_m
  m32 = [[-1, 3], [-4, -5], [2, 1]].to_m

  # NB: We must always use the compositional operators when creating
  # the input expressions to the normalizer tests since we don't want
  # the expressions to be simplified before we send it to the
  # normalizer.
  norm = {
    'sums' => {
      1.to_m.add(3) =>
        4.to_m,
      3.to_m.div(4).add(5.to_m.add(2).div(34)) =>
        3.to_m/4 + 7.to_m/34,
      x.add(x) =>
        2*x,
      x.sub(x) =>
        0.to_m,
      sin(x).add(sin(x)*2).add(3*y).sub(3*y) =>
        3*sin(x),
      2.to_m.power(3).add(3.to_m.power(2)) =>
        17.to_m,
      3.to_m.power(-4).add(2.to_m.power(-5)) =>
        1.to_m/81 + 1.to_m/32,
      0.to_m.add(0.to_m) =>
        0.to_m,
    },

    'products' => {
      2.to_m.mul(4.to_m**-1) =>
        1.to_m/2,
      x.mul(x) =>
        x**2,
      x.mul(-y) =>
        - x*y,
      x.mul(-x) =>
        - x**2,
      x.mul(x.power(2)) =>
        x**3,
      x.mul(4).mul(x).mul(3).mul(y).mul(y.power(10)) =>
        12*x**2*y**11,
      x.div(y).mul(a).div(b) =>
        a*x/(b*y),
      14175.to_m.div(9000) =>
        63.to_m/40,
      cos(x).mul(y) =>
        y*cos(x),
      i*j*k => -1,
      i*k*j => 1,
    },

    'fractions' => {
      (-1.to_m).div(-1) => 1,
    },

    'powers' => {
      (-2.to_m).power(2)*(-2.to_m).power(2) => 16,
      (-2.to_m).power(3)                    => -8,
      x.power(2).power(3)                   => x**6,
      x.power(2).power(y)                   => x**(2*y),
      i.power(3)                            => -i,
      j.power(6)                            => -1,
      k.power(4)                            => 1,
      i.power(x)                            => i**x,
      # No simplification
      (-4).to_m.power(x)                    => (-4)**x,
    },

    'wedge products' => {
      dx.wedge(dx) =>
         0.to_m,
      dy.wedge(dx).wedge(dz) =>
        - (dx^dy^dz),
      sin(x).mul(dy).wedge(dx) =>
      - ((sin(x)*dx)^dy),
      dx.add(x.power(1).wedge(dx)) =>
        x*dx + dx,
      (dx.wedge(ln(a.mul(x)))).add((x.wedge(1)).div(a.mul(x)).wedge((0.to_m.wedge(x)).add(a.wedge(dx)))).sub(dx) =>
        ln(a*x)*dx,
    },

    'square roots' => {
      sqrt(-7.to_m)   => nan,
      sqrt(a**(2*b))  => a**b,
      sqrt(-a**(2*b)) => nan,
    },

    'exp' => {
      exp(0)     => 1,
      exp(1)     => e,
      exp(oo)    => oo,
      exp(-oo)   => 0,
      exp(:a)    => exp(:a),
      exp(-nan)  => nan,
    },

    'ln' => {
      ln(1)   => 0,
      ln(e)   => 1,
      ln(0)   => -oo,
      ln(oo)  => oo,
      ln(-10) => nan,
    },

    'factorial' => {
      fact(5)  => 120,
      fact(:a) => fact(:a),
    },

    'abs' => {
      abs(-10)  => 10,
      abs(20)   => 20,
      abs(0)    => 0,
      abs(:a)   => abs(:a),
      abs(nan)  => nan,
    },

    'various' => {
      x.mul(op12.mul(x)) => x*(op12*x),
    },

    'matrix' => {
      m23*m32 => m23*m32,
    },
  }

  norm.keys.sort.each do |k|
    describe SyMath::Operation::Normalization, ", normalize '#{k}'" do

      norm[k].each do |from, to|
        it "normalizes '#{from.to_s}' to '#{to.to_s}'" do
          SyMath::setting(:complex_arithmetic, false)
          expect(from.normalize).to be_equal_to to
          SyMath::setting(:complex_arithmetic, true)
        end
      end
    end
  end

  complex = {
    'square roots' => {
      sqrt(-4.to_m)   => 2*i,
      sqrt(-7.to_m)   => sqrt(7)*i,
      sqrt(-a**(2*b)) => a**b*i,
    },

    'exp' => {
      exp(oo)  => nan,
      exp(-oo) => nan,
    },

    'ln' => {
      ln(-1)         => pi*i,
      ln(-e)         => pi*i + 1,
      ln(i)          => pi*i/2,
      ln(i*e)        => pi*i/2 + 1,
      ln(-i)         => -pi*i/2,
      ln(-i*e)       => -pi*i/2 + 1,
    },
  }

  complex.keys.sort.each do |k|
    describe SyMath::Operation::Normalization, ", normalize '#{k}'" do

      complex[k].each do |from, to|
        it "with complex arithmetic, normalizes '#{from.to_s}' to '#{to.to_s}'" do
          expect(from.normalize).to be_equal_to to
        end
      end
    end
  end

  define_fn(:myfunc, [:x])
  
  reductions = {
    abs(SyMath::Minus.new(nan))   => nan,
    abs(-fn(:myfunc, x))      => abs(-fn(:myfunc, x)),
  }

  describe SyMath::Operation::Normalization, ', reductions' do
    reductions.each do |from, to|
      it "reduces '#{from.to_s} to '#{to.to_s}'" do
        SyMath::setting(:complex_arithmetic, false)
        expect(from.reduce).to be_equal_to to
        SyMath::setting(:complex_arithmetic, true)
      end
    end
  end

  complex_reductions = {
    abs(SyMath::Minus.new(oo)) => oo,
  }

  describe SyMath::Operation::Normalization, ', complex reductions' do
    complex_reductions.each do |from, to|
      it "with complex arithmetic, reduces '#{from.to_s} to '#{to.to_s}'" do
        expect(from.reduce).to be_equal_to to
      end
    end
  end
end
