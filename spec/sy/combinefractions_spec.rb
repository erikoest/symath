require 'spec_helper'
require 'sy'

module Sy
  n = Sy::Operation::Normalization.new

  a = :a
  b = :b
  c = :c
  
  describe Sy::Operation::CombineFractions do
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
      it "combines '#{from.to_s}' to '#{to}'" do
        expect(n.act(op(:combfrac, from).evaluate)).to be_equal_to to
      end
    end
  end
end
