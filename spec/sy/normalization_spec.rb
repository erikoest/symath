require 'spec_helper'
require 'sy'

module Sy
  x = :x.to_m
  y = :y.to_m
  a = :a.to_m
  b = :b.to_m
  
  dx = :x.to_m(:dform)
  dy = :y.to_m(:dform)
  dz = :z.to_m(:dform)

  op1 = :op1.to_m(Sy::Type.new('operator'))

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
      fn(:sin, x).add(fn(:sin, x)*2).add(3*y).sub(3*y) =>
        3*fn(:sin, x),
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
      fn(:cos, x).mul(y) =>
        y*fn(:cos, x),
      :i.to_m*:j.to_m*:k.to_m => -1,
      :i.to_m*:k.to_m*:j.to_m => 1,
      dx.mul(x).mul(dx) => 0,
    },

    'powers' => {
      (-2.to_m).power(2)*(-2.to_m).power(2) => 16,
      (-2.to_m).power(3)                    => -8,
      x.power(2).power(3)                   => x**6,
      x.power(2).power(y)                   => x**(2*y),
      :i.to_m.power(3)                      => -:i,
      :j.to_m.power(6)                      => -1,
      :k.to_m.power(4)                      => 1,
      :i.to_m.power(x)                      => :i**x,
    },

    'wedge products' => {
      dx.wedge(dx) =>
         0.to_m,
      dy.wedge(dx).wedge(dz) =>
        - (dx^dy^dz),
      fn(:sin, x).mul(dy).wedge(dx) =>
        - ((fn(:sin, x)*dx)^dy),
      x.power(3).wedge(dy).mul(:e.to_m.power(4)).wedge(dz).wedge(dx) =>
        (((:e**4*x**3*dx)^dy)^dz),
      dx.add(x.power(1).wedge(dx)) =>
        x*dx + dx,
      (dx.wedge(fn(:ln, a.mul(x)))).add((x.wedge(1)).div(a.mul(x)).wedge((0.to_m.wedge(x)).add(a.wedge(dx)))).sub(dx) =>
        fn(:ln, a*x)*dx,
    },

    'square roots' => {
      fn(:sqrt, -7.to_m)   => :NaN,
      fn(:sqrt, a**(2*b))  => a**b,
      fn(:sqrt, -a**(2*b)) => :NaN,
    },

    'exp' => {
      fn(:exp, 0)     => 1,
      fn(:exp, 1)     => :e,
      fn(:exp, :oo)   => :oo,
      fn(:exp, -:oo)  => 0,
      fn(:exp, :a)    => fn(:exp, :a),
      fn(:exp, -:NaN) => :NaN,
    },

    'ln' => {
      fn(:ln, 1)   => 0,
      fn(:ln, :e)  => 1,
      fn(:ln, 0)   => -:oo,
      fn(:ln, :oo) => :oo,
      fn(:ln, -10) => :NaN,
    },

    'factorial' => {
      fn(:fact, 5)  => 120,
      fn(:fact, :a) => fn(:fact, :a),
    },

    'abs' => {
      fn(:abs, -10)  => 10,
      fn(:abs, 20)   => 20,
      fn(:abs, 0)    => 0,
      fn(:abs, :a)   => fn(:abs, :a),
      fn(:abs, :NaN) => :NaN,
    },

    'various' => {
      x.mul(op1.mul(x)) => x*op1*x,
    },
  }

  norm.keys.sort.each do |k|
    describe Sy::Operation::Normalization, ", normalize '#{k}'" do

      norm[k].each do |from, to|
        it "normalizes '#{from.to_s}' to '#{to.to_s}'" do
          Sy::setting(:complex_arithmetic, false)
          expect(from.normalize).to be_equal_to to
          Sy::setting(:complex_arithmetic, true)
        end
      end
    end
  end

  complex = {
    'square roots' => {
      fn(:sqrt, -4.to_m)   => 2.to_m*:i,
      fn(:sqrt, -7.to_m)   => fn(:sqrt, 7)*:i,
      fn(:sqrt, -a**(2*b)) => a**b*:i,
    },

    'exp' => {
      fn(:exp, :oo)  => :NaN,
      fn(:exp, -:oo) => :NaN,
    },

    'ln' => {
      fn(:ln, -1)          => :pi.to_m*:i,
      fn(:ln, -:e)         => :pi.to_m*:i + 1,
      fn(:ln, :i)          => :pi.to_m*:i/2,
      fn(:ln, :i.to_m*:e)  => :pi.to_m*:i/2 + 1,
      fn(:ln, -:i)         => -:pi.to_m*:i/2,
      fn(:ln, -:i.to_m*:e) => -:pi.to_m*:i/2 + 1,
    },
  }

  complex.keys.sort.each do |k|
    describe Sy::Operation::Normalization, ", normalize '#{k}'" do

      complex[k].each do |from, to|
        it "with complex arithmetic, normalizes '#{from.to_s}' to '#{to.to_s}'" do
          expect(from.normalize).to be_equal_to to
        end
      end
    end
  end

  reductions = {
    fn(:abs, Sy::Minus.new(:NaN.to_m)) => :NaN,
    fn(:abs, -fn(:myfunc, x))           => fn(:abs, -fn(:myfunc, x)),
  }

  describe Sy::Operation::Normalization, ', reductions' do
    reductions.each do |from, to|
      it "reduces '#{from.to_s} to '#{to.to_s}'" do
        Sy::setting(:complex_arithmetic, false)
        expect(from.reduce).to be_equal_to to
        Sy::setting(:complex_arithmetic, true)
      end
    end
  end

  complex_reductions = {
    fn(:abs, Sy::Minus.new(:oo.to_m)) => :oo,
  }

  describe Sy::Operation::Normalization, ', complex reductions' do
    complex_reductions.each do |from, to|
      it "with complex arithmetic, reduces '#{from.to_s} to '#{to.to_s}'" do
        expect(from.reduce).to be_equal_to to
      end
    end
  end
end
