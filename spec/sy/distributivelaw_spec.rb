require 'spec_helper'
require 'sy'

module Sy
  n = Sy::Operation::Normalization.new
  x = :x
  y = :y
  a = :a
  b = :b
  c = :c
  
  describe Sy::Operation::DistributiveLaw do
    sums = {
      x*(1 + 3*y)                              => 3*(x*y) + x,
      -x*(-y - 3)                              => x*y + 3*x,
      -x*(x - 3)                               => 3*x - x**2,
      (a + b)*c                                => a*c + b*c,
      (fn(:sin, :x) + :y)*(fn(:cos, :x) + :y)  => fn(:cos, x)*fn(:sin, x) + fn(:cos, x)*y + fn(:sin, x)*y + y**2,
    }

    sums.each do |from, to|
      it "multiplies '#{from.to_s}' to '#{to}'" do
        expect(n.act(op(:dist, from).evaluate)).to be_equal_to to
      end
    end
  end
end
