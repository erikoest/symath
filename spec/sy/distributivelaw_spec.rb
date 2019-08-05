require 'spec_helper'
require 'sy'

module Sy
  n = Sy::Operation::Normalization.new

  describe Sy::Operation::DistributiveLaw do
    sums = {
      :x*(1 + 3*:y)                            => '3*x*y + x',
      -:x*(-:y - 3)                            => 'x*y + 3*x',
      -:x*(:x - 3)                             => '3*x - x**2',
      (:a + :b)*:c                             => 'a*c + b*c',
      (fn(:sin, :x) + :y)*(fn(:cos, :x) + :y)  => 'cos(x)*sin(x) + cos(x)*y + sin(x)*y + y**2',
    }

    sums.each do |from, to|
      it "multiplies '#{from.to_s}' to '#{to}'" do
        n.act(op(:dist, from).evaluate).to_s.should == to
      end
    end
  end
end
