require 'spec_helper'
require 'sy'

module Sy
  n = Sy::Operation::Normalization.new

  describe Sy::Operation::DistributiveLaw do
    sums = {
      :x.to_m*(1.to_m + 3.to_m*:y)             => '3*x*y + x',
      -:x.to_m*(-:y.to_m - 3.to_m)             => 'x*y + 3*x',
      -:x.to_m*(:x.to_m - 3.to_m)              => '3*x - x**2',
      (:a.to_m + :b)*:c                        => 'a*c + b*c',
      (fn(:sin, :x) + :y)*(fn(:cos, :x) + :y)  => 'cos(x)*sin(x) + cos(x)*y + sin(x)*y + y**2',
    }

    sums.each do |from, to|
      it "multiplies '#{from.to_s}' to '#{to}'" do
        n.act(op(:dist, from).evaluate).to_s.should == to
      end
    end
  end
end
