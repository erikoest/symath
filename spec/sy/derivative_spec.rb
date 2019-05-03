require 'spec_helper'
require 'sy'

module Sy
  d = Sy::Derivative.new('x'.to_m)
  n = Sy::Normalization.new

  describe Sy::Derivative, ', simple polynomials' do
    poly = {
      :x.to_m + 3.to_m*:x.to_m**2 + 4.to_m*:y + 10.to_m  => '1 + 6*x'
    }

    poly.each do |from, to|
      it "derives '#{from.to_s}' into '#{to}'" do
        n.act(d.act(from)).to_s.should == to
      end
    end
  end

  describe Sy::Derivative, ', exponential functions' do
    exp = {
      fn('exp', :x.to_m**2) => '2*x*exp(x^2)',
      fn('ln', 3.to_m*:x + :x.to_m**2)   => '(3 + 2*x)/(3*x + x^2)'
    }

    exp.each do |from, to|
      it "derives '#{from.to_s}' into '#{to}'" do
        n.act(d.act(from)).to_s.should == to
      end
    end
  end
end
