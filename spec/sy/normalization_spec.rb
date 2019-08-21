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
        7.to_m/34 + 3.to_m/4,
      x.add(x) =>
        2*x,
      x.sub(x) =>
        0.to_m,
      fn(:sin, x).add(fn(:sin, x)*2).add(3*y).sub(3*y) =>
        3*fn(:sin, x),
      2.to_m.power(3).add(3.to_m.power(2)) =>
        17.to_m,
      3.to_m.power(-4).add(2.to_m.power(-5)) =>
        1.to_m/32 + 1.to_m/81,
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
        fn(:cos, x)*y,
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
        - (fn(:sin, x)*(dx^dy)),
      x.power(3).wedge(dy).mul(:e.to_m.power(4)).wedge(dz).wedge(dx) =>
        :e**4*x**3*(dx^dy^dz),
      dx.add(x.power(1).wedge(dx)) =>
        (x + 1)*dx,
      (dx.wedge(fn(:ln, a.mul(x)))).add((x.wedge(1)).div(a.mul(x)).wedge((0.to_m.wedge(x)).add(a.wedge(dx)))).sub(dx) =>
        fn(:ln, a*x)*dx,
    }

    wedges.each do |from, to|
      it "normalizes '#{from.to_s}' to '#{to.to_s}'" do
        expect(from.normalize).to be_equal_to to
      end
    end
  end
end
