require 'spec_helper'
require 'sy'

module Sy
  d = Sy::Derivative.new
  n = Sy::Normalization.new

  describe Sy::Derivative, ', simple polynomials' do
    poly = {
      op(:diff, :x.to_m + 3.to_m*:x.to_m**2 + 4.to_m*:y + 10.to_m) => 'dx*(1 + 6*x)'
    }

    poly.each do |from, to|
      it "derives '#{from.to_s}' into '#{to}'" do
        n.act(d.act(from)).to_s.should == to
      end
    end
  end

  describe Sy::Derivative, ', exponential functions' do
    exp = {
      op(:diff, fn('exp', :x.to_m**2)) => '2*dx*x*exp(x^2)',
      op(:diff, fn('ln', 3.to_m*:x + :x.to_m**2)) => 'dx*(3 + 2*x)/(3*x + x^2)'
    }

    exp.each do |from, to|
      it "derives '#{from.to_s}' into '#{to}'" do
        n.act(d.act(from)).to_s.should == to
      end
    end
  end
end
