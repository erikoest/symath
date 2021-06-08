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

  # NB: We must always use the compositional operators when creating
  # the input expressions to the normalizer tests since we don't want
  # the expressions to be simplified before we send it to the
  # normalizer.
  describe Sy::Operation::Normalization, ', normalize sum' do
    sums = {
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
    }

    sums.each do |from, to|
      it "normalizes '#{from.to_s}' to '#{to.to_s}'" do
        expect(from.normalize).to be_equal_to to
      end
    end
  end

  describe Sy::Operation::Normalization, ', normalize product' do
    products = {
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
    }

    products.each do |from, to|
      it "normalizes '#{from.to_s}' to '#{to.to_s}'" do
        expect(from.normalize).to be_equal_to to
      end
    end
  end

  describe Sy::Operation::Normalization, ', normalize power' do
    powers = {
      x.power(2).power(3) =>
        x**6,
      x.power(2).power(y) =>
        x**(2*y),
      :i.to_m.power(3) =>
        -1,
      :j.to_m.power(6) =>
        -1,
      :k.to_m.power(4) =>
        1,
      :i.to_m.power(x) =>
        :i**x,
    }

    powers.each do |from, to|
      it "normalizes '#{from.to_s}' to '#{to.to_s}'" do
        expect(from.normalize).to be_equal_to to
      end
    end
  end

  describe Sy::Operation::Normalization, ', normalize wedge products' do
    wedges = {
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
    }

    wedges.each do |from, to|
      it "normalizes '#{from.to_s}' to '#{to.to_s}'" do
        expect(from.normalize).to be_equal_to to
      end
    end
  end

  describe Sy::Operation::Normalization, ', reduce square roots' do
    it 'normalizes sqrt(-4) to 2*i' do
      Sy::setting(:complex_arithmetic, true)
      expect(fn(:sqrt, -4.to_m).normalize).to be_equal_to 2.to_m*:i
      Sy::setting(:complex_arithmetic, false)
    end
    it 'normalizes sqrt(-7) to i*sqrt(7)' do
      Sy::setting(:complex_arithmetic, true)
      expect(fn(:sqrt, -7.to_m).normalize).to be_equal_to fn(:sqrt, 7)*:i
      Sy::setting(:complex_arithmetic, false)
    end
    it 'normalizes sqrt(-7) to NaN' do
      expect(fn(:sqrt, -7.to_m).normalize).to be_equal_to :NaN
    end
    it 'normalizes sqrt(a**(2*b)) to a**b' do
      expect(fn(:sqrt, a**(2*b)).normalize).to be_equal_to a**b
    end
    it 'normalizes sqrt(-a**(2*b)) to a**b*i' do
      Sy::setting(:complex_arithmetic, true)
      expect(fn(:sqrt, -a**(2*b)).normalize).to be_equal_to a**b*:i
      Sy::setting(:complex_arithmetic, false)
    end
    it 'normalizes sqrt(-a**(2*b)) to NaN' do
      expect(fn(:sqrt, -a**(2*b)).normalize).to be_equal_to :NaN
    end
  end

  describe Sy::Operation::Normalization, ', reduce exp' do
    it 'normalizes e**0 to 1' do
      expect(fn(:exp, 0).normalize).to be_equal_to 1
    end
    it 'normalizes e**1 to e' do
      expect(fn(:exp, 1).normalize).to be_equal_to :e
    end
    it 'normalizes e**oo to NaN' do
      Sy::setting(:complex_arithmetic, true)
      expect(fn(:exp, :oo).normalize).to be_equal_to :NaN
      Sy::setting(:complex_arithmetic, false)
    end
    it 'normalizes e**-oo to NaN' do
      Sy::setting(:complex_arithmetic, true)
      expect(fn(:exp, -:oo).normalize).to be_equal_to :NaN
      Sy::setting(:complex_arithmetic, false)
    end
    it 'normalizes e**oo to oo' do
      expect(fn(:exp, :oo).normalize).to be_equal_to :oo
    end
    it 'normalizes e**-oo to 0' do
      expect(fn(:exp, -:oo).normalize).to be_equal_to 0
    end
    it 'does not normalize e**:a' do
      expect(fn(:exp, :a).normalize).to be_equal_to fn(:exp, :a)
    end
  end

  describe Sy::Operation::Normalization, ', reduce ln' do
    it 'normalizes ln(1) to 0' do
      expect(fn(:ln, 1).normalize).to be_equal_to 0
    end
    it 'normalizes ln(e) to 1' do
      expect(fn(:ln, :e).normalize).to be_equal_to 1
    end
    it 'normalizes ln(0) to -oo' do
      expect(fn(:ln, 0).normalize).to be_equal_to -:oo
    end
    it 'normalizes ln(oo) to oo' do
      expect(fn(:ln, :oo).normalize).to be_equal_to :oo
    end
    it 'normalizes ln(-10) to NaN' do
      expect(fn(:ln, -10).normalize).to be_equal_to :NaN
    end

    it 'normalizes ln(-1) to pi*i' do
      Sy::setting(:complex_arithmetic, true)
      expect(fn(:ln, -1).normalize).to be_equal_to :pi.to_m*:i
      Sy::setting(:complex_arithmetic, false)
    end
    it 'normalizes ln(-e) to 1 + pi*i' do
      Sy::setting(:complex_arithmetic, true)
      expect(fn(:ln, -:e).normalize).to be_equal_to :pi.to_m*:i + 1
      Sy::setting(:complex_arithmetic, false)
    end
    it 'normalizes ln(i) to pi*i/2' do
      Sy::setting(:complex_arithmetic, true)
      expect(fn(:ln, :i).normalize).to be_equal_to :pi.to_m*:i/2
      Sy::setting(:complex_arithmetic, false)
    end
    it 'normalizes ln(i*e) to 1 + pi*i/2' do
      Sy::setting(:complex_arithmetic, true)
      expect(fn(:ln, :i.to_m*:e).normalize).to be_equal_to :pi.to_m*:i/2 + 1
      Sy::setting(:complex_arithmetic, false)
    end
    it 'normalizes ln(-i) to -pi*i/2' do
      Sy::setting(:complex_arithmetic, true)
      expect(fn(:ln, -:i).normalize).to be_equal_to -:pi.to_m*:i/2
      Sy::setting(:complex_arithmetic, false)
    end
    it 'normalizes ln(-i*e) to 1 - pi*i/2' do
      Sy::setting(:complex_arithmetic, true)
      expect(fn(:ln, -:i.to_m*:e).normalize).to be_equal_to -:pi.to_m*:i/2 + 1
      Sy::setting(:complex_arithmetic, false)
    end
  end

  describe Sy::Operation::Normalization, ', reduce factorial' do
    it 'normalizes 5! to 120' do
      expect(fn(:fact, 5).normalize).to be_equal_to 120
    end
    it 'does not normalize a!' do
      expect(fn(:fact, :a).normalize).to be_equal_to fn(:fact, :a)
    end
  end

  describe Sy::Operation::Normalization, ', reduce abs' do
    it 'normalizes abs(-10) to 10' do
      expect(fn(:abs, -10).normalize).to be_equal_to 10
    end
    it 'normalizes abs(20) to 20' do
      expect(fn(:abs, 20).normalize).to be_equal_to 20
    end
    it 'normalizes abs(0) to 0' do
      expect(fn(:abs, 0).normalize).to be_equal_to 0
    end
    it 'does not normalize abs(a)' do
      expect(fn(:abs, :a).normalize).to be_equal_to fn(:abs, :a)
    end
  end
end
