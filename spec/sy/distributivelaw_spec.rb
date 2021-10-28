require 'spec_helper'
require 'sy'

module Sy
  x = :x
  y = :y
  a = :a
  b = :b
  c = :c
  
  describe Sy::Operation::DistributiveLaw, ', expand' do
    sums = {
      x*(1 + 3*y)                           => 3*x*y + x,
      -x*(-y - 3)                           => x*y + 3*x,
      -x*(x - 3)                            => - x**2 + 3*x,
      (a + b)*c                             => b*c + a*c,
      (sin(x) + y)*(cos(x) + y)   =>
        cos(x)*sin(x) + y**2 + y*sin(x) + y*cos(x),
      3*x*(2*x - 1)*(4*x + 3)*(3*x**3 + 1)  =>
        72*x**6 + 18*x**5 - 27*x**4 + 24*x**3 + 6*x**2 - 9*x,
    }

    sums.each do |from, to|
      it "multiplies '#{from.to_s}' to '#{to.to_s}'" do
        expect(from.expand.normalize).to be_equal_to to
      end
    end
  end

  describe Sy::Operation::DistributiveLaw, ', combine fractions' do
    sums = {
      1.to_m              => 1.to_m,
      2.to_m              => 2.to_m,
      a.to_m              => a.to_m,
      a/2                 => a/2,
      a/b                 => a/b,
      2/a                 => 2/a,
      a/c + b/c           => (b + a)/c,
      2.to_m/3 + 3.to_m/4 => 17.to_m/12,
      a/2 + 2*a/3         => 7*a/6,
      2*a/b + 2*c/(3*b)   => (2*c + 6*a)/(3*b),
    }

    sums.each do |from, to|
      it "combines '#{from.to_s}' to '#{to.to_s}'" do
        expect(from.combine_fractions.normalize).to be_equal_to to
      end
    end
  end

  describe Sy::Operation::DistributiveLaw, ', factorization' do
    poly = {
      6*x**2 + 24*x**3 - 27*x**4 + 18*x**5 + 72*x**6 - 9*x =>
        3*x*(2*x - 1)*(3*x**3 + 1)*(4*x + 3),
      :x**4/:b - 1/(:b*4)                                  =>
        (2*x**2 + 1)*(2*x**2 - 1)/(4*b),
    }

    poly.each do |from, to|
      it "factorizes '#{from.to_s}' to '#{to.to_s}'" do
        expect(from.factorize.normalize).to be_equal_to to
      end
    end
  end
end
