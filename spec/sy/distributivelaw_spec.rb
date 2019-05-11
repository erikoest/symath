require 'spec_helper'
require 'sy'

module Sy
  m = Sy::DistributiveLaw.new
  n = Sy::Normalization.new

  describe Sy::DistributiveLaw do
    sums = {
      :x.to_m*(1.to_m + 3.to_m*:y)             => 'x + 3*x*y',
      -:x.to_m*(-:y.to_m - 3.to_m)             => '3*x + x*y',
      -:x.to_m*(:x.to_m - 3.to_m)              => '3*x - x^2',
      (:a.to_m + :b)*:c                        => 'a*c + b*c',
      (fn(:sin, :x) + :y)*(fn(:cos, :x) + :y)  => 'y^2 + y*cos(x) + y*sin(x) + cos(x)*sin(x)',
    }

    sums.each do |from, to|
      it "multiplies '#{from.to_s}' to '#{to}'" do
        n.act(m.act(from)).to_s.should == to
#        m.act(from).to_s.should == to
      end
    end
  end
end
