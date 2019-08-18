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
      x*(1 + 3*y)                              => 3*(x*y) + x,
      -x*(-y - 3)                              => x*y + 3*x,
      -x*(x - 3)                               => 3*x - x**2,
      (a + b)*c                                => a*c + b*c,
      (fn(:sin, :x) + :y)*(fn(:cos, :x) + :y)  => fn(:cos, x)*fn(:sin, x) + fn(:cos, x)*y + fn(:sin, x)*y + y**2,
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
      a/c + b/c           => (a + b)/c,
      2.to_m/3 + 3.to_m/4 => 17.to_m/12,
      a/2 + 2*a/3         => 7*a/6,
      2*a/b + 2*c/(3*b)   => (6*a + 2*c)/(3*b),
    }

    sums.each do |from, to|
      it "combines '#{from.to_s}' to '#{to.to_s}'" do
        expect(from.combine_fractions.normalize).to be_equal_to to
      end
    end
  end
end
